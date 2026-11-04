import 'package:discoman_client/discoman_client.dart';
import 'package:discoman_worker/discoman_compute.dart'
    show ExternalCodeSource, manualInstallNote;
import 'package:flutter/material.dart';

import '../app_controller.dart';
import 'action_button.dart';
import 'error_banner.dart';
import 'parallel_runs_dialog.dart';
import 'section_card.dart';

/// Everything about one project on this computer: whether it runs here, how
/// many of its runs this computer takes at once, its script, and the code
/// outside Discoman it uses.
class ProjectPage extends StatelessWidget {
  const ProjectPage({
    required this.controller,
    required this.projectId,
    required this.onLink,
    required this.onInstall,
    required this.onEditExternalCode,
    super.key,
  });

  final AppController controller;
  final String projectId;
  final ValueChanged<CreatorProjectSummary> onLink;
  final ValueChanged<List<String>> onInstall;
  final ValueChanged<CreatorProjectSummary> onEditExternalCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final project = controller.projects
              .where((p) => p.projectId == projectId)
              .firstOrNull;
          if (project == null) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: _BackHeader(title: 'This project is gone'),
            );
          }
          return _ProjectBody(
            controller: controller,
            project: project,
            onLink: () => onLink(project),
            onInstall: onInstall,
            onEditExternalCode: () => onEditExternalCode(project),
          );
        },
      ),
    );
  }
}

class _ProjectBody extends StatelessWidget {
  const _ProjectBody({
    required this.controller,
    required this.project,
    required this.onLink,
    required this.onInstall,
    required this.onEditExternalCode,
  });

  final AppController controller;
  final CreatorProjectSummary project;
  final VoidCallback onLink;
  final ValueChanged<List<String>> onInstall;
  final VoidCallback onEditExternalCode;

