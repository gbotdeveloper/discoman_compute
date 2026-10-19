import 'dart:io';

import 'package:discoman_worker/src/machine_check.dart';
import 'package:discoman_worker/src/scripts/script_store.dart';
import 'package:discoman_worker/src/settings/worker_settings.dart';
import 'package:test/test.dart';

void main() {
  late Directory temp;
  late ScriptStore scripts;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('discoman_check');
    scripts = ScriptStore(Directory('${temp.path}/scripts'))
      ..store(
        'alpha',
        'import pandas\nimport json\n\ndef run():\n    return 1\n',
      )
      ..store('beta', 'def run():\n    return 2\n');
  });

  tearDown(() => temp.deleteSync(recursive: true));

  Future<ProcessResult> python(
    String executable,
    List<String> arguments,
  ) async {
    if (arguments.first == '--version') {
      return ProcessResult(0, 0, 'Python 3.11.9', '');
    }
    // Only pandas is missing on this pretend machine.
    final missing = arguments.contains('pandas') ? '["pandas"]' : '[]';
    return ProcessResult(0, 0, missing, '');
  }

  test(
    'reports each script, its fingerprint and its missing modules',
    () async {
      final result = await runMachineCheck(
        pythonPath: '/usr/bin/python3',
        scriptStore: scripts,
        settings: const WorkerSettings(pausedProjectIds: {'beta'}),
        expectedScripts: {
          'alpha': fingerprintScript(
            scripts.fileFor('alpha').readAsStringSync(),
          ),
          'beta': 'sha256:older',
          'gamma': 'sha256:elsewhere',
        },
        runProcess: python,
      );

      expect(result.pythonUsable, isTrue);
      expect(result.pythonVersion, 'Python 3.11.9');

      final byId = {for (final s in result.scripts) s.projectId: s};
      expect(byId.keys, ['alpha', 'beta', 'gamma']);

      expect(byId['alpha']!.present, isTrue);
      expect(byId['alpha']!.fingerprint, byId['alpha']!.expectedFingerprint);
      expect(byId['alpha']!.missingModules, ['pandas']);

      expect(byId['beta']!.paused, isTrue);
      expect(byId['beta']!.fingerprint, isNot('sha256:older'));

      expect(byId['gamma']!.present, isFalse);
      expect(byId['gamma']!.fingerprint, isNull);
    },
  );

  test(
    'a broken interpreter is reported and modules are not looked up',
    () async {
      var lookups = 0;
      final result = await runMachineCheck(
        pythonPath: '/nowhere/python3',
        scriptStore: scripts,
        settings: const WorkerSettings(),
        expectedScripts: const {},
        runProcess: (executable, arguments) async {
          if (arguments.first != '--version') lookups++;
          throw const ProcessException('/nowhere/python3', ['--version']);
        },
      );

      expect(result.pythonUsable, isFalse);
      expect(result.pythonProblem, contains('/nowhere/python3'));
      expect(lookups, 0);
      expect(
        result.scripts.map((s) => s.missingModules),
        everyElement(isEmpty),
      );
    },
  );
}
