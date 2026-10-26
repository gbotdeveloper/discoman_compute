import 'package:discoman_worker/discoman_compute.dart';
import 'package:flutter/material.dart';

import '../app_controller.dart';
import 'action_button.dart';

/// Installs pip packages into this computer's Python and shows pip's output
/// as it goes.
class InstallPackagesDialog extends StatefulWidget {
  const InstallPackagesDialog({
    required this.controller,
    required this.packages,
    super.key,
  });

  final AppController controller;
  final List<String> packages;

  @override
  State<InstallPackagesDialog> createState() => _InstallPackagesDialogState();
}

class _InstallPackagesDialogState extends State<InstallPackagesDialog> {
  PackageInstallResult? _result;

  @override
  void initState() {
    super.initState();
    widget.controller.installMissingPackages(widget.packages).then((result) {
      if (mounted) setState(() => _result = result);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final result = _result;

    final (String status, Color colour) = switch (result) {
      null => (
        'Installing ${widget.packages.join(', ')}…',
        colorScheme.primary,
      ),
      PackageInstallResult(success: true) => (
        'Installed. Your runs can use '
            '${widget.packages.length == 1 ? 'it' : 'them'} now.',
        colorScheme.primary,
      ),
      PackageInstallResult(externallyManaged: true) => (
        'This Python does not allow installing packages: it is managed by '
            'Homebrew or your system. Choose another Python, such as a '
            'virtual environment, and try again.',
        colorScheme.error,
      ),
      _ => ('The install failed. See what pip said above.', colorScheme.error),
    };

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Install packages',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              SelectableText(
                widget.controller.config.pythonPath,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListenableBuilder(
                    listenable: widget.controller,
                    builder: (context, _) => ListView(
                      shrinkWrap: true,
                      reverse: true,
                      padding: const EdgeInsets.all(12),
                      children: [
                        for (final line
                            in widget.controller.installLog.reversed)
                          SelectableText(
                            line,
                            style: textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  if (result == null) ...[
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      status,
                      style: textTheme.bodyMedium?.copyWith(color: colour),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: ActionButton(
                  label: 'Close',
                  onPressed: result == null
                      ? null
                      : () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
