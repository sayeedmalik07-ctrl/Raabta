import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/domain/models/eosb_scenario.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_disclaimer_banner.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';

class ScenarioSimulatorScreen extends ConsumerWidget {
  const ScenarioSimulatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(eosbLocaleProvider);
    final input = ref.watch(eosbProvider).input;
    final scenarios = ref.watch(eosbScenariosProvider);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        if (scenarios.isEmpty) {
          return GlassScreenScaffold(
            title: EosbStrings.t('eosb_scenarios', locale),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            body: GlassEmptyState(
              icon: Icons.compare_outlined,
              title: EosbStrings.t('eosb_scenarios_empty_title', locale),
              description: EosbStrings.t('eosb_scenarios_empty_desc', locale),
              actionLabel: EosbStrings.t('eosb_employee_info', locale),
              onAction: () => context.push('/eosb/employee-info'),
            ),
          );
        }

        final base = ref.watch(eosbProvider).result?.totalEntitlement ??
            ref
                .read(eosbScenarioServiceProvider)
                .calculateBase(input)
                .totalEntitlement;

        return GlassScreenScaffold(
          title: EosbStrings.t('eosb_scenarios', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              EosbDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.lg),
              Text(
                EosbStrings.t('eosb_scenarios_desc', locale),
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      EosbStrings.t('eosb_scenario_base', locale),
                      style: AppTypography.title,
                    ),
                    Text(
                      formatEosbCurrency(base),
                      style: AppTypography.title.copyWith(
                        color: AppColors.emeraldGlow,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...scenarios.map(
                (s) => _ScenarioCard(
                  scenario: s,
                  locale: locale,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScenarioCard extends StatefulWidget {
  const _ScenarioCard({
    required this.scenario,
    required this.locale,
  });

  final EosbScenario scenario;
  final String locale;

  @override
  State<_ScenarioCard> createState() => _ScenarioCardState();
}

class _ScenarioCardState extends State<_ScenarioCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.scenario;
    final locale = widget.locale;
    final diff = s.differenceFromBase;
    final diffColor =
        diff >= 0 ? AppColors.successBright : AppColors.errorBright;
    final diffIcon = diff >= 0 ? Icons.north_east : Icons.south_east;
    final items = s.result.breakdown.where((b) => b.amount > 0).toList();

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
                      EosbStrings.t(s.titleKey, locale),
                      style: AppTypography.title.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      EosbStrings.t(s.descriptionKey, locale),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatEosbCurrency(s.result.totalEntitlement),
                style: AppTypography.title.copyWith(
                  color: AppColors.cyanGlow,
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
                      '${diff >= 0 ? '+' : ''}${formatEosbCurrency(diff)}',
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
                EosbStrings.t('eosb_scenario_tap_expand', locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          if (_expanded) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              EosbStrings.t('eosb_scenario_breakdown', locale),
              style: AppTypography.title.copyWith(fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (items.isEmpty)
              Text(
                EosbStrings.t('eosb_scenarios_empty_desc', locale),
                style: AppTypography.bodySmall,
              )
            else
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          EosbStrings.t(item.titleKey, locale),
                          style: AppTypography.bodySmall,
                        ),
                      ),
                      Text(
                        formatEosbCurrency(item.amount),
                        style: AppTypography.chipLabel.copyWith(
                          color: AppColors.successBright,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
