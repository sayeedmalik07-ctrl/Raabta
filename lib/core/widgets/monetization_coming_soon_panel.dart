import 'package:flutter/material.dart';
import 'package:raabta/config/monetization_state.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

/// Intentional unavailable state for monetization screens during HOLD.
class MonetizationHoldBanner extends StatelessWidget {
  const MonetizationHoldBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppSpacing.radiusMd,
      glowColor: AppColors.cyanGlow,
      glowIntensity: 0.1,
      backgroundColor: AppColors.cyanGlow.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Currently free',
            style: AppTypography.subtitle.copyWith(
              color: AppColors.cyanGlow,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            MonetizationState.freeGrowthMessage,
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}

class MonetizationComingSoonPanel extends StatelessWidget {
  const MonetizationComingSoonPanel({
    super.key,
    required this.productName,
    required this.plannedPriceLabel,
    this.subtitle,
    this.accentColor = AppColors.amberGlow,
  });

  final String productName;
  final String plannedPriceLabel;
  final String? subtitle;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppSpacing.radiusSm,
      glowColor: accentColor,
      glowIntensity: 0.15,
      backgroundColor: accentColor.withValues(alpha: 0.12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'COMING SOON',
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            productName,
            textAlign: TextAlign.center,
            style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            plannedPriceLabel,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: AppTypography.caption,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Not available yet — planned for a future update.',
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
