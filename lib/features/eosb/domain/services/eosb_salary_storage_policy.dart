import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';

/// Redaction + Firestore payload shaping for device salary-storage consent.
abstract final class EosbSalaryStoragePolicy {
  /// History row safe for salary-aware features (Expat, Home Intelligence).
  static CalculationHistoryEntry? pickSalaryAwareHistoryEntry(
    List<CalculationHistoryEntry> history, {
    required bool salaryStorageConsent,
  }) {
    if (!salaryStorageConsent || history.isEmpty) return null;
    for (final entry in history) {
      if (entry.salaryDetailsStored) return entry;
    }
    return null;
  }

  /// Non-empty history list without exposing salary rows when consent is off.
  static bool hasCalculationHistorySignal(
    List<CalculationHistoryEntry> history, {
    required bool salaryStorageConsent,
  }) {
    if (history.isEmpty) return false;
    if (salaryStorageConsent) {
      return pickSalaryAwareHistoryEntry(history, salaryStorageConsent: true) !=
          null;
    }
    return history.any((e) => !e.salaryDetailsStored);
  }

  static const firestoreSalaryFieldKeys = <String>[
    'companyName',
    'normalizedEmployerKey',
    'totalEntitlement',
    'employerOffer',
    'joiningDate',
    'contractEndDate',
    'label',
  ];

  static const firestoreSummarySalaryFieldKeys = <String>[
    'joiningDate',
    'contractEndDate',
  ];

  static EosbEmployeeInput redactInput(EosbEmployeeInput input) {
    return EosbEmployeeInput(
      country: input.country,
      contractType: input.contractType,
      employmentCategory: input.employmentCategory,
      terminationType: input.terminationType,
      summaryDismissalGround: input.summaryDismissalGround,
      summaryDismissalGroundConfirmed: input.summaryDismissalGroundConfirmed,
      dismissalReviewSkipped: input.dismissalReviewSkipped,
      dismissalReviewReasonGiven: input.dismissalReviewReasonGiven,
      dismissalReviewMatchesArt61Ground:
          input.dismissalReviewMatchesArt61Ground,
      dismissalReviewProcessFollowed: input.dismissalReviewProcessFollowed,
      showStandardEmployeeReference: input.showStandardEmployeeReference,
      noticeServed: input.noticeServed,
      familySponsored: input.familySponsored,
      returnTicketIncluded: input.returnTicketIncluded,
      storeSalaryWithConsent: false,
    );
  }

  static EosbResult redactResult(EosbResult result) {
    return EosbResult(
      totalEntitlement: 0,
      breakdown: const [],
      warnings: result.warnings,
      violations: result.violations,
      explanation: result.explanation,
      comparison: null,
      calculatedAt: result.calculatedAt,
    );
  }

  static CalculationHistoryEntry prepareHistoryEntry({
    required CalculationHistoryEntry entry,
    required bool includeSalaryDetails,
  }) {
    if (includeSalaryDetails) {
      return CalculationHistoryEntry(
        id: entry.id,
        input: entry.input.forPersistence().copyWith(
          storeSalaryWithConsent: true,
        ),
        result: entry.result,
        savedAt: entry.savedAt,
        label: entry.label,
        salaryDetailsStored: true,
      );
    }
    return CalculationHistoryEntry(
      id: entry.id,
      input: redactInput(entry.input.forPersistence()),
      result: redactResult(entry.result),
      savedAt: entry.savedAt,
      label: null,
      salaryDetailsStored: false,
    );
  }

  static Map<String, dynamic> firestoreCalculationDoc({
    required CalculationHistoryEntry entry,
    required String legalVersionVerifiedAt,
    required bool includeSalaryDetails,
  }) {
    final base = <String, dynamic>{
      'calculatedAt': entry.result.calculatedAt.toIso8601String(),
      'legalVersionVerifiedAt': legalVersionVerifiedAt,
      'contractType': entry.input.contractType.name,
      'violationRuleKeys': entry.result.violations
          .map((v) => v.ruleKey)
          .toList(),
      'violationTitleKeys': entry.result.violations
          .map((v) => v.titleKey)
          .toList(),
      'engineSource': 'eosb',
      'hasSalaryData': includeSalaryDetails,
    };

    if (includeSalaryDetails) {
      return {
        ...base,
        'companyName': entry.input.companyName,
        'normalizedEmployerKey': entry.input.effectiveNormalizedEmployerKey,
        'totalEntitlement': entry.result.totalEntitlement,
        'contractEndDate': entry.input.lastWorkingDate?.toIso8601String(),
        'joiningDate': entry.input.joiningDate?.toIso8601String(),
        'employerOffer': entry.input.employerOffer,
        'label': entry.label,
      };
    }

    return {
      ...base,
      for (final key in firestoreSalaryFieldKeys) key: FieldValue.delete(),
    };
  }

  static Map<String, dynamic> firestoreUserSummary({
    required int calculationCount,
    required CalculationHistoryEntry entry,
    required String legalVersionVerifiedAt,
    required bool includeSalaryDetails,
  }) {
    final base = <String, dynamic>{
      'calculationCount': calculationCount,
      'latestCalculationId': entry.id,
      'latestCalculatedAt': entry.result.calculatedAt.toIso8601String(),
      'legalVersionVerifiedAt': legalVersionVerifiedAt,
      'contractType': entry.input.contractType.name,
    };

    if (includeSalaryDetails) {
      return {
        ...base,
        'contractEndDate': entry.input.lastWorkingDate?.toIso8601String(),
        'joiningDate': entry.input.joiningDate?.toIso8601String(),
      };
    }

    return {
      ...base,
      for (final key in firestoreSummarySalaryFieldKeys)
        key: FieldValue.delete(),
    };
  }
}
