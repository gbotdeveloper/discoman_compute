import 'dart:io';

import 'package:discoman_client/discoman_client.dart';
import 'package:discoman_compute/app_controller.dart';
import 'package:discoman_compute/app_theme.dart';
import 'package:discoman_compute/widgets/project_page.dart';
import 'package:discoman_compute/widgets/projects_panel.dart';
import 'package:discoman_compute/widgets/script_guide_dialog.dart';
import 'package:discoman_worker/discoman_compute.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _gb = 1024 * 1024 * 1024;

void main() {
  final bmi = CreatorProjectSummary(
    projectId: 'p1',
    name: 'BMI Index',
    scriptLocation: ScriptLocation.creatorMachine,
    hasContract: true,
  );

  Future<AppController> pump(
    WidgetTester tester, {
    WorkerSettings settings = const WorkerSettings(),
    Map<String, List<RunUsage>> usage = const {},
    void Function(AppController controller)? configure,
  }) async {
    tester.view.physicalSize = const Size(1200, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final temp = Directory.systemTemp.createTempSync('project_page_test');
    addTearDown(() => temp.deleteSync(recursive: true));
    final store = WorkerSettingsStore(File('${temp.path}/settings.json'))
      ..save(settings);

    final controller = AppController(settingsStore: store)
      ..projects = [bmi]
      ..linkedProjectIds = {'p1'}
      ..machine = const MachineResources(cores: 9, ramBytes: 16 * _gb)
      ..usageByProject = usage;
    configure?.call(controller);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: ProjectPage(
          controller: controller,
          projectId: 'p1',
          onLink: (_) {},
          onInstall: (_) {},
          onEditExternalCode: (_) {},
        ),
      ),
    );
    return controller;
  }

  testWidgets('a project is not limited until asked', (tester) async {
    await pump(tester, settings: const WorkerSettings(parallelRuns: 3));

    expect(find.text('BMI Index'), findsOneWidget);
    expect(find.textContaining('No limit: it can use all'), findsOneWidget);
    expect(
      find.textContaining('Once it has run here, Discoman suggests'),
      findsOneWidget,
    );
  });

  testWidgets('limiting a project saves it, starting from the suggestion', (
    tester,
  ) async {
    final controller = await pump(
      tester,
      settings: const WorkerSettings(parallelRuns: 3),
      usage: {
        'p1': [
          const RunUsage(peakRamBytes: 6 * _gb, cpuSeconds: 10, wallMs: 10000),
        ],
      },
    );
    expect(find.textContaining('Suggested: 2 at once'), findsOneWidget);

    await tester.tap(find.byType(Switch).last);
    await tester.pumpAndSettle();

    expect(controller.settingsStore.load().projectRunLimits, {'p1': 2});
    expect(find.textContaining('At most 2 of this computer'), findsOneWidget);

    await tester.tap(find.text('+'));
    await tester.pumpAndSettle();

    expect(controller.settingsStore.load().projectRunLimits, {'p1': 3});
    expect(find.textContaining('More than suggested'), findsOneWidget);
  });

  testWidgets('lifting the limit forgets it', (tester) async {
    final controller = await pump(
      tester,
      settings: const WorkerSettings(projectRunLimits: {'p1': 1}),
    );

    await tester.tap(find.byType(Switch).last);
    await tester.pumpAndSettle();

    expect(controller.settingsStore.load().projectRunLimits, isEmpty);
  });

  testWidgets('the project list says when a project is limited', (
    tester,
  ) async {
    final temp = Directory.systemTemp.createTempSync('project_row_test');
    addTearDown(() => temp.deleteSync(recursive: true));
    final store = WorkerSettingsStore(File('${temp.path}/settings.json'))
      ..save(const WorkerSettings(projectRunLimits: {'p1': 1}));
    final controller = AppController(settingsStore: store)
      ..projects = [bmi]
      ..linkedProjectIds = {'p1'};
    addTearDown(controller.dispose);
    var opened = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProjectsPanel(
              controller: controller,
              onLink: (_) {},
              onOpen: (_) => opened = true,
            ),
          ),
        ),
      ),
    );

    expect(
      find.text('Running from this computer · at most 1 at once'),
      findsOneWidget,
    );
    await tester.tap(find.text('BMI Index'));
    expect(opened, isTrue);
  });

  testWidgets('shows where the script runs from and why it cannot', (
    tester,
  ) async {
    await pump(
      tester,
      configure: (controller) => controller
        ..scriptOrigins = {
          'p1': const ScriptOrigin(
            path: '/work/bmi/bmi.py',
            fingerprint: 'sha256:1',
          ),
        }
        ..scriptProblems = {
          'p1':
              "The script's inputs or outputs changed — link it again in "
              'Discoman Compute.',
        }
        ..missingPackagesByProject = {
          'p1': ['matlabengine'],
        },
    );

    expect(find.text('/work/bmi/bmi.py'), findsOneWidget);
    expect(find.text('Show in folder'), findsOneWidget);
    expect(find.textContaining('inputs or outputs changed'), findsOneWidget);
    expect(
      find.textContaining('must match your MATLAB release'),
      findsOneWidget,
    );
    expect(find.text('Install'), findsNothing);
  });

  testWidgets('the script guide saves the example script', (tester) async {
    final controller = await pump(tester);
    final temp = Directory.systemTemp.createTempSync('script_guide_test');
    addTearDown(() => temp.deleteSync(recursive: true));
    final target = '${temp.path}/example.py';

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: ScriptGuideDialog(
          controller: controller,
          saveTo: () async => target,
        ),
      ),
    );
    await tester.tap(find.text('Save example script'));
    for (
      var i = 0;
      i < 50 && find.text('Saved to $target').evaluate().isEmpty;
      i++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }

    expect(File(target).readAsStringSync(), contains('- photos -> image[]'));
    expect(find.text('Saved to $target'), findsOneWidget);
  });
}
