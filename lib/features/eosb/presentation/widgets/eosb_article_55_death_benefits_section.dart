import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/truth_confidence_banner.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';

/// Article 55 — death during employment: court deposit, heirs, repatriation.
/// Informational only; calm presentation for family members.
class EosbArticle55DeathBenefitsSection extends StatelessWidget {
  const EosbArticle55DeathBenefitsSection({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.textSecondary,
      glowIntensity: 0.04,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            EosbStrings.t('eosb_art55_screen_title', locale),
            style: AppTypography.subtitle.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            EosbStrings.t('eosb_art55_screen_subtitle', locale),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TruthConfidenceBanner(
            locale: locale,
            state: TruthConfidenceState.known,
            text: EosbStrings.t('eosb_art55_deposit_known', locale),
          ),
          const SizedBox(height: AppSpacing.sm),
          TruthConfidenceBanner(
            locale: locale,
            state: TruthConfidenceState.known,
            text: EosbStrings.t('eosb_art55_report_known', locale),
          ),
          const SizedBox(height: AppSpacing.sm),
          TruthConfidenceBanner(
            locale: locale,
            state: TruthConfidenceState.known,
            text: EosbStrings.t('eosb_art55_gratuity_known', locale),
          ),
          const SizedBox(height: AppSpacing.sm),
          TruthConfidenceBanner(
            locale: locale,
            state: TruthConfidenceState.known,
            text: EosbStrings.t('eosb_art55_distribution_known', locale),
          ),
          const SizedBox(height: AppSpacing.sm),
          TruthConfidenceBanner(
            locale: locale,
            state: TruthConfidenceState.known,
            text: EosbStrings.t('eosb_art55_unclaimed_known', locale),
          ),
          const SizedBox(height: AppSpacing.sm),
          TruthConfidenceBanner(
            locale: locale,
            state: TruthConfidenceState.known,
            text: EosbStrings.t('eosb_art55_repatriation_known', locale),
          ),
          const SizedBox(height: AppSpacing.sm),
          TruthConfidenceBanner(
            locale: locale,
            state: TruthConfidenceState.known,
            text: EosbStrings.t('eosb_art55_repatriation_failure_known', locale),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            EosbStrings.t('eosb_art55_work_related_title', locale),
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          TruthConfidenceBanner(
            locale: locale,
            state: TruthConfidenceState.possible,
            text: EosbStrings.t('eosb_art55_work_related_body', locale),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            EosbStrings.t('eosb_art55_family_section_title', locale),
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          TruthConfidenceBanner(
            locale: locale,
            state: TruthConfidenceState.action,
            text: EosbStrings.t('eosb_art55_family_action', locale),
          ),
          const SizedBox(height: AppSpacing.sm),
          TruthConfidenceBanner(
            locale: locale,
            state: TruthConfidenceState.possible,
            text: EosbStrings.t('eosb_art55_wsif_crossref', locale),
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () => context.push('/eosb/warnings'),
              child: Text(
                EosbStrings.t('eosb_art55_wsif_link', locale),
                textAlign: TextAlign.start,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TruthConfidenceBanner(
            locale: locale,
            state: TruthConfidenceState.unknown,
            text: EosbStrings.t('eosb_art55_unknown', locale),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            EosbStrings.t('eosb_art55_disclaimer', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
