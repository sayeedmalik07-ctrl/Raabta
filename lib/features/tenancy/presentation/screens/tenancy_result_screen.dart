import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/legal_deadline_engine_widgets.dart';
import 'package:raabta/core/widgets/truth_engine_result_skeleton.dart';
import 'package:raabta/core/widgets/truth_engine_secondary_actions.dart';
import 'package:raabta/features/legal_sources/presentation/widgets/legal_freshness_indicator.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_enums.dart';
import 'package:raabta/features/tenancy/presentation/l10n/tenancy_strings.dart';
import 'package:raabta/features/tenancy/presentation/widgets/tenancy_maintenance_self_remedy_section.dart';
import 'package:raabta/features/tenancy/presentation/widgets/tenancy_eviction_protections_section.dart';
import 'package:raabta/features/tenancy/presentation/widgets/tenancy_rent_increase_section.dart';
import 'package:raabta/features/tenancy/presentation/widgets/tenancy_result_summary_card.dart';
import 'package:raabta/features/tenancy/presentation/widgets/tenancy_shared_housing_section.dart';
import 'package:raabta/features/tenancy/presentation/widgets/tenancy_widgets.dart';
import 'package:raabta/features/tenancy/providers/tenancy_providers.dart';

class TenancyResultScreen extends ConsumerWidget {
  const TenancyResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(tenancyLocaleProvider);
    final result = ref.watch(tenancyProvider).result;

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
            title: TenancyStrings.t('tenancy_results_title', locale),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            body: GlassEmptyState(
              icon: Icons.home_work_outlined,
              title: TenancyStrings.t('tenancy_form_title', locale),
              description: TenancyStrings.t('tenancy_results_empty', locale),
              actionLabel: TenancyStrings.t('tenancy_dashboard_cta', locale),
              onAction: () => context.push('/tenancy/lease-entry'),
            ),
          );
        }

        final showCritical = result.hasCriticalIssue;
        final showChecklistPrimary = showCritical || result.hasViolation;
        final complianceItems = result.items
            .where((i) => i.status != TenancyComplianceStatus.informational)
            .toList();
        final infoItems = result.items
            .where((i) => i.status == TenancyComplianceStatus.informational)
            .toList();

        return GlassScreenScaffold(
          title: TenancyStrings.t('tenancy_results_title', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              TenancyDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.sm),
              LegalFreshnessIndicator(locale: locale),
              const SizedBox(height: AppSpacing.md),
              TenancyResultSummaryCard(result: result, locale: locale),
              const SizedBox(height: AppSpacing.md),
              if (showCritical) ...[
                TenancyCriticalBanner(locale: locale),
                const SizedBox(height: AppSpacing.md),
              ],
              if (showChecklistPrimary) ...[
                GlassPrimaryButton(
                  label: TenancyStrings.t(
                    'tenancy_dashboard_checklist_cta',
                    locale,
                  ),
                  icon: Icons.checklist_outlined,
                  expand: true,
                  accentColor: AppColors.chipLease,
                  onPressed: () => context.push('/tenancy/checklist'),
                ),
                const SizedBox(height: AppSpacing.md),
              ] else ...[
                GlassPrimaryButton(
                  label: TenancyStrings.t('tenancy_edit_lease', locale),
                  expand: true,
                  accentColor: AppColors.chipLease,
                  onPressed: () => context.push('/tenancy/lease-entry'),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              LegalDeadlineEngineWidgets.tenancy(
                locale: locale,
                input: ref.watch(tenancyProvider).input,
              ),
              const SizedBox(height: AppSpacing.md),
              if (result.lateFeeEstimate != null &&
                  result.lateFeeEstimate!.monthsLate >= 1) ...[
                Text(
                  TenancyStrings.format(
                    'tenancy_late_fee_estimate',
                    locale,
                    {
                      'amount': result.lateFeeEstimate!.totalFeeQar.toStringAsFixed(0),
                      'months': result.lateFeeEstimate!.monthsLate.toString(),
                      'percent':
                          (result.lateFeeEstimate!.penaltyRate * 100).toStringAsFixed(0),
                    },
                  ),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.accentGold,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              for (final item in complianceItems) ...[
                TenancyComplianceResultCard(item: item, locale: locale),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (infoItems.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  TenancyStrings.t('tenancy_status_informational', locale),
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final item in infoItems) ...[
                  TenancyComplianceResultCard(item: item, locale: locale),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
              const SizedBox(height: AppSpacing.md),
              TenancyMaintenanceSelfRemedySection(locale: locale),
              const SizedBox(height: AppSpacing.md),
              TenancyRentIncreaseSection(
                locale: locale,
                checkedAt: result.checkedAt,
              ),
              const SizedBox(height: AppSpacing.md),
              TenancySharedHousingSection(locale: locale),
              const SizedBox(height: AppSpacing.md),
              TenancyEvictionProtectionsSection(
                locale: locale,
                checkedAt: result.checkedAt,
              ),
              TruthEngineSecondaryActions(
                topSpacing: AppSpacing.sm,
                actions: [
                  if (!showChecklistPrimary)
                    TruthEngineSecondaryAction(
                      label: TenancyStrings.t(
                        'tenancy_dashboard_checklist_cta',
                        locale,
                      ),
                      icon: Icons.checklist_outlined,
                      onPressed: () => context.push('/tenancy/checklist'),
                    )
                  else
                    TruthEngineSecondaryAction(
                      label: TenancyStrings.t('tenancy_edit_lease', locale),
                      onPressed: () => context.push('/tenancy/lease-entry'),
                    ),
                  TruthEngineSecondaryAction(
                    label: TenancyStrings.t('tenancy_dashboard_ai_cta', locale),
                    icon: Icons.chat_outlined,
                    onPressed: () => context.push('/tenancy/ai-assistant'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
