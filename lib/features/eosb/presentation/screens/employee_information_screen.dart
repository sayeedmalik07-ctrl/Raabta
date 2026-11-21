import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_enums.dart';
import 'package:raabta/features/eosb/domain/rules/employment_coverage_rules.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/before_you_sign_section.dart';
import 'package:raabta/features/eosb/presentation/widgets/employer_track_record_panel.dart';
import 'package:raabta/features/eosb/presentation/widgets/calculator_form_widgets.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_article_62_assessment_section.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_disclaimer_banner.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/core/mixins/draft_persistence_mixin.dart';
import 'package:raabta/features/eosb/services/eosb_analytics_service.dart';
import 'package:raabta/features/onboarding/l10n/onboarding_strings.dart';
import 'package:raabta/features/onboarding/providers/onboarding_providers.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/features/referral/presentation/widgets/referral_invite_banner.dart';
import 'package:raabta/services/drafts/draft_box_keys.dart';
import 'package:raabta/services/referral/referral_service.dart';

class EmployeeInformationScreen extends ConsumerStatefulWidget {
  const EmployeeInformationScreen({
    super.key,
    this.fromOnboarding = false,
    this.referralCode,
  });

  final bool fromOnboarding;
  final String? referralCode;

  @override
  ConsumerState<EmployeeInformationScreen> createState() =>
      _EmployeeInformationScreenState();
}

