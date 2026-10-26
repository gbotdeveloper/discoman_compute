import 'package:discoman_client/discoman_client.dart';
import 'package:discoman_worker/discoman_compute.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../app_controller.dart';
import 'action_button.dart';

/// Lets the creator list the code outside Discoman a script uses on this
/// computer — a version they type, or a git checkout read on every report —
/// so the dashboard shows which version each computer has.
class ExternalCodeDialog extends StatefulWidget {
  const ExternalCodeDialog({
    required this.controller,
    required this.projectId,
    required this.projectName,
    this.pickFolder,
    this.read,
    super.key,
  });

  final AppController controller;
  final String projectId;
  final String projectName;

  /// Injected by tests, which cannot open a native picker.
  final Future<String?> Function()? pickFolder;

  /// Injected by tests so no git runs.
  final Future<ExternalCodeVersion> Function(ExternalCodeSource source)? read;

  @override
  State<ExternalCodeDialog> createState() => _ExternalCodeDialogState();
}

class _ExternalCodeDialogState extends State<ExternalCodeDialog> {
  late List<ExternalCodeSource> _code =
      widget.controller.externalCode[widget.projectId] ?? const [];

  final _name = TextEditingController();
  final _version = TextEditingController();
  bool _usesGit = false;
  String? _gitPath;

  @override
  void dispose() {
    _name.dispose();
    _version.dispose();
    super.dispose();
  }

  bool get _canAdd =>
      _name.text.trim().isNotEmpty &&
      (_usesGit ? _gitPath != null : _version.text.trim().isNotEmpty);

  void _save(List<ExternalCodeSource> code) {
    widget.controller.setExternalCode(widget.projectId, code);
    setState(() => _code = code);
  }

  void _add() {
    _save([
      ..._code,
      ExternalCodeSource(
        name: _name.text.trim(),
        version: _usesGit ? null : _version.text.trim(),
        gitPath: _usesGit ? _gitPath : null,
      ),
    ]);
    setState(() {
      _name.clear();
      _version.clear();
      _gitPath = null;
    });
  }

  Future<void> _browse() async {
    final picked = await (widget.pickFolder ?? getDirectoryPath)();
    if (picked != null && mounted) setState(() => _gitPath = picked);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'External code versions',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'What "${widget.projectName}" uses on this computer that '
                'Discoman does not see, such as MATLAB or a library you keep '
                'in git. The dashboard shows it for every computer, and each '
                'run records the versions it ran with.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_code.isEmpty)
                        Text('Nothing added yet.', style: textTheme.bodyMedium),
                      for (final source in _code)
                        _ExternalCodeRow(
                          key: ObjectKey(source),
                          source: source,
                          read: widget.read,
                          onRemove: () => _save([
                            for (final other in _code)
                              if (!identical(other, source)) other,
                          ]),
                        ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 28),
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Signal processing library',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 10),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Version I type')),
                  ButtonSegment(value: true, label: Text('Git folder')),
                ],
                selected: {_usesGit},
                onSelectionChanged: (choice) =>
                    setState(() => _usesGit = choice.single),
              ),
              const SizedBox(height: 10),
              if (_usesGit)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _gitPath ?? 'No folder chosen',
                        style: textTheme.bodyMedium?.copyWith(
                          color: _gitPath == null
                              ? colorScheme.onSurfaceVariant
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ActionButton(
                      label: 'Choose folder…',
                      isPrimary: false,
                      onPressed: _browse,
                    ),
                  ],
                )
              else
                TextField(
                  controller: _version,
                  decoration: const InputDecoration(
                    labelText: 'Version',
                    hintText: 'R2024b, or "code from 12 October"',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 10,
                runSpacing: 10,
                children: [
                  ActionButton(
                    label: 'Add',
                    isPrimary: false,
                    onPressed: _canAdd ? _add : null,
                  ),
                  ActionButton(
                    label: 'Done',
                    onPressed: () => Navigator.of(context).pop(),
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

class _ExternalCodeRow extends StatefulWidget {
  const _ExternalCodeRow({
    required this.source,
    required this.onRemove,
    this.read,
    super.key,
  });

  final ExternalCodeSource source;
  final VoidCallback onRemove;
  final Future<ExternalCodeVersion> Function(ExternalCodeSource source)? read;

  @override
  State<_ExternalCodeRow> createState() => _ExternalCodeRowState();
}

class _ExternalCodeRowState extends State<_ExternalCodeRow> {
  late final Future<ExternalCodeVersion> _version =
      widget.read?.call(widget.source) ??
      readExternalCodeVersion('', widget.source);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.source.name,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                FutureBuilder(
                  future: _version,
                  builder: (context, snapshot) {
                    final version = snapshot.data;
                    final problem = snapshot.hasError
                        ? '${snapshot.error}'
                        : version?.problem;
                    return Text(
                      snapshot.hasError
                          ? 'Could not read it: $problem'
                          : version == null
                          ? 'Reading…'
                          : describeExternalCode(version),
                      style: textTheme.bodySmall?.copyWith(
                        color: problem != null
                            ? colorScheme.error
                            : colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ActionButton(
            label: 'Remove',
            isPrimary: false,
            onPressed: widget.onRemove,
          ),
        ],
      ),
    );
  }
}

/// One line saying what version [code] is.
String describeExternalCode(ExternalCodeVersion code) {
  final problem = code.problem;
  if (problem != null) return '${code.gitPath} — $problem';
  final commit = code.commit;
  if (commit == null) return code.manualVersion ?? '';
  final parts = [
    commit.substring(0, commit.length < 7 ? commit.length : 7),
    ?code.branch,
    if (code.dirty ?? false) 'uncommitted changes',
    ?code.commitMessage,
  ];
  return '${parts.join(' · ')}\n${code.gitPath}';
}
