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
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_disclaimer_banner.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_hero_card.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_loading_skeleton.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';

class EosbDashboardScreen extends ConsumerWidget {
  const EosbDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(eosbLocaleProvider);
    final eosbState = ref.watch(eosbProvider);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        title: 'EOSB',
        body: EosbDashboardSkeleton(),
      ),
      error: (_, _) => const GlassScreenScaffold(
        title: 'EOSB',
        body: Center(child: Text('Error loading')),
      ),
      data: (locale) {
        final result = eosbState.result;
        final preview = result ??
            (eosbState.input.basicSalary > 0
                ? ref.read(eosbCalculationServiceProvider).calculate(
                      eosbState.input,
                    )
                : null);

        final total = preview?.totalEntitlement ?? 0;
        final hasResult = result != null;
        final hasComparison = result?.comparison != null;
        final hasWarnings = (result?.warnings.isNotEmpty ?? false) ||
            (result?.violations.isNotEmpty ?? false);

        return GlassScreenScaffold(
          title: EosbStrings.t('eosb_title', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.push('/eosb/settings'),
            ),
          ],
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              Text(
                EosbStrings.t('eosb_subtitle', locale),
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              EosbDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.lg),
              if (total > 0)
                EosbHeroCard(
                  amount: total,
                  locale: locale,
                  result: preview,
                  confidenceScore: preview?.explanation.confidenceScore,
                )
              else
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    EosbStrings.t('eosb_explanation_default', locale),
                    style: AppTypography.body,
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              if (hasResult) ...[
                LegalDeadlineEngineWidgets.eosb(
                  locale: locale,
                  input: eosbState.input,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              GlassPrimaryButton(
                label: hasResult
                    ? EosbStrings.t('eosb_recalculate_cta', locale)
                    : EosbStrings.t('eosb_calculate_cta', locale),
                expand: true,
                accentColor: AppColors.emeraldGlow,
                icon: Icons.calculate_outlined,
                onPressed: eosbState.isCalculating
                    ? null
                    : () => context.push('/eosb/employee-info'),
              ),
              if (hasResult) ...[
                const SizedBox(height: AppSpacing.sm),
                GlassPrimaryButton(
                  label: EosbStrings.t('eosb_view_results', locale),
                  expand: true,
                  accentColor: AppColors.cyanGlow,
                  icon: Icons.insights_outlined,
                  onPressed: () => context.push('/eosb/result'),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              Text(
                EosbStrings.t('eosb_hub_your_tools', locale),
                style: AppTypography.title,
              ),
              const SizedBox(height: AppSpacing.sm),
              _ToolGrid(
                locale: locale,
                items: [
                  if (hasComparison)
                    _ToolItem(
                      'eosb_comparison',
                      Icons.compare_arrows,
                      '/eosb/comparison',
                      AppColors.accentGold,
                    ),
                  if (hasWarnings)
                    _ToolItem(
                      'eosb_warnings',
                      Icons.warning_amber_rounded,
                      '/eosb/warnings',
                      AppColors.errorBright,
                    ),
                  _ToolItem(
                    'ot_title',
                    Icons.schedule,
                    '/eosb/overtime',
                    AppColors.cyanGlow,
                  ),
                  _ToolItem(
                    'eosb_contract_analysis',
                    Icons.description_outlined,
                    '/eosb/contract-analysis',
                    AppColors.purpleGlow,
                  ),
                  _ToolItem(
                    'eosb_payslip_hub_button',
                    Icons.receipt_long_outlined,
                    '/eosb/payslip-consistency',
                    AppColors.accentGold,
                  ),
                  if (hasResult)
                    _ToolItem(
                      'eosb_legal_review',
                      Icons.gavel_outlined,
                      '/eosb/legal-review',
                      AppColors.emeraldGlow,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                EosbStrings.t('eosb_art55_hub_section_title', locale),
                style: AppTypography.title,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                EosbStrings.t('eosb_art55_hub_section_sub', locale),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  EosbStrings.t('eosb_art55_hub_link', locale),
                  style: AppTypography.body,
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
                onTap: () => context.push('/eosb/death-benefits'),
              ),
              const SizedBox(height: AppSpacing.lg),
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    EosbStrings.t('eosb_hub_explore', locale),
                    style: AppTypography.title,
                  ),
                  children: [
                    _ToolGrid(
                      locale: locale,
                      items: [
                        _ToolItem(
                          'eosb_scenarios',
                          Icons.insights_outlined,
                          '/eosb/scenarios',
                          AppColors.cyanGlow,
                        ),
                        _ToolItem(
                          'eosb_timeline',
                          Icons.timeline,
                          '/eosb/timeline',
                          AppColors.info,
                        ),
                        _ToolItem(
                          'eosb_ai_assistant',
                          Icons.auto_awesome,
                          '/eosb/ai-assistant',
                          AppColors.purpleGlow,
                        ),
                        _ToolItem(
                          'eosb_documents',
                          Icons.picture_as_pdf_outlined,
                          '/eosb/documents',
                          AppColors.textSecondary,
                        ),
                        _ToolItem(
                          'eosb_history',
                          Icons.history,
                          '/eosb/history',
                          AppColors.textSecondary,
                        ),
                      ],
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

class _ToolItem {
  const _ToolItem(this.labelKey, this.icon, this.route, this.color);

  final String labelKey;
  final IconData icon;
  final String route;
  final Color color;
}

class _ToolGrid extends StatelessWidget {
  const _ToolGrid({required this.locale, required this.items});

  final String locale;
  final List<_ToolItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: items
          .map(
            (e) => SizedBox(
              width: (MediaQuery.sizeOf(context).width -
                      AppSpacing.lg * 2 -
                      AppSpacing.sm) /
                  2,
              child: GlassCard(
                onTap: () => context.push(e.route),
                padding: const EdgeInsets.all(AppSpacing.md),
                glowColor: e.color,
                glowIntensity: 0.1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(e.icon, color: e.color),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      EosbStrings.t(e.labelKey, locale),
                      style: AppTypography.title.copyWith(fontSize: 13),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
