import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/health_insurance/presentation/l10n/health_insurance_strings.dart';
import 'package:raabta/features/health_insurance/data/models/insurer_lookup_models.dart';
import 'package:raabta/features/health_insurance/presentation/providers/health_insurance_providers.dart';
import 'package:raabta/features/health_insurance/presentation/widgets/health_insurance_widgets.dart';
import 'package:raabta/features/health_insurance/presentation/widgets/healthcare_navigation_section.dart';
import 'package:raabta/features/legal_sources/presentation/widgets/legal_freshness_indicator.dart';

class HealthInsuranceDashboardScreen extends ConsumerStatefulWidget {
  const HealthInsuranceDashboardScreen({super.key});

  @override
  ConsumerState<HealthInsuranceDashboardScreen> createState() =>
      _HealthInsuranceDashboardScreenState();
}

class _HealthInsuranceDashboardScreenState
    extends ConsumerState<HealthInsuranceDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final repo =
          await ref.read(healthInsuranceRepositoryProvider.future);
      await repo.recordLastOpened();
      if (!mounted) return;
      ref.read(healthInsuranceProvider.notifier).scheduleOnboardingNudgeIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localeAsync = ref.watch(healthInsuranceLocaleProvider);
    final state = ref.watch(healthInsuranceProvider);
    final mophAsync = ref.watch(mophInsurerSnapshotProvider);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        return GlassScreenScaffold(
          title: HealthInsuranceStrings.t('hi_title', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              Text(
                HealthInsuranceStrings.t('hi_subtitle', locale),
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              LegalFreshnessIndicator(locale: locale),
              mophAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (MophInsurerLookupSnapshot snapshot) =>
                    MophInsurerFreshnessIndicator(
                  locale: locale,
                  lastVerified: snapshot.lastVerified,
                ),
              ),
              HealthInsuranceDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.lg),
              HealthcareNavigationSection(locale: locale),
              const SizedBox(height: AppSpacing.md),
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                glowColor: AppColors.chipHealthInsurance,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HealthInsuranceSectionHeader(
                      title: HealthInsuranceStrings.t('hi_form_title', locale),
                      subtitle: HealthInsuranceStrings.t('hi_disclaimer', locale),
                      icon: Icons.fact_check_outlined,
                    ),
                    GlassPrimaryButton(
                      label: HealthInsuranceStrings.t(
                        'hi_dashboard_compliance_cta',
                        locale,
                      ),
                      icon: Icons.play_arrow_rounded,
                      onPressed: () => context.push('/health-insurance/compliance'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      HealthInsuranceStrings.t('hi_results_title', locale),
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ComplianceResultsPreview(
                      locale: locale,
                      result: state.result,
                      onViewAll: state.result != null
                          ? () => context.push('/health-insurance/compliance/results')
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          HealthInsuranceStrings.t('hi_hub_explore', locale),
                          style: AppTypography.title.copyWith(fontSize: 14),
                        ),
                        children: [
                          GlassCard(
                            onTap: () =>
                                context.push('/health-insurance/scenarios'),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            glowColor: AppColors.chipHealthInsurance,
                            glowIntensity: 0.1,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.insights_outlined,
                                  color: AppColors.chipHealthInsurance,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    HealthInsuranceStrings.t(
                                      'hi_scenarios',
                                      locale,
                                    ),
                                    style: AppTypography.title.copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          GlassCard(
                            onTap: () => context.push(
                              '/health-insurance/compliance/history',
                            ),
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
                                    HealthInsuranceStrings.t('hi_history', locale),
                                    style: AppTypography.title.copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                glowColor: AppColors.chipHealthInsurance,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HealthInsuranceSectionHeader(
                      title: HealthInsuranceStrings.t(
                        'hi_crc_title',
                        locale,
                      ),
                      subtitle: HealthInsuranceStrings.t(
                        'hi_crc_dashboard_subtitle',
                        locale,
                      ),
                      icon: Icons.visibility_outlined,
                      accentColor: AppColors.chipHealthInsurance,
                    ),
                    GlassPrimaryButton(
                      label: HealthInsuranceStrings.t(
                        'hi_dashboard_crc_cta',
                        locale,
                      ),
                      icon: Icons.checklist_rtl_outlined,
                      expand: true,
                      onPressed: () => context.push(
                        '/health-insurance/coverage-reality-check',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                glowColor: AppColors.chipScanner,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HealthInsuranceSectionHeader(
                      title: HealthInsuranceStrings.t(
                        'hi_policy_explainer_title',
                        locale,
                      ),
                      subtitle: HealthInsuranceStrings.t(
                        'hi_policy_upload_subtitle',
                        locale,
                      ),
                      icon: Icons.description_outlined,
                      accentColor: AppColors.chipScanner,
                    ),
                    GlassPrimaryButton(
                      label: HealthInsuranceStrings.t(
                        'hi_dashboard_upload_cta',
                        locale,
                      ),
                      icon: Icons.document_scanner_outlined,
                      accentColor: AppColors.chipScanner,
                      expand: true,
                      onPressed: () =>
                          context.push('/health-insurance/policy-explainer'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                glowColor: AppColors.chipHealthInsurance,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HealthInsuranceSectionHeader(
                      title: HealthInsuranceStrings.t(
                        'hi_denial_dashboard_cta',
                        locale,
                      ),
                      subtitle: HealthInsuranceStrings.t(
                        'hi_denial_subtitle',
                        locale,
                      ),
                      icon: Icons.gavel_outlined,
                      accentColor: AppColors.chipHealthInsurance,
                    ),
                    GlassPrimaryButton(
                      label: HealthInsuranceStrings.t(
                        'hi_denial_dashboard_cta',
                        locale,
                      ),
                      icon: Icons.timeline_outlined,
                      expand: true,
                      onPressed: () =>
                          context.push('/health-insurance/denial-dispute'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GlassCard(
                onTap: () => context.push('/visa'),
                padding: const EdgeInsets.all(AppSpacing.md),
                glowColor: AppColors.cyanGlow,
                glowIntensity: 0.08,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.cyanGlow.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: const Icon(
                        Icons.event_outlined,
                        color: AppColors.cyanGlow,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        HealthInsuranceStrings.t('hi_dashboard_visa_link', locale),
                        style: AppTypography.link,
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.textSecondary),
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
