import 'package:flutter/material.dart';

import '../app_controller.dart';
import 'action_button.dart';

/// Shows what was read from the picked script, and asks before sending it.
///
/// This is the point of the whole flow: the creator sees the exact list that
/// will leave this machine — parameter names and types — and can confirm that
/// their code is not in it.
class ContractReviewDialog extends StatelessWidget {
  const ContractReviewDialog({
    required this.candidate,
    required this.projectName,
    super.key,
  });

  final ScriptCandidate candidate;
  final String projectName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final draft = candidate.draft;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Link ${candidate.fileName}',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'to "$projectName"',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Field(
                        label: 'Entrypoint',
                        value: draft.entrypointName,
                      ),
                      const SizedBox(height: 16),
                      _FieldList(
                        title: 'Inputs',
                        entries: [
                          for (final field in draft.inputFields)
                            '${field.parameterName} — ${field.type.name}'
                                '${field.isRequired ? '' : ', optional'}',
                        ],
                      ),
                      const SizedBox(height: 16),
                      _FieldList(
                        title: 'Outputs',
                        entries: [
                          for (final field in draft.outputFields)
                            '${field.outputKey} — ${field.type.name}',
                        ],
                      ),
                      if (draft.notes.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _FieldList(title: 'Notes', entries: draft.notes),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Only what you see above is sent. The script itself is copied '
                'to this computer and stays here.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ActionButton(
                    label: 'Cancel',
                    isPrimary: false,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  const SizedBox(width: 10),
                  ActionButton(
                    label: 'Link it',
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _FieldList extends StatelessWidget {
  const _FieldList({required this.title, required this.entries});

  final String title;
  final List<String> entries;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        if (entries.isEmpty)
          Text('None found.', style: textTheme.bodyMedium)
        else
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SelectableText(entry, style: textTheme.bodyMedium),
            ),
      ],
    );
  }
}
