import 'dart:io';

import 'package:discoman_compute/app_controller.dart';
import 'package:discoman_compute/app_theme.dart';
import 'package:discoman_compute/widgets/theme_switch.dart';
import 'package:discoman_worker/discoman_compute.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late WorkerSettingsStore store;
  late AppController controller;

  setUp(() {
    // Its own settings file: the choice is written through to disk, and a
    // test must never touch the creator's real home directory.
    final temp = Directory.systemTemp.createTempSync('theme_test');
    addTearDown(() => temp.deleteSync(recursive: true));
    store = WorkerSettingsStore(File('${temp.path}/settings.json'));
    controller = AppController(settingsStore: store);
    addTearDown(controller.dispose);
  });

  Future<void> pump(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: Scaffold(
          body: ListenableBuilder(
            listenable: controller,
            builder: (context, _) => ThemeSwitch(controller: controller),
          ),
        ),
      ),
    );
  }

  testWidgets('follows the system until the creator chooses', (tester) async {
    await pump(tester);

    expect(controller.theme, ThemePreference.system);
    expect(find.byIcon(Icons.brightness_auto_outlined), findsOneWidget);
  });

  testWidgets('choosing dark applies it and remembers it', (tester) async {
    await pump(tester);

    await tester.tap(find.byIcon(Icons.dark_mode_outlined));
    await tester.pumpAndSettle();

    expect(controller.theme, ThemePreference.dark);
    expect(store.load().theme, ThemePreference.dark);
  });
}
