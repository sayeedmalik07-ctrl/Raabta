import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/widgets/hub/hub_feed_footer_notice.dart';
import 'package:raabta/core/widgets/hub/money_tool_screen_scaffold.dart';
import 'package:raabta/features/cost_of_living/presentation/providers/cost_of_living_providers.dart';
import 'package:raabta/features/cost_of_living/services/cost_of_living_service.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/features/home/widgets/metric_chip.dart';
import 'package:raabta/features/personal_budget/domain/personal_budget_calculator.dart';
import 'package:raabta/features/personal_budget/domain/personal_budget_models.dart';
import 'package:raabta/features/personal_budget/presentation/l10n/personal_budget_strings.dart';
import 'package:raabta/features/personal_budget/presentation/widgets/personal_budget_attention_card.dart';
import 'package:raabta/features/personal_budget/presentation/widgets/personal_budget_animated_amount.dart';
import 'package:raabta/features/personal_budget/presentation/widgets/personal_budget_breakdown_chart.dart';
import 'package:raabta/features/personal_budget/presentation/widgets/personal_budget_export_bar.dart';
import 'package:raabta/features/personal_budget/presentation/widgets/personal_budget_pressure_badge.dart';
import 'package:raabta/features/personal_budget/presentation/widgets/personal_budget_report_panel.dart';
import 'package:raabta/features/personal_budget/presentation/widgets/personal_budget_share_card.dart';
import 'package:raabta/features/personal_budget/presentation/widgets/personal_budget_slider_field.dart';
import 'package:raabta/features/personal_budget/services/personal_budget_bill_prefill_service.dart';
import 'package:raabta/features/personal_budget/services/personal_budget_export_service.dart';
import 'package:raabta/features/personal_budget/services/personal_budget_local_store.dart';
import 'package:raabta/features/personal_budget/services/personal_budget_report_service.dart';
import 'package:raabta/providers/visa_providers.dart';
class PersonalBudgetScreen extends ConsumerStatefulWidget {
  const PersonalBudgetScreen({super.key});

  @override
  ConsumerState<PersonalBudgetScreen> createState() =>
      _PersonalBudgetScreenState();
}

