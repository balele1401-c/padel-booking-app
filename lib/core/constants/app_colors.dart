import 'package:flutter/material.dart';

/// Premium Modern Color Palette — Production-ready, Publication-grade
/// Design language: Midnight Court — Sporty · Luxe · Professional
class AppColors {
  AppColors._();

  // ─── Primary Brand (Deep Emerald Teal) ────────────────────────────────────
  static const Color primary     = Color(0xFF0D9488); // Vibrant Teal
  static const Color primaryDark = Color(0xFF0F766E); // Deep Teal
  static const Color primaryLight= Color(0xFF2DD4BF); // Accent Teal (hover/chip)

  // ─── Gradient Stops ───────────────────────────────────────────────────────
  static const Color gradientStart = Color(0xFF0F766E); // Deep Teal
  static const Color gradientEnd   = Color(0xFF134E4A); // Midnight Teal

  // ─── Backgrounds ──────────────────────────────────────────────────────────
  static const Color background   = Color(0xFFF0F4F8); // Cool Slate White
  static const Color surface      = Color(0xFFFFFFFF); // Pure White card
  static const Color surfaceAlt   = Color(0xFFF8FAFC); // Subtle off-white
  static const Color overlay      = Color(0xFF1C1C2E); // Dark overlay for modals

  // ─── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF0F172A); // Slate 900 — rich black
  static const Color textSecondary = Color(0xFF64748B); // Slate 500 — subdued
  static const Color textHint      = Color(0xFFADB5BD); // Light hint
  static const Color textOnDark    = Colors.white;

  // ─── System / Status ──────────────────────────────────────────────────────
  static const Color success = Color(0xFF059669); // Emerald Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error   = Color(0xFFDC2626); // Red
  static const Color info    = Color(0xFF3B82F6); // Blue

  // ─── Borders & Dividers ───────────────────────────────────────────────────
  static const Color border      = Color(0xFFE2E8F0); // Slate 200
  static const Color borderFocus = Color(0xFF0D9488); // Focus ring Teal

  // ─── Status Badge Pills ───────────────────────────────────────────────────
  static const Color pendingBg   = Color(0xFFFFFBEB);
  static const Color pendingText = Color(0xFFD97706);

  static const Color confirmedBg   = Color(0xFFECFDF5);
  static const Color confirmedText = Color(0xFF059669);

  static const Color cancelledBg   = Color(0xFFFEF2F2);
  static const Color cancelledText = Color(0xFFB91C1C);

  // ─── Shadows ──────────────────────────────────────────────────────────────
  static const Color shadowLight = Color(0x0D000000); // 5% black
  static const Color shadowMedium = Color(0x1A000000); // 10% black
}
