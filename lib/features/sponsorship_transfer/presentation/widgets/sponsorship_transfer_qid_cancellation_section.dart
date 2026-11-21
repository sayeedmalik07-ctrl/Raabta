import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/truth_confidence_banner.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/l10n/sponsorship_transfer_strings.dart';

/// Urgent QID cancellation guidance — separate from the voluntary employer-change readiness flow.
class SponsorshipTransferQidCancellationSection extends StatelessWidget {
  const SponsorshipTransferQidCancellationSection({
    super.key,
    required this.locale,
  });

  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.errorBright,
      glowIntensity: 0.28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emergency_outlined, color: AppColors.errorBright),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  SponsorshipTransferStrings.t(
                    'st_qid_cancel_urgency_badge',
                    locale,
                  ),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.errorBright,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            SponsorshipTransferStrings.t('st_qid_cancel_section_title', locale),
            style: AppTypography.subtitle.copyWith(
              color: AppColors.errorBright,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            SponsorshipTransferStrings.t('st_qid_cancel_section_subtitle', locale),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            SponsorshipTransferStrings.t('st_qid_cancel_countdown_heading', locale),
            style: AppTypography.title.copyWith(fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.sm),
          TruthConfidenceBanner(
            locale: locale,
            state: TruthConfidenceState.known,
            text: SponsorshipTransferStrings.t(
              'st_qid_cancel_countdown_known',
              locale,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TruthConfidenceBanner(
            locale: locale,
            state: TruthConfidenceState.action,
            text: SponsorshipTransferStrings.t(
              'st_qid_cancel_countdown_action',
              locale,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          TruthConfidenceBanner(
            locale: locale,
            state: TruthConfidenceState.unknown,
            text: SponsorshipTransferStrings.t(
              'st_qid_cancel_countdown_unknown',
              locale,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            SponsorshipTransferStrings.t(
              'st_qid_cancel_active_transfer_heading',
              locale,
            ),
            style: AppTypography.title.copyWith(fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.sm),
          TruthConfidenceBanner(
            locale: locale,
            state: TruthConfidenceState.known,
            text: SponsorshipTransferStrings.t(
              'st_qid_cancel_active_transfer_known',
              locale,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          TruthConfidenceBanner(
            locale: locale,
            state: TruthConfidenceState.action,
            text: SponsorshipTransferStrings.t(
              'st_qid_cancel_active_transfer_action',
              locale,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            SponsorshipTransferStrings.t(
              'st_qid_cancel_employer_closure_heading',
              locale,
            ),
            style: AppTypography.title.copyWith(fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.sm),
          TruthConfidenceBanner(
            locale: locale,
            state: TruthConfidenceState.known,
            text: SponsorshipTransferStrings.t(
              'st_qid_cancel_employer_closure_known',
              locale,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TruthConfidenceBanner(
            locale: locale,
            state: TruthConfidenceState.action,
            text: SponsorshipTransferStrings.t(
              'st_qid_cancel_employer_closure_action',
              locale,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TruthConfidenceBanner(
            locale: locale,
            state: TruthConfidenceState.possible,
            text: SponsorshipTransferStrings.t(
              'st_qid_cancel_scenarios_note',
              locale,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: () => context.push('/eosb/warnings'),
            icon: const Icon(Icons.open_in_new, size: 18),
            label: Text(
              SponsorshipTransferStrings.t('st_qid_cancel_wsif_link', locale),
              textAlign: TextAlign.start,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            SponsorshipTransferStrings.t('st_qid_cancel_disclaimer', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
