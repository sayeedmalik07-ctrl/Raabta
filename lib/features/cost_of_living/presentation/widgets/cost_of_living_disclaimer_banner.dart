import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/cost_of_living/domain/cost_of_living_constants.dart';

class CostOfLivingDisclaimerBanner extends StatelessWidget {
  const CostOfLivingDisclaimerBanner({super.key, this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppSpacing.radiusLg,
      backgroundColor: AppColors.warning.withValues(alpha: 0.1),
      glowColor: AppColors.warning,
      glowIntensity: 0.08,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text ?? CostOfLivingConstants.disclaimer,
              style: AppTypography.bodySmall.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}

class CostOfLivingDataAsOfChip extends StatelessWidget {
  const CostOfLivingDataAsOfChip({
    super.key,
    required this.cpiLabel,
    this.qolLabel,
  });

  final String cpiLabel;
  final String? qolLabel;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      borderRadius: AppSpacing.radiusLg,
      glowColor: AppColors.cyanGlow,
      glowIntensity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: AppColors.cyanGlow),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Data as of $cpiLabel',
                style: AppTypography.chipLabel.copyWith(
                  color: AppColors.cyanGlow,
                ),
              ),
            ],
          ),
          if (qolLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              'Quality of Life Index: $qolLabel',
              style: AppTypography.caption,
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'Official NPC / data.gov.qa — not real-time',
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