class _EmployeeInformationScreenState
    extends ConsumerState<EmployeeInformationScreen>
    with DraftPersistenceMixin {
  late TextEditingController _basicSalary;
  late TextEditingController _finalBasicSalary;
  late TextEditingController _totalSalary;
  late TextEditingController _unusedLeave;
  late TextEditingController _overtimeHours;
  late TextEditingController _pendingSalary;
  late TextEditingController _employerOffer;
  late TextEditingController _otherBenefits;
  late TextEditingController _companyName;

  EosbContractType _contractType = EosbContractType.unlimited;
  EosbEmploymentCategory _employmentCategory = EosbEmploymentCategory.fullTime;
  bool _showReferenceCalculation = false;
  EosbTerminationType _termination = EosbTerminationType.employerTermination;
  EosbSummaryDismissalGround _summaryDismissalGround =
      EosbSummaryDismissalGround.none;
  bool _summaryDismissalConfirmed = false;
  bool _dismissalReviewExpanded = false;
  bool _dismissalReviewSkipped = false;
  bool? _dismissalReviewReasonGiven;
  bool? _dismissalReviewMatchesArt61;
  bool? _dismissalReviewProcessFollowed;
  DateTime? _joining;
  DateTime? _lastDay;
  bool _noticeServed = true;
  bool? _art49NoticeGiven;
  DateTime? _contractTerminationDate;
  DateTime? _dateOfLeavingWork;
  bool _contractTerminationSameAsLast = false;
  bool _dateOfLeavingSameAsLast = false;
  bool _basicSalaryChanged = false;
  DateTime? _basicSalaryChangeDate;
  bool _returnTicket = false;
  bool _familySponsored = false;
  bool _consent = false;
  int _dependents = 0;
  bool _onboardingPrefillApplied = false;

  bool get _fromOnboarding => widget.fromOnboarding;

  void _applyOnboardingPrefill() {
    if (_onboardingPrefillApplied) return;
    final qualifier = ref.read(onboardingQualifierProvider);
    final lastDay = DateTime.now();
    final joining = lastDay.subtract(
      Duration(days: (qualifier.approximateYears * 365.25).round()),
    );
    _onboardingPrefillApplied = true;
    setState(() {
      _contractType = qualifier.contractType;
      _joining = joining;
      _lastDay = lastDay;
    });
    ref.read(eosbProvider.notifier).updateInput(
          ref.read(eosbProvider).input.copyWith(
                contractType: qualifier.contractType,
                joiningDate: joining,
                lastWorkingDate: lastDay,
              ),
        );
  }

  @override
  void initState() {
    super.initState();
    _basicSalary = TextEditingController();
    _finalBasicSalary = TextEditingController();
    _totalSalary = TextEditingController();
    _unusedLeave = TextEditingController(text: '0');
    _overtimeHours = TextEditingController(text: '0');
    _pendingSalary = TextEditingController(text: '0');
    _employerOffer = TextEditingController();
    _otherBenefits = TextEditingController(text: '0');
    _companyName = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        await setupDraftPersistence(
          formId: DraftBoxKeys.eosbEmployeeInfo,
          controllers: [
            _basicSalary,
            _totalSalary,
            _unusedLeave,
            _overtimeHours,
            _pendingSalary,
            _employerOffer,
            _otherBenefits,
            _companyName,
          ],
          serialize: _serializeDraft,
          applyDraft: _applyDraft,
        );
      } catch (_) {
        // Draft restore is optional — never block the calculator UI.
      }
      if (!mounted || hasPendingDraftRestore) return;
      final input = ref.read(eosbProvider).input;
      _basicSalary.text =
          input.basicSalary > 0 ? input.basicSalary.toStringAsFixed(0) : '';
      _totalSalary.text =
          input.totalSalary > 0 ? input.totalSalary.toStringAsFixed(0) : '';
      _unusedLeave.text = input.unusedLeaveDays.toString();
      _overtimeHours.text = input.overtimeHours.toString();
      _pendingSalary.text = input.pendingSalary.toString();
      _employerOffer.text = input.employerOffer?.toStringAsFixed(0) ?? '';
      _otherBenefits.text = input.otherContractualBenefits.toString();
      _companyName.text = input.companyName;
      setState(() {
        _contractType = input.contractType;
        _employmentCategory = input.employmentCategory;
        _showReferenceCalculation = input.showStandardEmployeeReference;
        _termination = input.terminationType;
        _summaryDismissalGround = input.summaryDismissalGround;
        _summaryDismissalConfirmed = input.summaryDismissalGroundConfirmed;
        _dismissalReviewSkipped = input.dismissalReviewSkipped;
        _dismissalReviewReasonGiven = input.dismissalReviewReasonGiven;
        _dismissalReviewMatchesArt61 = input.dismissalReviewMatchesArt61Ground;
        _dismissalReviewProcessFollowed = input.dismissalReviewProcessFollowed;
        _dismissalReviewExpanded = !_dismissalReviewSkipped &&
            (input.dismissalReviewReasonGiven != null ||
                input.dismissalReviewProcessFollowed != null);
        _joining = input.joiningDate;
        _lastDay = input.lastWorkingDate;
        _noticeServed = input.noticeServed;
        _art49NoticeGiven = input.art49NoticeGiven;
        _contractTerminationDate = input.contractTerminationDate;
        _dateOfLeavingWork = input.dateOfLeavingWork;
        _contractTerminationSameAsLast =
            input.contractTerminationSameAsLastWorkingDate;
        _dateOfLeavingSameAsLast = input.dateOfLeavingSameAsLastWorkingDate;
        _basicSalaryChanged = input.basicSalaryChanged;
        _basicSalaryChangeDate = input.basicSalaryChangeDate;
        if (input.basicSalaryChanged && input.basicSalary > 0) {
          _finalBasicSalary.text = input.basicSalary.toStringAsFixed(0);
        }
        _returnTicket = input.returnTicketIncluded;
        _familySponsored = input.familySponsored;
        _dependents = input.dependentsCount;
        _consent = input.storeSalaryWithConsent;
      });
      if (_fromOnboarding) {
        _applyOnboardingPrefill();
      }
    });
  }

  Map<String, dynamic> _serializeDraft() => {
        'companyName': _companyName.text,
        'basicSalary': _basicSalary.text,
        'finalBasicSalary': _finalBasicSalary.text,
        'basicSalaryChanged': _basicSalaryChanged,
        'basicSalaryChangeDate': _basicSalaryChangeDate?.toIso8601String(),
        'totalSalary': _totalSalary.text,
        'unusedLeave': _unusedLeave.text,
        'overtimeHours': _overtimeHours.text,
        'pendingSalary': _pendingSalary.text,
        'employerOffer': _employerOffer.text,
        'otherBenefits': _otherBenefits.text,
        'contractType': _contractType.name,
        'employmentCategory': _employmentCategory.name,
        'showReferenceCalculation': _showReferenceCalculation,
        'termination': _termination.name,
        'summaryDismissalGround': _summaryDismissalGround.name,
        'summaryDismissalConfirmed': _summaryDismissalConfirmed,
        'dismissalReviewSkipped': _dismissalReviewSkipped,
        'dismissalReviewExpanded': _dismissalReviewExpanded,
        'dismissalReviewReasonGiven': _dismissalReviewReasonGiven,
        'dismissalReviewMatchesArt61': _dismissalReviewMatchesArt61,
        'dismissalReviewProcessFollowed': _dismissalReviewProcessFollowed,
        'joining': _joining?.toIso8601String(),
        'lastDay': _lastDay?.toIso8601String(),
        'noticeServed': _noticeServed,
        'art49NoticeGiven': _art49NoticeGiven,
        'contractTerminationDate':
            _contractTerminationDate?.toIso8601String(),
        'dateOfLeavingWork': _dateOfLeavingWork?.toIso8601String(),
        'contractTerminationSameAsLast': _contractTerminationSameAsLast,
        'dateOfLeavingSameAsLast': _dateOfLeavingSameAsLast,
        'returnTicket': _returnTicket,
        'familySponsored': _familySponsored,
        'dependents': _dependents,
        'consent': _consent,
      };

  void _applyDraft(Map<String, dynamic> data) {
    _companyName.text = data['companyName']?.toString() ?? '';
    _basicSalary.text = data['basicSalary']?.toString() ?? '';
    _finalBasicSalary.text = data['finalBasicSalary']?.toString() ?? '';
    _basicSalaryChanged = data['basicSalaryChanged'] == true;
    _basicSalaryChangeDate =
        DateTime.tryParse(data['basicSalaryChangeDate']?.toString() ?? '');
    _totalSalary.text = data['totalSalary']?.toString() ?? '';
    _unusedLeave.text = data['unusedLeave']?.toString() ?? '0';
    _overtimeHours.text = data['overtimeHours']?.toString() ?? '0';
    _pendingSalary.text = data['pendingSalary']?.toString() ?? '0';
    _employerOffer.text = data['employerOffer']?.toString() ?? '';
    _otherBenefits.text = data['otherBenefits']?.toString() ?? '0';
    _contractType = EosbContractType.values.byName(
      data['contractType']?.toString() ?? EosbContractType.unlimited.name,
    );
    _employmentCategory = EosbEmploymentCategory.values.byName(
      data['employmentCategory']?.toString() ??
          EosbEmploymentCategory.fullTime.name,
    );
    _showReferenceCalculation = data['showReferenceCalculation'] == true;
    _termination = EosbTerminationType.values.byName(
      data['termination']?.toString() ??
          EosbTerminationType.employerTermination.name,
    );
    _summaryDismissalGround = EosbSummaryDismissalGround.values.byName(
      data['summaryDismissalGround']?.toString() ??
          EosbSummaryDismissalGround.none.name,
    );
    _summaryDismissalConfirmed = data['summaryDismissalConfirmed'] == true;
    _dismissalReviewSkipped = data['dismissalReviewSkipped'] == true ||
        data['art62Skipped'] == true;
    _dismissalReviewExpanded = data['dismissalReviewExpanded'] == true ||
        data['art62Expanded'] == true;
    _dismissalReviewReasonGiven = data.containsKey('dismissalReviewReasonGiven')
        ? data['dismissalReviewReasonGiven'] as bool?
        : data.containsKey('art62ReasonGiven')
            ? data['art62ReasonGiven'] as bool?
            : null;
    _dismissalReviewMatchesArt61 =
        data.containsKey('dismissalReviewMatchesArt61')
            ? data['dismissalReviewMatchesArt61'] as bool?
            : data.containsKey('art62MatchesArt61')
                ? data['art62MatchesArt61'] as bool?
                : null;
    _dismissalReviewProcessFollowed =
        data.containsKey('dismissalReviewProcessFollowed')
            ? data['dismissalReviewProcessFollowed'] as bool?
            : data.containsKey('art62ProcessFollowed')
                ? data['art62ProcessFollowed'] as bool?
                : null;
    _joining = DateTime.tryParse(data['joining']?.toString() ?? '');
    _lastDay = DateTime.tryParse(data['lastDay']?.toString() ?? '');
    _noticeServed = data['noticeServed'] == true;
    _art49NoticeGiven = data.containsKey('art49NoticeGiven')
        ? data['art49NoticeGiven'] as bool?
        : null;
    _contractTerminationDate =
        DateTime.tryParse(data['contractTerminationDate']?.toString() ?? '');
    _dateOfLeavingWork =
        DateTime.tryParse(data['dateOfLeavingWork']?.toString() ?? '');
    _contractTerminationSameAsLast =
        data['contractTerminationSameAsLast'] == true;
    _dateOfLeavingSameAsLast = data['dateOfLeavingSameAsLast'] == true;
    _returnTicket = data['returnTicket'] == true;
    _familySponsored = data['familySponsored'] == true;
    _dependents = data['dependents'] as int? ?? 0;
    _consent = data['consent'] == true;
    setState(() {});
  }

  @override
  void dispose() {
    disposeDraftMixin();
    _basicSalary.dispose();
    _finalBasicSalary.dispose();
    _totalSalary.dispose();
    _unusedLeave.dispose();
    _overtimeHours.dispose();
    _pendingSalary.dispose();
    _employerOffer.dispose();
    _otherBenefits.dispose();
    _companyName.dispose();
    super.dispose();
  }

  double _parse(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  void _resetDismissalReview() {
    _dismissalReviewExpanded = false;
    _dismissalReviewSkipped = false;
    _dismissalReviewReasonGiven = null;
    _dismissalReviewMatchesArt61 = null;
    _dismissalReviewProcessFollowed = null;
  }

  void _onFieldChanged() {
    notifyDraftChanged();
    setState(() {});
  }

  double? _tenureYears() {
    if (_joining == null || _lastDay == null) return null;
    if (_lastDay!.isBefore(_joining!)) return null;
    return _lastDay!.difference(_joining!).inDays / 365.25;
  }

  String _terminationLabel(String locale, EosbTerminationType type) {
    return EosbStrings.t('tpl_eosb_term_${type.name}', locale);
  }

  Future<void> _pickTermination(String locale) async {
    final picked = await showCalculatorPickerSheet<EosbTerminationType>(
      context: context,
      title: EosbStrings.t('eosb_termination_type', locale),
      selected: _termination,
      options: EosbTerminationType.values
          .map(
            (e) => CalculatorPickerOption(
              value: e,
              label: _terminationLabel(locale, e),
            ),
          )
          .toList(),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _termination = picked;
      if (_termination != EosbTerminationType.employerTermination) {
        _summaryDismissalGround = EosbSummaryDismissalGround.none;
        _summaryDismissalConfirmed = false;
        _resetDismissalReview();
      }
    });
    notifyDraftChanged();
  }

  Future<void> _pickDate(bool joining) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: joining ? (_joining ?? DateTime.now()) : (_lastDay ?? DateTime.now()),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (joining) {
          _joining = picked;
        } else {
          _lastDay = picked;
        }
      });
      notifyDraftChanged();
    }
  }

  Future<void> _pickContractTerminationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _contractTerminationDate ?? _lastDay ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _contractTerminationDate = picked;
        _contractTerminationSameAsLast = false;
      });
      notifyDraftChanged();
    }
  }

  Future<void> _pickDateOfLeavingWork() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfLeavingWork ?? _lastDay ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateOfLeavingWork = picked;
        _dateOfLeavingSameAsLast = false;
      });
      notifyDraftChanged();
    }
  }

  String _formatOptionalDate(DateTime? date, String locale) {
    if (date == null) return EosbStrings.t('eosb_select_date', locale);
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _pickSalaryChangeDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _basicSalaryChangeDate ?? _joining ?? DateTime.now(),
      firstDate: _joining ?? DateTime(1990),
      lastDate: _lastDay ?? DateTime(2100),
    );
    if (picked != null) {
      setState(() => _basicSalaryChangeDate = picked);
      notifyDraftChanged();
    }
  }

  Future<void> _submit(String locale) async {
    final basic = _parse(_basicSalary);
    final finalBasic = _parse(_finalBasicSalary);
    final effectiveBasic =
        _basicSalaryChanged && finalBasic > 0 ? finalBasic : basic;
    final total = _parse(_totalSalary);

    if (_basicSalaryChanged &&
        (finalBasic <= 0 || _basicSalaryChangeDate == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            EosbStrings.t('eosb_validation_salary_change', locale),
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (effectiveBasic <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(EosbStrings.t('eosb_validation_basic_salary', locale)),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    if (_joining == null || _lastDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(EosbStrings.t('eosb_validation_dates', locale)),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    if (_lastDay!.isBefore(_joining!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(EosbStrings.t('eosb_validation_date_order', locale)),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (total > 0 && basic > 0 && total < basic) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(EosbStrings.t('eosb_warn_total_below_basic', locale)),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_employmentCategory != EosbEmploymentCategory.fullTime &&
        !_showReferenceCalculation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            EosbStrings.t('eosb_employment_reference_required', locale),
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final input = EosbEmployeeInput(
      companyName: _companyName.text.trim(),
      basicSalary: effectiveBasic,
      basicSalaryChanged: _basicSalaryChanged,
      basicSalaryChangeDate:
          _basicSalaryChanged ? _basicSalaryChangeDate : null,
      totalSalary: total > 0 ? total : effectiveBasic,
      joiningDate: _joining,
      lastWorkingDate: _lastDay,
      contractType: _contractType,
      employmentCategory: _employmentCategory,
      showStandardEmployeeReference: _showReferenceCalculation,
      terminationType: _termination,
      summaryDismissalGround: _termination ==
              EosbTerminationType.employerTermination
          ? _summaryDismissalGround
          : EosbSummaryDismissalGround.none,
      summaryDismissalGroundConfirmed:
          _termination == EosbTerminationType.employerTermination &&
              _summaryDismissalGround ==
                  EosbSummaryDismissalGround.unlawfulStrikeIncitement
          ? _summaryDismissalConfirmed
          : false,
      dismissalReviewSkipped: _termination ==
              EosbTerminationType.employerTermination
          ? _dismissalReviewSkipped
          : false,
      dismissalReviewReasonGiven: _termination ==
              EosbTerminationType.employerTermination &&
          !_dismissalReviewSkipped
          ? _dismissalReviewReasonGiven
          : null,
      dismissalReviewMatchesArt61Ground: _termination ==
              EosbTerminationType.employerTermination &&
          !_dismissalReviewSkipped
          ? _dismissalReviewMatchesArt61
          : null,
      dismissalReviewProcessFollowed: _termination ==
              EosbTerminationType.employerTermination &&
          !_dismissalReviewSkipped
          ? _dismissalReviewProcessFollowed
          : null,
      noticeServed: _noticeServed,
      art49NoticeGiven: _art49NoticeGiven,
      contractTerminationDate: _contractTerminationSameAsLast
          ? null
          : _contractTerminationDate,
      dateOfLeavingWork:
          _dateOfLeavingSameAsLast ? null : _dateOfLeavingWork,
      contractTerminationSameAsLastWorkingDate:
          _contractTerminationSameAsLast,
      dateOfLeavingSameAsLastWorkingDate: _dateOfLeavingSameAsLast,
      unusedLeaveDays: int.tryParse(_unusedLeave.text) ?? 0,
      overtimeHours: _parse(_overtimeHours),
      pendingSalary: _parse(_pendingSalary),
      employerOffer: _parse(_employerOffer) > 0 ? _parse(_employerOffer) : null,
      returnTicketIncluded: _returnTicket,
      familySponsored: _familySponsored,
      dependentsCount: _dependents,
      otherContractualBenefits: _parse(_otherBenefits),
      storeSalaryWithConsent: _consent,
    );

    ref.read(eosbProvider.notifier).updateInput(input);
    final result = await ref.read(eosbProvider.notifier).calculate();
    if (!mounted || result == null) return;

    EosbAnalyticsService().trackCalculatorUsed(
      totalEntitlement: result.totalEntitlement,
    );

    final uid = ref.read(currentUserProvider)?.uid;
    final fromOnboarding =
        _fromOnboarding || ref.read(onboardingActiveProvider);
    if (uid != null && !fromOnboarding) {
      await ReferralService.instance.tryGrantRewardsOnFirstEstimate(uid);
    }

    await clearFormDraft();
    if (fromOnboarding) {
      context.push('/eosb/result?fromOnboarding=1');
      return;
    }

    context.push('/eosb/result');
  }

  @override
  Widget build(BuildContext context) {
    final localeAsync = ref.watch(eosbLocaleProvider);
    final loading = ref.watch(eosbProvider).isCalculating;

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        title: 'Employee Information',
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => GlassScreenScaffold(
        title: 'Employee Information',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        body: Center(child: Text(EosbStrings.t('eosb_load_error'))),
      ),
      data: (locale) {
        final basic = _parse(_basicSalary);
        final tenure = _tenureYears();
        final heroValue = basic > 0 ? formatEosbCurrency(basic) : '—';
        final needsReferenceOptIn =
            EmploymentCoverageRules.mayFallOutsideStandardLabourLaw(
          EosbEmployeeInput(employmentCategory: _employmentCategory),
        );
        final canCalculate = !needsReferenceOptIn || _showReferenceCalculation;

        return GlassScreenScaffold(
          title: EosbStrings.t('eosb_employee_info', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          body: CalculatorScreenLayout(
            footer: CalculatorStickyBar(
              label: needsReferenceOptIn && !_showReferenceCalculation
                  ? EosbStrings.t('eosb_employment_reference_opt_in', locale)
                  : EosbStrings.t('eosb_calculate_cta', locale),
              loading: loading,
              onPressed: canCalculate ? () => _submit(locale) : null,
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
              if (widget.referralCode != null &&
                  widget.referralCode!.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                ReferralInviteBanner(referralCode: widget.referralCode!),
              ],
              if (_fromOnboarding) ...[
                const SizedBox(height: AppSpacing.sm),
                CalculatorFormSection(
                  glowColor: AppColors.cyanGlow,
                  child: Text(
                    OnboardingStrings.t(
                      'form_banner',
                      ref.watch(userLanguageProvider),
                    ),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.cyanGlow,
                    ),
                  ),
                ),
              ],
              if (draftRestoreBanner != null) ...[
                const SizedBox(height: AppSpacing.md),
                draftRestoreBanner!,
              ],
              const SizedBox(height: AppSpacing.lg),
              CalculatorLiveHero(
                title: EosbStrings.t('eosb_basic_salary', locale),
                primaryValue: heroValue,
                secondaryLabel: tenure != null ? 'Service' : null,
                secondaryValue: tenure != null
                    ? '${tenure.toStringAsFixed(1)} years'
                    : null,
                accentColor: AppColors.emeraldGlow,
                chips: [
                  if (_contractType == EosbContractType.limited)
                    CalculatorMetricChip(
                      label: EosbStrings.t('tpl_eosb_contract_limited', locale),
                      color: AppColors.amberGlow,
                      icon: Icons.description_outlined,
                    ),
                  if (_employmentCategory != EosbEmploymentCategory.fullTime)
                    CalculatorMetricChip(
                      label: EosbStrings.t(
                        _employmentCategory == EosbEmploymentCategory.partTime
                            ? 'eosb_employment_part_time'
                            : 'eosb_employment_freelance',
                        locale,
                      ),
                      color: AppColors.cyanGlow,
                      icon: Icons.badge_outlined,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              CalculatorFeatureAction(
                title: EosbStrings.t('eosb_contract_analysis', locale),
                subtitle: EosbStrings.t('eosb_contract_analysis_desc', locale),
                icon: Icons.document_scanner_outlined,
                onTap: () => context.push('/eosb/contract-analysis'),
              ),
              const SizedBox(height: AppSpacing.xl),
              CalculatorSectionHeader(
                title: EosbStrings.t('eosb_section_employment', locale),
                subtitle: EosbStrings.t('eosb_section_employment_sub', locale),
                icon: Icons.work_outline_rounded,
              ),
              CalculatorFormSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CalculatorTextField(
                      controller: _companyName,
                      label: EosbStrings.t('eosb_company_name', locale),
                      hint: 'e.g. Qatar Energy',
                      icon: Icons.business_outlined,
                      onChanged: (_) => _onFieldChanged(),
                    ),
                    EmployerTrackRecordPanel(
                      companyName: _companyName.text,
                      locale: locale,
                    ),
                    BeforeYouSignSection(
                      locale: locale,
                      employerName: _companyName.text,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CalculatorDateRow(
                      startLabel: EosbStrings.t('eosb_joining_date', locale),
                      endLabel: EosbStrings.t('eosb_last_working_date', locale),
                      startDate: _joining,
                      endDate: _lastDay,
                      onStartTap: () => _pickDate(true),
                      onEndTap: () => _pickDate(false),
                      locale: locale,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      EosbStrings.t('eosb_contract_type', locale),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    CalculatorSegmentRow<EosbContractType>(
                      selected: _contractType,
                      onSelected: (v) {
                        setState(() => _contractType = v);
                        notifyDraftChanged();
                      },
                      options: [
                        CalculatorSegmentOption(
                          value: EosbContractType.unlimited,
                          label: EosbStrings.t(
                            'tpl_eosb_contract_unlimited',
                            locale,
                          ),
                        ),
                        CalculatorSegmentOption(
                          value: EosbContractType.limited,
                          label: EosbStrings.t(
                            'tpl_eosb_contract_limited',
                            locale,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      EosbStrings.t('eosb_employment_category', locale),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    CalculatorChoiceTile<EosbEmploymentCategory>(
                      title: 'Full-time',
                      subtitle: EosbStrings.t(
                        'eosb_employment_full_time',
                        locale,
                      ),
                      icon: Icons.schedule_rounded,
                      selected:
                          _employmentCategory == EosbEmploymentCategory.fullTime,
                      onTap: () {
                        setState(() {
                          _employmentCategory = EosbEmploymentCategory.fullTime;
                          _showReferenceCalculation = false;
                        });
                        notifyDraftChanged();
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    CalculatorChoiceTile<EosbEmploymentCategory>(
                      title: 'Part-time',
                      subtitle: EosbStrings.t(
                        'eosb_employment_part_time',
                        locale,
                      ),
                      icon: Icons.timelapse_rounded,
                      selected:
                          _employmentCategory == EosbEmploymentCategory.partTime,
                      onTap: () {
                        setState(() {
                          _employmentCategory = EosbEmploymentCategory.partTime;
                          _showReferenceCalculation = false;
                        });
                        notifyDraftChanged();
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    CalculatorChoiceTile<EosbEmploymentCategory>(
                      title: 'Freelance',
                      subtitle: EosbStrings.t(
                        'eosb_employment_freelance',
                        locale,
                      ),
                      icon: Icons.person_outline_rounded,
                      selected:
                          _employmentCategory == EosbEmploymentCategory.freelance,
                      onTap: () {
                        setState(() {
                          _employmentCategory = EosbEmploymentCategory.freelance;
                          _showReferenceCalculation = false;
                        });
                        notifyDraftChanged();
                      },
                    ),
                    if (_employmentCategory != EosbEmploymentCategory.fullTime) ...[
                      const SizedBox(height: AppSpacing.lg),
                      CalculatorFormSection(
                        glowColor: AppColors.accentGold,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              EosbStrings.t(
                                'eosb_employment_coverage_scope_notice',
                                locale,
                              ),
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            CalculatorToggleTile(
                              title: EosbStrings.t(
                                'eosb_employment_reference_opt_in',
                                locale,
                              ),
                              subtitle: EosbStrings.t(
                                'eosb_employment_reference_opt_in_sub',
                                locale,
                              ),
                              value: _showReferenceCalculation,
                              icon: Icons.info_outline_rounded,
                              onChanged: (v) {
                                setState(() => _showReferenceCalculation = v);
                                notifyDraftChanged();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const CalculatorSectionHeader(
                title: 'Compensation',
                subtitle: 'Salary and outstanding amounts',
                icon: Icons.payments_outlined,
                accentColor: AppColors.accentGold,
              ),
              CalculatorFormSection(
                glowColor: AppColors.accentGold,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CalculatorTextField(
                      controller: _basicSalary,
                      label: EosbStrings.t('eosb_basic_salary', locale),
                      hint: '5,000',
                      prefix: 'QAR ',
                      large: true,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => _onFieldChanged(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CalculatorToggleTile(
                      title: EosbStrings.t('eosb_basic_salary_changed', locale),
                      subtitle: EosbStrings.t(
                        'eosb_basic_salary_changed_sub',
                        locale,
                      ),
                      value: _basicSalaryChanged,
                      icon: Icons.trending_up_outlined,
                      onChanged: (v) {
                        setState(() {
                          _basicSalaryChanged = v;
                          if (!v) {
                            _basicSalaryChangeDate = null;
                            _finalBasicSalary.clear();
                          }
                        });
                        notifyDraftChanged();
                      },
                    ),
                    if (_basicSalaryChanged) ...[
                      const SizedBox(height: AppSpacing.md),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          EosbStrings.t('eosb_basic_salary_change_date', locale),
                          style: AppTypography.bodySmall,
                        ),
                        subtitle: Text(
                          _basicSalaryChangeDate != null
                              ? MaterialLocalizations.of(context)
                                  .formatMediumDate(_basicSalaryChangeDate!)
                              : EosbStrings.t('eosb_select_date', locale),
                          style: AppTypography.caption,
                        ),
                        trailing: const Icon(Icons.calendar_today_outlined),
                        onTap: _pickSalaryChangeDate,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      CalculatorTextField(
                        controller: _finalBasicSalary,
                        label: EosbStrings.t('eosb_final_basic_salary', locale),
                        hint: '6,000',
                        prefix: 'QAR ',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => _onFieldChanged(),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    CalculatorTextField(
                      controller: _totalSalary,
                      label: EosbStrings.t('eosb_total_salary', locale),
                      hint: '6,500',
                      prefix: 'QAR ',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => _onFieldChanged(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CalculatorTextField(
                            controller: _unusedLeave,
                            label: 'Unused leave days',
                            hint: '0',
                            keyboardType: TextInputType.number,
                            onChanged: (_) => _onFieldChanged(),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: CalculatorTextField(
                            controller: _overtimeHours,
                            label: EosbStrings.t('eosb_overtime', locale),
                            hint: '0',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) => _onFieldChanged(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CalculatorFeatureAction(
                      title: EosbStrings.t('eosb_ot_calculate_precisely', locale),
                      subtitle: EosbStrings.t('eosb_ot_calculate_precisely_desc', locale),
                      icon: Icons.schedule_rounded,
                      accentColor: AppColors.accentGold,
                      onTap: () => context.push('/eosb/overtime'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CalculatorTextField(
                            controller: _pendingSalary,
                            label: EosbStrings.t('eosb_pending_salary', locale),
                            hint: '0',
                            prefix: 'QAR ',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) => _onFieldChanged(),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: CalculatorTextField(
                            controller: _otherBenefits,
                            label: EosbStrings.t('eosb_other_benefits', locale),
                            hint: '0',
                            prefix: 'QAR ',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) => _onFieldChanged(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CalculatorTextField(
                      controller: _employerOffer,
                      label: EosbStrings.t('eosb_employer_offer', locale),
                      hint: 'Optional — for comparison',
                      prefix: 'QAR ',
                      icon: Icons.compare_arrows_rounded,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => _onFieldChanged(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              CalculatorSectionHeader(
                title: EosbStrings.t('eosb_section_separation', locale),
                subtitle: EosbStrings.t('eosb_section_separation_sub', locale),
                icon: Icons.logout_rounded,
                accentColor: AppColors.cyanGlow,
              ),
              CalculatorFormSection(
                glowColor: AppColors.cyanGlow,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CalculatorPickerField<EosbTerminationType>(
                      label: EosbStrings.t('eosb_termination_type', locale),
                      valueLabel: _terminationLabel(locale, _termination),
                      onTap: () => _pickTermination(locale),
                    ),
                    if (_termination ==
                        EosbTerminationType.employerTermination) ...[
                      const SizedBox(height: AppSpacing.lg),
                      CalculatorChoiceTile<EosbSummaryDismissalGround>(
                        title: EosbStrings.t(
                          'eosb_summary_dismissal_none',
                          locale,
                        ),
                        selected: _summaryDismissalGround ==
                            EosbSummaryDismissalGround.none,
                        onTap: () {
                          setState(() {
                            _summaryDismissalGround =
                                EosbSummaryDismissalGround.none;
                            _summaryDismissalConfirmed = false;
                          });
                          notifyDraftChanged();
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      CalculatorChoiceTile<EosbSummaryDismissalGround>(
                        title: EosbStrings.t(
                          'eosb_summary_dismissal_strike',
                          locale,
                        ),
                        subtitle: EosbStrings.t(
                          'eosb_summary_dismissal_ground',
                          locale,
                        ),
                        selected: _summaryDismissalGround ==
                            EosbSummaryDismissalGround.unlawfulStrikeIncitement,
                        accentColor: AppColors.errorBright,
                        onTap: () {
                          setState(
                            () => _summaryDismissalGround =
                                EosbSummaryDismissalGround
                                    .unlawfulStrikeIncitement,
                          );
                          notifyDraftChanged();
                        },
                      ),
                      if (_summaryDismissalGround ==
                          EosbSummaryDismissalGround
                              .unlawfulStrikeIncitement)
                        CalculatorToggleTile(
                          title: EosbStrings.t(
                            'eosb_summary_dismissal_confirm',
                            locale,
                          ),
                          value: _summaryDismissalConfirmed,
                          icon: Icons.gavel_outlined,
                          onChanged: (v) {
                            setState(() => _summaryDismissalConfirmed = v);
                            notifyDraftChanged();
                          },
                        ),
                      const SizedBox(height: AppSpacing.lg),
                      EosbArticle62AssessmentSection(
                        locale: locale,
                        expanded: _dismissalReviewExpanded,
                        skipped: _dismissalReviewSkipped,
                        reasonGiven: _dismissalReviewReasonGiven,
                        matchesArt61Ground: _dismissalReviewMatchesArt61,
                        processFollowed: _dismissalReviewProcessFollowed,
                        onExpand: () {
                          setState(() {
                            _dismissalReviewExpanded = true;
                            _dismissalReviewSkipped = false;
                          });
                          notifyDraftChanged();
                        },
                        onSkip: () {
                          setState(() {
                            _dismissalReviewSkipped = true;
                            _dismissalReviewExpanded = false;
                            _dismissalReviewReasonGiven = null;
                            _dismissalReviewMatchesArt61 = null;
                            _dismissalReviewProcessFollowed = null;
                          });
                          notifyDraftChanged();
                        },
                        onReasonGivenChanged: (v) {
                          setState(() {
                            _dismissalReviewReasonGiven = v;
                            if (v != true) {
                              _dismissalReviewMatchesArt61 = null;
                            }
                          });
                          notifyDraftChanged();
                        },
                        onMatchesArt61Changed: (v) {
                          setState(() => _dismissalReviewMatchesArt61 = v);
                          notifyDraftChanged();
                        },
                        onProcessFollowedChanged: (v) {
                          setState(() => _dismissalReviewProcessFollowed = v);
                          notifyDraftChanged();
                        },
                      ),
                    ],
                    const Divider(height: AppSpacing.xl),
                    CalculatorToggleTile(
                      title: EosbStrings.t('eosb_notice_served', locale),
                      subtitle: EosbStrings.t('eosb_notice_served_sub', locale),
                      value: _noticeServed,
                      icon: Icons.notifications_active_outlined,
                      onChanged: (v) {
                        setState(() => _noticeServed = v);
                        notifyDraftChanged();
                      },
                    ),
                    const Divider(height: AppSpacing.xl),
                    Text(
                      EosbStrings.t('eosb_art67_section_title', locale),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      EosbStrings.t('eosb_art67_section_sub', locale),
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      EosbStrings.t('eosb_art49_notice_question', locale),
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    CalculatorChoiceTile<bool?>(
                      title: EosbStrings.t('eosb_art49_notice_yes', locale),
                      selected: _art49NoticeGiven == true,
                      onTap: () {
                        setState(() => _art49NoticeGiven = true);
                        notifyDraftChanged();
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    CalculatorChoiceTile<bool?>(
                      title: EosbStrings.t('eosb_art49_notice_no', locale),
                      selected: _art49NoticeGiven == false,
                      onTap: () {
                        setState(() => _art49NoticeGiven = false);
                        notifyDraftChanged();
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    CalculatorChoiceTile<bool?>(
                      title: EosbStrings.t('eosb_art49_notice_unsure', locale),
                      selected: _art49NoticeGiven == null,
                      onTap: () {
                        setState(() => _art49NoticeGiven = null);
                        notifyDraftChanged();
                      },
                    ),
                    if (_art49NoticeGiven == true) ...[
                      const SizedBox(height: AppSpacing.lg),
                      CalculatorToggleTile(
                        title: EosbStrings.t(
                          'eosb_contract_termination_same_as_last',
                          locale,
                        ),
                        value: _contractTerminationSameAsLast,
                        icon: Icons.event_outlined,
                        onChanged: (v) {
                          setState(() {
                            _contractTerminationSameAsLast = v;
                            if (v) _contractTerminationDate = null;
                          });
                          notifyDraftChanged();
                        },
                      ),
                      if (!_contractTerminationSameAsLast) ...[
                        const SizedBox(height: AppSpacing.sm),
                        CalculatorPickerField<void>(
                          label: EosbStrings.t(
                            'eosb_contract_termination_date',
                            locale,
                          ),
                          valueLabel: _formatOptionalDate(
                            _contractTerminationDate,
                            locale,
                          ),
                          onTap: _pickContractTerminationDate,
                        ),
                      ],
                    ],
                    if (_art49NoticeGiven == false) ...[
                      const SizedBox(height: AppSpacing.lg),
                      CalculatorToggleTile(
                        title: EosbStrings.t(
                          'eosb_date_of_leaving_same_as_last',
                          locale,
                        ),
                        value: _dateOfLeavingSameAsLast,
                        icon: Icons.exit_to_app_outlined,
                        onChanged: (v) {
                          setState(() {
                            _dateOfLeavingSameAsLast = v;
                            if (v) _dateOfLeavingWork = null;
                          });
                          notifyDraftChanged();
                        },
                      ),
                      if (!_dateOfLeavingSameAsLast) ...[
                        const SizedBox(height: AppSpacing.sm),
                        CalculatorPickerField<void>(
                          label: EosbStrings.t(
                            'eosb_date_of_leaving_work',
                            locale,
                          ),
                          valueLabel: _formatOptionalDate(
                            _dateOfLeavingWork,
                            locale,
                          ),
                          onTap: _pickDateOfLeavingWork,
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              CalculatorSectionHeader(
                title: EosbStrings.t('eosb_section_benefits', locale),
                subtitle: EosbStrings.t('eosb_section_benefits_sub', locale),
                icon: Icons.shield_outlined,
              ),
              CalculatorFormSection(
                child: Column(
                  children: [
                    CalculatorToggleTile(
                      title: EosbStrings.t('eosb_return_ticket_contract', locale),
                      value: _returnTicket,
                      icon: Icons.flight_takeoff_outlined,
                      onChanged: (v) {
                        setState(() => _returnTicket = v);
                        notifyDraftChanged();
                      },
                    ),
                    CalculatorToggleTile(
                      title: EosbStrings.t('eosb_save_consent', locale),
                      value: _consent,
                      icon: Icons.lock_outline_rounded,
                      onChanged: (v) {
                        setState(() => _consent = v);
                        notifyDraftChanged();
                      },
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
