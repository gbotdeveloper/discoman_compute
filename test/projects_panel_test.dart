import 'dart:io';

import 'package:discoman_client/discoman_client.dart';
import 'package:discoman_compute/app_controller.dart';
import 'package:discoman_worker/src/settings/worker_settings.dart';
import 'package:discoman_compute/app_theme.dart';
import 'package:discoman_compute/widgets/projects_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CreatorProjectSummary project(
    String name, {
    required ScriptLocation where,
  }) {
    return CreatorProjectSummary(
      projectId: name.toLowerCase(),
      name: name,
      scriptLocation: where,
      hasContract: false,
    );
    }

  Future<void> pump(
    WidgetTester tester,
    List<CreatorProjectSummary> projects, {
    Set<String> linked = const {},
  }) async {
    // Its own settings file: the controller writes switch changes through to
    // disk, and a test must never touch the creator's real home directory.
    final temp = Directory.systemTemp.createTempSync('panel_test');
    addTearDown(() => temp.deleteSync(recursive: true));

    final controller = AppController(
      settingsStore: WorkerSettingsStore(File('${temp.path}/settings.json')),
    )
      ..projects = projects
      ..linkedProjectIds = linked.toSet();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: Scaffold(
          body: SingleChildScrollView(
            // The panel is stateless; home_page.dart wraps it in exactly this,
            // so the test has to as well or nothing redraws on a tap.
            child: ListenableBuilder(
              listenable: controller,
              builder: (_, _) =>
                  ProjectsPanel(controller: controller, onLink: (_) {}),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('projects that run here are listed first', (tester) async {
    await pump(tester, [
      project('Cloud one', where: ScriptLocation.uploaded),
      project('Mine', where: ScriptLocation.creatorMachine),
      project('Cloud two', where: ScriptLocation.uploaded),
    ]);

    double top(String name) => tester.getTopLeft(find.text(name)).dy;

    expect(top('Mine'), lessThan(top('Cloud one')));
    expect(top('Mine'), lessThan(top('Cloud two')));
  });

  testWidgets('a cloud project offers no way to link a script', (tester) async {
    await pump(tester, [project('Cloud one', where: ScriptLocation.uploaded)]);

    // Linking here would flip the project onto this machine behind the
    // creator's back; that decision belongs in GBot.
    // Both controls keep their space so rows line up, but neither can be
    // reached: hitTestable is the question the creator actually asks.
    expect(find.text('Link a script').hitTestable(), findsNothing);
    expect(find.text('Replace script').hitTestable(), findsNothing);
    expect(find.byType(Switch).hitTestable(), findsNothing);
    expect(find.text('Its script is uploaded to GBot'), findsOneWidget);
    expect(find.text("Runs in GBot's cloud"), findsOneWidget);
  });

  testWidgets('a project that runs here can be given a script', (tester) async {
    await pump(tester, [project('Mine', where: ScriptLocation.creatorMachine)]);

    expect(find.text('Link a script').hitTestable(), findsOneWidget);
    expect(
      find.text('Link a script to run it on this computer'),
      findsOneWidget,
    );
    // The switch keeps its space so rows line up, but it is not offered:
    // there is nothing to claim until the script is here.
    expect(find.byType(Switch).hitTestable(), findsNothing);
  });

  testWidgets('a linked project can be switched off here', (tester) async {
    await pump(
      tester,
      [project('Mine', where: ScriptLocation.creatorMachine)],
      linked: {'mine'},
    );

    expect(find.text('Running from this computer'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(
      find.text('Paused here — its runs go to your other computers'),
      findsOneWidget,
    );
  });

  testWidgets('the switch sits level with the status it changes', (
    tester,
  ) async {
    await pump(
      tester,
      [project('Mine', where: ScriptLocation.creatorMachine)],
      linked: {'mine'},
    );

    final status = tester.getCenter(find.text('Running from this computer'));
    final toggle = tester.getCenter(find.byType(Switch));

    expect(toggle.dy, moreOrLessEquals(status.dy, epsilon: 1));
  });

  testWidgets('every row is the same height', (tester) async {
    await pump(
      tester,
      [
        project('Linked', where: ScriptLocation.creatorMachine),
        project('Unlinked', where: ScriptLocation.creatorMachine),
        project('Cloud', where: ScriptLocation.uploaded),
      ],
      linked: {'linked'},
    );

    final heights = tester
        .widgetList<ProjectRow>(find.byType(ProjectRow))
        .map((row) => tester.getSize(find.byWidget(row)).height)
        .toSet();

    // Rows of different heights read as different kinds of thing; a project
    // without a script is still just a project.
    expect(heights, hasLength(1));
  });

}
