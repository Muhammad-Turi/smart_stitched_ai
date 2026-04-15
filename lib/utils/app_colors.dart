import 'package:flutter/material.dart';
import 'color_pallete.dart';

class AppColors {
  // Brand Colors
  static const Color primary = ColorPalette.primary;
  static const Color secondary = ColorPalette.secondary;
  static const Color accent = ColorPalette.accent;

  // Background Colors
  static const Color background = ColorPalette.background;
  static const Color card = ColorPalette.cardBackground;

  // Text Colors
  static const Color textPrimary = ColorPalette.textPrimary;
  static const Color textSecondary = ColorPalette.textSecondary;
  static const Color textWhite = ColorPalette.textWhite;

  // Status Colors
  static const Color success = ColorPalette.success;
  static const Color warning = ColorPalette.warning;
  static const Color error = ColorPalette.error;
  static const Color info = ColorPalette.info;

  // UI Colors - Add these to reference your ColorPalette
  static const Color border = ColorPalette.border;
  static const Color divider = ColorPalette.divider;
  static const Color surface = ColorPalette.cardBackground; // Use cardBackground as surface
}