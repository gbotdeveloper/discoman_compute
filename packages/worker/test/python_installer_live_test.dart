import 'dart:io';

import 'package:discoman_worker/src/python/python_installer.dart';
import 'package:test/test.dart';

/// Downloads and installs the real Python for this machine. Runs only when
/// DISCOMAN_LIVE_PYTHON_INSTALL is set, which CI does on macOS and Windows.
void main() {
  final live = Platform.environment['DISCOMAN_LIVE_PYTHON_INSTALL'] == '1';

  test(
    'installs a Python that imports the base packages',
    () async {
      final home = Directory.systemTemp.createTempSync('discoman_live');
      addTearDown(() => home.deleteSync(recursive: true));

      final path = await PythonInstaller(home: home).install(
        onProgress: (progress) {
          if (progress.line != null) print(progress.line);
        },
      );

      final imports = Process.runSync(path, [
        '-c',
        'import numpy, pandas, matplotlib, PIL; print("ok")',
      ]);
      expect(imports.stderr, '');
      expect('${imports.stdout}'.trim(), 'ok');
    },
    skip: live ? false : 'set DISCOMAN_LIVE_PYTHON_INSTALL=1 to run',
    timeout: const Timeout(Duration(minutes: 15)),
  );
}
