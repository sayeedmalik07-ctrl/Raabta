import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';

/// Kit ContentTrustTier chip (Community PostCard header).
enum HubContentTrustTier {
  official,
  verified,
  community,
  /// Raabta-derived / AI summary signal (brand tint).
  aiDerived,
}

/// Trust tier badge for community posts (distinct from job source tier).
class HubContentTrustTierBadge extends StatelessWidget {
  const HubContentTrustTierBadge({
    super.key,
    required this.label,
    required this.tier,
  });

  final String label;
  final HubContentTrustTier tier;

  static const _tintAlpha = 0.16;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (tier) {
      HubContentTrustTier.official => (
          AppColors.brandFamilyMain.withValues(alpha: _tintAlpha),
          AppColors.brandFamilyText,
        ),
      HubContentTrustTier.verified => (
          AppColors.greenFamilyMain.withValues(alpha: _tintAlpha),
          AppColors.greenFamilyMain,
        ),
      HubContentTrustTier.community => (
          AppColors.textPrimary.withValues(alpha: _tintAlpha),
          AppColors.textSecondary,
        ),
      HubContentTrustTier.aiDerived => (
          AppColors.brandFamilyMain.withValues(alpha: _tintAlpha),
          AppColors.brandFamilyText,
        ),
    };

    return Container(
      height: HubLayoutTokens.trustBadgeHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(HubLayoutTokens.trustBadgeRadius),
        border: tier == HubContentTrustTier.community
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
