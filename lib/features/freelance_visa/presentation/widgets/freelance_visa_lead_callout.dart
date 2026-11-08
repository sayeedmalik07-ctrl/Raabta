import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/freelance_visa/presentation/l10n/freelance_visa_strings.dart';

/// Lead fact — no visa officially named "freelance visa"; shown first.
class FreelanceVisaLeadCallout extends StatelessWidget {
  const FreelanceVisaLeadCallout({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.info,
      glowIntensity: 0.18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: AppColors.info, size: 24),
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
                        color: AppColors.info.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.info.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Text(
                        FreelanceVisaStrings.t('fv_lead_badge', locale),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      FreelanceVisaStrings.t('fv_lead_title', locale),
                      style: AppTypography.subtitle.copyWith(
                        color: AppColors.info,
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
            FreelanceVisaStrings.t('fv_lead_body', locale),
            style: AppTypography.bodySmall.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}
