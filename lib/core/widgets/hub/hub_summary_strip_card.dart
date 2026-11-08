import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/hub/hub_premium_surface.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';

/// Summary strip metric card (icon chip 36, value 14sp/700, label 12sp).
class HubSummaryStripCard extends StatelessWidget {
  const HubSummaryStripCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String value;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: HubPremiumSurface.summaryCardRadius,
      glowColor: AppColors.brandFamilyMain,
      glowIntensity: HubPremiumSurface.brandGlowIntensity,
      backgroundColor: HubPremiumSurface.brandFamilyTint(),
      child: Row(
        children: [
          HomeIconBadge(
            icon: icon,
            accentColor: AppColors.brandFamilyMain,
            size: 36,
            iconSize: 18,
            variant: HomeIconBadgeVariant.exploreBrand,
            chipBorderRadius: AppSpacing.radiusSm,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTypography.subtitle.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
