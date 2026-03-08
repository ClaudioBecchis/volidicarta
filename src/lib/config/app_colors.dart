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
}
