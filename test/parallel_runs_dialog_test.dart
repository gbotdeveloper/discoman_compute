import 'package:discoman_compute/app_theme.dart';
import 'package:discoman_compute/widgets/parallel_runs_dialog.dart';
import 'package:discoman_worker/discoman_compute.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _gb = 1024 * 1024 * 1024;

void main() {
  Future<void> open(
    WidgetTester tester, {
    int current = 1,
    int? suggested,
    Map<String, List<RunUsage>> usage = const {},
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<int>(
              context: context,
              builder: (_) => ParallelRunsDialog(
                current: current,
                suggested: suggested,
                machine: const MachineResources(cores: 8, ramBytes: 16 * _gb),
                usageByProject: usage,
                projectNames: const {'p1': 'BMI Index'},
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('explains the suggestion comes after a run', (tester) async {
    await open(tester);

    expect(
      find.textContaining('Once a linked script has run here'),
      findsOneWidget,
    );
    expect(find.textContaining('Use suggestion'), findsNothing);
  });

  testWidgets('shows what each script used and suggests a number', (
    tester,
  ) async {
    await open(
      tester,
      suggested: 3,
      usage: {
        'p1': [
          const RunUsage(peakRamBytes: 2 * _gb, cpuSeconds: 10, wallMs: 10000),
        ],
      },
    );

    expect(find.text('This computer: 8 cores, 16.0 GB memory'), findsOneWidget);
    expect(
      find.text('BMI Index: up to 2.0 GB memory, 1.0 core'),
      findsOneWidget,
    );
    expect(find.textContaining('Suggested: 3'), findsOneWidget);
  });

  testWidgets('warns when set above the suggestion', (tester) async {
    await open(tester, current: 2, suggested: 2);
    expect(find.textContaining('More than suggested'), findsNothing);

    await tester.tap(find.text('+'));
    await tester.pumpAndSettle();

    expect(find.textContaining('More than suggested'), findsOneWidget);
  });

  testWidgets('saves the suggestion when taken', (tester) async {
    int? picked;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              picked = await showDialog<int>(
                context: context,
                builder: (_) => const ParallelRunsDialog(
                  current: 1,
                  suggested: 4,
                  machine: null,
                  usageByProject: {},
                  projectNames: {},
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Use suggestion (4)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(picked, 4);
  });

  testWidgets('never goes below one', (tester) async {
    await open(tester);

    await tester.tap(find.text('−'));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
  });
}
