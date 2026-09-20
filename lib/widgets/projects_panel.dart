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
    // Split rather than sorted, so each group keeps the server's newest-first
    // order. The projects this window can act on come first: a creator with
    // thirty cloud projects should not have to hunt for the three that need a
    // script.
    final runsHere = [
      for (final project in controller.projects)
        if (project.scriptLocation == ScriptLocation.creatorMachine) project,
    ];
    final runsInCloud = [
      for (final project in controller.projects)
        if (project.scriptLocation != ScriptLocation.creatorMachine) project,
    ];

    return SectionCard(
      title: 'Your projects',
      trailing: ActionButton(
        label: 'Refresh',
        icon: Icons.refresh_rounded,
        isPrimary: false,
        onPressed: controller.isBusy ? null : controller.refreshProjects,
      ),
      child: controller.projects.isEmpty
          ? _EmptyProjects(isBusy: controller.isBusy)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (runsHere.isNotEmpty) ...[
                  const _GroupHeading(
                    title: 'Runs on your computers',
                    detail:
                        'Each of these runs a Python script kept on the '
                        'computer it runs from.',
                  ),
                  for (final project in runsHere) _row(project, runsHere: true),
                ],
                if (runsInCloud.isNotEmpty) ...[
                  if (runsHere.isNotEmpty) const SizedBox(height: 20),
                  const _GroupHeading(
                    title: "Runs in GBot's cloud",
                    detail:
                        'Move one to your own computers in GBot, and it will '
                        'appear above.',
                  ),
                  for (final project in runsInCloud)
                    _row(project, runsHere: false),
                ],
              ],
            ),
    );
  }

  Widget _row(CreatorProjectSummary project, {required bool runsHere}) {
    return ProjectRow(
      project: project,
      runsHere: runsHere,
      isBusy: controller.isBusy,
      isLinkedHere: controller.linkedProjectIds.contains(project.projectId),
      isServed: !controller.pausedProjectIds.contains(project.projectId),
      onLink: () => onLink(project),
      onServedChanged: (served) =>
          controller.setProjectServed(project.projectId, served: served),
    );
  }
}

/// Names what the rows under it have in common, so each row can stay short.
class _GroupHeading extends StatelessWidget {
  const _GroupHeading({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            detail,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
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

/// What a project is doing on this computer right now.
enum _ProjectState {
  /// Its script is uploaded to GBot, so this computer has no part in it.
  inCloud,

  /// It runs on the creator's computers, but not from this one yet.
  scriptMissing,

  /// This computer is claiming its runs.
  running,

  /// Switched off here; the creator's other computers can still take it.
  paused,
}

/// One project, with what it is doing here and a way to change it.
class ProjectRow extends StatelessWidget {
  const ProjectRow({
    required this.project,
    required this.runsHere,
    required this.isBusy,
    required this.isLinkedHere,
    required this.isServed,
    required this.onLink,
    required this.onServedChanged,
    super.key,
  });

  final CreatorProjectSummary project;

  /// Whether the project runs on the creator's own computers at all. Decided
  /// in GBot, never here.
  final bool runsHere;

  final bool isBusy;

  /// Whether this computer holds the project's script. Scripts are linked per
  /// machine on purpose — we never copy one between a creator's computers —
  /// so a project can run here and not there.
  final bool isLinkedHere;

  /// Whether the creator wants this machine to take work for it.
  final bool isServed;

  final VoidCallback onLink;
  final ValueChanged<bool> onServedChanged;

  _ProjectState get _state {
    if (!runsHere) return _ProjectState.inCloud;
    if (!isLinkedHere) return _ProjectState.scriptMissing;
    return isServed ? _ProjectState.running : _ProjectState.paused;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final state = _state;

    final (icon, label, colour) = switch (state) {
      _ProjectState.inCloud => (
        Icons.cloud_outlined,
        'Its script is uploaded to GBot',
        colorScheme.onSurfaceVariant,
      ),
      _ProjectState.scriptMissing => (
        Icons.link_off_rounded,
        'Link a script to run it on this computer',
        colorScheme.error,
      ),
      _ProjectState.running => (
        Icons.play_circle_fill_rounded,
        'Running from this computer',
        colorScheme.primary,
      ),
      _ProjectState.paused => (
        Icons.pause_circle_filled_rounded,
        'Paused here — its runs go to your other computers',
        colorScheme.onSurfaceVariant,
      ),
    };

    // bodySmall was too quiet for the one line that says what this computer
    // is doing. The icon is sized from the text so the pair keeps its
    // proportions if the style changes again.
    final statusStyle = textTheme.bodyMedium?.copyWith(color: colour);
    final iconSize = (statusStyle?.fontSize ?? 14) * 1.35;

    final canClaim =
        state == _ProjectState.running || state == _ProjectState.paused;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          // Two rows rather than two columns: the switch belongs beside the
          // status it changes, and a Row centres the pair on each other for
          // free.
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name.isEmpty
                          ? 'Untitled project'
                          : project.name,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Held open even where a control does not apply: rows of
                  // different heights read as different kinds of thing, and
                  // these are all just projects.
                  _Reserved(
                    // Linking a script here would silently move the project
                    // onto this machine. Where a project runs is decided in
                    // GBot, so the group heading says so rather than offering
                    // a shortcut.
                    visible: runsHere,
                    child: ActionButton(
                      label: isLinkedHere ? 'Replace script' : 'Link a script',
                      isPrimary: !isLinkedHere,
                      onPressed: isBusy ? null : onLink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(icon, size: iconSize, color: colour),
                  const SizedBox(width: 8),
                  Expanded(child: Text(label, style: statusStyle)),
                  const SizedBox(width: 20),
                  _Reserved(
                    // Only a project whose script is here has runs to claim.
                    visible: canClaim,
                    child: Tooltip(
                      // The switch carries no label, so this is the only place
                      // that says what it does.
                      message: 'Run this project on this computer',
                      child: Switch(
                        value: isServed,
                        onChanged: isBusy ? null : onServedChanged,
                      ),
                    ),
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

/// Keeps a control's space in the layout even where it does not apply, so
/// every project row is the same height.
class _Reserved extends StatelessWidget {
  const _Reserved({required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: child,
    );
  }
}
