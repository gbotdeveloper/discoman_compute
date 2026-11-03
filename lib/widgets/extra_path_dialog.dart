import 'package:discoman_worker/discoman_compute.dart' show expandHomePath;
import 'package:flutter/material.dart';

import 'action_button.dart';

/// Lets the creator name folders whose programs their scripts call, for
/// programs their terminal's PATH does not find either.
///
/// Pops the folders, one per line as typed, or null if the creator backed out.
class ExtraPathDialog extends StatefulWidget {
  const ExtraPathDialog({required this.initial, super.key});

  final List<String> initial;

  @override
  State<ExtraPathDialog> createState() => _ExtraPathDialogState();
}

class _ExtraPathDialogState extends State<ExtraPathDialog> {
  late final TextEditingController _folders = TextEditingController(
    text: widget.initial.join('\n'),
  );

  @override
  void dispose() {
    _folders.dispose();
    super.dispose();
  }

  List<String> get _parsed => [
    for (final line in _folders.text.split('\n'))
      if (line.trim().isNotEmpty) expandHomePath(line),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Extra PATH',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Runs already find the programs your terminal finds. Add the '
                'folder of any other program your scripts call, such as '
                'MATLAB\'s bin folder, one per line. They are searched first.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _folders,
                autofocus: true,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Folders',
                  border: OutlineInputBorder(),
                  hintText: '/Applications/MATLAB_R2024b.app/bin',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ActionButton(
                    label: 'Cancel',
                    isPrimary: false,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 10),
                  ActionButton(
                    label: 'Save',
                    onPressed: () => Navigator.of(context).pop(_parsed),
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