  @override
  Widget build(BuildContext context) {
    final id = project.projectId;
    final isLinked = controller.linkedProjectIds.contains(id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BackHeader(
            title: project.name.isEmpty ? 'Untitled project' : project.name,
          ),
          if (controller.errorMessage != null) ...[
            const SizedBox(height: 16),
            ErrorBanner(message: controller.errorMessage!),
          ],
          const SizedBox(height: 20),
          SectionCard(
            title: 'On this computer',
            child: isLinked
                ? _OnThisComputer(controller: controller, projectId: id)
                : const _MutedText(
                    'Link a script below to run this project on this computer.',
                  ),
          ),
          const SizedBox(height: 20),
          SectionCard(
            title: 'Script',
            trailing: ActionButton(
              label: isLinked ? 'Replace script' : 'Link a script',
              isPrimary: !isLinked,
              onPressed: controller.isBusy ? null : onLink,
            ),
            child: _ScriptDetails(
              controller: controller,
              project: project,
              onInstall: onInstall,
            ),
          ),
          const SizedBox(height: 20),
          SectionCard(
            title: 'External code versions',
            trailing: ActionButton(
              label: 'Edit',
              isPrimary: false,
              onPressed: controller.isBusy ? null : onEditExternalCode,
            ),
            child: _ExternalCodeList(
              code: controller.externalCode[id] ?? const [],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackHeader extends StatelessWidget {
  const _BackHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chevron_left_rounded,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  Text(
                    'Your projects',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

/// Whether the project runs here, and how many of its runs at once.
class _OnThisComputer extends StatelessWidget {
  const _OnThisComputer({required this.controller, required this.projectId});

  final AppController controller;
  final String projectId;

  @override
  Widget build(BuildContext context) {
    final isServed = !controller.pausedProjectIds.contains(projectId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _SwitchRow(
          label: 'Run this project on this computer',
          detail: isServed
              ? null
              : 'Paused here — its runs go to your other computers.',
          value: isServed,
          onChanged: controller.isBusy
              ? null
              : (served) =>
                    controller.setProjectServed(projectId, served: served),
        ),
        const Divider(height: 28),
        _RunLimit(controller: controller, projectId: projectId),
      ],
    );
  }
}

/// The most runs of this project the computer takes at once.
class _RunLimit extends StatelessWidget {
  const _RunLimit({required this.controller, required this.projectId});

  final AppController controller;
  final String projectId;

  static const _maxLimit = 32;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final limit = controller.projectRunLimits[projectId];
    final workers = controller.parallelRuns;
    final suggested = controller.suggestedRunsFor(projectId);
    final usage = controller.usageByProject[projectId] ?? const [];

    void set(int? value) =>
        controller.setProjectRunLimit(projectId, value?.clamp(1, _maxLimit));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _SwitchRow(
          label: 'Limit how many of its runs this computer takes at once',
          value: limit != null,
          onChanged: (on) => set(on ? (suggested ?? 1) : null),
        ),
        if (limit != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              ActionButton(
                label: '−',
                isPrimary: false,
                onPressed: limit > 1 ? () => set(limit - 1) : null,
              ),
              SizedBox(
                width: 56,
                child: Text(
                  '$limit',
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge,
                ),
              ),
              ActionButton(
                label: '+',
                isPrimary: false,
                onPressed: limit < _maxLimit ? () => set(limit + 1) : null,
              ),
              const Spacer(),
              if (suggested != null && suggested != limit)
                ActionButton(
                  label: 'Use suggestion ($suggested)',
                  isPrimary: false,
                  onPressed: () => set(suggested),
                ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        _MutedText(
          usage.isEmpty || suggested == null
              ? 'Once it has run here, Discoman suggests how many of its runs '
                    'this computer can take at once.'
              : 'Suggested: $suggested at once. Its runs here used '
                    '${describeUsage(usage)}; the suggestion leaves a quarter '
                    'of the memory and one core free.',
        ),
        if (limit != null && suggested != null && limit > suggested) ...[
          const SizedBox(height: 8),
          Text(
            'More than suggested: its runs may slow each other down, or fail '
            'when memory runs out.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.error,
              height: 1.45,
            ),
          ),
        ],
        const SizedBox(height: 8),
        _MutedText(_workersNote(limit, workers)),
      ],
    );
  }

  String _workersNote(int? limit, int workers) {
    final count = workers == 1 ? '1 worker' : '$workers workers';
    if (limit == null) {
      return 'No limit: it can use all of this computer\'s $count.';
    }
    if (limit >= workers) {
      return 'This computer has $count, so no more than $workers of its runs '
          'go at once anyway.';
    }
    return 'At most $limit of this computer\'s $count take its runs; the '
        'rest stay free for your other projects.';
  }
}

class _ScriptDetails extends StatelessWidget {
  const _ScriptDetails({
    required this.controller,
    required this.project,
    required this.onInstall,
  });

  final AppController controller;
  final CreatorProjectSummary project;
  final ValueChanged<List<String>> onInstall;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final id = project.projectId;
    final isLinked = controller.linkedProjectIds.contains(id);
    final missing = controller.missingPackagesByProject[id] ?? const [];
    final installable = [
      for (final package in missing)
        if (manualInstallNote(package) == null) package,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _MutedText(
          isLinked
              ? 'Its script is on this computer.'
              : 'No script on this computer yet.',
        ),
        if (project.keepsScriptInDiscoman ?? false) ...[
          const SizedBox(height: 8),
          const _MutedText(
            'Kept in Discoman: all your computers get this script.',
          ),
        ],
        if (isLinked && missing.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Missing packages: ${missing.join(', ')}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
              if (installable.isNotEmpty) ...[
                const SizedBox(width: 20),
                ActionButton(
                  label: 'Install',
                  isPrimary: false,
                  onPressed: controller.isBusy
                      ? null
                      : () => onInstall(installable),
                ),
              ],
            ],
          ),
          for (final package in missing)
            if (manualInstallNote(package) case final note?) ...[
              const SizedBox(height: 8),
              _MutedText(note),
            ],
        ],
      ],
    );
  }
}

class _ExternalCodeList extends StatelessWidget {
  const _ExternalCodeList({required this.code});

  final List<ExternalCodeSource> code;

  @override
  Widget build(BuildContext context) {
    if (code.isEmpty) {
      return const _MutedText(
        'Nothing recorded. Add code outside Discoman this script uses here, '
        'such as MATLAB or a library you keep in git.',
      );
    }
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final source in code)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '${source.name}: ${source.version ?? source.gitPath ?? ''}',
              style: textTheme.bodyMedium,
            ),
          ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.detail,
  });

  final String label;
  final String? detail;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (detail != null) ...[
                const SizedBox(height: 2),
                _MutedText(detail!),
              ],
            ],
          ),
        ),
        const SizedBox(width: 20),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _MutedText extends StatelessWidget {
  const _MutedText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        height: 1.45,
      ),
    );
  }
}
