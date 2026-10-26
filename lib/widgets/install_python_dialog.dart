import 'package:discoman_worker/discoman_compute.dart';
import 'package:flutter/material.dart';

import '../app_controller.dart';
import 'action_button.dart';

/// Downloads Discoman's own Python and the packages scripts need, step by
/// step, and switches this computer to it.
class InstallPythonDialog extends StatefulWidget {
  const InstallPythonDialog({
    required this.controller,
    this.installer,
    super.key,
  });

  final AppController controller;

  /// Injected by tests so nothing is downloaded.
  final PythonInstaller? installer;

  @override
  State<InstallPythonDialog> createState() => _InstallPythonDialogState();
}

enum _Phase { ready, installing, done, failed }

class _InstallPythonDialogState extends State<InstallPythonDialog> {
  _Phase _phase = _Phase.ready;
  PythonInstallStep? _step;
  double? _downloaded;
  String? _error;
  List<String> _unavailable = const [];
  final List<String> _pipLines = [];

  Future<void> _install() async {
    setState(() {
      _phase = _Phase.installing;
      _step = null;
      _downloaded = null;
      _error = null;
      _pipLines.clear();
    });
    try {
      final result = await widget.controller.installPython(
        (progress) {
          if (!mounted) return;
          setState(() {
            _step = progress.step;
            if (progress.fraction != null) _downloaded = progress.fraction;
            if (progress.line != null) _pipLines.add(progress.line!);
          });
        },
        confirmGuessed: _confirmGuessed,
        installer: widget.installer,
      );
      if (!mounted) return;
      setState(() {
        _phase = _Phase.done;
        _unavailable = result.unavailablePackages;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.failed;
        _error = '$error';
      });
    }
  }

  /// Asks which of the packages guessed from the scripts' imports to
  /// install: an import can name the creator's own module rather than a
  /// package.
  Future<List<String>> _confirmGuessed(List<String> packages) async {
    if (!mounted) return const [];
    final chosen = await showDialog<List<String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _GuessedPackagesDialog(packages: packages),
    );
    return chosen ?? const [];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                'Install Python $managedPythonVersion',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Discoman downloads its own Python into ~/.discoman/python, '
                'with numpy, pandas, matplotlib, Pillow and whatever your '
                'linked scripts import. Other Pythons on this computer are '
                'left alone.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              if (_phase != _Phase.ready) ...[
                const SizedBox(height: 18),
                for (final step in PythonInstallStep.values)
                  _StepLine(
                    label: _label(step),
                    state: _stateOf(step),
                    fraction: step == PythonInstallStep.download
                        ? _downloaded
                        : null,
                  ),
              ],
              if (_pipLines.isNotEmpty) ...[
                const SizedBox(height: 12),
                Flexible(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      reverse: true,
                      padding: const EdgeInsets.all(12),
                      children: [
                        for (final line in _pipLines.reversed)
                          Text(
                            line,
                            style: textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
              if (_phase == _Phase.done) ...[
                const SizedBox(height: 14),
                Text(
                  'Done. This computer now runs your scripts with it.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ],
              if (_unavailable.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'pip could not install ${_unavailable.join(', ')}. If one '
                  'of these is your own module rather than a package, that '
                  'is expected; otherwise install it yourself.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 14),
                SelectableText(
                  _error!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (_phase != _Phase.done)
                    ActionButton(
                      label: 'Cancel',
                      isPrimary: false,
                      onPressed: _phase == _Phase.installing
                          ? null
                          : () => Navigator.of(context).pop(),
                    ),
                  switch (_phase) {
                    _Phase.ready => ActionButton(
                      label: 'Install',
                      onPressed: _install,
                    ),
                    _Phase.installing => const ActionButton(
                      label: 'Installing…',
                      onPressed: null,
                    ),
                    _Phase.failed => ActionButton(
                      label: 'Try again',
                      onPressed: _install,
                    ),
                    _Phase.done => ActionButton(
                      label: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  },
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _label(PythonInstallStep step) => switch (step) {
    PythonInstallStep.download => 'Downloading Python',
    PythonInstallStep.verify => 'Checking the download',
    PythonInstallStep.unpack => 'Unpacking',
    PythonInstallStep.packages => 'Installing packages',
    PythonInstallStep.check => 'Checking Python runs',
  };

  _StepState _stateOf(PythonInstallStep step) {
    if (_phase == _Phase.done) return _StepState.done;
    final current = _step ?? PythonInstallStep.download;
    if (step.index < current.index) return _StepState.done;
    if (step.index > current.index) return _StepState.waiting;
    return _phase == _Phase.failed ? _StepState.failed : _StepState.active;
  }
}

enum _StepState { waiting, active, done, failed }

class _StepLine extends StatelessWidget {
  const _StepLine({required this.label, required this.state, this.fraction});

  final String label;
  final _StepState state;
  final double? fraction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final Widget icon = switch (state) {
      _StepState.waiting => Icon(
        Icons.radio_button_unchecked,
        size: 18,
        color: colorScheme.outline,
      ),
      _StepState.active => const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      _StepState.done => Icon(
        Icons.check_circle,
        size: 18,
        color: colorScheme.primary,
      ),
      _StepState.failed => Icon(
        Icons.error,
        size: 18,
        color: colorScheme.error,
      ),
    };

    final percent = fraction == null || state != _StepState.active
        ? ''
        : ' ${(fraction! * 100).round()}%';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$label$percent',
              style: textTheme.bodyMedium?.copyWith(
                color: state == _StepState.waiting
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuessedPackagesDialog extends StatefulWidget {
  const _GuessedPackagesDialog({required this.packages});

  final List<String> packages;

  @override
  State<_GuessedPackagesDialog> createState() => _GuessedPackagesDialogState();
}

class _GuessedPackagesDialogState extends State<_GuessedPackagesDialog> {
  late final Set<String> _chosen = {...widget.packages};

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Install these packages too?',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your scripts import them and the new Python does not have '
                'them. Untick any that is a file of your own rather than a '
                'package from PyPI.',
                style: textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final name in widget.packages)
                      CheckboxListTile(
                        value: _chosen.contains(name),
                        title: Text(name),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (on) => setState(
                          () => (on ?? false)
                              ? _chosen.add(name)
                              : _chosen.remove(name),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 10,
                runSpacing: 10,
                children: [
                  ActionButton(
                    label: 'Skip them',
                    isPrimary: false,
                    onPressed: () =>
                        Navigator.of(context).pop(const <String>[]),
                  ),
                  ActionButton(
                    label: 'Install selected',
                    onPressed: () => Navigator.of(context).pop([
                      for (final name in widget.packages)
                        if (_chosen.contains(name)) name,
                    ]),
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
