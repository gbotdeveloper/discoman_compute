import 'package:discoman_worker/discoman_compute.dart';
import 'package:flutter/material.dart';

import '../app_controller.dart';
import 'action_button.dart';
import 'install_python_dialog.dart';
import 'parallel_runs_dialog.dart';
import 'python_interpreter_dialog.dart';
import 'section_card.dart';

/// Start and stop the worker, and watch what it does.
class WorkerPanel extends StatelessWidget {
  const WorkerPanel({required this.controller, super.key});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final isRunning = controller.isWorkerBusy;
    // Starting with nothing linked would register a machine that shows as
    // online and never runs anything — worse than refusing to start.
    final canStart = controller.canServeAnything;

    return SectionCard(
      title: 'This computer',
      trailing: ActionButton(
        label: isRunning ? 'Stop' : 'Start',
        icon: isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
        isPrimary: !isRunning,
        onPressed: controller.isBusy || (!isRunning && !canStart)
            ? null
            : (isRunning ? controller.stopWorker : controller.startWorker),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _WorkerStatusLine(state: controller.workerState),
          if (!isRunning && !canStart) ...[
            const SizedBox(height: 8),
            _NothingToServe(),
          ],
          const SizedBox(height: 12),
          _DetailRow(
            label: 'Python',
            value: controller.config.pythonPath,
            // Changing it mid-run would be a lie: the running worker keeps
            // the interpreter it started with.
            onChange: isRunning || controller.isBusy
                ? null
                : () => _changeInterpreter(context, controller),
            changeHint: isRunning ? 'Stop the worker to change this' : null,
            onInstall:
                isRunning ||
                    controller.isBusy ||
                    _usesInstalledManagedPython(controller)
                ? null
                : () => _installPython(context, controller),
          ),
          _DetailRow(
            label: 'Workers',
            value: _parallelRunsLabel(controller),
            onChange: isRunning || controller.isBusy
                ? null
                : () => _changeParallelRuns(context, controller),
            changeHint: isRunning ? 'Stop the worker to change this' : null,
          ),
          _DetailRow(label: 'Server', value: controller.config.serverUrl),
          const SizedBox(height: 16),
          _WorkerLog(lines: controller.log),
        ],
      ),
    );
  }
}

/// Whether Discoman's own Python is the one in use and is still there to
/// run, so installing it again would change nothing.
bool _usesInstalledManagedPython(AppController controller) {
  final installer = PythonInstaller();
  return controller.config.pythonPath == installer.executablePath &&
      installer.isInstalled;
}

Future<void> _changeInterpreter(
  BuildContext context,
  AppController controller,
) async {
  final picked = await showDialog<String>(
    context: context,
    builder: (context) =>
        PythonInterpreterDialog(initialPath: controller.config.pythonPath),
  );
  if (picked == null) return;
  await controller.setPythonPath(picked);
}

String _parallelRunsLabel(AppController controller) {
  final runs = controller.parallelRuns;
  return runs == 1 ? '1 worker' : '$runs workers';
}

Future<void> _changeParallelRuns(
  BuildContext context,
  AppController controller,
) async {
  final served = {
    for (final entry in controller.usageByProject.entries)
      if (controller.linkedProjectIds.contains(entry.key) &&
          !controller.pausedProjectIds.contains(entry.key))
        entry.key: entry.value,
  };
  final picked = await showDialog<int>(
    context: context,
    builder: (context) => ParallelRunsDialog(
      current: controller.parallelRuns,
      machine: controller.machine,
      usageByProject: served,
      projectNames: {
        for (final project in controller.projects)
          project.projectId: project.name,
      },
    ),
  );
  if (picked == null) return;
  controller.setParallelRuns(picked);
}

Future<void> _installPython(BuildContext context, AppController controller) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => InstallPythonDialog(controller: controller),
  );
}

/// Explains why Start is unavailable.
class _NothingToServe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.link_off_rounded,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Link a script below before starting. This computer can only run '
            'projects whose script is on it.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkerStatusLine extends StatelessWidget {
  const _WorkerStatusLine({required this.state});

  final RemoteWorkerState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final (String label, Color color) = switch (state) {
      RemoteWorkerState.stopped => (
        'Stopped — your apps wait in the queue until you start it.',
        colorScheme.onSurfaceVariant,
      ),
      RemoteWorkerState.connecting => ('Connecting…', colorScheme.primary),
      RemoteWorkerState.online => (
        'Online — waiting for runs.',
        colorScheme.primary,
      ),
      RemoteWorkerState.failed => (
        'Stopped by an error. See the log below.',
        colorScheme.error,
      ),
    };

    return Row(
      children: [
        SizedBox(
          width: 10,
          height: 10,
          child: DecoratedBox(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.onChange,
    this.changeHint,
    this.onInstall,
  });

  final String label;
  final String value;

  /// When given, the row offers a way to change the value.
  final VoidCallback? onChange;

  /// Why the change action is unavailable, when it is.
  final String? changeHint;

  /// When given, the row offers to install Discoman's own Python.
  final VoidCallback? onInstall;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final labelStyle = textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ConstrainedBox(
            // Rows without a button stay as tall as rows with one.
            constraints: const BoxConstraints(minHeight: 30),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text(
                    label,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: SelectableText(
                    value,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                if (onInstall != null) ...[
                  _RowAction(label: 'Install Python', onTap: onInstall!),
                  const SizedBox(width: 8),
                ],
                if (onChange != null)
                  _RowAction(label: 'Change', onTap: onChange!)
                else if (changeHint != null)
                  Text(changeHint!, style: labelStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RowAction extends StatelessWidget {
  const _RowAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkerLog extends StatelessWidget {
  const _WorkerLog({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        height: 160,
        child: lines.isEmpty
            ? Center(
                child: Text(
                  'Nothing has run yet.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                // Newest first: the interesting line is the last one, and
                // this way it needs no scrolling to see.
                reverse: true,
                itemCount: lines.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: SelectableText(
                      lines[lines.length - 1 - index],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        // Menlo is macOS, Consolas is Windows; the generic
                        // name catches anything else.
                        fontFamily: 'Menlo',
                        fontFamilyFallback: const ['Consolas', 'monospace'],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
