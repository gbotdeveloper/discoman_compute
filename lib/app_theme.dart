import 'package:flutter/material.dart';

/// The window's colours and text styles, in one place so no widget reaches for
/// a literal.
///
/// GBot's teal is the seed, so this app looks like the web app a creator just
/// came from. Light and dark both follow the system setting.
ThemeData buildAppTheme(Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF0E7490),
    brightness: brightness,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
  );
}
