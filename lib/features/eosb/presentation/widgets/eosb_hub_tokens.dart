import 'package:flutter/material.dart';

import 'package:raabta/features/eosb/presentation/design/eosb_design_tokens.dart';

/// Hub-facing facade over [EosbDesignTokens] (Dashboard, Legal Review).
///
/// Prefer [EosbDesignTokens] in new EOSB code; this type preserves the
/// existing import path until screen migration.
abstract final class EosbHubTokens {
  EosbHubTokens._();

  static const Color purple = EosbDesignBrandColors.purple;
  static const Color gold = EosbDesignBrandColors.gold;
  static const Color cyan = EosbDesignBrandColors.cyan;

  static const double cardRadius = EosbDesignRadii.card;
  static const double tileRadius = EosbDesignRadii.tile;
  static const double iconChipRadius = EosbDesignRadii.iconChip;

  static const double tileMinHeight = EosbDesignHubMetrics.tileMinHeight;
  static const double emptyIconSize = EosbDesignHubMetrics.emptyIconSize;
  static const double iconBadgeSize = EosbDesignHubMetrics.iconBadgeSize;

  static double surfaceGlow(bool enabled) =>
      EosbDesignTokens.glow.surface(enabled);

  static double tileGlow(bool enabled) => EosbDesignTokens.glow.tile(enabled);

  static Color familyTintedSurface() =>
      EosbDesignTokens.brand.tintedGoldSurface();

  static double get primaryCtaGlow => EosbDesignTokens.glow.primaryCta;

  static Color get primaryCtaGradientEnd =>
      EosbDesignBrandColors.purpleGradientEnd;

  static double get exploreChipGlow => EosbDesignTokens.glow.exploreChip;
}
