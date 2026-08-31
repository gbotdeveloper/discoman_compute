import 'package:discoman_compute_app/app_controller.dart';
import 'package:discoman_compute_app/app_theme.dart';
import 'package:discoman_compute_app/widgets/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sign-in page renders its fields and button', (tester) async {
    final controller = AppController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: Scaffold(body: SignInPage(controller: controller)),
      ),
    );

    expect(find.text('GBot compute'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('sign-in refuses empty credentials without a network call', (
    tester,
  ) async {
    final controller = AppController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: Scaffold(body: SignInPage(controller: controller)),
      ),
    );

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    // The banner uses SelectableText, which `find.text` does not match.
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SelectableText &&
            widget.data == 'Email and password are both required.',
      ),
      findsOneWidget,
    );
  });
}
