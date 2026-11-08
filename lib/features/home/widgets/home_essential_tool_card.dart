import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/home/domain/home_chip_status.dart';
import 'package:raabta/features/home/widgets/home_chip_status_line.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';

/// Horizontal-rail tool card used on Home (Truth Engines, Qatar Life, etc.).
class HomeEssentialToolCard extends StatelessWidget {
  const HomeEssentialToolCard({
    super.key,
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.onTap,
    required this.cardWidth,
    required this.rowHeight,
    this.status = const HomeChipStatus.ready(line: ''),
    this.expand = false,
    this.glowIntensity = HomeCardTier.toolGlowIntensity,
    this.surfaceGlowColor = AppColors.cyanGlow,
    this.titleFontSize = 15,
    this.iconBadgeSize = 44,
    this.iconBadgeVariant = HomeIconBadgeVariant.standard,
    this.topAlignedContent = false,
  });

  final IconData icon;
  final String title;
  final Color accentColor;
  final Color surfaceGlowColor;
  final VoidCallback onTap;
  final double cardWidth;
  final double rowHeight;
  final bool expand;
  final double glowIntensity;
  final double titleFontSize;
  final double iconBadgeSize;
  final HomeIconBadgeVariant iconBadgeVariant;
  final HomeChipStatus status;

  /// Catalog tiles: icon and title stack from the top (no [Spacer] gap).
  final bool topAlignedContent;

  @override
  Widget build(BuildContext context) {
    final semanticsLabel = status.isLoading || status.line.isEmpty
        ? title
        : '$title, ${status.line}';
    final card = GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: HomeCardTier.homeCardRadius,
      glowColor: surfaceGlowColor,
      glowIntensity: glowIntensity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          HomeIconBadge(
            icon: icon,
            accentColor: accentColor,
            size: iconBadgeSize,
            variant: iconBadgeVariant,
            chipBorderRadius: iconBadgeVariant == HomeIconBadgeVariant.goldBrand ||
                    iconBadgeVariant == HomeIconBadgeVariant.tealBrand
                ? HomeCardTier.coreServiceIconChipRadius
                : null,
          ),
          SizedBox(height: topAlignedContent ? AppSpacing.sm : 0),
          if (!topAlignedContent) const Spacer(),
          Text(
            title,
            style: AppTypography.title.copyWith(
              fontSize: titleFontSize,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          HomeChipStatusLine.build(status),
        ],
      ),
    );

    if (expand) {
      return Semantics(
        button: true,
        label: semanticsLabel,
        child: SizedBox(height: rowHeight, child: card),
      );
    }

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: SizedBox(
        width: cardWidth,
        height: rowHeight,
        child: card,
      ),
    );
  }
}
