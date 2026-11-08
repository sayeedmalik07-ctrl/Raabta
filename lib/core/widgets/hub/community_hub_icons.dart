import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/icons/raabta_icons.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/hub/community_hub_accent.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';

/// Community hub icon grammar — teal social chips, brand chrome (kit §3–4).
abstract final class CommunityHubIcons {
  static const double sectionChipSize = 40;
  static const double sectionGlyphSize = 22;
  static const double actionGlyphSize = RaabtaIcons.gridSize;
  static const double emptyStateChipSize = 52;
  static const double emptyStateGlyphSize = 26;
  static const double ctaChipSize = 28;
  static const double ctaGlyphSize = 16;

  static Widget sectionChip(
    IconData icon, {
    Color? accent,
    HomeIconBadgeVariant variant = HomeIconBadgeVariant.tealBrand,
  }) {
    final color = accent ?? communityHubAccent;
    return HomeIconBadge(
      icon: icon,
      accentColor: color,
      size: sectionChipSize,
      iconSize: sectionGlyphSize,
      variant: variant,
      chipBorderRadius: HomeCardTier.coreServiceIconChipRadius,
    );
  }

  static Widget emptyStateChip(
    IconData icon, {
    bool brand = false,
  }) {
    if (brand) {
      return HomeIconBadge(
        icon: icon,
        accentColor: AppColors.brandFamilyMain,
        size: emptyStateChipSize,
        iconSize: emptyStateGlyphSize,
        variant: HomeIconBadgeVariant.exploreBrand,
        chipBorderRadius: AppSpacing.radiusLg,
      );
    }
    return HomeIconBadge(
      icon: icon,
      accentColor: communityHubAccent,
      size: emptyStateChipSize,
      iconSize: emptyStateGlyphSize,
      variant: HomeIconBadgeVariant.tealBrand,
      chipBorderRadius: AppSpacing.radiusLg,
    );
  }

  static Widget ctaLeading(IconData icon) {
    return HomeIconBadge(
      icon: icon,
      accentColor: AppColors.brandFamilyMain,
      size: ctaChipSize,
      iconSize: ctaGlyphSize,
      variant: HomeIconBadgeVariant.exploreBrand,
      chipBorderRadius: AppSpacing.radiusSm,
    );
  }

  static Widget actionGlyph(
    IconData icon, {
    Color? color,
    bool active = false,
    double? size,
  }) {
    return Icon(
      icon,
      size: size ?? actionGlyphSize,
      color: color ??
          (active ? communityHubAccentText : AppColors.textSecondary),
    );
  }

  static Widget composerSend({Color? color}) {
    return actionGlyph(
      Icons.send_rounded,
      color: color ?? AppColors.brandFamilyMain,
    );
  }
}
