import 'dart:io';

import 'package:discoman_compute/app_controller.dart';
import 'package:discoman_compute/app_theme.dart';
import 'package:discoman_compute/widgets/script_guide_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the script guide saves the example script', (tester) async {
    final controller = AppController();
    addTearDown(controller.dispose);
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
    expect(find.textContaining('class Outputs'), findsWidgets);

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

    expect(File(target).readAsStringSync(), contains('class Outputs:'));
    expect(find.text('Saved to $target'), findsOneWidget);
  });
}
