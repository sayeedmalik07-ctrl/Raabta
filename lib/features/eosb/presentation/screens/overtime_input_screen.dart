import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/before_you_sign_section.dart';
import 'package:raabta/features/eosb/presentation/widgets/employer_track_record_panel.dart';
import 'package:raabta/features/eosb/presentation/widgets/calculator_form_widgets.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_disclaimer_banner.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/core/mixins/draft_persistence_mixin.dart';
import 'package:raabta/services/drafts/draft_box_keys.dart';
import 'package:raabta/features/eosb/providers/overtime_truth_providers.dart';

class OvertimeInputScreen extends ConsumerStatefulWidget {
  const OvertimeInputScreen({super.key});

  @override
  ConsumerState<OvertimeInputScreen> createState() => _OvertimeInputScreenState();
}

class _OvertimeInputScreenState extends ConsumerState<OvertimeInputScreen>
    with DraftPersistenceMixin {
  late TextEditingController _company;
  late TextEditingController _salary;
  late TextEditingController _totalHours;
  late TextEditingController _weekdayOt;
  late TextEditingController _restDay;
  late TextEditingController _holiday;
  late TextEditingController _employerPaid;
  late TextEditingController _employerHours;
  late TextEditingController _workingDays;

  DateTime? _start;
  DateTime? _end;
  bool _ramadan = false;
  OvertimeInputMode _mode = OvertimeInputMode.simple;

  @override
  void initState() {
    super.initState();
    _company = TextEditingController();
    _salary = TextEditingController();
    _totalHours = TextEditingController();
    _weekdayOt = TextEditingController();
    _restDay = TextEditingController();
    _holiday = TextEditingController();
    _employerPaid = TextEditingController();
    _employerHours = TextEditingController();
    _workingDays = TextEditingController(text: '6');
    _end = DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await setupDraftPersistence(
        formId: DraftBoxKeys.overtimeInput,
        controllers: [
          _company,
          _salary,
          _totalHours,
          _weekdayOt,
          _restDay,
          _holiday,
          _employerPaid,
          _employerHours,
          _workingDays,
        ],
        serialize: _serializeDraft,
        applyDraft: _applyDraft,
      );
      if (!mounted || hasPendingDraftRestore) return;
      final input = ref.read(overtimeTruthProvider).input;
      _company.text = input.companyName;
      _salary.text =
          input.basicSalary > 0 ? input.basicSalary.toStringAsFixed(0) : '';
      _totalHours.text = input.totalHoursWorked > 0
          ? input.totalHoursWorked.toStringAsFixed(0)
          : '';
      _weekdayOt.text = input.weekdayOvertimeHours > 0
          ? input.weekdayOvertimeHours.toStringAsFixed(0)
          : '';
      _restDay.text =
          input.restDayHours > 0 ? input.restDayHours.toStringAsFixed(0) : '';
      _holiday.text = input.publicHolidayHours > 0
          ? input.publicHolidayHours.toStringAsFixed(0)
          : '';
      _employerPaid.text = input.employerPaidOvertime > 0
          ? input.employerPaidOvertime.toStringAsFixed(0)
          : '';
      _employerHours.text = input.employerReportedOvertimeHours > 0
          ? input.employerReportedOvertimeHours.toStringAsFixed(0)
          : '';
      _workingDays.text = '${input.workingDaysPerWeek}';
      setState(() {
        _start = input.periodStart;
        _end = input.periodEnd ?? DateTime.now();
        _ramadan = input.isRamadanPeriod;
        _mode = input.inputMode;
      });
    });
  }

  Map<String, dynamic> _serializeDraft() => {
        'company': _company.text,
        'salary': _salary.text,
        'totalHours': _totalHours.text,
        'weekdayOt': _weekdayOt.text,
        'restDay': _restDay.text,
        'holiday': _holiday.text,
        'employerPaid': _employerPaid.text,
        'employerHours': _employerHours.text,
        'workingDays': _workingDays.text,
        'start': _start?.toIso8601String(),
        'end': _end?.toIso8601String(),
        'ramadan': _ramadan,
        'mode': _mode.name,
      };

  void _applyDraft(Map<String, dynamic> data) {
    _company.text = data['company']?.toString() ?? '';
    _salary.text = data['salary']?.toString() ?? '';
    _totalHours.text = data['totalHours']?.toString() ?? '';
    _weekdayOt.text = data['weekdayOt']?.toString() ?? '';
    _restDay.text = data['restDay']?.toString() ?? '';
    _holiday.text = data['holiday']?.toString() ?? '';
    _employerPaid.text = data['employerPaid']?.toString() ?? '';
    _employerHours.text = data['employerHours']?.toString() ?? '';
    _workingDays.text = data['workingDays']?.toString() ?? '6';
    _start = DateTime.tryParse(data['start']?.toString() ?? '');
    _end = DateTime.tryParse(data['end']?.toString() ?? '') ?? DateTime.now();
    _ramadan = data['ramadan'] == true;
    _mode = OvertimeInputMode.values.byName(
      data['mode']?.toString() ?? OvertimeInputMode.simple.name,
    );
    setState(() {});
  }

  @override
  void dispose() {
    disposeDraftMixin();
    _company.dispose();
    _salary.dispose();
    _totalHours.dispose();
    _weekdayOt.dispose();
    _restDay.dispose();
    _holiday.dispose();
    _employerPaid.dispose();
    _employerHours.dispose();
    _workingDays.dispose();
    super.dispose();
  }

  double _parse(TextEditingController c) =>
      double.tryParse(c.text.trim()) ?? 0;

  int _parseInt(TextEditingController c) =>
      int.tryParse(c.text.trim()) ?? 6;

  void _onChanged() {
    notifyDraftChanged();
    setState(() {});
  }

  OvertimeTruthInput _buildInput() {
    return OvertimeTruthInput(
      companyName: _company.text.trim(),
      basicSalary: _parse(_salary),
      periodStart: _start,
      periodEnd: _end,
      workingDaysPerWeek: _parseInt(_workingDays).clamp(1, 7).toInt(),
      isRamadanPeriod: _ramadan,
      inputMode: _mode,
      totalHoursWorked: _parse(_totalHours),
      weekdayOvertimeHours: _parse(_weekdayOt),
      restDayHours: _parse(_restDay),
      publicHolidayHours: _parse(_holiday),
      employerPaidOvertime: _parse(_employerPaid),
      employerReportedOvertimeHours: _parse(_employerHours),
    );
  }

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart ? (_start ?? DateTime.now()) : (_end ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2010),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
    notifyDraftChanged();
  }

  Future<void> _calculate() async {
    ref.read(overtimeTruthProvider.notifier).updateInput(_buildInput());
    final result =
        await ref.read(overtimeTruthProvider.notifier).calculateLegacy(_buildInput());
    if (!mounted) return;
    if (result != null) {
      await clearFormDraft();
      context.push('/eosb/overtime/summary');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeAsync = ref.watch(eosbLocaleProvider);
    final isCalculating = ref.watch(overtimeTruthProvider).isCalculating;
    final salary = _parse(_salary);
    final hourly = salary > 0 ? salary / 30 / 8 : 0.0;

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => GlassScreenScaffold(
        title: EosbStrings.t('ot_nav_title', 'English'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        body: Center(
          child: Text(EosbStrings.t('ot_locale_load_error', 'English')),
        ),
      ),
      data: (locale) {
        return GlassScreenScaffold(
          title: EosbStrings.t('ot_start_calc', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          body: CalculatorScreenLayout(
            footer: CalculatorStickyBar(
              label: EosbStrings.t('eosb_calculate_cta', locale),
              loading: isCalculating,
              accentColor: AppColors.accentGold,
              onPressed: _calculate,
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              children: [
              EosbDisclaimerBanner(locale: locale),
              if (draftRestoreBanner != null) ...[
                const SizedBox(height: AppSpacing.md),
                draftRestoreBanner!,
              ],
              const SizedBox(height: AppSpacing.lg),
              CalculatorLiveHero(
                title: EosbStrings.t('ot_hourly_rate', locale),
                primaryValue: hourly > 0 ? formatEosbCurrency(hourly) : '—',
                secondaryLabel: salary > 0 ? 'Basic salary' : null,
                secondaryValue:
                    salary > 0 ? formatEosbCurrency(salary) : null,
                accentColor: AppColors.accentGold,
                chips: [
                  if (_ramadan)
                    const CalculatorMetricChip(
                      label: 'Ramadan period',
                      color: AppColors.purpleGlow,
                      icon: Icons.nightlight_round,
                    ),
                  CalculatorMetricChip(
                    label: _mode == OvertimeInputMode.simple
                        ? EosbStrings.t('ot_simple_mode', locale)
                        : EosbStrings.t('ot_detailed_mode', locale),
                    color: AppColors.cyanGlow,
                    icon: Icons.tune_rounded,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              CalculatorFeatureAction(
                title: EosbStrings.t('ot_calendar_mode', locale),
                subtitle: 'Log daily hours with calendar precision',
                icon: Icons.calendar_month_outlined,
                accentColor: AppColors.emeraldGlow,
                onTap: () => context.push('/eosb/overtime/calendar'),
              ),
              const SizedBox(height: AppSpacing.xl),
              const CalculatorSectionHeader(
                title: 'Employer & salary',
                subtitle: 'Used to derive your legal hourly rate',
                icon: Icons.account_balance_wallet_outlined,
                accentColor: AppColors.accentGold,
              ),
              CalculatorFormSection(
                glowColor: AppColors.accentGold,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CalculatorTextField(
                      controller: _company,
                      label: EosbStrings.t('eosb_company_name', locale),
                      hint: 'Company name',
                      icon: Icons.business_outlined,
                      onChanged: (_) => _onChanged(),
                    ),
                    EmployerTrackRecordPanel(
                      companyName: _company.text,
                      locale: locale,
                    ),
                    BeforeYouSignSection(
                      locale: locale,
                      employerName: _company.text,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CalculatorTextField(
                      controller: _salary,
                      label: EosbStrings.t('ot_basic_salary', locale),
                      hint: '3,000',
                      prefix: 'QAR ',
                      large: true,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _onChanged(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const CalculatorSectionHeader(
                title: 'Pay period',
                subtitle: 'Month or custom range',
                icon: Icons.date_range_outlined,
              ),
              CalculatorFormSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CalculatorDateRow(
                      startLabel: EosbStrings.t('ot_period_start', locale),
                      endLabel: EosbStrings.t('ot_period_end', locale),
                      startDate: _start,
                      endDate: _end,
                      onStartTap: () => _pickDate(true),
                      onEndTap: () => _pickDate(false),
                      locale: locale,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CalculatorTextField(
                      controller: _workingDays,
                      label: EosbStrings.t('ot_working_days', locale),
                      hint: '6',
                      icon: Icons.view_week_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _onChanged(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    CalculatorToggleTile(
                      title: EosbStrings.t('ot_ramadan', locale),
                      subtitle: 'Reduced working hours apply',
                      value: _ramadan,
                      icon: Icons.nightlight_round,
                      onChanged: (v) {
                        setState(() => _ramadan = v);
                        notifyDraftChanged();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const CalculatorSectionHeader(
                title: 'Hours worked',
                subtitle: 'Simple total or detailed breakdown',
                icon: Icons.more_time_rounded,
                accentColor: AppColors.cyanGlow,
              ),
              CalculatorFormSection(
                glowColor: AppColors.cyanGlow,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CalculatorSegmentRow<OvertimeInputMode>(
                      selected: _mode,
                      onSelected: (v) {
                        setState(() => _mode = v);
                        notifyDraftChanged();
                      },
                      options: [
                        CalculatorSegmentOption(
                          value: OvertimeInputMode.simple,
                          label: EosbStrings.t('ot_simple_mode', locale),
                        ),
                        CalculatorSegmentOption(
                          value: OvertimeInputMode.detailed,
                          label: EosbStrings.t('ot_detailed_mode', locale),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_mode == OvertimeInputMode.simple)
                      CalculatorTextField(
                        controller: _totalHours,
                        label: EosbStrings.t('ot_total_hours', locale),
                        hint: '220',
                        icon: Icons.schedule_rounded,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _onChanged(),
                      )
                    else ...[
                      CalculatorTextField(
                        controller: _weekdayOt,
                        label: EosbStrings.t('ot_weekday_hours', locale),
                        hint: '0',
                        icon: Icons.work_history_outlined,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _onChanged(),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      CalculatorTextField(
                        controller: _restDay,
                        label: EosbStrings.t('ot_restday_hours', locale),
                        hint: '0',
                        icon: Icons.weekend_outlined,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _onChanged(),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      CalculatorTextField(
                        controller: _holiday,
                        label: EosbStrings.t('ot_holiday_hours', locale),
                        hint: '0',
                        icon: Icons.celebration_outlined,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _onChanged(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const CalculatorSectionHeader(
                title: 'Employer records',
                subtitle: 'Compare what you were paid vs reported',
                icon: Icons.receipt_long_outlined,
              ),
              CalculatorFormSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CalculatorTextField(
                      controller: _employerPaid,
                      label: EosbStrings.t('ot_employer_paid', locale),
                      hint: '0',
                      prefix: 'QAR ',
                      icon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _onChanged(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CalculatorTextField(
                      controller: _employerHours,
                      label: EosbStrings.t('ot_employer_hours', locale),
                      hint: '0',
                      icon: Icons.timer_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _onChanged(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
        );
      },
    );
  }
}
