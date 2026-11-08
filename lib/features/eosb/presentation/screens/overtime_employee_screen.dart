import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/domain/rules/overtime_rules.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/before_you_sign_section.dart';
import 'package:raabta/features/eosb/presentation/widgets/employer_track_record_panel.dart';
import 'package:raabta/features/eosb/presentation/widgets/calculator_form_widgets.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_disclaimer_banner.dart';
import 'package:raabta/features/eosb/presentation/widgets/overtime_employer_comparison_fields.dart';
import 'package:raabta/core/mixins/draft_persistence_mixin.dart';
import 'package:raabta/services/drafts/draft_box_keys.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/eosb/providers/overtime_truth_providers.dart';

class OvertimeEmployeeScreen extends ConsumerStatefulWidget {
  const OvertimeEmployeeScreen({super.key});

  @override
  ConsumerState<OvertimeEmployeeScreen> createState() =>
      _OvertimeEmployeeScreenState();
}

class _OvertimeEmployeeScreenState extends ConsumerState<OvertimeEmployeeScreen>
    with DraftPersistenceMixin {
  late TextEditingController _name;
  late TextEditingController _employeeId;
  late TextEditingController _company;
  late TextEditingController _jobTitle;
  late TextEditingController _project;
  late TextEditingController _basicSalary;
  late TextEditingController _totalSalary;
  late TextEditingController _hoursPerDay;
  late TextEditingController _daysPerWeek;
  late TextEditingController _monthlyDays;

  String _countryCode = 'QA';
  OvertimeEmploymentType _employment = OvertimeEmploymentType.permanent;
  OvertimeShiftType _shift = OvertimeShiftType.normal;
  DateTime? _joining;
  bool _ramadan = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(overtimeTruthProvider).record.profile;
    _name = TextEditingController(text: profile.employeeName);
    _employeeId = TextEditingController(text: profile.employeeId);
    _company = TextEditingController(text: profile.companyName);
    _jobTitle = TextEditingController(text: profile.jobTitle);
    _project = TextEditingController(text: profile.project);
    _basicSalary = TextEditingController(
      text: profile.basicSalary > 0 ? profile.basicSalary.toStringAsFixed(0) : '',
    );
    _totalSalary = TextEditingController(
      text: profile.totalSalary > 0 ? profile.totalSalary.toStringAsFixed(0) : '',
    );
    _hoursPerDay = TextEditingController(text: '${profile.workingHoursPerDay}');
    _daysPerWeek = TextEditingController(text: '${profile.workingDaysPerWeek}');
    _monthlyDays = TextEditingController(text: '${profile.monthlyWorkingDays}');
    _countryCode = profile.countryCode;
    _employment = profile.employmentType;
    _shift = profile.shiftType;
    _joining = profile.joiningDate;
    _ramadan = profile.isRamadanPeriod;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await setupDraftPersistence(
        formId: DraftBoxKeys.overtimeEmployeeProfile,
        controllers: [
          _name,
          _employeeId,
          _company,
          _jobTitle,
          _project,
          _basicSalary,
          _totalSalary,
          _hoursPerDay,
          _daysPerWeek,
          _monthlyDays,
        ],
        serialize: _serializeDraft,
        applyDraft: _applyDraft,
      );
    });
  }

  Map<String, dynamic> _serializeDraft() => {
        'name': _name.text,
        'employeeId': _employeeId.text,
        'company': _company.text,
        'jobTitle': _jobTitle.text,
        'project': _project.text,
        'basicSalary': _basicSalary.text,
        'totalSalary': _totalSalary.text,
        'hoursPerDay': _hoursPerDay.text,
        'daysPerWeek': _daysPerWeek.text,
        'monthlyDays': _monthlyDays.text,
        'countryCode': _countryCode,
        'employment': _employment.name,
        'shift': _shift.name,
        'joining': _joining?.toIso8601String(),
        'ramadan': _ramadan,
      };

  void _applyDraft(Map<String, dynamic> data) {
    setState(() {
      _name.text = data['name']?.toString() ?? '';
      _employeeId.text = data['employeeId']?.toString() ?? '';
      _company.text = data['company']?.toString() ?? '';
      _jobTitle.text = data['jobTitle']?.toString() ?? '';
      _project.text = data['project']?.toString() ?? '';
      _basicSalary.text = data['basicSalary']?.toString() ?? '';
      _totalSalary.text = data['totalSalary']?.toString() ?? '';
      _hoursPerDay.text = data['hoursPerDay']?.toString() ?? '';
      _daysPerWeek.text = data['daysPerWeek']?.toString() ?? '';
      _monthlyDays.text = data['monthlyDays']?.toString() ?? '';
      _countryCode = data['countryCode']?.toString() ?? 'QA';
      _employment = OvertimeEmploymentType.values.firstWhere(
        (e) => e.name == data['employment'],
        orElse: () => OvertimeEmploymentType.permanent,
      );
      _shift = OvertimeShiftType.values.firstWhere(
        (e) => e.name == data['shift'],
        orElse: () => OvertimeShiftType.normal,
      );
      _joining = DateTime.tryParse(data['joining']?.toString() ?? '');
      _ramadan = data['ramadan'] == true;
    });
  }

  @override
  void dispose() {
    disposeDraftMixin();
    _name.dispose();
    _employeeId.dispose();
    _company.dispose();
    _jobTitle.dispose();
    _project.dispose();
    _basicSalary.dispose();
    _totalSalary.dispose();
    _hoursPerDay.dispose();
    _daysPerWeek.dispose();
    _monthlyDays.dispose();
    super.dispose();
  }

  double _parse(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;
  int _parseInt(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  String _countryName() {
    return OvertimeRulesRegistry.all
        .firstWhere((r) => r.countryCode == _countryCode)
        .countryName;
  }

  Future<void> _pickCountry(String locale) async {
    final picked = await showCalculatorPickerSheet<String>(
      context: context,
      title: EosbStrings.t('ot_country', locale),
      selected: _countryCode,
      options: OvertimeRulesRegistry.all
          .map(
            (r) => CalculatorPickerOption(
              value: r.countryCode,
              label: r.isPreview
                  ? '${r.countryName} (${EosbStrings.t('ot_country_preview', locale)})'
                  : r.countryName,
            ),
          )
          .toList(),
    );
    if (picked != null) {
      setState(() => _countryCode = picked);
      notifyDraftChanged();
      final rules = OvertimeRulesRegistry.forCountry(picked);
      if (rules.isPreview && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(EosbStrings.t('ot_country_preview_note', locale)),
          ),
        );
      }
    }
  }

  Future<void> _pickJoiningDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _joining ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _joining = picked);
      notifyDraftChanged();
    }
  }

  Future<void> _save(String locale) async {
    final rules = OvertimeRulesRegistry.forCountry(_countryCode);
    final profile = OvertimeEmployeeProfile(
      employeeName: _name.text.trim(),
      employeeId: _employeeId.text.trim(),
      companyName: _company.text.trim(),
      jobTitle: _jobTitle.text.trim(),
      project: _project.text.trim(),
      countryCode: _countryCode,
      employmentType: _employment,
      joiningDate: _joining,
      basicSalary: _parse(_basicSalary),
      totalSalary: _parse(_totalSalary),
      workingHoursPerDay: _parseInt(_hoursPerDay).clamp(1, 16),
      workingDaysPerWeek: _parseInt(_daysPerWeek).clamp(1, 7),
      monthlyWorkingDays: _parseInt(_monthlyDays).clamp(1, 31),
      shiftType: _shift,
      currency: rules.currency,
      isRamadanPeriod: _ramadan,
    );
    ref.read(overtimeTruthProvider.notifier).updateProfile(profile);
    ref.read(overtimeTruthProvider.notifier).calculate();
    await clearFormDraft();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(EosbStrings.t('ot_profile_saved', locale))),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final localeAsync = ref.watch(eosbLocaleProvider);
    final basic = _parse(_basicSalary);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        return GlassScreenScaffold(
          title: EosbStrings.t('ot_employee_info', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          body: CalculatorScreenLayout(
            footer: CalculatorStickyBar(
              label: EosbStrings.t('ot_save_profile', locale),
              icon: Icons.save_outlined,
              accentColor: AppColors.accentGold,
              onPressed: () => _save(locale),
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              children: [
              if (draftRestoreBanner != null) draftRestoreBanner!,
              EosbDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.lg),
              CalculatorLiveHero(
                title: EosbStrings.t('ot_basic_salary', locale),
                primaryValue: basic > 0 ? formatEosbCurrency(basic) : '—',
                secondaryLabel: _name.text.isNotEmpty ? 'Employee' : null,
                secondaryValue: _name.text.isNotEmpty ? _name.text : null,
                accentColor: AppColors.accentGold,
                chips: [
                  CalculatorMetricChip(
                    label: _countryName(),
                    color: AppColors.cyanGlow,
                    icon: Icons.public,
                  ),
                  if (_ramadan)
                    const CalculatorMetricChip(
                      label: 'Ramadan',
                      color: AppColors.purpleGlow,
                      icon: Icons.nightlight_round,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              CalculatorSectionHeader(
                title: EosbStrings.t('ot_section_identity', locale),
                subtitle: EosbStrings.t('ot_section_identity_sub', locale),
                icon: Icons.badge_outlined,
              ),
              CalculatorFormSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CalculatorTextField(
                      controller: _name,
                      label: EosbStrings.t('ot_emp_name', locale),
                      hint: 'Ahmed Ali',
                      icon: Icons.person_outline_rounded,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CalculatorTextField(
                      controller: _employeeId,
                      label: EosbStrings.t('ot_emp_id', locale),
                      hint: 'EMP-001',
                      icon: Icons.numbers_rounded,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CalculatorTextField(
                      controller: _company,
                      label: EosbStrings.t('eosb_company_name', locale),
                      hint: 'Company',
                      icon: Icons.business_outlined,
                      onChanged: (_) => setState(() {}),
                    ),
                    EmployerTrackRecordPanel(
                      companyName: _company.text,
                      locale: locale,
                    ),
                    BeforeYouSignSection(
                      locale: locale,
                      employerName: _company.text,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CalculatorTextField(
                            controller: _jobTitle,
                            label: EosbStrings.t('ot_job_title', locale),
                            hint: 'Technician',
                            icon: Icons.work_outline_rounded,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: CalculatorTextField(
                            controller: _project,
                            label: EosbStrings.t('ot_project', locale),
                            hint: 'Lusail',
                            icon: Icons.location_city_outlined,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              CalculatorSectionHeader(
                title: EosbStrings.t('ot_section_jurisdiction', locale),
                subtitle: EosbStrings.t('ot_section_jurisdiction_sub', locale),
                icon: Icons.public,
                accentColor: AppColors.cyanGlow,
              ),
              CalculatorFormSection(
                glowColor: AppColors.cyanGlow,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CalculatorPickerField<String>(
                      label: EosbStrings.t('ot_country', locale),
                      valueLabel: _countryName(),
                      onTap: () => _pickCountry(locale),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CalculatorPickerField<OvertimeEmploymentType>(
                      label: EosbStrings.t('ot_employment_type', locale),
                      valueLabel: _employment.name,
                      onTap: () async {
                        final picked =
                            await showCalculatorPickerSheet<OvertimeEmploymentType>(
                          context: context,
                          title: EosbStrings.t('ot_employment_type', locale),
                          selected: _employment,
                          options: OvertimeEmploymentType.values
                              .map(
                                (e) => CalculatorPickerOption(
                                  value: e,
                                  label: e.name,
                                ),
                              )
                              .toList(),
                        );
                        if (picked != null) {
                          setState(() => _employment = picked);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    GlassContainer(
                      onTap: _pickJoiningDate,
                      borderRadius: AppSpacing.radiusSm,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  EosbStrings.t('ot_joining_date', locale),
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                Text(
                                  _joining == null
                                      ? EosbStrings.t('eosb_select_date', locale)
                                      : '${_joining!.day.toString().padLeft(2, '0')}/'
                                          '${_joining!.month.toString().padLeft(2, '0')}/'
                                          '${_joining!.year}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textTertiary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      EosbStrings.t('ot_shift_type_label', locale),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    CalculatorSegmentRow<OvertimeShiftType>(
                      selected: _shift,
                      onSelected: (v) => setState(() => _shift = v),
                      options: [
                        CalculatorSegmentOption(
                          value: OvertimeShiftType.normal,
                          label: EosbStrings.t('ot_shift_normal', locale),
                        ),
                        CalculatorSegmentOption(
                          value: OvertimeShiftType.night,
                          label: EosbStrings.t('ot_shift_night', locale),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              CalculatorSectionHeader(
                title: EosbStrings.t('ot_section_compensation', locale),
                subtitle: EosbStrings.t('ot_section_compensation_sub', locale),
                icon: Icons.schedule_rounded,
                accentColor: AppColors.accentGold,
              ),
              CalculatorFormSection(
                glowColor: AppColors.accentGold,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CalculatorTextField(
                      controller: _basicSalary,
                      label: EosbStrings.t('ot_basic_salary', locale),
                      hint: '3,000',
                      prefix: 'QAR ',
                      large: true,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CalculatorTextField(
                      controller: _totalSalary,
                      label: EosbStrings.t('ot_total_salary', locale),
                      hint: '3,500',
                      prefix: 'QAR ',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CalculatorTextField(
                            controller: _hoursPerDay,
                            label: EosbStrings.t('ot_hours_per_day', locale),
                            hint: '8',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: CalculatorTextField(
                            controller: _daysPerWeek,
                            label: EosbStrings.t('ot_working_days', locale),
                            hint: '6',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CalculatorTextField(
                      controller: _monthlyDays,
                      label: EosbStrings.t('ot_monthly_days', locale),
                      hint: '26',
                      icon: Icons.calendar_view_month_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    CalculatorToggleTile(
                      title: EosbStrings.t('ot_ramadan', locale),
                      value: _ramadan,
                      icon: Icons.nightlight_round,
                      onChanged: (v) => setState(() => _ramadan = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              OvertimeEmployerComparisonFields(locale: locale),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
        );
      },
    );
  }
}
