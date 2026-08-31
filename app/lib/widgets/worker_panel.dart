import 'package:discoman_compute/discoman_compute.dart';
import 'package:flutter/material.dart';

import '../app_controller.dart';
import 'action_button.dart';
import 'section_card.dart';

/// Start and stop the worker, and watch what it does.
class WorkerPanel extends StatelessWidget {
  const WorkerPanel({required this.controller, super.key});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final isRunning = controller.isWorkerBusy;

    return SectionCard(
      title: 'This computer',
      trailing: ActionButton(
        label: isRunning ? 'Stop' : 'Start',
        icon: isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
        isPrimary: !isRunning,
        onPressed: controller.isBusy
            ? null
            : (isRunning ? controller.stopWorker : controller.startWorker),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _WorkerStatusLine(state: controller.workerState),
          const SizedBox(height: 12),
          _DetailRow(
            label: 'Python',
            value: controller.config.pythonPath,
          ),
          _DetailRow(label: 'Server', value: controller.config.serverUrl),
          const SizedBox(height: 16),
          _WorkerLog(lines: controller.log),
        ],
      ),
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
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
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
                        fontFamilyFallback: const [
                          'Consolas',
                          'monospace',
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
