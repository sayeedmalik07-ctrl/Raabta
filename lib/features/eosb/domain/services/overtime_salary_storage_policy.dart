import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/services/drafts/draft_box_keys.dart';

/// Redaction + Firestore/export shaping for OT salary-storage consent (EOSB toggle).
abstract final class OvertimeSalaryStoragePolicy {
  static const firestoreSalaryFieldKeys = <String>[
    'companyName',
    'normalizedEmployerKey',
  ];

  static bool isOvertimeSalaryDraftForm(String formId) {
    return formId == DraftBoxKeys.overtimeInput ||
        formId == DraftBoxKeys.overtimeEmployeeProfile ||
        formId.startsWith('overtime_calendar_entry_');
  }

  static OvertimeEmployeeProfile redactProfile(
    OvertimeEmployeeProfile profile,
  ) {
    return OvertimeEmployeeProfile(
      countryCode: profile.countryCode,
      employmentType: profile.employmentType,
      workingHoursPerDay: profile.workingHoursPerDay,
      workingDaysPerWeek: profile.workingDaysPerWeek,
      monthlyWorkingDays: profile.monthlyWorkingDays,
      shiftType: profile.shiftType,
      currency: profile.currency,
      isRamadanPeriod: profile.isRamadanPeriod,
    );
  }

  static List<OvertimeDayEntry> redactDays(List<OvertimeDayEntry> days) {
    return days
        .map(
          (d) => d.copyWith(
            notes: '',
            holidayName: '',
            clearUserShiftTimes: true,
            clearEmployerShiftTimes: true,
          ),
        )
        .toList();
  }

  static OvertimeMonthlyRecord redactRecord(OvertimeMonthlyRecord record) {
    return record.copyWith(
      profile: redactProfile(record.profile),
      days: redactDays(record.days),
      employerPaidOvertime: 0,
      employerReportedHours: 0,
      salaryDetailsStored: false,
    );
  }

  static OvertimeTruthInput redactInput(OvertimeTruthInput input) {
    return OvertimeTruthInput(
      normalizedEmployerKey: '',
      periodStart: input.periodStart,
      periodEnd: input.periodEnd,
      workingDaysPerWeek: input.workingDaysPerWeek,
      standardHoursPerDay: input.standardHoursPerDay,
      isRamadanPeriod: input.isRamadanPeriod,
      inputMode: input.inputMode,
      record: input.record != null ? redactRecord(input.record!) : null,
    );
  }

  /// Persists [records]; when consent is off every row is salary-redacted (idempotent).
  static List<OvertimeMonthlyRecord> prepareHistoryList({
    required List<OvertimeMonthlyRecord> records,
    required bool includeSalaryDetails,
    required Map<String, OvertimeMonthlyRecord> existingById,
  }) {
    if (includeSalaryDetails) {
      return records
          .map((r) => r.forPersistence().copyWith(salaryDetailsStored: true))
          .toList();
    }

    return records.map((r) {
      final existing = existingById[r.id];
      return redactRecord(r.forPersistence()).copyWith(
        isFavorite: r.isFavorite,
        updatedAt: r.updatedAt ?? existing?.updatedAt,
      );
    }).toList();
  }

  /// Firestore merge patch when salary consent is revoked (does not alter violation flags).
  static Map<String, dynamic> firestoreOvertimeSalaryRevocationPatch() {
    return {
      'hasSalaryData': false,
      for (final key in firestoreSalaryFieldKeys) key: FieldValue.delete(),
    };
  }

  static Map<String, dynamic> recordToExportJson(OvertimeMonthlyRecord record) {
    if (record.salaryDetailsStored) {
      return record.toJson()..['salaryDetailsStored'] = true;
    }
    return redactRecord(record).toJson();
  }

  static Map<String, dynamic> firestoreOvertimeDoc({
    required OvertimeMonthlyRecord record,
    required DateTime calculatedAt,
    required bool violationFlagged,
    required bool includeSalaryDetails,
  }) {
    final base = <String, dynamic>{
      'calculatedAt': calculatedAt.toIso8601String(),
      'violationFlagged': violationFlagged,
      'engineSource': 'overtime',
      'year': record.year,
      'month': record.month,
      'hasSalaryData': includeSalaryDetails,
    };

    if (includeSalaryDetails) {
      final profile = record.profile.forPersistence();
      return {
        ...base,
        'companyName': profile.companyName,
        'normalizedEmployerKey': profile.effectiveNormalizedEmployerKey,
      };
    }

    return {
      ...base,
      for (final key in firestoreSalaryFieldKeys) key: FieldValue.delete(),
    };
  }
}
