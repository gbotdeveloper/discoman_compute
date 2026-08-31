import 'package:discoman_client/discoman_client.dart';
import 'package:flutter/material.dart';

import '../app_controller.dart';
import 'action_button.dart';
import 'section_card.dart';

/// The creator's projects, and which of them run a script from this machine.
class ProjectsPanel extends StatelessWidget {
  const ProjectsPanel({
    required this.controller,
    required this.onLink,
    super.key,
  });

  final AppController controller;

  /// Called with the project the creator wants to attach a script to.
  final ValueChanged<CreatorProjectSummary> onLink;

  @override
  Widget build(BuildContext context) {
    final projects = controller.projects;

    return SectionCard(
      title: 'Your projects',
      trailing: ActionButton(
        label: 'Refresh',
        icon: Icons.refresh_rounded,
        isPrimary: false,
        onPressed: controller.isBusy ? null : controller.refreshProjects,
      ),
      child: projects.isEmpty
          ? _EmptyProjects(isBusy: controller.isBusy)
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final project in projects)
                  ProjectRow(
                    project: project,
                    isBusy: controller.isBusy,
                    onLink: () => onLink(project),
                  ),
              ],
            ),
    );
  }
}

class _EmptyProjects extends StatelessWidget {
  const _EmptyProjects({required this.isBusy});

  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Text(
      isBusy
          ? 'Loading…'
          : 'No projects yet. Create one in GBot, then refresh this list.',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// One project, with what it currently runs and a way to change it.
class ProjectRow extends StatelessWidget {
  const ProjectRow({
    required this.project,
    required this.isBusy,
    required this.onLink,
    super.key,
  });

  final CreatorProjectSummary project;
  final bool isBusy;
  final VoidCallback onLink;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLinked = project.scriptLocation == ScriptLocation.creatorMachine;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      project.name.isEmpty ? 'Untitled project' : project.name,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isLinked
                          ? 'Runs a script from this computer'
                          : 'Runs a script uploaded to GBot',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ActionButton(
                label: isLinked ? 'Replace script' : 'Link a script',
                isPrimary: !isLinked,
                onPressed: isBusy ? null : onLink,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
