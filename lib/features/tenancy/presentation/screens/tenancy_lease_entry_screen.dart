import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/presentation/widgets/calculator_form_widgets.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_enums.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_lease_input.dart';
import 'package:raabta/features/tenancy/presentation/l10n/tenancy_strings.dart';
import 'package:raabta/features/tenancy/presentation/widgets/tenancy_widgets.dart';
import 'package:raabta/features/tenancy/providers/tenancy_providers.dart';

class TenancyLeaseEntryScreen extends ConsumerStatefulWidget {
  const TenancyLeaseEntryScreen({super.key});

  @override
  ConsumerState<TenancyLeaseEntryScreen> createState() =>
      _TenancyLeaseEntryScreenState();
}

class _TenancyLeaseEntryScreenState extends ConsumerState<TenancyLeaseEntryScreen> {
  late TextEditingController _rent;
  late TextEditingController _deposit;
  late TextEditingController _landlord;
  TenancyPropertyType _propertyType = TenancyPropertyType.residential;
  TenancyRegistrationStatus? _registration;
  bool? _inVault;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _committeeDecisionDate;
  bool _prefillApplied = false;

  @override
  void initState() {
    super.initState();
    _rent = TextEditingController();
    _deposit = TextEditingController();
    _landlord = TextEditingController();
  }

  @override
  void dispose() {
    _rent.dispose();
    _deposit.dispose();
    _landlord.dispose();
    super.dispose();
  }

  void _applyPrefill(TenancyLeaseInput input) {
    if (_prefillApplied) return;
    _prefillApplied = true;
    _rent.text = input.monthlyRent > 0 ? input.monthlyRent.toStringAsFixed(0) : '';
    _deposit.text =
        input.securityDeposit > 0 ? input.securityDeposit.toStringAsFixed(0) : '';
    _landlord.text = input.landlordName;
    _propertyType = input.propertyType;
    _registration = input.registrationStatus;
    _inVault = input.leaseScannedToVault;
    _startDate = input.leaseStartDate;
    _endDate = input.leaseEndDate;
    _committeeDecisionDate = input.committeeDecisionDate;
  }

  Future<void> _pickCommitteeDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _committeeDecisionDate ?? DateTime.now(),
      firstDate: DateTime(2005),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() => _committeeDecisionDate = picked);
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2005),
      lastDate: DateTime(2040),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    final input = TenancyLeaseInput(
      monthlyRent: double.tryParse(_rent.text.trim()) ?? 0,
      securityDeposit: double.tryParse(_deposit.text.trim()) ?? 0,
      leaseStartDate: _startDate,
      leaseEndDate: _endDate,
      registrationStatus: _registration,
      propertyType: _propertyType,
      landlordName: _landlord.text.trim(),
      leaseScannedToVault: _inVault,
      committeeDecisionDate: _committeeDecisionDate,
    );
    ref.read(tenancyProvider.notifier).updateInput(input);

    final checker = ref.read(tenancyComplianceCheckerProvider);
    await ref.read(tenancyProvider.notifier).runComplianceCheck(checker: checker);

    if (mounted) {
      context.push('/tenancy/result');
    }
  }

  Widget _registrationChip(
    TenancyRegistrationStatus value,
    String label,
    String locale,
  ) {
    final selected = _registration == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _registration = value),
      selectedColor: AppColors.chipLease.withValues(alpha: 0.35),
    );
  }

  Widget _yesNoVault(String locale) {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: Text(TenancyStrings.t('tenancy_form_reg_yes', locale)),
          selected: _inVault == true,
          onSelected: (_) => setState(() => _inVault = true),
        ),
        ChoiceChip(
          label: Text(TenancyStrings.t('tenancy_form_reg_no', locale)),
          selected: _inVault == false,
          onSelected: (_) => setState(() => _inVault = false),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeAsync = ref.watch(tenancyLocaleProvider);
    final isChecking = ref.watch(tenancyProvider).isChecking;

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        _applyPrefill(ref.watch(tenancyProvider).input);

        return GlassScreenScaffold(
          title: TenancyStrings.t('tenancy_form_title', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              TenancyDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.lg),
              CalculatorFormSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CalculatorTextField(
                      controller: _rent,
                      label: TenancyStrings.t('tenancy_form_rent', locale),
                      hint: '5000',
                      icon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CalculatorTextField(
                      controller: _deposit,
                      label: TenancyStrings.t('tenancy_form_deposit', locale),
                      hint: '10000',
                      icon: Icons.account_balance_wallet_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CalculatorTextField(
                      controller: _landlord,
                      label: TenancyStrings.t('tenancy_form_landlord', locale),
                      hint: 'Landlord name',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CalculatorDateRow(
                      startLabel: TenancyStrings.t('tenancy_form_start', locale),
                      endLabel: TenancyStrings.t('tenancy_form_end', locale),
                      startDate: _startDate,
                      endDate: _endDate,
                      onStartTap: () => _pickDate(true),
                      onEndTap: () => _pickDate(false),
                      locale: locale,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      TenancyStrings.t('tenancy_form_property_type', locale),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    CalculatorSegmentRow<TenancyPropertyType>(
                      selected: _propertyType,
                      onSelected: (v) => setState(() => _propertyType = v),
                      options: [
                        CalculatorSegmentOption(
                          value: TenancyPropertyType.residential,
                          label: TenancyStrings.t('tenancy_form_residential', locale),
                        ),
                        CalculatorSegmentOption(
                          value: TenancyPropertyType.commercial,
                          label: TenancyStrings.t('tenancy_form_commercial', locale),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      TenancyStrings.t('tenancy_form_committee_decision', locale),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: _pickCommitteeDate,
                      icon: const Icon(Icons.gavel_outlined, size: 18),
                      label: Text(
                        _committeeDecisionDate == null
                            ? TenancyStrings.t('tenancy_form_pick_date', locale)
                            : MaterialLocalizations.of(context)
                                .formatMediumDate(_committeeDecisionDate!),
                      ),
                    ),
                    if (_committeeDecisionDate != null)
                      TextButton(
                        onPressed: () =>
                            setState(() => _committeeDecisionDate = null),
                        child: Text(
                          TenancyStrings.t('tenancy_form_clear_date', locale),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      TenancyStrings.t('tenancy_form_registration', locale),
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _registrationChip(
                          TenancyRegistrationStatus.yes,
                          TenancyStrings.t('tenancy_form_reg_yes', locale),
                          locale,
                        ),
                        _registrationChip(
                          TenancyRegistrationStatus.no,
                          TenancyStrings.t('tenancy_form_reg_no', locale),
                          locale,
                        ),
                        _registrationChip(
                          TenancyRegistrationStatus.notSure,
                          TenancyStrings.t('tenancy_form_reg_unsure', locale),
                          locale,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      TenancyStrings.t('tenancy_form_vault', locale),
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _yesNoVault(locale),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              GlassPrimaryButton(
                label: isChecking
                    ? '…'
                    : TenancyStrings.t('tenancy_form_submit', locale),
                expand: true,
                accentColor: AppColors.chipLease,
                onPressed: isChecking ? null : _submit,
              ),
            ],
          ),
        );
      },
    );
  }
}
