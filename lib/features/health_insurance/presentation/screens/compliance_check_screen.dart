import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/health_insurance/data/models/compliance_check_model.dart';
import 'package:raabta/features/health_insurance/domain/models/health_insurance_exemption.dart';
import 'package:raabta/features/health_insurance/domain/models/premium_deduction_status.dart';
import 'package:raabta/features/health_insurance/presentation/l10n/health_insurance_strings.dart';
import 'package:raabta/features/health_insurance/presentation/providers/health_insurance_providers.dart';
import 'package:raabta/features/health_insurance/presentation/widgets/health_insurance_widgets.dart';
import 'package:raabta/features/health_insurance/presentation/widgets/insurer_lookup_field.dart';

class ComplianceCheckScreen extends ConsumerStatefulWidget {
  const ComplianceCheckScreen({super.key});

  @override
  ConsumerState<ComplianceCheckScreen> createState() =>
      _ComplianceCheckScreenState();
}

class _ComplianceCheckScreenState extends ConsumerState<ComplianceCheckScreen> {
  PremiumDeductionStatus _premiumStatus = PremiumDeductionStatus.unanswered;
  HealthInsuranceExemptionCategory _exemption =
      HealthInsuranceExemptionCategory.none;
  bool? _hasCard;
  bool? _qidProof;
  bool _hadSwitch = false;
  String _insurerCardLabel = '';
  String _resolvedInsurer = '';
  bool _insurerManualReview = false;
  DateTime? _oldEnd;
  DateTime? _newStart;
  bool _prefillApplied = false;

  bool get _isExemptSession =>
      HealthInsuranceExemptionRules.isExempt(_exemption);

  void _applyPrefill(InsuranceComplianceInput input) {
    if (_prefillApplied) return;
    _prefillApplied = true;
    _premiumStatus = input.premiumDeductionStatus;
    _exemption = input.exemptionCategory;
    _hasCard = input.hasInsuranceCard;
    _qidProof = input.qidRenewalProofProvided;
    _hadSwitch = input.hadInsurerSwitch;
    _insurerCardLabel = input.insurerCardLabel.isNotEmpty
        ? input.insurerCardLabel
        : input.insurerName;
    _resolvedInsurer = input.insurerName;
    _insurerManualReview = input.insurerManualReview;
    _oldEnd = input.previousPolicyEndDate;
    _newStart = input.newPolicyStartDate;
  }

