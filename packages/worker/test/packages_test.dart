import 'dart:io';

import 'package:discoman_worker/src/python/packages.dart';
import 'package:test/test.dart';

void main() {
  test('names the pip packages a script needs and Python lacks', () async {
    final packages = await missingPackagesFor(
      '/usr/bin/python3',
      'import json\nimport cv2\nfrom PIL import Image\n',
      runProcess: (executable, arguments) async =>
          ProcessResult(0, 0, '["cv2", "PIL"]', ''),
    );

    expect(packages, ['opencv-python', 'Pillow']);
  });

  test('finds nothing missing when the lookup fails', () async {
    final missing = await findMissingModules(
      '/nowhere/python3',
      ['pandas'],
      runProcess: (executable, arguments) async =>
          throw const ProcessException('/nowhere/python3', []),
    );

    expect(missing, isEmpty);
  });

  final hasPython = Process.runSync('python3', ['--version']).exitCode == 0;

  test(
    'reports a failed install and what pip printed',
    () async {
      final lines = <String>[];
      final result = await installPackages(
        'python3',
        ['discoman-no-such-package-0d3f'],
        onOutput: lines.add,
        startProcess: (executable, arguments) => Process.start(executable, [
          '-c',
          'import sys; print("ERROR: no matching distribution", '
              'file=sys.stderr); sys.exit(1)',
        ]),
      );

      expect(result.success, isFalse);
      expect(lines, contains('ERROR: no matching distribution'));
    },
    skip: hasPython ? false : 'python3 is not installed',
  );

  test(
    'notices a Python that refuses pip installs',
    () async {
      final result = await installPackages(
        'python3',
        ['numpy'],
        onOutput: (_) {},
        startProcess: (executable, arguments) => Process.start(executable, [
          '-c',
          'import sys; print("error: externally-managed-environment", '
              'file=sys.stderr); sys.exit(1)',
        ]),
      );

      expect(result.externallyManaged, isTrue);
    },
    skip: hasPython ? false : 'python3 is not installed',
  );
}
