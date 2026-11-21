import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/domain/services/eosb_salary_claude_consent.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_disclaimer_banner.dart';
import 'package:raabta/features/eosb/presentation/widgets/shared/eosb_shared_widgets.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_salary_claude_consent_feedback.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/eosb/providers/overtime_truth_providers.dart';
import 'package:raabta/features/eosb/services/overtime_ai_service.dart';

class OvertimeImportScreen extends ConsumerStatefulWidget {
  const OvertimeImportScreen({super.key});

  @override
  ConsumerState<OvertimeImportScreen> createState() =>
      _OvertimeImportScreenState();
}

class _OvertimeImportScreenState extends ConsumerState<OvertimeImportScreen> {
  final _textController = TextEditingController();
  String _documentKind = 'Salary Slip';
  bool _loading = false;

  static const _kinds = [
    'Salary Slip',
    'Timesheet',
    'Attendance Report',
    'Payslip',
    'Employer Overtime Sheet',
    'Employment Contract',
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _import(String locale) async {
    if (_textController.text.trim().length < 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(EosbStrings.t('ot_import_text_short', locale))),
      );
      return;
    }

    final consent = await ref.read(eosbSalaryConsentProvider.future);
    if (!consent) {
      if (mounted) showEosbSalaryClaudeConsentSnackBar(context, locale);
      return;
    }

