import 'dart:io';

import 'package:discoman_compute/app_controller.dart';
import 'package:discoman_compute/app_theme.dart';
import 'package:discoman_compute/widgets/worker_panel.dart';
import 'package:discoman_worker/discoman_compute.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppController controller;

  setUp(() {
    final temp = Directory.systemTemp.createTempSync('worker_panel_test');
    addTearDown(() => temp.deleteSync(recursive: true));
    controller = AppController(
      settingsStore: WorkerSettingsStore(File('${temp.path}/settings.json')),
      machineIdStore: MachineIdStore(File('${temp.path}/machine_id')),
    );
    addTearDown(controller.dispose);
  });

  Future<void> pump(WidgetTester tester) {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    return tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: Scaffold(
          body: SingleChildScrollView(
            child: WorkerPanel(controller: controller),
          ),
        ),
      ),
    );
  }

  testWidgets('clearing the history asks first', (tester) async {
    controller.log.add('Ran a project');
    await pump(tester);

    await tester.tap(find.text('Clear history'));
    await tester.pumpAndSettle();

    expect(find.text("Clear this computer's history?"), findsOneWidget);
    expect(find.textContaining('queued or running stay'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text("Clear this computer's history?"), findsNothing);
    expect(find.text('Ran a project'), findsOneWidget);
  });
}
