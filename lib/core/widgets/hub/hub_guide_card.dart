import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/hub/hub_premium_surface.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';

/// Visa hub kit §4 — [list] row: gold icon chip ~44, title, meta, law chip, chevron.
///
/// [compact] keeps a denser vertical stack for tight grids or tests.
enum HubGuideCardLayout { list, compact }

/// Guide hub tile — icon, title, optional “law updated” line, optional meta row (steps, ETA).
///
/// Compose [lawUpdatedLabel] from [LegalFreshnessIndicator] / legal_sources dates at call site.
class HubGuideCard extends StatelessWidget {
  const HubGuideCard({
    super.key,
    required this.icon,
    required this.title,
    this.lawUpdatedLabel,
    this.metaLine,
    this.accentColor,
    this.onTap,
    this.layout = HubGuideCardLayout.list,
  });

  final IconData icon;
  final String title;
  final String? lawUpdatedLabel;
  final String? metaLine;
  final Color? accentColor;
  final VoidCallback? onTap;
  final HubGuideCardLayout layout;

  static const double _listIconChipSize = 44;
  static const double _listIconGlyphSize = 22;

  Color get _accent => accentColor ?? AppColors.brandFamilyMain;

  @override
  Widget build(BuildContext context) {
    final goldAccent = AppColors.goldFamilyMain;

    return GlassCard(
      onTap: onTap,
      padding: layout == HubGuideCardLayout.list
          ? const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            )
          : const EdgeInsets.all(AppSpacing.sm),
      borderRadius: layout == HubGuideCardLayout.list
          ? AppSpacing.radiusLg
          : HubPremiumSurface.quickActionTileRadius,
      glowColor: layout == HubGuideCardLayout.list ? goldAccent : _accent,
      glowIntensity: HubPremiumSurface.brandGlowIntensity * 0.85,
      backgroundColor: HubPremiumSurface.brandFamilyTint(),
      child: layout == HubGuideCardLayout.list
          ? _buildListRow(context, goldAccent)
          : _buildCompactColumn(goldAccent),
    );
  }

  Widget _buildListRow(BuildContext context, Color goldAccent) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        HomeIconBadge(
          icon: icon,
          accentColor: goldAccent,
          size: _listIconChipSize,
          iconSize: _listIconGlyphSize,
          variant: HomeIconBadgeVariant.goldBrand,
          chipBorderRadius: HomeCardTier.coreServiceIconChipRadius,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.subtitle.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (metaLine != null && metaLine!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  metaLine!,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textOnGlassMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (lawUpdatedLabel != null && lawUpdatedLabel!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                StatusBadge(
                  label: lawUpdatedLabel!,
                  color: goldAccent,
                  icon: Icons.gavel_outlined,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Icon(
          Directionality.of(context) == TextDirection.rtl
              ? Icons.chevron_left
              : Icons.chevron_right,
          color: AppColors.textSecondary,
          size: 22,
        ),
      ],
    );
  }

  Widget _buildCompactColumn(Color goldAccent) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeIconBadge(
          icon: icon,
          accentColor: _accent,
          size: 40,
          iconSize: 20,
          variant: HomeIconBadgeVariant.standard,
          chipBorderRadius: AppSpacing.radiusSm,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          title,
          style: AppTypography.subtitle.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (lawUpdatedLabel != null && lawUpdatedLabel!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          StatusBadge(
            label: lawUpdatedLabel!,
            color: goldAccent,
            icon: Icons.gavel_outlined,
          ),
        ],
        if (metaLine != null && metaLine!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            metaLine!,
            style: AppTypography.caption.copyWith(
              color: AppColors.textOnGlassMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