    setState(() => _loading = true);
    try {
      final ai = ref.read(overtimeAiServiceProvider);
      final data = await ai.extractFromDocument(
        documentText: _textController.text,
        documentKind: _documentKind,
        language: locale,
      );

      final record = ref.read(overtimeTruthProvider).record;
      final updatedRecord = _recordWithImportData(record, data);

      ref.read(overtimeTruthProvider.notifier).updateRecord(updatedRecord);
      await ref.read(overtimeTruthProvider.notifier).calculate();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(EosbStrings.t('ot_import_applied', locale)),
            backgroundColor: AppColors.successBright,
          ),
        );
        context.push('/eosb/overtime/calendar');
      }
    } on EosbSalaryClaudeConsentRequired {
      if (mounted) showEosbSalaryClaudeConsentSnackBar(context, locale);
    } on OvertimeAiImportFailure {
      _showImportFailureSnackBar(locale);
    } catch (_) {
      _showImportFailureSnackBar(locale);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showImportFailureSnackBar(String locale) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(EosbStrings.t('ot_import_error', locale))),
    );
  }

  OvertimeMonthlyRecord _recordWithImportData(
    OvertimeMonthlyRecord record,
    Map<String, dynamic> data,
  ) {
    var profile = record.profile;
    if (data['employeeName'] != null) {
      profile = profile.copyWith(
        employeeName: data['employeeName'] as String? ?? profile.employeeName,
      );
    }
    if (data['basicSalary'] != null) {
      profile = profile.copyWith(
        basicSalary:
            (data['basicSalary'] as num?)?.toDouble() ?? profile.basicSalary,
      );
    }
    if (data['totalSalary'] != null) {
      profile = profile.copyWith(
        totalSalary:
            (data['totalSalary'] as num?)?.toDouble() ?? profile.totalSalary,
      );
    }
    if (data['workingHoursPerDay'] != null) {
      profile = profile.copyWith(
        workingHoursPerDay:
            (data['workingHoursPerDay'] as num?)?.toInt() ??
            profile.workingHoursPerDay,
      );
    }
    if (data['workingDaysPerWeek'] != null) {
      profile = profile.copyWith(
        workingDaysPerWeek:
            (data['workingDaysPerWeek'] as num?)?.toInt() ??
            profile.workingDaysPerWeek,
      );
    }

    var days = List<OvertimeDayEntry>.from(record.days);
    final entries = data['overtimeEntries'] as List<dynamic>? ?? [];
    for (final raw in entries) {
      if (raw is! Map<String, dynamic>) continue;
      final dateStr = raw['date'] as String?;
      final hours = (raw['hours'] as num?)?.toDouble() ?? 0;
      if (dateStr == null || hours <= 0) continue;
      final date = DateTime.tryParse(dateStr);
      if (date == null) continue;
      final idx = days.indexWhere(
        (d) =>
            d.date.year == date.year &&
            d.date.month == date.month &&
            d.date.day == date.day,
      );
      if (idx < 0) continue;
      final catName = raw['category'] as String? ?? 'regularDay';
      final cat = OvertimeDayCategory.values.firstWhere(
        (c) => c.name == catName,
        orElse: () => OvertimeDayCategory.regularDay,
      );
      days[idx] = days[idx].copyWith(
        dayCategory: cat,
        overtimeHours: hours.floor(),
        overtimeMinutes: ((hours - hours.floor()) * 60).round(),
      );
    }

    final employerShifts = data['employerShiftEntries'] as List<dynamic>? ?? [];
    for (final raw in employerShifts) {
      if (raw is! Map<String, dynamic>) continue;
      final dateStr = raw['date'] as String?;
      if (dateStr == null) continue;
      final date = DateTime.tryParse(dateStr);
      if (date == null) continue;
      final idx = days.indexWhere(
        (d) =>
            d.date.year == date.year &&
            d.date.month == date.month &&
            d.date.day == date.day,
      );
      if (idx < 0) continue;
      final start = raw['startTime'] as String?;
      final end = raw['endTime'] as String?;
      days[idx] = days[idx].copyWith(
        employerReportedStartTime: start,
        employerReportedEndTime: end,
      );
    }

    return record.copyWith(
      profile: profile,
      days: days,
      employerPaidOvertime:
          (data['employerPaidOvertime'] as num?)?.toDouble() ??
          record.employerPaidOvertime,
      employerReportedHours:
          (data['employerReportedHours'] as num?)?.toDouble() ??
          record.employerReportedHours,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeAsync = ref.watch(eosbLocaleProvider);

    final presentationLocale = ref.watch(eosbPresentationLocaleProvider);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => GlassScreenScaffold(
        title: EosbStrings.t('ot_import_docs', presentationLocale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: EosbEmptyState(
              icon: Icons.error_outline,
              title: EosbStrings.t('ot_locale_load_error', presentationLocale),
              description: EosbStrings.t('ot_subtitle', presentationLocale),
            ),
          ),
        ),
      ),
      data: (locale) {
        return GlassScreenScaffold(
          title: EosbStrings.t('ot_import_docs', locale),
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
                EosbStrings.t('ot_import_desc', locale),
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: _documentKind,
                dropdownColor: AppColors.surfaceElevated,
                decoration: InputDecoration(
                  labelText: EosbStrings.t('ot_doc_type', locale),
                ),
                items: _kinds
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _documentKind = v ?? _documentKind),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: GlassPrimaryButton(
                      label: EosbStrings.t('eosb_scan_document', locale),
                      icon: Icons.document_scanner_outlined,
                      accentColor: AppColors.cyanGlow,
                      onPressed: () => context.push('/scanner/capture'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: GlassPrimaryButton(
                      label: EosbStrings.t('eosb_import_vault', locale),
                      icon: Icons.folder_outlined,
                      accentColor: AppColors.sharePurple,
                      onPressed: () => context.push('/document-vault'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              GlassContainer(
                padding: EdgeInsets.zero,
                borderRadius: AppSpacing.radiusSm,
                child: TextField(
                  controller: _textController,
                  maxLines: 12,
                  decoration: InputDecoration(
                    hintText: EosbStrings.t('ot_import_paste', locale),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              GlassPrimaryButton(
                label: EosbStrings.t('ot_import_analyze', locale),
                expand: true,
                accentColor: AppColors.accentGold,
                icon: Icons.auto_awesome,
                onPressed: _loading ? null : () => _import(locale),
              ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.md),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      },
    );
  }
}
