import 'dart:io';

import 'package:discoman_client/discoman_client.dart';
import 'package:discoman_compute/app_controller.dart';
import 'package:discoman_compute/app_theme.dart';
import 'package:discoman_compute/widgets/external_code_dialog.dart';
import 'package:discoman_worker/discoman_compute.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<AppController> pump(
    WidgetTester tester, {
    List<ExternalCodeSource> initial = const [],
  }) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final temp = Directory.systemTemp.createTempSync('external_code_test');
    addTearDown(() => temp.deleteSync(recursive: true));
    final controller = AppController(
      settingsStore: WorkerSettingsStore(File('${temp.path}/settings.json')),
    );
    addTearDown(controller.dispose);
    if (initial.isNotEmpty) controller.setExternalCode('p1', initial);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: Scaffold(
          body: ExternalCodeDialog(
            controller: controller,
            projectId: 'p1',
            projectName: 'Mine',
            pickFolder: () async => '/src/signal',
            read: (source) async => ExternalCodeVersion(
              projectId: 'p1',
              name: source.name,
              manualVersion: source.version,
              gitPath: source.gitPath,
              commit: source.gitPath == null
                  ? null
                  : 'a1b2c3d4e5f60718293a4b5c6d7e8f9012345678',
              branch: source.gitPath == null ? null : 'main',
              commitMessage: source.gitPath == null ? null : 'Fix the filter',
            ),
          ),
        ),
      ),
    );
    return controller;
  }

  testWidgets('records a typed version and a git folder', (tester) async {
    final controller = await pump(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'MATLAB');
    await tester.enterText(find.widgetWithText(TextField, 'Version'), 'R2024b');
    await tester.pump();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Library');
    await tester.tap(find.text('Git folder'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose folder…'));
    await tester.pumpAndSettle();
    await tester.pump();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    final stored = controller.settingsStore.load().externalCode['p1']!;
    expect(stored.map((c) => c.name), ['MATLAB', 'Library']);
    expect(stored.first.version, 'R2024b');
    expect(stored.last.gitPath, '/src/signal');
    expect(find.text('R2024b'), findsOneWidget);
    expect(
      find.text('a1b2c3d · main · Fix the filter\n/src/signal'),
      findsOneWidget,
    );
  });

  testWidgets('removes an entry', (tester) async {
    final controller = await pump(
      tester,
      initial: const [ExternalCodeSource(name: 'MATLAB', version: 'R2024b')],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(find.text('Nothing added yet.'), findsOneWidget);
    expect(controller.settingsStore.load().externalCode['p1'], isNull);
  });
}
