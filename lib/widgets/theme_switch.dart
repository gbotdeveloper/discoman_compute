import 'package:discoman_worker/discoman_compute.dart' show ThemePreference;
import 'package:flutter/material.dart';

import '../app_controller.dart';

/// Lets the creator choose whether the window follows the system's light or
/// dark setting, or is always one of them.
class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({required this.controller, super.key});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ThemePreference>(
      segments: const [
        ButtonSegment(
          value: ThemePreference.system,
          icon: Icon(Icons.brightness_auto_outlined, size: 18),
          tooltip: 'Follow the system',
        ),
        ButtonSegment(
          value: ThemePreference.light,
          icon: Icon(Icons.light_mode_outlined, size: 18),
          tooltip: 'Light',
        ),
        ButtonSegment(
          value: ThemePreference.dark,
          icon: Icon(Icons.dark_mode_outlined, size: 18),
          tooltip: 'Dark',
        ),
      ],
      selected: {controller.theme},
      showSelectedIcon: false,
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onSelectionChanged: (choice) => controller.setTheme(choice.first),
    );
  }
}
