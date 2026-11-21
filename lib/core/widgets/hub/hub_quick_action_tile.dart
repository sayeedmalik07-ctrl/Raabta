import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/hub/hub_premium_surface.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';

/// DomainCard compact vertical quick action — max 2-line label (hub kit).
class HubQuickActionTile extends StatelessWidget {
  const HubQuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      borderRadius: HubPremiumSurface.quickActionTileRadius,
      glowColor: AppColors.brandFamilyMain,
      glowIntensity: HubPremiumSurface.brandGlowIntensity,
      backgroundColor: HubPremiumSurface.brandFamilyTint(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HomeIconBadge(
            icon: icon,
            accentColor: AppColors.brandFamilyMain,
            size: 40,
            iconSize: 20,
            variant: HomeIconBadgeVariant.exploreBrand,
            chipBorderRadius: HomeCardTier.coreServiceIconChipRadius,
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                label,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
