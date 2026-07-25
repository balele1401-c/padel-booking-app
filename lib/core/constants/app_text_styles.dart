import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App Typography Guidelines based on PRD
class AppTextStyles {
  AppTextStyles._();

  // Heading (Judul Halaman): 20-24px, semi-bold
  static const TextStyle heading = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Subheading (Judul section/card): 16-18px, medium
  static const TextStyle subheading = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Body text: 14px, regular
  static const TextStyle body = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  // Caption/label kecil: 12px, regular
  static const TextStyle caption = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Badge text: 11-12px, bold
  static const TextStyle badge = TextStyle(
    fontSize: 11.0,
    fontWeight: FontWeight.bold,
  );
}
