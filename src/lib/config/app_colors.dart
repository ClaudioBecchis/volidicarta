import 'package:flutter/material.dart';

abstract class AppColors {
  static const primary = Color(0xFF1A5276);
  static const secondary = Color(0xFF2471A3);
  static const amber = Color(0xFFFFB300);
  static const purple = Color(0xFF7C3AED);

  static Color screenBg(BuildContext ctx) =>
      Theme.of(ctx).colorScheme.surfaceContainerLow;

  static Color cardBg(BuildContext ctx) =>
      Theme.of(ctx).colorScheme.surface;

  static Color textPrimary(BuildContext ctx) =>
      Theme.of(ctx).colorScheme.onSurface;

  /// Sfondo placeholder copertina e mini-chip (0xFFD6EAF8 in light)
  static Color chipBg(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFF1A3A50)
          : const Color(0xFFD6EAF8);

  /// Sfondo card recensione (0xFFEAF4FC in light)
  static Color chipBgLight(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFF0D2035)
          : const Color(0xFFEAF4FC);
}
