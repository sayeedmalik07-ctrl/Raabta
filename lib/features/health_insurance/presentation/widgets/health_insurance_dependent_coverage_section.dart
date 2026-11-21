import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/legal_reference_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/legal_reference_disclosure.dart';
import 'package:raabta/core/widgets/truth_confidence_banner.dart';
import 'package:raabta/features/health_insurance/presentation/l10n/health_insurance_strings.dart';
import 'package:raabta/features/truth_engine/presentation/truth_engine_status_colors.dart';

/// Addendum to Coverage Reality Check — spouse/children/parent gaps (general info).
class HealthInsuranceDependentCoverageSection extends StatelessWidget {
  const HealthInsuranceDependentCoverageSection({super.key, required this.locale});

  final String locale;

  static const possibleItemKeys = [
    'hi_crc_dependent_possible_item_1',
    'hi_crc_dependent_possible_item_2',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          HealthInsuranceStrings.t('hi_crc_dependent_section_title', locale),
          style: AppTypography.title,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          HealthInsuranceStrings.t('hi_crc_dependent_intro', locale),
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TruthConfidenceBanner(
          locale: locale,
          state: TruthConfidenceState.known,
          text: HealthInsuranceStrings.t('hi_crc_dependent_known', locale),
        ),
        const SizedBox(height: AppSpacing.sm),
        TruthConfidenceBanner(
          locale: locale,
          state: TruthConfidenceState.possible,
          text: HealthInsuranceStrings.t(
            'hi_crc_dependent_possible_framing',
            locale,
          ),
        ),
        LegalReferenceDisclosure(
          locale: locale,
          sourceKind: TruthEngineSourceKind.healthInsurance,
          citationPreview: LegalReferenceStrings.format(
            'legal_reference_item_count',
            locale,
            {'count': '${possibleItemKeys.length}'},
          ),
          children: [
            for (final key in possibleItemKeys)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  '• ${HealthInsuranceStrings.t(key, locale)}',
                  style: AppTypography.bodySmall,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        TruthConfidenceBanner(
          locale: locale,
          state: TruthConfidenceState.action,
          engine: TruthEngineFamily.healthInsurance,
          text: HealthInsuranceStrings.t('hi_crc_dependent_action', locale),
        ),
        const SizedBox(height: AppSpacing.sm),
        TruthConfidenceBanner(
          locale: locale,
          state: TruthConfidenceState.unknown,
          text: HealthInsuranceStrings.t('hi_crc_dependent_unknown', locale),
        ),
      ],
    );
  }
}
