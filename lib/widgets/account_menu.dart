import 'package:flutter/material.dart';

import '../app_controller.dart';
import 'theme_switch.dart';

/// The signed-in creator's email, opening a menu with the appearance choice
/// and sign out. The menu stays open while the appearance is switched, so
/// the creator sees the window change before closing it.
class AccountMenu extends StatelessWidget {
  const AccountMenu({required this.controller, super.key});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return MenuAnchor(
      alignmentOffset: const Offset(0, 6),
      menuChildren: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Appearance',
                style: theme.textTheme.labelMedium?.copyWith(color: muted),
              ),
              const SizedBox(height: 8),
              // The menu is built once when it opens; listening here keeps
              // the selected segment in step with the choice.
              ListenableBuilder(
                listenable: controller,
                builder: (context, _) => ThemeSwitch(controller: controller),
              ),
            ],
          ),
        ),
        const Divider(height: 12),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) => MenuItemButton(
            leadingIcon: const Icon(Icons.logout_rounded, size: 18),
            onPressed: controller.isBusy ? null : controller.signOut,
            child: const Text('Sign out'),
          ),
        ),
      ],
      builder: (context, menu, _) => TextButton.icon(
        onPressed: () => menu.isOpen ? menu.close() : menu.open(),
        icon: const Icon(Icons.account_circle_outlined, size: 18),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                controller.signedInAs ?? '',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more_rounded, size: 18),
          ],
        ),
        style: TextButton.styleFrom(
          foregroundColor: muted,
          textStyle: theme.textTheme.bodySmall,
        ),
      ),
    );
  }
}
