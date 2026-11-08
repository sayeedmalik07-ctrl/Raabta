import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_scenario.dart';
import 'package:raabta/features/tenancy/presentation/l10n/tenancy_strings.dart';
import 'package:raabta/features/tenancy/presentation/widgets/tenancy_widgets.dart';
import 'package:raabta/features/tenancy/providers/tenancy_providers.dart';

class TenancyScenarioSimulatorScreen extends ConsumerWidget {
  const TenancyScenarioSimulatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(tenancyLocaleProvider);
    final input = ref.watch(tenancyProvider).input;
    final scenarios = ref.watch(tenancyScenariosProvider);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        if (scenarios.isEmpty) {
          return GlassScreenScaffold(
            title: TenancyStrings.t('tenancy_scenarios', locale),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            body: GlassEmptyState(
              icon: Icons.compare_outlined,
              title: TenancyStrings.t('tenancy_scenarios_empty_title', locale),
              description: TenancyStrings.t(
                'tenancy_scenarios_empty_desc',
                locale,
              ),
              actionLabel: TenancyStrings.t('tenancy_dashboard_cta', locale),
              onAction: () => context.push('/tenancy/lease-entry'),
            ),
          );
        }

        final baseResult = ref.watch(tenancyProvider).result ??
            ref.read(tenancyScenarioServiceProvider).calculateBase(input);

        return GlassScreenScaffold(
          title: TenancyStrings.t('tenancy_scenarios', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              TenancyDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.md),
              _HypotheticalBanner(locale: locale),
              const SizedBox(height: AppSpacing.md),
              Text(
                TenancyStrings.t('tenancy_scenarios_desc', locale),
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TenancyStrings.t('tenancy_scenario_base', locale),
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _baseStatusLabel(baseResult, locale),
                      style: AppTypography.bodySmall.copyWith(
                        color: baseResult.hasCriticalIssue
                            ? AppColors.errorBright
                            : baseResult.hasViolation
                                ? AppColors.accentGold
                                : AppColors.successBright,
                      ),
                    ),
                    if (baseResult.lateFeeEstimate != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        TenancyStrings.t('tenancy_late_fee_estimate', locale)
                            .replaceAll(
                          '{amount}',
                          baseResult.lateFeeEstimate!.totalFeeQar.toStringAsFixed(
                            0,
                          ),
                        ),
                        style: AppTypography.caption,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...scenarios.map(
                (scenario) => _TenancyScenarioCard(
                  scenario: scenario,
                  locale: locale,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _baseStatusLabel(dynamic baseResult, String locale) {
    if (baseResult.hasCriticalIssue) {
      return TenancyStrings.t('tenancy_status_critical', locale);
    }
    if (baseResult.hasViolation) {
      return TenancyStrings.t('tenancy_status_violation', locale);
    }
    return TenancyStrings.t('tenancy_status_compliant', locale);
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
              TenancyStrings.t('tenancy_scenario_hypothetical', locale),
              style: AppTypography.caption.copyWith(color: AppColors.cyanGlow),
            ),
          ),
        ],
      ),
    );
  }
}

class _TenancyScenarioCard extends StatefulWidget {
  const _TenancyScenarioCard({
    required this.scenario,
    required this.locale,
  });

  final TenancyScenario scenario;
  final String locale;

  @override
  State<_TenancyScenarioCard> createState() => _TenancyScenarioCardState();
}

class _TenancyScenarioCardState extends State<_TenancyScenarioCard> {
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
                      TenancyStrings.t(scenario.titleKey, locale),
                      style: AppTypography.title.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      TenancyStrings.t(scenario.descriptionKey, locale),
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
                  TenancyStrings.t(scenario.differenceSummaryKey, locale),
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
          if (scenario.result.lateFeeEstimate != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              TenancyStrings.t('tenancy_late_fee_estimate', locale).replaceAll(
                '{amount}',
                scenario.result.lateFeeEstimate!.totalFeeQar.toStringAsFixed(0),
              ),
              style: AppTypography.caption.copyWith(
                color: AppColors.accentGold,
              ),
            ),
          ],
          if (!_expanded)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                TenancyStrings.t('tenancy_scenario_tap_expand', locale),
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
                child: TenancyComplianceResultCard(item: item, locale: locale),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
