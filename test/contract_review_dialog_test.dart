import 'package:discoman_client/discoman_client.dart';
import 'package:discoman_compute/app_controller.dart';
import 'package:discoman_compute/app_theme.dart';
import 'package:discoman_compute/widgets/contract_review_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<LinkChoice?> review(
    WidgetTester tester, {
    required List<String> missing,
    required String tap,
    bool keepsInDiscoman = false,
    String? expectText,
  }) async {
    LinkChoice? choice;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              choice = await showDialog<LinkChoice>(
                context: context,
                builder: (_) => ContractReviewDialog(
                  candidate: ScriptCandidate(
                    path: '/tmp/script.py',
                    source: '',
                    draft: ContractDraft(
                      entrypointName: 'main',
                      inputFields: const [],
                      outputFields: const [],
                      notes: const [],
                      summaryMessage: '',
                    ),
                    missingPackages: missing,
                  ),
                  projectName: 'Mine',
                  keepsInDiscoman: keepsInDiscoman,
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
    if (expectText != null) {
      expect(find.textContaining(expectText), findsOneWidget);
    }
    await tester.tap(find.text(tap));
    await tester.pumpAndSettle();
    return choice;
  }

  testWidgets('offers to install what the script is missing', (tester) async {
    final choice = await review(
      tester,
      missing: ['pandas'],
      tap: 'Link and install',
    );
    expect(choice, LinkChoice.linkAndInstall);
  });

  testWidgets('links straight away when nothing is missing', (tester) async {
    final choice = await review(tester, missing: const [], tap: 'Link it');
    expect(choice, LinkChoice.link);
    expect(find.text('Link and install'), findsNothing);
  });

  testWidgets('says the script is sent when the project keeps it', (
    tester,
  ) async {
    await review(
      tester,
      missing: const [],
      tap: 'Link it',
      keepsInDiscoman: true,
      expectText: 'It is never run in the cloud.',
    );
  });
}
