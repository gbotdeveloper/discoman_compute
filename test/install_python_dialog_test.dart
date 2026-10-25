import 'dart:io';

import 'package:discoman_compute/app_controller.dart';
import 'package:discoman_compute/app_theme.dart';
import 'package:discoman_compute/widgets/install_python_dialog.dart';
import 'package:discoman_worker/discoman_compute.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeInstaller extends PythonInstaller {
  _FakeInstaller({this.fail = false});

  final bool fail;
  List<String>? packages;

  @override
  Future<String> install({
    List<String> packages = const [],
    required void Function(PythonInstallProgress progress) onProgress,
  }) async {
    this.packages = packages;
    onProgress(
      const PythonInstallProgress(PythonInstallStep.download, fraction: 0.5),
    );
    if (fail) {
      throw const PythonInstallException('Could not download Python.');
    }
    onProgress(
      const PythonInstallProgress(
        PythonInstallStep.packages,
        line: 'Successfully installed numpy',
      ),
    );
    return '/home/me/.discoman/python/bin/python3';
  }
}

void main() {
  Future<AppController> pump(
    WidgetTester tester,
    PythonInstaller installer,
  ) async {
    final temp = Directory.systemTemp.createTempSync('install_python_test');
    addTearDown(() => temp.deleteSync(recursive: true));
    final controller =
        AppController(
            settingsStore: WorkerSettingsStore(
              File('${temp.path}/settings.json'),
            ),
          )
          ..missingPackagesByProject = {
            'p1': ['opencv-python'],
          };
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: Scaffold(
          body: InstallPythonDialog(
            controller: controller,
            installer: installer,
          ),
        ),
      ),
    );
    return controller;
  }

  testWidgets('installs Python with what the scripts need and uses it', (
    tester,
  ) async {
    final installer = _FakeInstaller();
    final controller = await pump(tester, installer);

    await tester.tap(find.text('Install'));
    await tester.pumpAndSettle();

    expect(installer.packages, ['opencv-python']);
    expect(find.text('Successfully installed numpy'), findsOneWidget);
    expect(
      find.text('Done. This computer now runs your scripts with it.'),
      findsOneWidget,
    );
    expect(
      controller.settingsStore.load().pythonPath,
      '/home/me/.discoman/python/bin/python3',
    );
  });

  testWidgets('says what went wrong and offers to try again', (tester) async {
    await pump(tester, _FakeInstaller(fail: true));

    await tester.tap(find.text('Install'));
    await tester.pumpAndSettle();

    expect(find.text('Could not download Python.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}
