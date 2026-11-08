import 'package:flutter/material.dart';

import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/utils/home_directional_icons.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';

/// Shared glance-row card shell — kit `.two .card` (Prayer + ScamShield).
class HomeGlanceAnchorShell extends StatelessWidget {
  const HomeGlanceAnchorShell({
    super.key,
    required this.familyMain,
    required this.icon,
    required this.iconVariant,
    this.iconAccent,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showLivePulse = false,
    this.denseSingleLine = false,
    required this.onTap,
  });

  final Color familyMain;
  final IconData icon;
  final HomeIconBadgeVariant iconVariant;
  final Color? iconAccent;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showLivePulse;
  final bool denseSingleLine;
  final VoidCallback onTap;

  /// Compact glance tiles keep smaller type but still allow two lines before ellipsis.
  int get _titleMaxLines => 2;

  int get _subtitleMaxLines => 2;

  double get _titleFontSize => denseSingleLine
      ? HomeCardTier.glanceDenseTitleFontSize
      : HomeCardTier.glanceTitleFontSize;

  double get _subtitleFontSize => denseSingleLine
      ? HomeCardTier.glanceDenseSubtitleFontSize
      : 12;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HomeCardTier.glanceTileRadius),
        child: GlassContainer(
          padding: const EdgeInsets.all(HomeCardTier.glanceTilePadding),
          borderRadius: HomeCardTier.glanceTileRadius,
          glowColor: familyMain,
          glowIntensity: 0.04,
          backgroundColor: familyMain.withValues(
            alpha: HomeCardTier.glanceFamilyTintAlpha,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                HomeIconBadge(
                  icon: icon,
                  accentColor: iconAccent ?? familyMain,
                  size: HomeCardTier.glanceIconBadge,
                  iconSize: HomeCardTier.glanceIconSize,
                  variant: iconVariant,
                  chipBorderRadius: HomeCardTier.glanceIconChipRadius,
                ),
                SizedBox(width: denseSingleLine ? 8 : 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTypography.chipLabel.copyWith(
                          fontSize: _titleFontSize,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: _titleMaxLines,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (showLivePulse) ...[
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: familyMain,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Expanded(
                              child: Text(
                                subtitle!,
                                style: AppTypography.bodySmall.copyWith(
                                  fontSize: _subtitleFontSize,
                                  height: 1.35,
                                  color: showLivePulse
                                      ? AppColors.tealFamilyText
                                      : AppColors.textOnGlassMuted,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                                maxLines: _subtitleMaxLines,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  trailing!,
                ] else ...[
                  SizedBox(width: denseSingleLine ? 2 : AppSpacing.xxs),
                  Icon(
                    HomeDirectionalIcons.forwardChevron(context),
                    size: denseSingleLine ? AppSpacing.iconSm : AppSpacing.iconSm + 2,
                    color: familyMain,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
