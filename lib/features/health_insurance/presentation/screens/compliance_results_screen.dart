import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/truth_confidence_banner.dart';
import 'package:raabta/core/widgets/truth_engine_result_skeleton.dart';
import 'package:raabta/features/truth_engine/presentation/truth_engine_status_colors.dart';
import 'package:raabta/features/eosb/presentation/widgets/employer_track_record_panel.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/health_insurance/data/models/compliance_check_model.dart';
import 'package:raabta/features/health_insurance/presentation/l10n/health_insurance_strings.dart';
import 'package:raabta/features/health_insurance/presentation/providers/health_insurance_providers.dart';
import 'package:raabta/features/health_insurance/presentation/widgets/compliance_result_summary_card.dart';
import 'package:raabta/features/health_insurance/presentation/widgets/health_insurance_share_card.dart';
import 'package:raabta/features/health_insurance/presentation/widgets/health_insurance_widgets.dart';
import 'package:raabta/features/legal_sources/presentation/widgets/legal_freshness_indicator.dart';

class ComplianceResultsScreen extends ConsumerWidget {
  const ComplianceResultsScreen({super.key});

  static TruthConfidenceState? truthStateForResult(
    ComplianceCheckResult result,
  ) {
    if (result.isExemptSession) return TruthConfidenceState.known;
    if (ComplianceResultSummaryCard.violationCount(result) > 0) {
      return TruthConfidenceState.action;
    }
    if (ComplianceResultSummaryCard.needsVerificationCount(result) > 0) {
      return TruthConfidenceState.unknown;
    }
    if (result.allCompliant) return TruthConfidenceState.known;
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(healthInsuranceLocaleProvider);
    final result = ref.watch(healthInsuranceProvider).result;
    final explainer = ref.watch(healthInsuranceExplanationServiceProvider);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: TruthEngineResultSkeleton(),
      ),
      error: (_, _) => const GlassScreenScaffold(
        body: TruthEngineResultSkeleton(),
      ),
      data: (locale) {
        if (result == null) {
          return GlassScreenScaffold(
            title: HealthInsuranceStrings.t('hi_results_title', locale),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            body: GlassEmptyState(
              icon: Icons.fact_check_outlined,
              title: HealthInsuranceStrings.t('hi_form_title', locale),
              description: HealthInsuranceStrings.t('hi_form_submit', locale),
              actionLabel: HealthInsuranceStrings.t('hi_form_submit', locale),
              onAction: () => context.push('/health-insurance/compliance'),
            ),
          );
        }

        final overview = explainer.buildResultsOverview(result, locale);
        final truthState = truthStateForResult(result);
        final violations =
            ComplianceResultSummaryCard.violationCount(result);
        final needsVerify =
            ComplianceResultSummaryCard.needsVerificationCount(result);
        final showUploadPrimary = needsVerify > 0;
        final showSharePrimary = violations > 0 && !showUploadPrimary;

        return GlassScreenScaffold(
          title: HealthInsuranceStrings.t('hi_results_title', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              HealthInsuranceDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.sm),
              LegalFreshnessIndicator(locale: locale),
              const SizedBox(height: AppSpacing.md),
              ComplianceResultSummaryCard(
                result: result,
                locale: locale,
                overview: overview,
              ),
              if (truthState != null) ...[
                const SizedBox(height: AppSpacing.sm),
                TruthConfidenceBanner(
                  locale: locale,
                  state: truthState,
                  text: overview,
                  engine: TruthEngineFamily.healthInsurance,
                ),
              ],
              if (showUploadPrimary || showSharePrimary) ...[
                const SizedBox(height: AppSpacing.md),
                GlassPrimaryButton(
                  label: showUploadPrimary
                      ? HealthInsuranceStrings.t(
                          'hi_dashboard_upload_cta',
                          locale,
                        )
                      : HealthInsuranceStrings.t('hi_share_card', locale),
                  icon: showUploadPrimary
                      ? Icons.document_scanner_outlined
                      : Icons.ios_share_rounded,
                  expand: true,
                  accentColor: showUploadPrimary
                      ? AppColors.chipScanner
                      : AppColors.chipHealthInsurance,
                  onPressed: showUploadPrimary
                      ? () => context.push('/health-insurance/policy-explainer')
                      : () => showHealthInsuranceComplianceShareCard(
                            context,
                            result: result,
                            locale: locale,
                          ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              for (final item in result.items) ...[
                ComplianceResultCard(item: item, locale: locale),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.md),
              EmployerTrackRecordPanel(
                companyName: ref.watch(eosbProvider).input.companyName,
                locale: locale,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (!showSharePrimary) ...[
                GlassPrimaryButton(
                  label: HealthInsuranceStrings.t('hi_share_card', locale),
                  icon: Icons.ios_share_rounded,
                  expand: true,
                  accentColor: AppColors.chipHealthInsurance,
                  onPressed: () => showHealthInsuranceComplianceShareCard(
                    context,
                    result: result,
                    locale: locale,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              GlassPrimaryButton(
                label: HealthInsuranceStrings.t('hi_denial_entry_cta', locale),
                icon: Icons.gavel_outlined,
                expand: true,
                onPressed: () =>
                    context.push('/health-insurance/denial-dispute'),
              ),
            ],
          ),
        );
      },
    );
  }
}
