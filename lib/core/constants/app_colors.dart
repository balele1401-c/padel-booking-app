import 'package:flutter/material.dart';

/// App Color Palette matching PRD specifications
class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF0D9488);       // Teal / Emerald
  static const Color primaryDark = Color(0xFF0F766E);   // Dark Teal

  // Background & Surfaces
  static const Color background = Color(0xFFFAFAFA);    // Very light grey/white
  static const Color surface = Color(0xFFFFFFFF);       // Pure White

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);   // Dark grey
  static const Color textSecondary = Color(0xFF6B7280); // Medium grey

  // Status & System Colors
  static const Color success = Color(0xFF16A34A);       // Green
  static const Color warning = Color(0xFFF59E0B);       // Yellow/Orange
  static const Color error = Color(0xFFDC2626);         // Red
  static const Color border = Color(0xFFE5E7EB);        // Light grey border

  // Status Badges (Pills)
  static const Color pendingBg = Color(0xFFFEF3C7);
  static const Color pendingText = Color(0xFFD97706);

  static const Color confirmedBg = Color(0xFFDCFCE7);
  static const Color confirmedText = Color(0xFF15803D);

  static const Color cancelledBg = Color(0xFFFEE2E2);
  static const Color cancelledText = Color(0xFFB91C1C);
}
