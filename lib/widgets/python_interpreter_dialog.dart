import 'dart:io';

import 'package:discoman_worker/discoman_compute.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'action_button.dart';

/// Lets the creator name the Python that runs their scripts, and tells them
/// straight away whether it works.
///
/// The check matters more than the field: someone who mistypes a path, or
/// points at a Python without their packages, would otherwise only find out
/// when a visitor's run fails with `ModuleNotFoundError`.
///
/// Pops the chosen path, or null if the creator backed out.
class PythonInterpreterDialog extends StatefulWidget {
  const PythonInterpreterDialog({
    required this.initialPath,
    this.check,
    this.browse,
    this.find,
    this.onInstallManaged,
    super.key,
  });

  final String initialPath;

  /// Runs the interpreter to see whether it is one. Injected by tests so they
  /// need no Python on the machine running them.
  final Future<InterpreterCheck> Function(String path)? check;

  /// Returns a path the creator picked from a file dialog, or null. Injected
  /// by tests, which cannot open a native picker.
  final Future<String?> Function()? browse;

  /// Lists the Pythons on this computer. Injected by tests.
  final List<FoundPython> Function()? find;

  /// When given, Discoman's own Python is not installed and the dialog offers
  /// to install it.
  final VoidCallback? onInstallManaged;

  @override
  State<PythonInterpreterDialog> createState() =>
      _PythonInterpreterDialogState();
}

class _PythonInterpreterDialogState extends State<PythonInterpreterDialog> {
  late final List<FoundPython> _found = (widget.find ?? findPythons)();

  /// The found Python picked, or null while the creator types a path.
  late FoundPython? _chosen = _found
      .where((python) => python.path == widget.initialPath.trim())
      .firstOrNull;

  late final TextEditingController _path = TextEditingController(
    text: _chosen == null ? widget.initialPath : '',
  );

  InterpreterCheck? _result;
  bool _isChecking = false;

  String get _selectedPath => _chosen?.path ?? _path.text.trim();

  @override
  void initState() {
    super.initState();
    if (_selectedPath.isNotEmpty) _check();
  }

  @override
  void dispose() {
    _path.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final path = _selectedPath;
    setState(() {
      _isChecking = true;
      _result = null;
    });

    final check = widget.check ?? (path) => checkInterpreter(path);
    final result = await check(path);

    // A later pick or edit has its own check coming.
    if (!mounted || path != _selectedPath) return;
    setState(() {
      _isChecking = false;
      _result = result;
    });
  }

  Future<void> _browse() async {
    final browse = widget.browse ?? _openSystemPicker;
    final picked = await browse();
    if (picked == null || !mounted) return;
    setState(() {
      _path.text = picked;
      _result = null;
    });
  }

  void _pick(FoundPython python) {
    setState(() => _chosen = python);
    _check();
  }

  void _typePath() {
    setState(() {
      _chosen = null;
      _isChecking = false;
      _result = null;
    });
  }

  static Future<String?> _openSystemPicker() async {
    final file = await openFile();
    return file?.path;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final result = _result;
    final typing = _chosen == null;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Python interpreter',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'The Python your scripts run with. Pick one that has the '
                'packages your scripts import.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              if (_found.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Found on this computer',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 260),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final python in _found)
                          _PythonChoiceRow(
                            title: python.label,
                            subtitle: python.path,
                            selected: _chosen == python,
                            onTap: () => _pick(python),
                          ),
                        _PythonChoiceRow(
                          title: 'Enter a path',
                          selected: typing,
                          onTap: _typePath,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (typing) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _path,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Path',
                    border: const OutlineInputBorder(),
                    hintText: Platform.isWindows
                        ? r'C:\path\to\python.exe'
                        : '/usr/bin/python3',
                  ),
                  onSubmitted: (_) => _check(),
                  // Whatever was checked was the old text.
                  onChanged: (_) => setState(() {
                    _result = null;
                    _isChecking = false;
                  }),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ActionButton(
                      label: 'Browse…',
                      isPrimary: false,
                      onPressed: _browse,
                    ),
                    const SizedBox(width: 10),
                    ActionButton(
                      label: _isChecking ? 'Checking…' : 'Check',
                      isPrimary: false,
                      onPressed: _isChecking || _path.text.trim().isEmpty
                          ? null
                          : _check,
                    ),
                  ],
                ),
              ],
              if (result != null) ...[
                const SizedBox(height: 14),
                _CheckResult(result: result),
              ] else if (_isChecking && !typing) ...[
                const SizedBox(height: 14),
                Text('Checking…', style: textTheme.bodySmall),
              ],
              if (widget.onInstallManaged != null) ...[
                const SizedBox(height: 16),
                _InstallManagedOffer(onInstall: widget.onInstallManaged!),
              ],
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
                    label: 'Use this Python',
                    // Only a path that has just passed the check: a typo
                    // would otherwise surface as a visitor's failed run.
                    // Expanded before it leaves this dialog: a stored `~` is
                    // meaningless to the process that will run it later.
                    onPressed: _isChecking || !(result?.isUsable ?? false)
                        ? null
                        : () => Navigator.of(
                            context,
                          ).pop(expandHomePath(_selectedPath)),
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

class _InstallManagedOffer extends StatelessWidget {
  const _InstallManagedOffer({required this.onInstall});

  final VoidCallback onInstall;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'No Python, or yours gives trouble? Discoman can download '
                'Python ${_short(managedPythonVersions.first)}–'
                '${_short(managedPythonVersions.last)} for you.',
                style: textTheme.bodySmall?.copyWith(height: 1.4),
              ),
            ),
            const SizedBox(width: 12),
            ActionButton(
              label: 'Install Python',
              isPrimary: false,
              onPressed: onInstall,
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckResult extends StatelessWidget {
  const _CheckResult({required this.result});

  final InterpreterCheck result;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ok = result.isUsable;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: ok
            ? colorScheme.surfaceContainerHighest
            : colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              ok ? Icons.check_circle_outline : Icons.error_outline_rounded,
              size: 18,
              color: ok ? colorScheme.primary : colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SelectableText(
                result.message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ok
                      ? colorScheme.onSurface
                      : colorScheme.onErrorContainer,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PythonChoiceRow extends StatelessWidget {
  const _PythonChoiceRow({
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 18,
              color: selected ? colorScheme.primary : colorScheme.outline,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _short(String version) => version.split('.').take(2).join('.');
