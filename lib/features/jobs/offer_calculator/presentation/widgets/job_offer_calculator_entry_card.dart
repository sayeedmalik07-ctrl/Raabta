import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/jobs/offer_calculator/l10n/job_offer_calculator_strings.dart';
import 'package:raabta/features/jobs/offer_calculator/presentation/screens/job_offer_calculator_screen.dart';

/// Jobs hub entry — opt-in calculator, not inline listing comparison.
class JobOfferCalculatorEntryCard extends StatelessWidget {
  const JobOfferCalculatorEntryCard({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        glowColor: AppColors.chipWage,
        glowIntensity: 0.12,
        onTap: () => context.push(JobOfferCalculatorScreen.route()),
        child: Row(
          children: [
            Icon(Icons.calculate_outlined, color: AppColors.chipWage, size: 28),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    JobOfferCalculatorStrings.t('joc_entry_title', locale),
                    style: AppTypography.subtitle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    JobOfferCalculatorStrings.t('joc_entry_subtitle', locale),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
