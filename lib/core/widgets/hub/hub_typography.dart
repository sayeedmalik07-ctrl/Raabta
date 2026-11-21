import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';

/// Hub landing chrome typography (Hub kit §3–4 HubHeader).
abstract final class HubTypography {
  static TextStyle get hubTitle => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
        height: 1.15,
        color: AppColors.textPrimary,
      );

  static TextStyle get hubSubtitle => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: AppColors.textSecondary,
      );

  /// Notice banner body (Hub kit §4 NoticeBanner).
  static TextStyle get noticeBannerBody => TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: AppColors.textSecondary,
      );
}
