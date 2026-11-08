import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';

/// Shared Global Search presentation tokens (Home + Hub kit).
abstract final class GlobalSearchPresentationTokens {
  static const cardRadius = AppRadius.xxl;
  static const cardPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.sm + 2,
  );
  static const sectionBottomGap = AppSpacing.lg;
  static const rowGap = AppSpacing.sm;
  static const iconChipSize = HomeCardTier.coreServiceIconBadge;
  static const iconChipRadius = HomeCardTier.coreServiceIconChipRadius;

  static Color categoryAccent(GlobalSearchCategory category) {
    return switch (category) {
      GlobalSearchCategory.money ||
      GlobalSearchCategory.exchange =>
        AppColors.goldFamilyMain,
      GlobalSearchCategory.community ||
      GlobalSearchCategory.mosques =>
        AppColors.tealFamilyMain,
      GlobalSearchCategory.actions =>
        AppColors.brandFamilyMain,
      _ => AppColors.brandFamilyMain,
    };
  }

  static TextStyle sectionTitleStyle = AppTypography.title.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static TextStyle overlineStyle = AppTypography.bodySmall.copyWith(
    color: AppColors.textOnGlassMuted,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
  );
}
