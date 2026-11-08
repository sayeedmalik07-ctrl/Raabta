import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/legal_deadline_engine_widgets.dart';
import 'package:raabta/features/legal_sources/presentation/widgets/legal_freshness_indicator.dart';
import 'package:raabta/features/tenancy/presentation/l10n/tenancy_strings.dart';
import 'package:raabta/features/tenancy/presentation/widgets/tenancy_maintenance_self_remedy_section.dart';
import 'package:raabta/features/tenancy/presentation/widgets/tenancy_eviction_protections_section.dart';
import 'package:raabta/features/tenancy/presentation/widgets/tenancy_rent_increase_section.dart';
import 'package:raabta/features/tenancy/presentation/widgets/tenancy_shared_housing_section.dart';
import 'package:raabta/features/tenancy/presentation/widgets/tenancy_widgets.dart';
import 'package:raabta/features/tenancy/providers/tenancy_providers.dart';

class TenancyDashboardScreen extends ConsumerWidget {
  const TenancyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(tenancyLocaleProvider);
    final state = ref.watch(tenancyProvider);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        final hasResult = state.result != null;
        final critical = state.result?.hasCriticalIssue ?? false;

        return GlassScreenScaffold(
          title: TenancyStrings.t('tenancy_title', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              Text(
                TenancyStrings.t('tenancy_subtitle', locale),
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              TenancyDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.sm),
              LegalFreshnessIndicator(locale: locale),
              const SizedBox(height: AppSpacing.lg),
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                glowColor: AppColors.cyanGlow,
                glowIntensity: 0.1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TenancySectionHeader(
                      title: TenancyStrings.t('tenancy_listing_title', locale),
                      subtitle: TenancyStrings.t(
                        'tenancy_listing_subtitle',
                        locale,
                      ),
                      icon: Icons.shield_outlined,
                      accentColor: AppColors.cyanGlow,
                    ),
                    GlassPrimaryButton(
                      label: TenancyStrings.t(
                        'tenancy_listing_dashboard_cta',
                        locale,
                      ),
                      icon: Icons.fact_check_outlined,
                      expand: true,
                      accentColor: AppColors.cyanGlow,
                      onPressed: () => context.push('/tenancy/listing-check'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (hasResult && critical) ...[
                TenancyCriticalBanner(locale: locale),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (hasResult) ...[
                LegalDeadlineEngineWidgets.tenancy(
                  locale: locale,
                  input: state.input,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                glowColor: AppColors.chipLease,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TenancySectionHeader(
                      title: TenancyStrings.t('tenancy_form_title', locale),
                      icon: Icons.home_work_outlined,
                    ),
                    GlassPrimaryButton(
                      label: TenancyStrings.t('tenancy_dashboard_cta', locale),
                      expand: true,
                      accentColor: AppColors.chipLease,
                      icon: Icons.fact_check_outlined,
                      onPressed: () => context.push('/tenancy/lease-entry'),
                    ),
                    if (hasResult) ...[
                      const SizedBox(height: AppSpacing.sm),
                      OutlinedButton(
                        onPressed: () => context.push('/tenancy/result'),
                        child: Text(
                          TenancyStrings.t('tenancy_dashboard_results_cta', locale),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: hasResult
                          ? () => context.push('/tenancy/condition')
                          : null,
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: Text(
                        TenancyStrings.t(
                          'tenancy_dashboard_condition_cta',
                          locale,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/tenancy/checklist'),
                      icon: const Icon(Icons.checklist_outlined),
                      label: Text(
                        TenancyStrings.t('tenancy_dashboard_checklist_cta', locale),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/tenancy/ai-assistant'),
                      icon: const Icon(Icons.chat_outlined),
                      label: Text(
                        TenancyStrings.t('tenancy_dashboard_ai_cta', locale),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TenancyMaintenanceSelfRemedySection(locale: locale),
              const SizedBox(height: AppSpacing.lg),
              TenancyRentIncreaseSection(
                locale: locale,
                checkedAt: ref.watch(tenancyProvider).result?.checkedAt,
              ),
              const SizedBox(height: AppSpacing.lg),
              TenancySharedHousingSection(locale: locale),
              const SizedBox(height: AppSpacing.lg),
              TenancyEvictionProtectionsSection(
                locale: locale,
                checkedAt: ref.watch(tenancyProvider).result?.checkedAt,
              ),
              const SizedBox(height: AppSpacing.lg),
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    TenancyStrings.t('tenancy_hub_explore', locale),
                    style: AppTypography.title,
                  ),
                  children: [
                    GlassCard(
                      onTap: () => context.push('/tenancy/scenarios'),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      glowColor: AppColors.chipLease,
                      glowIntensity: 0.1,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.insights_outlined,
                            color: AppColors.chipLease,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              TenancyStrings.t('tenancy_scenarios', locale),
                              style: AppTypography.title.copyWith(fontSize: 13),
                            ),
                          ),
                          Icon(Icons.chevron_right, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    GlassCard(
                      onTap: () => context.push('/tenancy/history'),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      glowColor: AppColors.textSecondary,
                      glowIntensity: 0.1,
                      child: Row(
                        children: [
                          Icon(
                            Icons.history,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              TenancyStrings.t('tenancy_history', locale),
                              style: AppTypography.title.copyWith(fontSize: 13),
                            ),
                          ),
                          Icon(Icons.chevron_right, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
