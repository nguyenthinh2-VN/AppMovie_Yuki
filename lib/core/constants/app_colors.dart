import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background Colors (Cinema Dark Theme)
  static const Color background = Color(0xFF0D0C11);
  static const Color surface = Color(0xFF1A1821);
  static const Color surfaceLight = Color(0xFF24222E);
  static const Color cardBackground = Color(0xFF16141D);

  // Accent Colors
  static const Color primary = Color(0xFFE50914); // Crimson Cinema Red
  static const Color primaryLight = Color(0xFFFF3B30);
  static const Color secondary = Color(0xFF8A2BE2); // Electric Purple
  static const Color accentGold = Color(0xFFFFC107); // Star Rating Gold

  // Text Colors
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textMuted = Color(0xFF5B5B60);

  // Status & Border Colors
  static const Color border = Color(0xFF2C2C35);
  static const Color transparent = Colors.transparent;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient imageOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x800D0C11),
      background,
    ],
    stops: [0.3, 0.7, 1.0],
  );

  static const LinearGradient cardOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0xCC0D0C11),
    ],
  );
}
