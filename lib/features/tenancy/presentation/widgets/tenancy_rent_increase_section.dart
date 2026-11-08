import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/legal_reference_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/legal_reference_disclosure.dart';
import 'package:raabta/core/widgets/truth_confidence_banner.dart';
import 'package:raabta/features/truth_engine/presentation/truth_engine_status_colors.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_engine_type.dart';
import 'package:raabta/features/case_timeline/presentation/navigation/case_timeline_navigation.dart';
import 'package:raabta/features/case_timeline/presentation/widgets/case_timeline_link_button.dart';
import 'package:raabta/features/tenancy/presentation/l10n/tenancy_strings.dart';

/// Article 10 rent-increase rules and Committee dispute options — informational only.
class TenancyRentIncreaseSection extends StatelessWidget {
  const TenancyRentIncreaseSection({
    super.key,
    required this.locale,
    this.checkedAt,
  });

  final String locale;
  final DateTime? checkedAt;

  @override
  Widget build(BuildContext context) {
    final caseId = checkedAt == null
        ? ''
        : CaseTimelineNavigation.tenancyCaseIdFromCheckedAt(checkedAt!);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.chipLease,
      glowIntensity: 0.08,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TenancyStrings.t('tenancy_rent_increase_section_title', locale),
            style: AppTypography.subtitle.copyWith(color: AppColors.chipLease),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            TenancyStrings.t('tenancy_rent_increase_section_subtitle', locale),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            TenancyStrings.t('tenancy_rent_increase_withhold_warning', locale),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TruthConfidenceBanner(
            locale: locale,
            state: TruthConfidenceState.action,
            engine: TruthEngineFamily.tenancy,
            text: TenancyStrings.t('tenancy_rent_increase_action', locale),
          ),
          LegalReferenceDisclosure(
            locale: locale,
            sourceKind: TruthEngineSourceKind.tenancy,
            citationPreview: LegalReferenceStrings.format(
              'legal_reference_item_count',
              locale,
              {'count': '5'},
            ),
            children: [
              TruthConfidenceBanner(
                locale: locale,
                state: TruthConfidenceState.known,
                text: TenancyStrings.t('tenancy_rent_increase_cap_known', locale),
              ),
              const SizedBox(height: AppSpacing.sm),
              TruthConfidenceBanner(
                locale: locale,
                state: TruthConfidenceState.known,
                text: TenancyStrings.t('tenancy_rent_increase_timing_known', locale),
              ),
              const SizedBox(height: AppSpacing.sm),
              TruthConfidenceBanner(
                locale: locale,
                state: TruthConfidenceState.known,
                text: TenancyStrings.t('tenancy_rent_increase_notice_known', locale),
              ),
              const SizedBox(height: AppSpacing.sm),
              TruthConfidenceBanner(
                locale: locale,
                state: TruthConfidenceState.possible,
                text: TenancyStrings.t('tenancy_rent_increase_benefit_possible', locale),
              ),
              const SizedBox(height: AppSpacing.sm),
              TruthConfidenceBanner(
                locale: locale,
                state: TruthConfidenceState.unknown,
                text: TenancyStrings.t('tenancy_rent_increase_unknown', locale),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                onPressed: () => context.push('/tenancy/checklist'),
                icon: const Icon(Icons.checklist_outlined, size: 18),
                label: Text(
                  TenancyStrings.t('tenancy_rent_increase_checklist_link', locale),
                  textAlign: TextAlign.start,
                ),
              ),
              if (caseId.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                CaseTimelineLinkButton(
                  engine: CaseTimelineEngineType.tenancy,
                  caseId: caseId,
                  locale: locale,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
