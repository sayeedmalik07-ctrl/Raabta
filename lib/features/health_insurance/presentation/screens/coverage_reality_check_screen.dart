import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/l10n/legal_reference_strings.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/legal_reference_disclosure.dart';
import 'package:raabta/core/widgets/truth_confidence_banner.dart';
import 'package:raabta/features/health_insurance/presentation/l10n/health_insurance_strings.dart';
import 'package:raabta/features/health_insurance/presentation/providers/health_insurance_providers.dart';
import 'package:raabta/features/health_insurance/presentation/widgets/health_insurance_dependent_coverage_section.dart';
import 'package:raabta/features/truth_engine/presentation/truth_engine_status_colors.dart';
import 'package:raabta/features/health_insurance/presentation/widgets/health_insurance_widgets.dart';

/// Pre-emptive coverage gap guide — general patterns to verify, not a policy review.
class CoverageRealityCheckScreen extends ConsumerWidget {
  const CoverageRealityCheckScreen({super.key});

  static const actionItemKeys = [
    'hi_crc_action_item_1',
    'hi_crc_action_item_2',
    'hi_crc_action_item_3',
    'hi_crc_action_item_4',
    'hi_crc_action_item_5',
  ];

  static const possibleItemKeys = [
    'hi_crc_possible_item_1',
    'hi_crc_possible_item_2',
    'hi_crc_possible_item_3',
    'hi_crc_possible_item_4',
    'hi_crc_possible_item_5',
    'hi_crc_possible_item_6',
    'hi_crc_possible_item_7',
    'hi_crc_possible_item_8',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(healthInsuranceLocaleProvider);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        return GlassScreenScaffold(
          title: HealthInsuranceStrings.t('hi_crc_title', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              Text(
                HealthInsuranceStrings.t('hi_crc_subtitle', locale),
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              HealthInsuranceDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.md),
              Text(
                HealthInsuranceStrings.t('hi_crc_intro', locale),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TruthConfidenceBanner(
                locale: locale,
                state: TruthConfidenceState.known,
                text: HealthInsuranceStrings.t('hi_crc_known_body', locale),
              ),
              LegalReferenceDisclosure(
                locale: locale,
                sourceKind: TruthEngineSourceKind.healthInsurance,
                citationPreview: HealthInsuranceStrings.t(
                  'hi_crc_legal_known_note',
                  locale,
                ),
                children: [
                  Text(
                    HealthInsuranceStrings.t('hi_crc_legal_known_note', locale),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              TruthConfidenceBanner(
                locale: locale,
                state: TruthConfidenceState.possible,
                text: HealthInsuranceStrings.t('hi_crc_possible_framing', locale),
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
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    HealthInsuranceStrings.t('hi_crc_legal_possible_note', locale),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              TruthConfidenceBanner(
                locale: locale,
                state: TruthConfidenceState.action,
                engine: TruthEngineFamily.healthInsurance,
                text: HealthInsuranceStrings.t('hi_crc_action_intro', locale),
              ),
              const SizedBox(height: AppSpacing.sm),
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                glowColor: AppColors.chipHealthInsurance,
                glowIntensity: 0.08,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < actionItemKeys.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Text(
                          '${i + 1}. ${HealthInsuranceStrings.t(actionItemKeys[i], locale)}',
                          style: AppTypography.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              HealthInsuranceDependentCoverageSection(locale: locale),
              const SizedBox(height: AppSpacing.lg),
              GlassPrimaryButton(
                label: HealthInsuranceStrings.t(
                  'hi_dashboard_upload_cta',
                  locale,
                ),
                icon: Icons.document_scanner_outlined,
                expand: true,
                accentColor: AppColors.chipScanner,
                onPressed: () =>
                    context.push('/health-insurance/policy-explainer'),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                HealthInsuranceStrings.t('hi_crc_upload_hint', locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
