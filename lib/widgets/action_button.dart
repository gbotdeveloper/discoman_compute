import 'package:flutter/material.dart';

/// A button with the padding inside its tap target, so the whole padded area
/// responds rather than just the label.
class ActionButton extends StatelessWidget {
  const ActionButton({
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
    this.icon,
    super.key,
  });

  final String label;

  /// Null disables the button and greys it out.
  final VoidCallback? onPressed;

  final bool isPrimary;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = onPressed != null;

    final background = isPrimary
        ? colorScheme.primary
        : colorScheme.surfaceContainerHighest;
    final foreground = isPrimary
        ? colorScheme.onPrimary
        : colorScheme.onSurface;

    return Opacity(
      opacity: isEnabled ? 1 : 0.5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
          border: isPrimary
              ? null
              : Border.all(color: colorScheme.outlineVariant),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: foreground),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
