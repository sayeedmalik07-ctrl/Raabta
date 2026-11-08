import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/domain/models/eosb_enums.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/calculator_form_widgets.dart';
import 'package:raabta/features/prospective_migrant/domain/models/prospective_profile.dart';
import 'package:raabta/features/prospective_migrant/presentation/l10n/prospective_migrant_strings.dart';
import 'package:raabta/features/prospective_migrant/presentation/providers/prospective_migrant_providers.dart';
import 'package:raabta/features/prospective_migrant/presentation/widgets/prospective_flow_actions.dart';

class ProspectiveContractScreen extends ConsumerStatefulWidget {
  const ProspectiveContractScreen({super.key});

  @override
  ConsumerState<ProspectiveContractScreen> createState() =>
      _ProspectiveContractScreenState();
}

class _ProspectiveContractScreenState
    extends ConsumerState<ProspectiveContractScreen> {
  late TextEditingController _company;
  late TextEditingController _role;
  late TextEditingController _salary;
  late TextEditingController _keyTerms;
  EosbContractType _contractType = EosbContractType.unlimited;
  DateTime? _startDate;
  bool _signedConfirm = false;

  @override
  void initState() {
    super.initState();
    _company = TextEditingController();
    _role = TextEditingController();
    _salary = TextEditingController();
    _keyTerms = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  void _hydrate() {
    final profile = ref.read(prospectiveProfileProvider).valueOrNull;
    if (profile == null) return;
    _company.text = profile.contract.companyName;
    _role.text = profile.roleTitle;
    _salary.text = profile.contract.basicSalary > 0
        ? profile.contract.basicSalary.toStringAsFixed(0)
        : '';
    _keyTerms.text = profile.keyTerms;
    _contractType = profile.contract.contractType;
    _startDate = profile.contract.joiningDate;
    _signedConfirm = profile.contractIntakeComplete;
    setState(() {});
  }

  @override
  void dispose() {
    _company.dispose();
    _role.dispose();
    _salary.dispose();
    _keyTerms.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _save({required bool complete}) async {
    final locale = ref.read(prospectiveLocaleProvider);
    if (!_signedConfirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ProspectiveMigrantStrings.t('pm_signed_confirm', locale)),
        ),
      );
      return;
    }
    final salary = double.tryParse(_salary.text.trim()) ?? 0;
    if (_company.text.trim().isEmpty || salary <= 0 || _startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employer, salary, and start date are required')),
      );
      return;
    }

    final existing = ref.read(prospectiveProfileProvider).valueOrNull ??
        const ProspectiveProfile();
    final contract = existing.contract.copyWith(
      companyName: _company.text.trim(),
      basicSalary: salary,
      totalSalary: salary,
      contractType: _contractType,
      joiningDate: _startDate,
      country: 'Qatar',
    );

    await ref.read(prospectiveProfileProvider.notifier).save(
          existing.copyWith(
            roleTitle: _role.text.trim(),
            keyTerms: _keyTerms.text.trim(),
            contract: contract,
            contractIntakeComplete: complete,
          ),
        );
    if (!mounted) return;
    if (complete) context.push('/prospective/preview');
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(prospectiveLocaleProvider);

    return GlassScreenScaffold(
      title: ProspectiveMigrantStrings.t('pm_contract_heading', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          Text(
            ProspectiveMigrantStrings.t('pm_contract_desc', locale),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          CalculatorFormSection(
            child: Column(
              children: [
                CalculatorTextField(
                  controller: _company,
                  label: EosbStrings.t('eosb_company_name', locale),
                  icon: Icons.business_outlined,
                ),
                const SizedBox(height: AppSpacing.md),
                CalculatorTextField(
                  controller: _role,
                  label: ProspectiveMigrantStrings.t('pm_role_label', locale),
                  icon: Icons.work_outline,
                ),
                const SizedBox(height: AppSpacing.md),
                CalculatorTextField(
                  controller: _salary,
                  label: ProspectiveMigrantStrings.t('pm_salary_label', locale),
                  prefix: 'QAR ',
                  keyboardType: TextInputType.number,
                  icon: Icons.payments_outlined,
                ),
                const SizedBox(height: AppSpacing.md),
                CalculatorPickerField<String>(
                  label: ProspectiveMigrantStrings.t('pm_start_date_label', locale),
                  valueLabel: _startDate == null
                      ? '—'
                      : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                  onTap: _pickStartDate,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Contract type',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                CalculatorSegmentRow<EosbContractType>(
                  selected: _contractType,
                  onSelected: (v) => setState(() => _contractType = v),
                  options: [
                    CalculatorSegmentOption(
                      value: EosbContractType.unlimited,
                      label: EosbStrings.t('tpl_eosb_contract_unlimited', locale),
                    ),
                    CalculatorSegmentOption(
                      value: EosbContractType.limited,
                      label: EosbStrings.t('tpl_eosb_contract_limited', locale),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                CalculatorTextField(
                  controller: _keyTerms,
                  label: ProspectiveMigrantStrings.t('pm_key_terms_label', locale),
                  icon: Icons.notes_outlined,
                ),
                const SizedBox(height: AppSpacing.md),
                CheckboxListTile(
                  value: _signedConfirm,
                  onChanged: (v) => setState(() => _signedConfirm = v ?? false),
                  title: Text(
                    ProspectiveMigrantStrings.t('pm_signed_confirm', locale),
                    style: AppTypography.bodySmall,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GlassPrimaryButton(
            label: ProspectiveMigrantStrings.t('pm_continue', locale),
            expand: true,
            onPressed: () => _save(complete: true),
          ),
          const SizedBox(height: AppSpacing.lg),
          const ProspectiveFlowActions(),
        ],
      ),
    );
  }
}
