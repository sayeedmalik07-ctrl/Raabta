import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/buying_car/presentation/l10n/buying_car_strings.dart';

/// Lead warning — most consequential private-sale fact, visually prominent.
class BuyingCarCriticalCallout extends StatelessWidget {
  const BuyingCarCriticalCallout({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.errorBright,
      glowIntensity: 0.2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, color: AppColors.errorBright, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.errorBright.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.errorBright.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Text(
                        BuyingCarStrings.t('bc_lead_badge', locale),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.errorBright,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      BuyingCarStrings.t('bc_as_is_title', locale),
                      style: AppTypography.subtitle.copyWith(
                        color: AppColors.errorBright,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            BuyingCarStrings.t('bc_as_is_body', locale),
            style: AppTypography.bodySmall.copyWith(height: 1.45),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            BuyingCarStrings.t('bc_inspection_body', locale),
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
