import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Palette
  static const Color navy = Color(0xFF0C2340);
  static const Color primaryBlue = Color(0xFF185FA5);
  static const Color accentBlue = Color(0xFF378ADD);
  static const Color criticalRed = Color(0xFFE24B4A);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0C2340);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF378ADD);

  // Dark Theme / Settings Design System
  static const Color darkBackground = Color(0xFF050F1A);
  static const Color primaryCyan = Color(0xFF00C2FF);
  static const Color settingsCriticalRed = Color(0xFFFF3B55);
  static const Color glassSurface = Color(0x1AFFFFFF); // 10% white for glass effect
  static const Color glassBorder = Color(0x33FFFFFF); // 20% white
  static const LinearGradient navyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navy, primaryBlue],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, accentBlue],
  );

  static const LinearGradient criticalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [criticalRed, Color(0xFFC0392B)],
  );
}
