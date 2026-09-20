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
    super.key,
  });

  final String initialPath;

  /// Runs the interpreter to see whether it is one. Injected by tests so they
  /// need no Python on the machine running them.
  final Future<InterpreterCheck> Function(String path)? check;

  /// Returns a path the creator picked from a file dialog, or null. Injected
  /// by tests, which cannot open a native picker.
  final Future<String?> Function()? browse;

  @override
  State<PythonInterpreterDialog> createState() =>
      _PythonInterpreterDialogState();
}

class _PythonInterpreterDialogState extends State<PythonInterpreterDialog> {
  late final TextEditingController _path = TextEditingController(
    text: widget.initialPath,
  );

  InterpreterCheck? _result;
  bool _isChecking = false;

  @override
  void dispose() {
    _path.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    if (_isChecking) return;
    setState(() {
      _isChecking = true;
      _result = null;
    });

    final check = widget.check ?? (path) => checkInterpreter(path);
    final result = await check(_path.text);

    if (!mounted) return;
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

  static Future<String?> _openSystemPicker() async {
    final file = await openFile();
    return file?.path;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final result = _result;

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
                'Python interpreter',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'The Python your scripts run with. It needs the packages they '
                'import — a virtual environment is usually the right answer.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _path,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Path',
                  border: OutlineInputBorder(),
                  hintText: '/usr/bin/python3',
                ),
                onSubmitted: (_) => _check(),
                onChanged: (_) {
                  if (_result != null) setState(() => _result = null);
                },
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
                    onPressed: _isChecking ? null : _check,
                  ),
                ],
              ),
              if (result != null) ...[
                const SizedBox(height: 14),
                _CheckResult(result: result),
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
                    // Expanded before it leaves this dialog: a stored `~` is
                    // meaningless to the process that will run it later.
                    onPressed: _path.text.trim().isEmpty
                        ? null
                        : () => Navigator.of(
                            context,
                          ).pop(expandHomePath(_path.text)),
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
