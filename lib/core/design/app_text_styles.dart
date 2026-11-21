import 'package:flutter/material.dart';
import 'package:raabta/core/design/app_colors.dart';

class AppTextStyles {
  static const String fontFamily = 'Inter';

  static TextStyle get displayLarge => TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        height: 1.2,
        fontFamily: fontFamily,
      );

  static TextStyle get displayMedium => TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        height: 1.2,
        fontFamily: fontFamily,
      );

  static TextStyle get h1 => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        fontFamily: fontFamily,
      );

  static TextStyle get h2 => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        fontFamily: fontFamily,
      );

  static TextStyle get h3 => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        fontFamily: fontFamily,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        fontFamily: fontFamily,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        fontFamily: fontFamily,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
        fontFamily: fontFamily,
      );

  static TextStyle get labelLarge => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: 0.5,
        fontFamily: fontFamily,
      );

  static TextStyle get labelSmall => TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 1.5,
        fontFamily: fontFamily,
      );

  static TextStyle get scoreNumber => TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: AppColors.primary,
        height: 1.0,
        fontFamily: fontFamily,
      );
}
