import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/legal_reference_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/legal_reference_disclosure.dart';
import 'package:raabta/core/widgets/truth_confidence_banner.dart';
import 'package:raabta/features/truth_engine/presentation/truth_engine_status_colors.dart';
import 'package:raabta/features/tenancy/presentation/l10n/tenancy_strings.dart';

/// Shared accommodation / subletting reality check — informational only.
class TenancySharedHousingSection extends StatelessWidget {
  const TenancySharedHousingSection({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.chipLease,
      glowIntensity: 0.08,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TenancyStrings.t('tenancy_shared_housing_section_title', locale),
            style: AppTypography.subtitle.copyWith(color: AppColors.chipLease),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            TenancyStrings.t('tenancy_shared_housing_section_subtitle', locale),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            TenancyStrings.t('tenancy_shared_housing_partition_warning', locale),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TruthConfidenceBanner(
            locale: locale,
            state: TruthConfidenceState.action,
            engine: TruthEngineFamily.tenancy,
            text: TenancyStrings.t('tenancy_shared_housing_subtenant_action', locale),
          ),
          LegalReferenceDisclosure(
            key: const ValueKey('tenancy_shared_housing_legal'),
            locale: locale,
            sourceKind: TruthEngineSourceKind.tenancy,
            citationPreview: LegalReferenceStrings.format(
              'legal_reference_item_count',
              locale,
              {'count': '3'},
            ),
            children: [
              TruthConfidenceBanner(
                locale: locale,
                state: TruthConfidenceState.known,
                text: TenancyStrings.t('tenancy_shared_housing_distinction_known', locale),
              ),
              const SizedBox(height: AppSpacing.sm),
              TruthConfidenceBanner(
                locale: locale,
                state: TruthConfidenceState.known,
                text: TenancyStrings.t('tenancy_shared_housing_md105_known', locale),
              ),
              const SizedBox(height: AppSpacing.sm),
              TruthConfidenceBanner(
                locale: locale,
                state: TruthConfidenceState.unknown,
                text: TenancyStrings.t('tenancy_shared_housing_unknown', locale),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
