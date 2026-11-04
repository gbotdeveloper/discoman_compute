import 'dart:io';

import 'package:discoman_worker/discoman_compute.dart';
import 'package:discoman_compute/app_theme.dart';
import 'package:discoman_compute/widgets/python_interpreter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Builds a real [InterpreterCheck] without launching anything, so these
  /// tests do not depend on which Pythons the machine happens to have.
  Future<InterpreterCheck> replying({int exitCode = 0, String stdout = ''}) {
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
    List<FoundPython> found = const [],
    VoidCallback? onInstallManaged,
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
                      check: check ?? (_) => replying(stdout: 'Python 3.11.9'),
                      browse: browse,
                      find: () => found,
                      onInstallManaged: onInstallManaged,
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
    await pump(tester, check: (_) => replying(stdout: 'Python 3.11.9'));

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
    await pump(tester, check: (_) => replying(stdout: 'hello'));

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

  testWidgets('the current interpreter is checked on opening', (tester) async {
    await pump(tester);

    expect(find.textContaining('Python 3.11.9'), findsWidgets);
  });

  testWidgets('Use this Python waits for a passing check', (tester) async {
    await pump(tester, check: (_) => replying(stdout: 'hello'));

    await tester.tap(find.text('Use this Python'));
    await tester.pumpAndSettle();
    expect(find.byType(PythonInterpreterDialog), findsOneWidget);

    await tester.enterText(find.byType(TextField), '/opt/typed/python3');
    await tester.pump();
    await tester.tap(find.text('Use this Python'));
    await tester.pumpAndSettle();
    expect(find.byType(PythonInterpreterDialog), findsOneWidget);
  });

  testWidgets('offers Discoman\'s Python only when asked to', (tester) async {
    var installs = 0;
    await pump(tester, onInstallManaged: () => installs++);

    await tester.tap(find.text('Install Python'));
    expect(installs, 1);
  });

  testWidgets('no install offer when Discoman\'s Python is there', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('Install Python'), findsNothing);
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

  const imaging = FoundPython(
    path: '/Users/me/anaconda3/envs/imaging/bin/python',
    label: 'Anaconda · imaging',
  );

  testWidgets('picking a found Python checks it with no path to type', (
    tester,
  ) async {
    String? checked;
    await pump(
      tester,
      found: const [imaging],
      check: (path) {
        checked = path;
        return replying(stdout: 'Python 3.11.9');
      },
    );

    expect(find.text('Found on this computer'), findsOneWidget);
    await tester.tap(find.text('Anaconda · imaging'));
    await tester.pumpAndSettle();

    expect(checked, imaging.path);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Check'), findsNothing);
    expect(find.text('Browse…'), findsNothing);

    await tester.tap(find.text('Use this Python'));
    await tester.pumpAndSettle();
    expect(find.byType(PythonInterpreterDialog), findsNothing);
  });

  testWidgets('opens on the found Python already in use', (tester) async {
    await pump(tester, initialPath: imaging.path, found: const [imaging]);

    expect(find.byType(TextField), findsNothing);
    expect(find.textContaining('Python 3.11.9'), findsWidgets);
  });

  testWidgets('entering a path brings the field, Browse and Check', (
    tester,
  ) async {
    await pump(tester, initialPath: imaging.path, found: const [imaging]);

    await tester.tap(find.text('Enter a path'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Browse…'), findsOneWidget);
    // Nothing typed yet, so nothing checked and nothing to use.
    await tester.tap(find.text('Use this Python'));
    await tester.pumpAndSettle();
    expect(find.byType(PythonInterpreterDialog), findsOneWidget);
  });
}
