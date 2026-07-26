import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App Typography — Publication-grade design scale
/// Roboto as base, consistent weights & letter-spacing for premium feel
class AppTextStyles {
  AppTextStyles._();

  // ─── Page Headings ────────────────────────────────────────────────────────
  static const TextStyle heading = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  // ─── Section / Card Headings ─────────────────────────────────────────────
  static const TextStyle subheading = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  // ─── Body Text ────────────────────────────────────────────────────────────
  static const TextStyle body = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // ─── Caption / Label ──────────────────────────────────────────────────────
  static const TextStyle caption = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // ─── Badge / Pill ─────────────────────────────────────────────────────────
  static const TextStyle badge = TextStyle(
    fontSize: 10.0,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  // ─── Price / Amount ───────────────────────────────────────────────────────
  static const TextStyle price = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    letterSpacing: -0.5,
  );

  // ─── CTA / Button Label ───────────────────────────────────────────────────
  static const TextStyle button = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.2,
    color: Colors.white,
  );
}
