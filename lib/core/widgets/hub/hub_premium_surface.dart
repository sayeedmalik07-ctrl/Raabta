import 'package:flutter/material.dart';

import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';

/// Brand-tinted surface tokens for hub summary / quick-action tiles (Home kit §3).
abstract final class HubPremiumSurface {
  /// Summary strip card radius (Home kit card 24).
  static const double summaryCardRadius = AppSpacing.radiusLg;

  /// Compact hub quick-action tile radius (Home kit tile 16).
  static const double quickActionTileRadius =
      HomeCardTier.dailyEssentialTileRadius;

  static double get brandGlowIntensity => HomeCardTier.standardGlowIntensity;

  static Color brandFamilyTint() => AppColors.brandFamilyMain.withValues(
        alpha: AppColors.isLight ? 0.06 : 0.08,
      );
}
