import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/health_insurance/domain/models/health_insurance_scenario.dart';
import 'package:raabta/features/health_insurance/presentation/l10n/health_insurance_strings.dart';
import 'package:raabta/features/health_insurance/presentation/providers/health_insurance_providers.dart';
import 'package:raabta/features/health_insurance/presentation/widgets/health_insurance_widgets.dart';

class HealthInsuranceScenarioSimulatorScreen extends ConsumerWidget {
  const HealthInsuranceScenarioSimulatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(healthInsuranceLocaleProvider);
    final scenariosAsync = ref.watch(healthInsuranceScenariosProvider);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        return scenariosAsync.when(
          loading: () => GlassScreenScaffold(
            title: HealthInsuranceStrings.t('hi_scenarios', locale),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => GlassScreenScaffold(
            title: HealthInsuranceStrings.t('hi_scenarios', locale),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            body: GlassEmptyState(
              icon: Icons.compare_outlined,
              title: HealthInsuranceStrings.t('hi_scenarios_empty_title', locale),
              description: HealthInsuranceStrings.t(
                'hi_scenarios_empty_desc',
                locale,
              ),
              actionLabel: HealthInsuranceStrings.t(
                'hi_dashboard_compliance_cta',
                locale,
              ),
              onAction: () => context.push('/health-insurance/compliance'),
            ),
          ),
          data: (scenarios) {
            if (scenarios.isEmpty) {
              return GlassScreenScaffold(
                title: HealthInsuranceStrings.t('hi_scenarios', locale),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                body: GlassEmptyState(
                  icon: Icons.compare_outlined,
                  title: HealthInsuranceStrings.t(
                    'hi_scenarios_empty_title',
                    locale,
                  ),
                  description: HealthInsuranceStrings.t(
                    'hi_scenarios_empty_desc',
                    locale,
                  ),
                  actionLabel: HealthInsuranceStrings.t(
                    'hi_dashboard_compliance_cta',
                    locale,
                  ),
                  onAction: () => context.push('/health-insurance/compliance'),
                ),
              );
            }

            final baseResult = ref.watch(healthInsuranceProvider).result;

            return GlassScreenScaffold(
              title: HealthInsuranceStrings.t('hi_scenarios', locale),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              body: ListView(
                children: [
                  HealthInsuranceDisclaimerBanner(locale: locale),
                  const SizedBox(height: AppSpacing.md),
                  _HypotheticalBanner(locale: locale),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    HealthInsuranceStrings.t('hi_scenarios_desc', locale),
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (baseResult != null)
                    GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            HealthInsuranceStrings.t('hi_scenario_base', locale),
                            style: AppTypography.title,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            baseResult.hasUnresolvedViolation
                                ? HealthInsuranceStrings.t(
                                    'hi_status_violation',
                                    locale,
                                  )
                                : HealthInsuranceStrings.t(
                                    'hi_status_compliant',
                                    locale,
                                  ),
                            style: AppTypography.bodySmall.copyWith(
                              color: baseResult.hasUnresolvedViolation
                                  ? AppColors.errorBright
                                  : AppColors.successBright,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  ...scenarios.map(
                    (scenario) => _HealthInsuranceScenarioCard(
                      scenario: scenario,
                      locale: locale,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _HypotheticalBanner extends StatelessWidget {
  const _HypotheticalBanner({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.cyanGlow.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.cyanGlow.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.cyanGlow, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              HealthInsuranceStrings.t('hi_scenario_hypothetical', locale),
              style: AppTypography.caption.copyWith(color: AppColors.cyanGlow),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthInsuranceScenarioCard extends StatefulWidget {
  const _HealthInsuranceScenarioCard({
    required this.scenario,
    required this.locale,
  });

  final HealthInsuranceScenario scenario;
  final String locale;

  @override
  State<_HealthInsuranceScenarioCard> createState() =>
      _HealthInsuranceScenarioCardState();
}

class _HealthInsuranceScenarioCardState
    extends State<_HealthInsuranceScenarioCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scenario = widget.scenario;
    final locale = widget.locale;
    final diff = scenario.differenceFromBase;
    final diffColor = diff > 0
        ? AppColors.errorBright
        : diff < 0
            ? AppColors.successBright
            : AppColors.textTertiary;
    final diffIcon = diff > 0
        ? Icons.trending_up
        : diff < 0
            ? Icons.trending_down
            : Icons.remove;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      onTap: () => setState(() => _expanded = !_expanded),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      HealthInsuranceStrings.t(scenario.titleKey, locale),
                      style: AppTypography.title.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      HealthInsuranceStrings.t(
                        scenario.descriptionKey,
                        locale,
                      ),
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  HealthInsuranceStrings.t(
                    scenario.differenceSummaryKey,
                    locale,
                  ),
                  style: AppTypography.chipLabel,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: diffColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                  border: Border.all(color: diffColor.withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(diffIcon, size: 14, color: diffColor),
                    const SizedBox(width: 4),
                    Text(
                      diff > 0 ? '+$diff' : diff == 0 ? '0' : '$diff',
                      style: AppTypography.chipLabel.copyWith(color: diffColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!_expanded)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                HealthInsuranceStrings.t('hi_scenario_tap_expand', locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          if (_expanded) ...[
            const SizedBox(height: AppSpacing.md),
            ...scenario.result.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ComplianceResultCard(item: item, locale: locale),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
