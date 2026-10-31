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
}
