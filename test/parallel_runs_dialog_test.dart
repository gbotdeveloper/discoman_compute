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
    Map<String, List<RunUsage>> usage = const {},
    ValueChanged<int?>? onPicked,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              final picked = await showDialog<int>(
                context: context,
                builder: (_) => ParallelRunsDialog(
                  current: current,
                  machine: const MachineResources(cores: 8, ramBytes: 16 * _gb),
                  usageByProject: usage,
                  projectNames: const {'p1': 'BMI Index'},
                ),
              );
              onPicked?.call(picked);
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows what each script used, and suggests no number', (
    tester,
  ) async {
    await open(
      tester,
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
    expect(find.textContaining('Suggest'), findsNothing);
  });

  testWidgets('saves the chosen number', (tester) async {
    int? picked;
    await open(tester, current: 2, onPicked: (runs) => picked = runs);

    await tester.tap(find.text('+'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(picked, 3);
  });

  testWidgets('never goes below one', (tester) async {
    await open(tester);

    await tester.tap(find.text('−'));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
  });
}
