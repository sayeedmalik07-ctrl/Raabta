import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';

/// Kit source-tier badge for JobCard (Verified employer / Community post).
enum HubJobSourceTier {
  verifiedEmployer,
  communityPost,
}

class HubSourceTierBadge extends StatelessWidget {
  const HubSourceTierBadge({
    super.key,
    required this.label,
    required this.tier,
  });

  final String label;
  final HubJobSourceTier tier;

  static const _tintAlpha = 0.16;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (tier) {
      HubJobSourceTier.verifiedEmployer => (
          AppColors.greenFamilyMain.withValues(alpha: _tintAlpha),
          AppColors.greenFamilyMain,
        ),
      HubJobSourceTier.communityPost => (
          AppColors.textPrimary.withValues(alpha: _tintAlpha),
          AppColors.textSecondary,
        ),
    };

    return Container(
      height: HubLayoutTokens.trustBadgeHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(HubLayoutTokens.trustBadgeRadius),
        border: tier == HubJobSourceTier.communityPost
            ? Border.all(color: AppColors.glassBorder)
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: HubLayoutTokens.trustBadgeFontSize,
          fontWeight: FontWeight.w700,
          height: 1.0,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