  Future<void> _pickDate(bool isOldEnd) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() {
      if (isOldEnd) {
        _oldEnd = picked;
      } else {
        _newStart = picked;
      }
    });
  }

  Future<void> _submit() async {
    final input = InsuranceComplianceInput(
      premiumDeductionStatus: _premiumStatus,
      exemptionCategory: _exemption,
      hasInsuranceCard: _hasCard,
      insurerName: _resolvedInsurer,
      insurerCardLabel: _insurerCardLabel,
      insurerManualReview: _insurerManualReview,
      qidRenewalProofProvided: _qidProof,
      hadInsurerSwitch: _hadSwitch,
      previousPolicyEndDate: _oldEnd,
      newPolicyStartDate: _newStart,
      currentRenewalYear: DateTime.now().year,
    );
    ref.read(healthInsuranceProvider.notifier).updateInput(input);

    final checker = await ref.read(insuranceComplianceCheckerProvider.future);
    await ref
        .read(healthInsuranceProvider.notifier)
        .runComplianceCheck(checker: checker);

    if (mounted) {
      context.push('/health-insurance/compliance/results');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeAsync = ref.watch(healthInsuranceLocaleProvider);
    final lookupAsync = ref.watch(insurerLookupServiceProvider);
    final isChecking = ref.watch(healthInsuranceProvider).isChecking;

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        _applyPrefill(ref.watch(healthInsuranceProvider).input);

        return GlassScreenScaffold(
          title: HealthInsuranceStrings.t('hi_form_title', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              HealthInsuranceDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.lg),
              Text(
                HealthInsuranceStrings.t('hi_form_exemption_title', locale),
                style: AppTypography.title,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                HealthInsuranceStrings.t('hi_form_exemption_subtitle', locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _exemptionTile(
                HealthInsuranceStrings.t('hi_exemption_none', locale),
                _exemption == HealthInsuranceExemptionCategory.none,
                () => setState(
                  () => _exemption = HealthInsuranceExemptionCategory.none,
                ),
              ),
              for (final category
                  in HealthInsuranceExemptionRules.selectableCategories)
                _exemptionTile(
                  HealthInsuranceStrings.t(
                    HealthInsuranceExemptionRules.labelKey(category),
                    locale,
                  ),
                  _exemption == category,
                  () => setState(() => _exemption = category),
                ),
              if (!_isExemptSession) ...[
                const SizedBox(height: AppSpacing.lg),
                _premiumDeductionTile(locale),
                _yesNoTile(
                  HealthInsuranceStrings.t('hi_form_card_label', locale),
                  _hasCard,
                  (v) => setState(() => _hasCard = v),
                  locale,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  HealthInsuranceStrings.t('hi_form_insurer_label', locale),
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  HealthInsuranceStrings.t('hi_insurer_search_hint', locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                lookupAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => InsurerLookupField(
                    locale: locale,
                    lookupService: null,
                    cardLabel: _insurerCardLabel,
                    onChanged: ({
                      required cardLabel,
                      required resolvedInsurerName,
                      required manualReview,
                      lookup,
                    }) {
                      setState(() {
                        _insurerCardLabel = cardLabel;
                        _resolvedInsurer = resolvedInsurerName;
                        _insurerManualReview = manualReview;
                      });
                    },
                  ),
                  data: (service) => InsurerLookupField(
                    locale: locale,
                    lookupService: service,
                    cardLabel: _insurerCardLabel,
                    onChanged: ({
                      required cardLabel,
                      required resolvedInsurerName,
                      required manualReview,
                      lookup,
                    }) {
                      setState(() {
                        _insurerCardLabel = cardLabel;
                        _resolvedInsurer = resolvedInsurerName;
                        _insurerManualReview = manualReview;
                      });
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _yesNoTile(
                  HealthInsuranceStrings.t('hi_form_qid_label', locale),
                  _qidProof,
                  (v) => setState(() => _qidProof = v),
                  locale,
                ),
                SwitchListTile(
                  title: Text(
                    HealthInsuranceStrings.t('hi_form_switch_label', locale),
                    style: AppTypography.body,
                  ),
                  value: _hadSwitch,
                  onChanged: (v) => setState(() => _hadSwitch = v),
                ),
                if (_hadSwitch) ...[
                  ListTile(
                    tileColor: AppColors.surface.withValues(alpha: 0.4),
                    title: Text(
                      HealthInsuranceStrings.t('hi_form_old_end_label', locale),
                    ),
                    subtitle: Text(_oldEnd?.toString().split(' ').first ?? '—'),
                    trailing: const Icon(Icons.calendar_today_outlined),
                    onTap: () => _pickDate(true),
                  ),
                  ListTile(
                    tileColor: AppColors.surface.withValues(alpha: 0.4),
                    title: Text(
                      HealthInsuranceStrings.t(
                        'hi_form_new_start_label',
                        locale,
                      ),
                    ),
                    subtitle:
                        Text(_newStart?.toString().split(' ').first ?? '—'),
                    trailing: const Icon(Icons.calendar_today_outlined),
                    onTap: () => _pickDate(false),
                  ),
                ],
              ],
              const SizedBox(height: AppSpacing.lg),
              GlassPrimaryButton(
                label: isChecking
                    ? '…'
                    : HealthInsuranceStrings.t('hi_form_submit', locale),
                expand: true,
                icon: Icons.fact_check_outlined,
                onPressed: isChecking ? null : _submit,
                accentColor: AppColors.chipHealthInsurance,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _exemptionTile(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: ListTile(
        dense: true,
        tileColor: selected
            ? AppColors.chipHealthInsurance.withValues(alpha: 0.15)
            : AppColors.surface.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          side: BorderSide(
            color: selected
                ? AppColors.chipHealthInsurance.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
        ),
        title: Text(label, style: AppTypography.bodySmall),
        trailing: selected
            ? Icon(Icons.check_circle, color: AppColors.chipHealthInsurance)
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _premiumDeductionTile(String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          HealthInsuranceStrings.t('hi_form_premium_label', locale),
          style: AppTypography.body,
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            ChoiceChip(
              label: Text(HealthInsuranceStrings.t('hi_yes', locale)),
              selected: _premiumStatus == PremiumDeductionStatus.deductionReported,
              onSelected: (_) => setState(
                () => _premiumStatus = PremiumDeductionStatus.deductionReported,
              ),
            ),
            ChoiceChip(
              label: Text(HealthInsuranceStrings.t('hi_no', locale)),
              selected: _premiumStatus == PremiumDeductionStatus.noDeduction,
              onSelected: (_) => setState(
                () => _premiumStatus = PremiumDeductionStatus.noDeduction,
              ),
            ),
            ChoiceChip(
              label: Text(HealthInsuranceStrings.t('hi_not_sure', locale)),
              selected: _premiumStatus == PremiumDeductionStatus.notSure,
              onSelected: (_) => setState(
                () => _premiumStatus = PremiumDeductionStatus.notSure,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _yesNoTile(
    String label,
    bool? value,
    ValueChanged<bool> onChanged,
    String locale,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.body),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            ChoiceChip(
              label: Text(HealthInsuranceStrings.t('hi_yes', locale)),
              selected: value == true,
              onSelected: (_) => onChanged(true),
            ),
            const SizedBox(width: AppSpacing.sm),
            ChoiceChip(
              label: Text(HealthInsuranceStrings.t('hi_no', locale)),
              selected: value == false,
              onSelected: (_) => onChanged(false),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}
