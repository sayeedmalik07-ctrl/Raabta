import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/hub/hub_typography.dart';
import 'package:raabta/features/eosb/presentation/screens/agency_verification_screen.dart';
import 'package:raabta/features/jobs/offer_calculator/domain/job_offer_reference_data.dart';
import 'package:raabta/features/jobs/offer_calculator/domain/job_offer_true_value_calculator.dart';
import 'package:raabta/features/jobs/offer_calculator/domain/models/job_offer_calculator_models.dart';
import 'package:raabta/features/jobs/offer_calculator/l10n/job_offer_calculator_strings.dart';
import 'package:raabta/providers/visa_providers.dart';

class JobOfferCalculatorScreen extends ConsumerStatefulWidget {
  const JobOfferCalculatorScreen({super.key, this.initialSalary});

  static const routePath = '/jobs/offer-calculator';

  static String route({double? initialSalary}) {
    if (initialSalary != null && initialSalary > 0) {
      return '$routePath?salary=${initialSalary.round()}';
    }
    return routePath;
  }

  final double? initialSalary;

  @override
  ConsumerState<JobOfferCalculatorScreen> createState() =>
      _JobOfferCalculatorScreenState();
}

class _JobOfferCalculatorScreenState
    extends ConsumerState<JobOfferCalculatorScreen> {
  final _salaryController = TextEditingController();
  final _accommodationAllowanceController = TextEditingController();
  final _foodAllowanceController = TextEditingController();
  final _feeController = TextEditingController(text: '0');

  JobOfferBenefitMode _accommodationMode = JobOfferBenefitMode.notIncluded;
  JobOfferBenefitMode _foodMode = JobOfferBenefitMode.notIncluded;
  JobOfferCalculatorResult? _result;
  String? _errorKey;

  @override
  void initState() {
    super.initState();
    if (widget.initialSalary != null && widget.initialSalary! > 0) {
      _salaryController.text = widget.initialSalary!.round().toString();
    }
  }

  @override
  void dispose() {
    _salaryController.dispose();
    _accommodationAllowanceController.dispose();
    _foodAllowanceController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  double? _parseAmount(String raw) {
    final cleaned = raw.replaceAll(',', '').trim();
    if (cleaned.isEmpty) return 0;
    return double.tryParse(cleaned);
  }

  void _calculate(String locale) {
    final salary = _parseAmount(_salaryController.text);
    if (salary == null || salary <= 0) {
      setState(() {
        _errorKey = 'joc_invalid_salary';
        _result = null;
      });
      return;
    }

    final input = JobOfferCalculatorInput(
      grossMonthlySalary: salary,
      accommodationMode: _accommodationMode,
      accommodationAllowance: _accommodationMode ==
              JobOfferBenefitMode.cashAllowance
          ? (_parseAmount(_accommodationAllowanceController.text) ?? 0)
          : 0,
      foodMode: _foodMode,
      foodAllowance: _foodMode == JobOfferBenefitMode.cashAllowance
          ? (_parseAmount(_foodAllowanceController.text) ?? 0)
          : 0,
      recruitmentFee: _parseAmount(_feeController.text) ?? 0,
    );

    setState(() {
      _errorKey = null;
      _result = JobOfferTrueValueCalculator.calculate(input);
    });
  }

  String _formatQar(double amount, String locale) {
    final formatted = NumberFormat('#,##0', 'en').format(amount.round());
    return JobOfferCalculatorStrings.format(
      'joc_qar_per_month',
      locale,
      params: {'amount': formatted},
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));

    return GlassScreenScaffold(
      title: JobOfferCalculatorStrings.t('joc_title', locale),
      titleStyle: HubTypography.hubTitle,
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                JobOfferCalculatorStrings.t('joc_subtitle', locale),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                JobOfferCalculatorStrings.t('joc_disclaimer', locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionLabel(
                      JobOfferCalculatorStrings.t('joc_section_salary', locale),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _amountField(
                      _salaryController,
                      locale: locale,
                      semanticsLabel: JobOfferCalculatorStrings.t(
                        'joc_section_salary',
                        locale,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _benefitSection(
                      locale: locale,
                      titleKey: 'joc_section_accommodation',
                      mode: _accommodationMode,
                      allowanceController: _accommodationAllowanceController,
                      onModeChanged: (m) =>
                          setState(() => _accommodationMode = m),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _benefitSection(
                      locale: locale,
                      titleKey: 'joc_section_food',
                      mode: _foodMode,
                      allowanceController: _foodAllowanceController,
                      onModeChanged: (m) => setState(() => _foodMode = m),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _sectionLabel(
                      JobOfferCalculatorStrings.t(
                        'joc_section_recruitment_fee',
                        locale,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      JobOfferCalculatorStrings.t(
                        'joc_recruitment_fee_hint',
                        locale,
                      ),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _amountField(
                      _feeController,
                      locale: locale,
                      semanticsLabel: JobOfferCalculatorStrings.t(
                        'joc_section_recruitment_fee',
                        locale,
                      ),
                    ),
                    if (_errorKey != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          JobOfferCalculatorStrings.t(_errorKey!, locale),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    Semantics(
                      button: true,
                      label: JobOfferCalculatorStrings.t('joc_calculate', locale),
                      child: GlassPrimaryButton(
                        label: JobOfferCalculatorStrings.t('joc_calculate', locale),
                        accentColor: AppColors.brandFamilyMain,
                        onPressed: () => _calculate(locale),
                      ),
                    ),
                  ],
                ),
              ),
              if (_result != null) ...[
                const SizedBox(height: AppSpacing.xl),
                Semantics(
                  container: true,
                  label: JobOfferCalculatorStrings.t(
                    'joc_a11y_results_region',
                    locale,
                  ),
                  child: _ResultsPanel(
                    result: _result!,
                    locale: locale,
                    formatQar: _formatQar,
                  ),
                ),
              ],
            ],
          ),
        ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w600),
      );

  Widget _amountField(
    TextEditingController controller, {
    required String locale,
    required String semanticsLabel,
  }) {
    return Semantics(
      textField: true,
      label: semanticsLabel,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
        ],
        decoration: InputDecoration(
          hintText: JobOfferCalculatorStrings.t('joc_amount_hint', locale),
          filled: true,
          fillColor: AppColors.surface.withValues(alpha: 0.5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _benefitSection({
    required String locale,
    required String titleKey,
    required JobOfferBenefitMode mode,
    required TextEditingController allowanceController,
    required ValueChanged<JobOfferBenefitMode> onModeChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(JobOfferCalculatorStrings.t(titleKey, locale)),
        const SizedBox(height: AppSpacing.sm),
        _modeTile(
          locale,
          JobOfferBenefitMode.inKind,
          'joc_benefit_in_kind',
          mode,
          onModeChanged,
        ),
        _modeTile(
          locale,
          JobOfferBenefitMode.cashAllowance,
          'joc_benefit_cash_allowance',
          mode,
          onModeChanged,
        ),
        _modeTile(
          locale,
          JobOfferBenefitMode.notIncluded,
          'joc_benefit_not_included',
          mode,
          onModeChanged,
        ),
        if (mode == JobOfferBenefitMode.cashAllowance) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            JobOfferCalculatorStrings.t('joc_allowance_amount', locale),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          _amountField(
            allowanceController,
            locale: locale,
            semanticsLabel: JobOfferCalculatorStrings.t(
              'joc_allowance_amount',
              locale,
            ),
          ),
        ],
      ],
    );
  }

  Widget _modeTile(
    String locale,
    JobOfferBenefitMode value,
    String labelKey,
    JobOfferBenefitMode groupValue,
    ValueChanged<JobOfferBenefitMode> onChanged,
  ) {
    return Material(
      color: Colors.transparent,
      child: RadioListTile<JobOfferBenefitMode>(
        value: value,
        groupValue: groupValue,
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
        title: Text(
          JobOfferCalculatorStrings.t(labelKey, locale),
          style: AppTypography.bodySmall,
        ),
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    );
  }
}

class _ResultsPanel extends StatelessWidget {
  const _ResultsPanel({
    required this.result,
    required this.locale,
    required this.formatQar,
  });

  final JobOfferCalculatorResult result;
  final String locale;
  final String Function(double, String) formatQar;

  @override
  Widget build(BuildContext context) {
    final minKey = switch (result.minimumWageComparison) {
      JobOfferMinimumWageComparison.belowMinimum => 'joc_result_minimum_below',
      JobOfferMinimumWageComparison.nearMinimum => 'joc_result_minimum_near',
      JobOfferMinimumWageComparison.aboveMinimum => 'joc_result_minimum_above',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          glowColor: AppColors.goldFamilyMain,
          glowIntensity: 0.12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                JobOfferCalculatorStrings.t('joc_result_true_value', locale),
                style: AppTypography.subtitle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                formatQar(result.trueMonthlyValue, locale),
                style: AppTypography.headline2.copyWith(
                  color: AppColors.goldFamilyMain,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                JobOfferCalculatorStrings.t('joc_result_true_value_body', locale),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          glowColor: _minimumGlow(result.minimumWageComparison),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                JobOfferCalculatorStrings.t('joc_result_minimum_title', locale),
                style: AppTypography.subtitle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                JobOfferCalculatorStrings.format(
                  'joc_result_minimum_applicable',
                  locale,
                  params: {
                    'amount': NumberFormat('#,##0', 'en')
                        .format(result.applicableMinimumWage.round()),
                    'citation': JobOfferReferenceData.minimumWageCitation,
                  },
                ),
                style: AppTypography.bodySmall.copyWith(height: 1.4),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                JobOfferCalculatorStrings.format(
                  minKey,
                  locale,
                  params: {
                    'value': NumberFormat('#,##0', 'en')
                        .format(result.trueMonthlyValue.round()),
                    'minimum': NumberFormat('#,##0', 'en')
                        .format(result.applicableMinimumWage.round()),
                  },
                ),
                style: AppTypography.bodySmall.copyWith(height: 1.45),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                JobOfferCalculatorStrings.t('joc_result_national_title', locale),
                style: AppTypography.subtitle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                JobOfferCalculatorStrings.t('joc_data_currency_note', locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                JobOfferCalculatorStrings.format(
                  'joc_result_national_body',
                  locale,
                  params: {
                    'period': result.nationalAverageReportingPeriod,
                    'amount': NumberFormat('#,##0', 'en')
                        .format(result.nationalAverageWage.round()),
                    'citation': JobOfferReferenceData.qnpsCitation,
                    'percent':
                        result.percentOfNationalAverage.toStringAsFixed(0),
                  },
                ),
                style: AppTypography.bodySmall.copyWith(height: 1.45),
              ),
            ],
          ),
        ),
        if (result.recruitmentFeeMonthsOfTrueValue != null) ...[
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  JobOfferCalculatorStrings.t('joc_result_fee_title', locale),
                  style: AppTypography.subtitle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  JobOfferCalculatorStrings.format(
                    'joc_result_fee_body',
                    locale,
                    params: {
                      'fee': NumberFormat('#,##0', 'en')
                          .format(result.recruitmentFeeAmount.round()),
                      'months': result.recruitmentFeeMonthsOfTrueValue!
                          .toStringAsFixed(1),
                      'value': NumberFormat('#,##0', 'en')
                          .format(result.trueMonthlyValue.round()),
                    },
                  ),
                  style: AppTypography.bodySmall.copyWith(height: 1.45),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  JobOfferCalculatorStrings.t('joc_fee_mol_reminder', locale),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                Semantics(
                  button: true,
                  label: JobOfferCalculatorStrings.t('joc_fee_mol_link', locale),
                  child: TextButton(
                    onPressed: () =>
                        context.push(AgencyVerificationScreen.route()),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.brandFamilyMain,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      JobOfferCalculatorStrings.t('joc_fee_mol_link', locale),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Color _minimumGlow(JobOfferMinimumWageComparison comparison) {
    return switch (comparison) {
      JobOfferMinimumWageComparison.belowMinimum => AppColors.warning,
      JobOfferMinimumWageComparison.nearMinimum => AppColors.warning,
      JobOfferMinimumWageComparison.aboveMinimum => AppColors.success,
    };
  }
}
