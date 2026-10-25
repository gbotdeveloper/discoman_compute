import 'package:discoman_client/discoman_client.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../app_controller.dart';
import 'contract_review_dialog.dart';
import 'error_banner.dart';
import 'external_code_dialog.dart';
import 'install_packages_dialog.dart';
import 'projects_panel.dart';
import 'worker_panel.dart';

/// The window once the creator is signed in: their projects, and the worker.
class HomePage extends StatelessWidget {
  const HomePage({required this.controller, super.key});

  final AppController controller;

  /// Picks a script, parses it here, and asks before sending its contract.
  Future<void> _link(
    BuildContext context,
    CreatorProjectSummary project,
  ) async {
    const pythonFiles = XTypeGroup(label: 'Python', extensions: ['py']);
    final file = await openFile(acceptedTypeGroups: const [pythonFiles]);
    if (file == null) return;

    await controller.pickScript(file.path);
    final candidate = controller.candidate;
    if (candidate == null || !context.mounted) return;

    final choice = await showDialog<LinkChoice>(
      context: context,
      builder: (context) => ContractReviewDialog(
        candidate: candidate,
        projectName: project.name,
        keepsInDiscoman: project.keepsScriptInDiscoman ?? false,
      ),
    );

    if (choice == null) {
      controller.clearCandidate();
      return;
    }
    await controller.linkTo(project.projectId);
    final linked = controller.errorMessage == null;
    if (linked && choice == LinkChoice.linkAndInstall && context.mounted) {
      await _install(context, candidate.missingPackages);
    }
  }

  Future<void> _install(BuildContext context, List<String> packages) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          InstallPackagesDialog(controller: controller, packages: packages),
    );
  }

  @override
  Widget build(BuildContext context) {
    // As in SignInPage: the page subscribes itself, so it cannot be dropped
    // into a tree that never rebuilds it.
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SignedInHeader(email: controller.signedInAs ?? ''),
          if (controller.errorMessage != null) ...[
            const SizedBox(height: 16),
            ErrorBanner(message: controller.errorMessage!),
          ],
          const SizedBox(height: 20),
          WorkerPanel(controller: controller),
          const SizedBox(height: 20),
          ProjectsPanel(
            controller: controller,
            onLink: (project) => _link(context, project),
            onInstall: (packages) => _install(context, packages),
            onEditExternalCode: (project) => showDialog<void>(
              context: context,
              builder: (context) => ExternalCodeDialog(
                controller: controller,
                projectId: project.projectId,
                projectName: project.name,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignedInHeader extends StatelessWidget {
  const _SignedInHeader({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            'Discoman Compute',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        Text(
          email,
          style: textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