class _PersonalBudgetScreenState extends ConsumerState<PersonalBudgetScreen> {
  double _salary = 0;
  double _rent = 0;
  double _food = 0;
  double _transport = 0;
  double _utilities = 0;
  double _family = 0;
  double _remittance = 0;
  double _other = 0;
  bool _exportBusy = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final saved =
        await ref.read(personalBudgetLocalStoreProvider).load();
    if (!mounted || saved == null) {
      setState(() => _loaded = true);
      return;
    }
    setState(() {
      _salary = saved.salary;
      _rent = saved.rent;
      _food = saved.food;
      _transport = saved.transport;
      _utilities = saved.utilities;
      _family = saved.family;
      _remittance = saved.remittance;
      _other = saved.other;
      _loaded = true;
    });
  }

  void _rebuild([VoidCallback? fn]) {
    if (fn != null) fn();
    setState(() {});
    _persist();
  }

  Future<void> _persist() async {
    await ref.read(personalBudgetLocalStoreProvider).save(_inputs);
  }

  PersonalBudgetInputs get _inputs => PersonalBudgetInputs(
        salary: _salary,
        rent: _rent,
        food: _food,
        transport: _transport,
        utilities: _utilities,
        family: _family,
        remittance: _remittance,
        other: _other,
      );

  PersonalBudgetResult get _result =>
      PersonalBudgetCalculator.compute(_inputs);

  String get _locale => ref.watch(userLanguageProvider);

  PersonalBudgetReport _buildReport() {
    final cpi = ref.read(costOfLivingSnapshotProvider).valueOrNull;
    return PersonalBudgetReportService.build(
      inputs: _inputs,
      result: _result,
      locale: AppLocale.normalize(_locale),
      cpiSnapshot: cpi,
    );
  }

  Future<void> _prefillFromBills() async {
    final bills = ref.read(userBillsProvider).valueOrNull ?? [];
    final prefill = PersonalBudgetBillPrefillService.prefillFromBills(bills);
    _rebuild(() {
      _utilities = prefill.utilities;
      _rent = prefill.rent;
      _other = prefill.other;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(PersonalBudgetStrings.t('pb_prefill_done', _locale)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _shareCard() async {
    showPersonalBudgetShareCard(
      context,
      inputs: _inputs,
      result: _result,
      locale: AppLocale.normalize(_locale),
    );
  }

  Future<void> _sharePdf() async {
    setState(() => _exportBusy = true);
    try {
      await ref
          .read(personalBudgetExportServiceProvider)
          .shareReportPdf(_buildReport());
    } finally {
      if (mounted) setState(() => _exportBusy = false);
    }
  }

  Future<void> _saveVault() async {
    setState(() => _exportBusy = true);
    try {
      final docId = await ref
          .read(personalBudgetExportServiceProvider)
          .saveReportToVault(_buildReport());
      if (!mounted) return;
      if (docId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(PersonalBudgetStrings.t('pb_vault_saved', _locale)),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Open',
              onPressed: () => context.push('/document-vault/$docId'),
            ),
          ),
        );
      } else {
        _snack(PersonalBudgetStrings.t('pb_vault_failed', _locale));
      }
    } finally {
      if (mounted) setState(() => _exportBusy = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return MoneyToolScreenScaffold(
        title: PersonalBudgetStrings.t('pb_title', _locale),
        subtitle: PersonalBudgetStrings.t('pb_subtitle', _locale),
        onBack: () => context.pop(),
        onRefresh: () async {},
        children: const [
          Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    final locale = AppLocale.normalize(_locale);
    final isRtl = AppLocale.isRtl(locale);
    final result = _result;
    final report = _buildReport();

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: MoneyToolScreenScaffold(
        title: PersonalBudgetStrings.t('pb_title', locale),
        subtitle: PersonalBudgetStrings.t('pb_subtitle', locale),
        onBack: () => context.pop(),
        onRefresh: () async {},
        headerTrailing: IconButton(
          icon: Icon(Icons.ios_share_outlined, color: AppColors.goldFamilyMain),
          tooltip: PersonalBudgetStrings.t('pb_share_card', locale),
          onPressed: _shareCard,
        ),
        disclaimer: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text(
            PersonalBudgetStrings.t('pb_disclaimer', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        children: [
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.receipt_long_outlined, size: 18),
                  label: Text(PersonalBudgetStrings.t('pb_prefill_bills', locale)),
                  onPressed: _prefillFromBills,
                ),
                ActionChip(
                  avatar: const Icon(Icons.analytics_outlined, size: 18),
                  label: Text(PersonalBudgetStrings.t('pb_link_col', locale)),
                  onPressed: () =>
                      context.push('/money-services/cost-of-living'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            _ResultsPanel(result: result, locale: locale),
            const SizedBox(height: AppSpacing.md),
            PersonalBudgetExportBar(
              locale: locale,
              busy: _exportBusy,
              onShareCard: _shareCard,
              onSharePdf: _sharePdf,
              onSaveVault: _saveVault,
            ),
            if (result.attentionInsight != null) ...[
              const SizedBox(height: AppSpacing.md),
              PersonalBudgetAttentionCard(
                insight: result.attentionInsight!,
                locale: locale,
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            PersonalBudgetReportPanel(report: report, locale: locale),
            const SizedBox(height: AppSpacing.xxl),
            HomeSectionHeader(
              title: PersonalBudgetStrings.t('pb_breakdown', locale),
              leadingIcon: Icons.pie_chart_outline,
            ),
            const SizedBox(height: AppSpacing.md),
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              borderRadius: AppSpacing.radiusLg,
              glowColor: AppColors.emeraldGlow,
              glowIntensity: 0.12,
              child: PersonalBudgetBreakdownChart(
                segments: result.segments,
                locale: locale,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            HomeSectionHeader(
              title: PersonalBudgetStrings.t('pb_inputs_heading', locale),
              leadingIcon: Icons.tune_outlined,
            ),
            const SizedBox(height: AppSpacing.md),
            PersonalBudgetSliderField(
              label: PersonalBudgetStrings.t('pb_input_salary', locale),
              value: _salary,
              min: 0,
              max: 50000,
              divisions: 100,
              accentColor: AppColors.emeraldGlow,
              onChanged: (v) => _rebuild(() => _salary = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            PersonalBudgetSliderField(
              label: PersonalBudgetStrings.t('pb_cat_rent', locale),
              value: _rent,
              min: 0,
              max: 20000,
              onChanged: (v) => _rebuild(() => _rent = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            PersonalBudgetSliderField(
              label: PersonalBudgetStrings.t('pb_cat_food', locale),
              value: _food,
              min: 0,
              max: 10000,
              onChanged: (v) => _rebuild(() => _food = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            PersonalBudgetSliderField(
              label: PersonalBudgetStrings.t('pb_cat_transport', locale),
              value: _transport,
              min: 0,
              max: 5000,
              onChanged: (v) => _rebuild(() => _transport = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            PersonalBudgetSliderField(
              label: PersonalBudgetStrings.t('pb_cat_utilities', locale),
              value: _utilities,
              min: 0,
              max: 5000,
              onChanged: (v) => _rebuild(() => _utilities = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            PersonalBudgetSliderField(
              label: PersonalBudgetStrings.t('pb_cat_family', locale),
              hint: PersonalBudgetStrings.t('pb_family_hint', locale),
              value: _family,
              min: 0,
              max: 15000,
              onChanged: (v) => _rebuild(() => _family = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            PersonalBudgetSliderField(
              label: PersonalBudgetStrings.t('pb_cat_remittance', locale),
              value: _remittance,
              min: 0,
              max: 15000,
              onChanged: (v) => _rebuild(() => _remittance = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            PersonalBudgetSliderField(
              label: PersonalBudgetStrings.t('pb_cat_other', locale),
              value: _other,
              min: 0,
              max: 10000,
              onChanged: (v) => _rebuild(() => _other = v),
            ),
            const SizedBox(height: AppSpacing.xl),
            HubFeedFooterNotice(locale: locale),
        ],
      ),
    );
  }
}

class _ResultsPanel extends StatelessWidget {
  const _ResultsPanel({
    required this.result,
    required this.locale,
  });

  final PersonalBudgetResult result;
  final String locale;

  String _formatAmount(double value) =>
      value.abs() == value.abs().roundToDouble()
          ? value.abs().toStringAsFixed(0)
          : value.abs().toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final savingsColor = result.potentialSavings >= 0
        ? AppColors.successBright
        : AppColors.errorBright;
    final savingsRateText = result.savingsRatePercent != null
        ? '${result.savingsRatePercent!.toStringAsFixed(1)}%'
        : PersonalBudgetStrings.t('pb_enter_salary', locale);

    final savingsMessage = !result.salarySet
        ? PersonalBudgetStrings.t('pb_enter_salary', locale)
        : result.potentialSavings >= 0
            ? PersonalBudgetStrings.format(
                'pb_savings_positive',
                locale,
                params: {'amount': _formatAmount(result.potentialSavings)},
              )
            : PersonalBudgetStrings.format(
                'pb_savings_negative',
                locale,
                params: {'amount': _formatAmount(result.potentialSavings)},
              );

    final annualSavingsMessage = !result.salarySet
        ? ''
        : result.annualPotentialSavings >= 0
            ? PersonalBudgetStrings.format(
                'pb_annual_savings_positive',
                locale,
                params: {
                  'amount': _formatAmount(result.annualPotentialSavings),
                },
              )
            : PersonalBudgetStrings.format(
                'pb_annual_savings_negative',
                locale,
                params: {
                  'amount': _formatAmount(result.annualPotentialSavings),
                },
              );

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppSpacing.radiusLg,
      glowColor: AppColors.emeraldGlow,
      glowIntensity: 0.2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const HomeIconBadge(
                icon: Icons.account_balance_wallet_outlined,
                accentColor: AppColors.emeraldGlow,
                size: 44,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      PersonalBudgetStrings.t('pb_results_heading', locale),
                      style: AppTypography.headline2,
                    ),
                    Text(
                      PersonalBudgetStrings.t('pb_monthly_cost', locale),
                      style: AppTypography.body.copyWith(
                        color: AppColors.textOnGlassMuted,
                      ),
                    ),
                  ],
                ),
              ),
              PersonalBudgetAnimatedAmount(
                amount: result.monthlyCost,
                style: AppTypography.tabular(
                  AppTypography.headline1.copyWith(
                    color: AppColors.emeraldGlow,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.md),
            borderRadius: AppSpacing.radiusXl,
            glowColor: AppColors.emeraldGlow,
            glowIntensity: 0.08,
            child: Row(
              children: [
                Expanded(
                  child: MetricChip(
                    icon: Icons.savings_outlined,
                    value: savingsRateText,
                    label: PersonalBudgetStrings.t('pb_savings_rate', locale),
                    accentColor: result.savingsRatePercent != null &&
                            result.savingsRatePercent! < 0
                        ? AppColors.errorBright
                        : AppColors.emeraldGlow,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: MetricChip(
                    icon: Icons.speed_outlined,
                    value: result.pressureBand == BudgetPressureBand.unknown
                        ? '—'
                        : (result.budgetPressurePercent != null
                            ? '${result.budgetPressurePercent!.toStringAsFixed(0)}%'
                            : PersonalBudgetStrings.t(
                                pressureBandLabelKey(result.pressureBand),
                                locale,
                              )),
                    label: PersonalBudgetStrings.t('pb_budget_pressure', locale),
                    accentColor: pressureBandColor(result.pressureBand),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _MetricRow(
            label: PersonalBudgetStrings.t('pb_annual_cost', locale),
            child: PersonalBudgetAnimatedAmount(
              amount: result.annualCost,
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _MetricRow(
            label: PersonalBudgetStrings.t('pb_budget_pressure', locale),
            child: PersonalBudgetPressureBadge(
              band: result.pressureBand,
              locale: locale,
              percent: result.budgetPressurePercent,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            PersonalBudgetStrings.t('pb_potential_savings', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            savingsMessage,
            style: AppTypography.body.copyWith(
              color: savingsColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (annualSavingsMessage.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              annualSavingsMessage,
              style: AppTypography.caption.copyWith(color: savingsColor),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textOnGlassMuted,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
