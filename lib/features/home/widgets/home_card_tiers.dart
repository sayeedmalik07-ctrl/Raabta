import 'package:flutter/material.dart';

import 'package:raabta/core/spacing/app_spacing.dart';

/// Shared visual tiers for Home Screen cards (Phase 2).
abstract final class HomeCardTier {
  HomeCardTier._();

  /// Hero-tier cards: Today focus, compact Expat Score.
  static const double heroGlowIntensity = 0.1;

  /// Calmer Expat Score summary on Home (presentation-only).
  static const double expatScoreGlowIntensity = 0.06;

  /// Standard Home card family radius (16–18dp band).
  static const double homeCardRadius = AppSpacing.radiusMd;

  /// Default restrained glow for standard Home cards.
  static const double homeCardGlowIntensity = 0.06;

  /// Contextual accent glow (Today focus, life events).
  static const double contextualGlowIntensity = 0.08;

  /// Standard content cards: Explore, For You, ScamShield.
  static const double standardGlowIntensity = 0.08;

  /// Tool grid cards: Truth Engines on Home.
  static const double toolGlowIntensity = 0.06;

  /// Natural-glass navigation chips — no accent surface fill.
  static const double navigationSurfaceTintAlpha = 0;

  /// Core Services rail surface glow (cyan/teal emphasis).
  static const double coreServiceGlowIntensity = 0.04;

  /// Qatar Life rail — quieter than Core Services.
  static const double lifestyleChipGlowIntensity = 0.03;

  /// Daily Essentials restrained surface glow.
  static const double dailyEssentialsGlowIntensity = 0.04;

  static const double toolGridExtent = 108;

  /// Truth Engine grid — active / tracked chips.
  static const double truthEngineGridExtent = 156;

  /// Truth Engine invite-only grid — two-line title/subtitle + Start (no dead band).
  static const double truthEngineInviteGridExtent = 132;
  /// Home See-all bottom sheets — matches Qatar Life catalog row height.
  static const double homeCatalogTileExtent = 118;
  static const double toolTitleFontSize = 14;
  static const double standardIconBadgeSize = 40;
  static const double compactIconBadgeSize = 36;

  /// Qatar Life horizontal rail — design kit v2.1 (`.rail .card`).
  static const double qatarLifeRailChipWidth = 132;
  static const double qatarLifeRailChipHeight = 112;
  static const double qatarLifeRailChipRadius = 22;
  static const double qatarLifeRailIconBadge = 40;
  static const double qatarLifeRailIconSize = 20;
  static const double qatarLifeRailLabelFontSize = 14;
  static const double qatarLifeRailFamilyTintAlpha = 0.08;

  /// For You pick rail — design kit v2.1 (`.rail.pk`).
  static const double forYouPickWidth = 210;
  static const double forYouPickHeight = 92;
  static const double forYouRailGap = 10;
  static const double forYouPickFamilyTintAlpha = 0.08;

  /// Send money home rate card — design kit v2.1 (`.card.f.gold.rate`).
  static const double sendMoneyRateLoadingHeight = 168;
  static const double sendMoneyRateSparklineHeight = 46;
  static const double sendMoneyRateBigFontSize = 34;
  static const double sendMoneyRateFamilyTintAlpha = 0.085;

  /// Glance row (Prayer + ScamShield) — kit `.two .card`.
  static const double glanceTileRadius = 20;
  static const double glanceTilePadding = 12;
  static const double glanceTileGap = 12;
  static const double glanceIconBadge = 38;
  static const double glanceIconSize = 19;
  static const double glanceIconChipRadius = 12;
  static const double glanceTitleFontSize = 14;
  static const double glanceDenseTitleFontSize = 13;
  static const double glanceDenseSubtitleFontSize = 11;
  static const double glanceFamilyTintAlpha = 0.08;

  /// Daily Essentials cmp stack — design kit v2.1.
  static const double dailyEssentialTileRadius = 16;
  static const double dailyEssentialTileGap = 8;
  static const double dailyEssentialTilePadding = 10;

  /// Vertical inset — with 36dp icon yields ~64dp row (normal text scale).
  static const double dailyEssentialTilePaddingVertical = 12;
  static const double dailyEssentialIconBadge = 36;
  static const double dailyEssentialIconSize = 18;
  static const double dailyEssentialIconChipRadius = 12;
  static const double dailyEssentialTitleFontSize = 14;

  /// Grouped Daily Essentials list row (Batch G — single surface).
  static const double dailyEssentialGroupedRowHeight = 60;

  /// Legacy bounds — prefer [dailyEssentialGroupedRowHeight].
  static const double dailyEssentialRowMinHeight = dailyEssentialGroupedRowHeight;
  static const double dailyEssentialRowMaxHeight = dailyEssentialGroupedRowHeight;

  /// Lifestyle rails (Qatar Life) — default chip footprint.
  static const double lifestyleChipWidth = 92;
  static const double lifestyleChipHeight = 96;
  static const double lifestyleChipIconBadge = 36;
  static const double lifestyleChipIconSize = 20;
  static const double lifestyleChipLabelFontSize = 11;

  /// Core Services (Explore) — kit `.grid3` tile footprint.
  static const double coreServiceChipWidth = 100;
  /// Min height 96 — 40dp badge + 2-line 12.5sp labels (kit §10).
  static const double coreServiceChipHeight = 96;
  static const double coreServiceIconBadge = 40;
  static const double coreServiceIconSize = 22;
  static const double coreServiceLabelFontSize = 12.5;

  /// Explore grid — design kit v2.1 (does not change global [homeCardRadius]).
  static const double coreServicesGridGap = 12;
  static const double coreServiceTileRadius = 20;
  static const double coreServiceIconChipRadius = 14;
  /// Kit horizontal 6; vertical tightened so 96dp fits 40dp badge + 2-line label.
  static const EdgeInsets coreServiceExploreTilePadding =
      EdgeInsets.fromLTRB(6, 8, 6, 8);
  static const double coreServiceExploreIconLabelGap = 8;
}

/// Vertical rhythm between Home zones (kit v2.1 / polish round 4).
abstract final class HomeZoneSpacing {
  HomeZoneSpacing._();

  /// Horizontal inset for Home section headers and content (matches screen gutter).
  static const double sectionHorizontalPadding = AppSpacing.screenHorizontalPadding;

  /// Space under a section title before its content.
  static const double afterSectionHeader = 12;

  /// Space between major Home sections.
  static const double betweenZones = 28;

  /// Hero card → Prayer / ScamShield glance row.
  static const double afterHero = 14;

  static const double withinTrustGroup = AppSpacing.md;
}
