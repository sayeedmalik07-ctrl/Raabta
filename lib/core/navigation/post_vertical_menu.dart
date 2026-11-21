import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/icons/post_vertical_icons.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';

/// Shared Post Engine vertical menu entries (Speed-Dial order preserved).
class PostVerticalMenuEntry {
  const PostVerticalMenuEntry({
    required this.vertical,
    required this.icon,
    required this.labelKey,
    required this.accentColor,
  });

  final PostVertical vertical;
  final IconData icon;
  final String labelKey;
  final Color accentColor;
}

abstract final class PostVerticalMenu {
  static const mainButtonSize = 56.0;
  static const navOverlap = 16.0;
  static const centerSlotWidth = 72.0;
  static const pillHeight = 48.0;
  static const pillMaxWidth = 280.0;

  static final entries = [
    PostVerticalMenuEntry(
      vertical: PostVertical.housing,
      icon: PostVerticalIcons.forVertical(PostVertical.housing),
      labelKey: 'home_post_dial_housing',
      accentColor: AppColors.tealGlow,
    ),
    PostVerticalMenuEntry(
      vertical: PostVertical.jobs,
      icon: PostVerticalIcons.forVertical(PostVertical.jobs),
      labelKey: 'home_post_dial_jobs',
      accentColor: AppColors.cyanGlow,
    ),
    PostVerticalMenuEntry(
      vertical: PostVertical.business,
      icon: PostVerticalIcons.forVertical(PostVertical.business),
      labelKey: 'home_post_dial_business',
      accentColor: AppColors.blueGlow,
    ),
    PostVerticalMenuEntry(
      vertical: PostVertical.services,
      icon: PostVerticalIcons.forVertical(PostVertical.services),
      labelKey: 'home_post_dial_services',
      accentColor: AppColors.iceCyanGlow,
    ),
    PostVerticalMenuEntry(
      vertical: PostVertical.marketplace,
      icon: PostVerticalIcons.forVertical(PostVertical.marketplace),
      labelKey: 'home_post_dial_marketplace',
      accentColor: AppColors.emeraldGlow,
    ),
  ];

  static String labelFor(PostVerticalMenuEntry entry, String locale) =>
      AppShellStrings.t(entry.labelKey, locale);

  static PostVerticalMenuEntry entryFor(PostVertical vertical) =>
      entries.firstWhere((e) => e.vertical == vertical);

  /// Bottom inset for the center FAB in [FloatingNavBar]'s outer stack.
  static double fabBottomInset() =>
      AppSpacing.navBottomMargin +
      AppSpacing.navHeight / 2 -
      mainButtonSize / 2;

  /// Bottom inset for the vertical pill column — clears nav bar + raised FAB.
  ///
  /// Lowest pill (Housing) must sit above the glass nav and the 56dp center
  /// button that overlaps the bar top edge.
  static double pillMenuBottomInset() {
    final navTop = AppSpacing.navBottomMargin + AppSpacing.navHeight;
    final fabProtrusionAboveNav = mainButtonSize - navOverlap;
    return navTop + fabProtrusionAboveNav + AppSpacing.md;
  }

  /// Total height of the five stacked pills (for small-screen checks).
  static double get pillColumnHeight =>
      entries.length * (pillHeight + AppSpacing.sm);
}
