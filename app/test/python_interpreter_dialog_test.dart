import 'dart:io';

import 'package:discoman_compute/discoman_compute.dart';
import 'package:discoman_compute_app/app_theme.dart';
import 'package:discoman_compute_app/widgets/python_interpreter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Builds a real [InterpreterCheck] without launching anything, so these
  /// tests do not depend on which Pythons the machine happens to have.
  Future<InterpreterCheck> replying({
    int exitCode = 0,
    String stdout = '',
  }) {
    return checkInterpreter(
      '/fake/python3',
      runProcess: (_, _) async => ProcessResult(0, exitCode, stdout, ''),
    );
  }

  Future<String?> pump(
    WidgetTester tester, {
    String initialPath = '/usr/bin/python3',
    Future<InterpreterCheck> Function(String)? check,
    Future<String?> Function()? browse,
  }) async {
    String? popped;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  popped = await showDialog<String>(
                    context: context,
                    builder: (_) => PythonInterpreterDialog(
                      initialPath: initialPath,
                      check: check,
                      browse: browse,
                    ),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return popped;
  }

  testWidgets('opens with the current interpreter filled in', (tester) async {
    await pump(tester, initialPath: '/opt/venv/bin/python3');

    expect(find.text('/opt/venv/bin/python3'), findsOneWidget);
  });

  testWidgets('a working interpreter is reported as ready', (tester) async {
    await pump(
      tester,
      check: (_) => replying(stdout: 'Python 3.11.9'),
    );

    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (w) => w is SelectableText && (w.data ?? '').contains('Python 3.11.9'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a path that is not Python is reported as such', (tester) async {
    await pump(
      tester,
      check: (_) => replying(stdout: 'hello'),
    );

    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (w) =>
            w is SelectableText &&
            (w.data ?? '').contains('does not look like Python'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('browsing replaces the path and clears a stale result', (
    tester,
  ) async {
    await pump(
      tester,
      check: (_) => replying(stdout: 'Python 3.11.9'),
      browse: () async => '/opt/other/bin/python3',
    );

    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Python 3.11.9'), findsWidgets);

    await tester.tap(find.text('Browse…'));
    await tester.pumpAndSettle();

    expect(find.text('/opt/other/bin/python3'), findsOneWidget);
    // The old result described the old path, so it must not linger.
    expect(find.textContaining('ready to run'), findsNothing);
  });

  testWidgets('confirming returns the path to the caller', (tester) async {
    await pump(tester, initialPath: '/usr/bin/python3');

    await tester.tap(find.text('Use this Python'));
    await tester.pumpAndSettle();

    expect(find.byType(PythonInterpreterDialog), findsNothing);
  });

  testWidgets('cancelling returns nothing', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(PythonInterpreterDialog), findsNothing);
  });
}
