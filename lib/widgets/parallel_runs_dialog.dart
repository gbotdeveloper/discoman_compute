import 'package:discoman_worker/discoman_compute.dart';
import 'package:flutter/material.dart';

import 'action_button.dart';

/// Lets the creator choose how many runs this computer takes at once, with a
/// suggestion from what the scripts used when they last ran here.
///
/// Pops the chosen number, or null if the creator backed out.
class ParallelRunsDialog extends StatefulWidget {
  const ParallelRunsDialog({
    required this.current,
    required this.suggested,
    required this.machine,
    required this.usageByProject,
    required this.projectNames,
    super.key,
  });

  final int current;
  final int? suggested;
  final MachineResources? machine;

  /// Only the projects this computer serves.
  final Map<String, List<RunUsage>> usageByProject;
  final Map<String, String> projectNames;

  static const maxRuns = 32;

  @override
  State<ParallelRunsDialog> createState() => _ParallelRunsDialogState();
}

class _ParallelRunsDialogState extends State<ParallelRunsDialog> {
  late int _runs = widget.current;

  void _set(int runs) =>
      setState(() => _runs = runs.clamp(1, ParallelRunsDialog.maxRuns));

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mutedStyle = textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
      height: 1.45,
    );
    final suggested = widget.suggested;
    final machine = widget.machine;

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
                'Runs at the same time',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'How many runs this computer takes at once. More finishes a '
                'queue sooner, as long as the computer has the memory and '
                'cores for them.',
                style: mutedStyle,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  ActionButton(
                    label: '−',
                    isPrimary: false,
                    onPressed: _runs > 1 ? () => _set(_runs - 1) : null,
                  ),
                  SizedBox(
                    width: 56,
                    child: Text(
                      '$_runs',
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge,
                    ),
                  ),
                  ActionButton(
                    label: '+',
                    isPrimary: false,
                    onPressed: _runs < ParallelRunsDialog.maxRuns
                        ? () => _set(_runs + 1)
                        : null,
                  ),
                  const Spacer(),
                  if (suggested != null && suggested != _runs)
                    ActionButton(
                      label: 'Use suggestion ($suggested)',
                      isPrimary: false,
                      onPressed: () => _set(suggested),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                suggested == null
                    ? 'Once a linked script has run here, Discoman suggests a '
                          'number from the memory and cores it used.'
                    : 'Suggested: $suggested, from the heaviest script here. '
                          'It leaves a quarter of the memory and one core for '
                          'everything else.',
                style: mutedStyle,
              ),
              if (suggested != null && _runs > suggested) ...[
                const SizedBox(height: 8),
                Text(
                  'More than suggested: runs may slow each other down, or '
                  'fail when memory runs out.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.error,
                    height: 1.45,
                  ),
                ),
              ],
              if (machine != null) ...[
                const SizedBox(height: 14),
                Text(
                  'This computer: ${_describeMachine(machine)}',
                  style: textTheme.bodySmall,
                ),
              ],
              for (final entry in widget.usageByProject.entries)
                if (entry.value.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${widget.projectNames[entry.key] ?? entry.key}: '
                      '${describeUsage(entry.value)}',
                      style: textTheme.bodySmall,
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
                    onPressed: () => Navigator.of(context).pop(_runs),
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

String _describeMachine(MachineResources machine) => [
  '${machine.cores} cores',
  if (machine.ramBytes != null) '${formatBytes(machine.ramBytes!)} memory',
  if (machine.vramBytes != null)
    '${formatBytes(machine.vramBytes!)} graphics memory',
].join(', ');

/// The most a project's recent runs used, as one line.
String describeUsage(List<RunUsage> runs) {
  final ram = runs.map((r) => r.peakRamBytes).reduce((a, b) => a > b ? a : b);
  final cores = runs.map((r) => r.cores).reduce((a, b) => a > b ? a : b);
  final vrams = [for (final r in runs) ?r.peakVramBytes];
  final vram = vrams.isEmpty ? 0 : vrams.reduce((a, b) => a > b ? a : b);
  return [
    'up to ${formatBytes(ram)} memory',
    '${cores.toStringAsFixed(1)} ${cores >= 0.95 && cores < 1.05 ? 'core' : 'cores'}',
    if (vram > 0) '${formatBytes(vram)} graphics memory',
  ].join(', ');
}

String formatBytes(int bytes) {
  const gb = 1024 * 1024 * 1024;
  const mb = 1024 * 1024;
  if (bytes >= gb) return '${(bytes / gb).toStringAsFixed(1)} GB';
  return '${(bytes / mb).round()} MB';
}
