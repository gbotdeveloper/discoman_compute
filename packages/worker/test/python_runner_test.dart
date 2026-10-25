import 'dart:io';

import 'package:discoman_worker/src/python/python_runner.dart';
import 'package:test/test.dart';

void main() {
  final hasPython = Process.runSync('python3', ['--version']).exitCode == 0;

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
}
