import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/legal_reference_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/legal_reference_disclosure.dart';
import 'package:raabta/core/widgets/truth_confidence_banner.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_engine_type.dart';
import 'package:raabta/features/case_timeline/presentation/navigation/case_timeline_navigation.dart';
import 'package:raabta/features/case_timeline/presentation/widgets/case_timeline_link_button.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/domain/rules/dismissal_dispute_assessment.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/truth_engine/presentation/truth_engine_status_colors.dart';

/// Separate from gratuity hero — neutral dismissal review outcome only.
class EosbArticle62ResultSection extends StatelessWidget {
  const EosbArticle62ResultSection({
    super.key,
    required this.locale,
    required this.input,
    required this.result,
  });

  final String locale;
  final EosbEmployeeInput input;
  final EosbResult result;

  @override
  Widget build(BuildContext context) {
    final outcome = DismissalDisputeAssessment.evaluate(input);
    if (outcome != EosbDismissalReviewOutcome.factsWorthReviewing) {
      return const SizedBox.shrink();
    }

    final caseId = CaseTimelineNavigation.eosbCaseIdFromCalculatedAt(
      result.calculatedAt,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        glowColor: AppColors.cyanGlow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.fact_check_outlined,
                  color: AppColors.cyanGlow,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    EosbStrings.t('eosb_art62_result_section_title', locale),
                    style: AppTypography.subtitle.copyWith(
                      color: AppColors.cyanGlow,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              EosbStrings.t('eosb_art62_result_section_sub', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TruthConfidenceBanner(
              locale: locale,
              state: TruthConfidenceState.action,
              engine: TruthEngineFamily.eosb,
              text: EosbStrings.t('eosb_art62_action', locale),
            ),
            LegalReferenceDisclosure(
              key: const ValueKey('eosb_art62_legal'),
              locale: locale,
              sourceKind: TruthEngineSourceKind.eosb,
              citationPreview: LegalReferenceStrings.format(
                'legal_reference_item_count',
                locale,
                {'count': '5'},
              ),
              children: [
                TruthConfidenceBanner(
                  locale: locale,
                  state: TruthConfidenceState.known,
                  text: EosbStrings.t('eosb_art62_known', locale),
                ),
                const SizedBox(height: AppSpacing.sm),
                TruthConfidenceBanner(
                  locale: locale,
                  state: TruthConfidenceState.possible,
                  text: EosbStrings.t('eosb_dismissal_review_art61_info', locale),
                ),
                const SizedBox(height: AppSpacing.sm),
                TruthConfidenceBanner(
                  locale: locale,
                  state: TruthConfidenceState.possible,
                  text: EosbStrings.t('eosb_dismissal_review_art62_info', locale),
                ),
                const SizedBox(height: AppSpacing.sm),
                TruthConfidenceBanner(
                  locale: locale,
                  state: TruthConfidenceState.possible,
                  text: EosbStrings.t('eosb_dismissal_review_art64_info', locale),
                ),
                const SizedBox(height: AppSpacing.sm),
                TruthConfidenceBanner(
                  locale: locale,
                  state: TruthConfidenceState.unknown,
                  text: EosbStrings.t('eosb_art62_unknown', locale),
                ),
              ],
            ),
            if (caseId.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              CaseTimelineLinkButton(
                engine: CaseTimelineEngineType.eosb,
                caseId: caseId,
                locale: locale,
                eosbIncludeSettlement: result.comparison != null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
