import 'package:discoman_compute/app_controller.dart';
import 'package:discoman_compute/app_theme.dart';
import 'package:discoman_compute/widgets/sign_in_page.dart';
import 'package:discoman_worker/discoman_compute.dart';
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

    expect(find.text('Discoman Compute'), findsOneWidget);
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

  testWidgets('a waiting browser sign-in shows its code and can be cancelled', (
    tester,
  ) async {
    final opened = <String>[];
    final controller = AppController(openUrl: (url) async => opened.add(url));
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: Scaffold(body: SignInPage(controller: controller)),
      ),
    );
    expect(find.text('Sign in with your browser'), findsOneWidget);

    controller.browserSignIn = const BrowserSignInPrompt(
      approvalUrl: 'https://discoman.test/link-device?code=K7QM-3XPD',
      userCode: 'K7QM-3XPD',
    );
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    controller.notifyListeners();
    await tester.pump();

    expect(find.text('Email'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is SelectableText && widget.data == 'K7QM-3XPD',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Open the page again'));
    expect(opened, ['https://discoman.test/link-device?code=K7QM-3XPD']);

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    expect(controller.browserSignIn, isNull);
    expect(find.text('Email'), findsOneWidget);
  });
}
