import 'dart:io';

import 'package:discoman_compute/app_controller.dart';
import 'package:discoman_compute/app_theme.dart';
import 'package:discoman_compute/widgets/account_menu.dart';
import 'package:discoman_worker/discoman_compute.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late WorkerSettingsStore store;
  late AppController controller;

  setUp(() {
    final temp = Directory.systemTemp.createTempSync('account_menu_test');
    addTearDown(() => temp.deleteSync(recursive: true));
    store = WorkerSettingsStore(File('${temp.path}/settings.json'));
    controller = AppController(settingsStore: store)
      ..signedInAs = 'ada@example.com';
    addTearDown(controller.dispose);
  });

  Future<void> pump(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topRight,
            child: AccountMenu(controller: controller),
          ),
        ),
      ),
    );
  }

  testWidgets('shows only the email until it is opened', (tester) async {
    await pump(tester);

    expect(find.text('ada@example.com'), findsOneWidget);
    expect(find.text('Sign out'), findsNothing);
    expect(find.byIcon(Icons.dark_mode_outlined), findsNothing);
  });

  testWidgets('the menu stays open while the appearance is switched', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.text('ada@example.com'));
    await tester.pumpAndSettle();
    expect(find.text('Sign out'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.dark_mode_outlined));
    await tester.pumpAndSettle();
    expect(store.load().theme, ThemePreference.dark);
    expect(find.text('Sign out'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.light_mode_outlined));
    await tester.pumpAndSettle();
    expect(store.load().theme, ThemePreference.light);
    expect(find.text('Sign out'), findsOneWidget);
  });
}
