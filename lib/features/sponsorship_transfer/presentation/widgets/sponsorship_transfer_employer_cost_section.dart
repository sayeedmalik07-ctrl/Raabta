import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/legal_reference_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/legal_reference_disclosure.dart';
import 'package:raabta/core/widgets/truth_confidence_banner.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/l10n/sponsorship_transfer_strings.dart';

/// Employer-to-employer transfer cost context — informational only, no calculator.
class SponsorshipTransferEmployerCostSection extends StatelessWidget {
  const SponsorshipTransferEmployerCostSection({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.chipSponsorshipTransfer,
      glowIntensity: 0.08,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            SponsorshipTransferStrings.t('st_employer_cost_section_title', locale),
            style: AppTypography.subtitle.copyWith(
              color: AppColors.chipSponsorshipTransfer,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            SponsorshipTransferStrings.t('st_employer_cost_section_subtitle', locale),
            style: AppTypography.bodySmall,
          ),
          LegalReferenceDisclosure(
            locale: locale,
            sourceKind: TruthEngineSourceKind.sponsorshipTransfer,
            citationPreview: LegalReferenceStrings.format(
              'legal_reference_item_count',
              locale,
              {'count': '4'},
            ),
            children: [
              TruthConfidenceBanner(
                locale: locale,
                state: TruthConfidenceState.known,
                text: SponsorshipTransferStrings.t(
                  'st_employer_cost_recruitment_known',
                  locale,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TruthConfidenceBanner(
                locale: locale,
                state: TruthConfidenceState.known,
                text: SponsorshipTransferStrings.t(
                  'st_employer_cost_return_flight_known',
                  locale,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TruthConfidenceBanner(
                locale: locale,
                state: TruthConfidenceState.possible,
                text: SponsorshipTransferStrings.t(
                  'st_employer_cost_delay_possible',
                  locale,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TruthConfidenceBanner(
                locale: locale,
                state: TruthConfidenceState.unknown,
                text: SponsorshipTransferStrings.t('st_employer_cost_unknown', locale),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
