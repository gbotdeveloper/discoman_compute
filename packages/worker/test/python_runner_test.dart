import 'dart:io';

import 'package:discoman_worker/src/python/python_runner.dart';
import 'package:test/test.dart';

bool _runs(String python) {
  try {
    return Process.runSync(python, ['--version']).exitCode == 0;
  } on ProcessException {
    return false;
  }
}

void main() {
  final hasPython = _runs('python3');

  test(
    'names the module a script could not import',
    () async {
      final result = await PythonRunner('python3').run(
        source:
            'import discoman_missing_module.sub\n\n'
            'def main():\n    return {}\n',
        entrypointName: 'main',
        inputs: const {},
        timeoutSeconds: 30,
        cancelRequested: () => false,
      );

      expect(result.success, isFalse);
      expect(result.missingModule, 'discoman_missing_module');
    },
    skip: hasPython ? false : 'python3 is not installed',
  );

  test(
    'a caught missing module does not hide the error the run ended on',
    () async {
      final result = await PythonRunner('python3').run(
        source:
            'import traceback\n'
            'try:\n    import discoman_missing_module\n'
            'except ImportError:\n    traceback.print_exc()\n\n'
            'def main():\n    raise ValueError("bad input")\n',
        entrypointName: 'main',
        inputs: const {},
        timeoutSeconds: 30,
        cancelRequested: () => false,
      );

      expect(result.success, isFalse);
      expect(result.missingModule, isNull);
      expect(result.errorMessage, 'bad input');
    },
    skip: hasPython ? false : 'python3 is not installed',
  );

  test(
    'imports modules from the folder the script was linked from',
    () async {
      final folder = Directory.systemTemp.createTempSync('discoman_linked');
      addTearDown(() => folder.deleteSync(recursive: true));
      File('${folder.path}/helper.py').writeAsStringSync('VALUE = 6\n');

      final result = await PythonRunner('python3').run(
        source:
            'import helper\n\ndef main():\n    return {"value": helper.VALUE}\n',
        entrypointName: 'main',
        inputs: const {},
        timeoutSeconds: 30,
        cancelRequested: () => false,
        extraPythonPath: folder.path,
      );

      expect(result.success, isTrue);
      expect(result.outputs?['value'], 6);
    },
    skip: hasPython ? false : 'python3 is not installed',
  );

  group('measuring', () {
    final python = Platform.isWindows ? 'python' : 'python3';
    final canMeasure = _runs(python);

    Future<PythonRunResult> run(String source) =>
        PythonRunner(python, measureUsage: true).run(
          source: source,
          entrypointName: 'main',
          inputs: const {'n': 3},
          timeoutSeconds: 60,
          cancelRequested: () => false,
        );

    test(
      'records the memory and processor time a run used',
      () async {
        final result = await run(
          'import time\n\n'
          'def main(n: int):\n'
          '    block = bytearray(80 * 1024 * 1024)\n'
          '    end = time.process_time() + 0.3\n'
          '    while time.process_time() < end:\n'
          '        pass\n'
          '    return {"value": n * 2, "size": len(block)}\n',
        );

        expect(result.success, isTrue);
        expect(result.outputs?['value'], 6);
        final usage = result.usage!;
        expect(usage.peakRamBytes, greaterThan(80 * 1024 * 1024));
        expect(usage.cpuSeconds, greaterThan(0.25));
        expect(usage.wallMs, result.durationMs);
      },
      skip: canMeasure ? false : '$python is not installed',
    );

    test(
      'records a failed run and keeps its error',
      () async {
        final result = await run(
          'def main(n: int):\n    raise ValueError("bad input")\n',
        );

        expect(result.success, isFalse);
        expect(result.errorMessage, 'bad input');
        expect(result.usage, isNotNull);
      },
      skip: canMeasure ? false : '$python is not installed',
    );

    test(
      'still finds its files after the script changes directory',
      () async {
        final result = await run(
          'import os, tempfile\n'
          'os.chdir(tempfile.gettempdir())\n\n'
          'def main(n: int):\n    return {"value": n}\n',
        );

        expect(result.success, isTrue);
        expect(result.outputs?['value'], 3);
        expect(result.usage, isNotNull);
      },
      skip: canMeasure ? false : '$python is not installed',
    );
  });

  group('the run process', () {
    final python = Platform.isWindows ? 'python' : 'python3';
    final canRun = _runs(python);

    Future<PythonRunResult> run(
      String source, {
      Map<String, dynamic> inputs = const {},
      bool Function()? cancelRequested,
    }) => PythonRunner(python).run(
      source: source,
      entrypointName: 'main',
      inputs: inputs,
      timeoutSeconds: 60,
      cancelRequested: cancelRequested ?? () => false,
    );

    test(
      'passes names with Turkish letters through unchanged',
      () async {
        final result = await run(
          'def main(name: str):\n'
          '    print("görüntü yazıldı")\n'
          '    return {"name": name}\n',
          inputs: const {'name': 'Ekran görüntüsü 2026.png'},
        );

        expect(result.success, isTrue, reason: result.logs.join('\n'));
        expect(result.outputs?['name'], 'Ekran görüntüsü 2026.png');
        expect(result.logs, contains('görüntü yazıldı'));
      },
      skip: canRun ? false : '$python is not installed',
    );

    test(
      'keeps what programs the script starts print',
      () async {
        final result = await run(
          'import subprocess, sys\n\n'
          'def main():\n'
          '    subprocess.run([sys.executable, "-c", "print(42)"])\n'
          '    return {}\n',
        );

        expect(result.success, isTrue, reason: result.logs.join('\n'));
        expect(result.logs, contains('[stdout] 42'));
      },
      skip: canRun ? false : '$python is not installed',
    );

    test(
      'a cancel stops what the script started too',
      () async {
        final dir = Directory.systemTemp.createTempSync('runner_tree_test');
        addTearDown(() => dir.deleteSync(recursive: true));
        final pidFile = File('${dir.path}${Platform.pathSeparator}child.pid');

        final result = await run(
          'import subprocess, sys, time\n\n'
          'def main(pid_file: str):\n'
          '    child = subprocess.Popen(\n'
          '        [sys.executable, "-c", "import time; time.sleep(120)"]\n'
          '    )\n'
          '    open(pid_file, "w").write(str(child.pid))\n'
          '    time.sleep(120)\n'
          '    return {}\n',
          inputs: {'pid_file': pidFile.path},
          cancelRequested: () =>
              pidFile.existsSync() && pidFile.readAsStringSync().isNotEmpty,
        );

        expect(result.canceled, isTrue);
        final child = int.parse(pidFile.readAsStringSync());
        await Future<void>.delayed(
          PythonRunner.killGrace + const Duration(seconds: 1),
        );
        expect(_alive(child), isFalse);
      },
      skip: canRun ? false : '$python is not installed',
    );
  });
}

bool _alive(int pid) {
  if (Platform.isWindows) {
    final out = Process.runSync('tasklist', ['/FI', 'PID eq $pid', '/NH']);
    return '${out.stdout}'.contains('$pid');
  }
  return Process.runSync('kill', ['-0', '$pid']).exitCode == 0;
}
