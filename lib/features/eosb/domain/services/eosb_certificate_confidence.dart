import 'package:raabta/features/eosb/domain/models/eosb_certificate_models.dart';
import 'package:raabta/features/eosb/domain/models/eosb_enums.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/domain/rules/eosb_certificate_constants.dart';

/// Deterministic estimate confidence band — not legal certainty.
abstract final class EosbCertificateConfidence {
  static EosbCertificateConfidenceBand derive({
    required double inputCompletenessScore,
    required String? joiningDate,
    required String? lastWorkingDate,
    required String basicSalary,
    required String totalSalary,
    required String totalEntitlement,
    required List<EosbWarningSnapshotItem> warnings,
    required List<EosbViolationSnapshotItem> violations,
    required List<EosbBreakdownSnapshotItem> breakdown,
  }) {
    final basic = double.tryParse(basicSalary) ?? 0;
    final totalSal = double.tryParse(totalSalary) ?? 0;
    final entitlement = double.tryParse(totalEntitlement) ?? 0;
    final hasDates = joiningDate != null && lastWorkingDate != null;
    final hasCritical = warnings.any(
      (w) => w.severity == EosbWarningSeverity.critical.name,
    );
    final hasWarning = warnings.any(
      (w) => w.severity == EosbWarningSeverity.warning.name,
    );
    final hasEstimatedPositive = breakdown.any(
      (b) => b.isEstimated && (double.tryParse(b.amount) ?? 0) > 0,
    );

    final highEligible = inputCompletenessScore >= 0.80 &&
        hasDates &&
        basic > 0 &&
        !hasCritical &&
        !hasEstimatedPositive &&
        violations.isEmpty;

    if (highEligible) {
      return EosbCertificateConfidenceBand.high;
    }

    final lowEligible = inputCompletenessScore < 0.60 ||
        !hasDates ||
        basic <= 0 ||
        hasCritical ||
        (entitlement == 0 && inputCompletenessScore < 0.80);

    if (lowEligible) {
      return EosbCertificateConfidenceBand.low;
    }

    if (inputCompletenessScore >= 0.60 ||
        hasEstimatedPositive ||
        hasWarning ||
        (totalSal == 0 && basic > 0) ||
        violations.isNotEmpty) {
      return EosbCertificateConfidenceBand.medium;
    }

    return EosbCertificateConfidenceBand.low;
  }

  static EosbCertificateConfidenceBand fromResult({
    required EosbResult result,
    required String? joiningDateIso,
    required String? lastWorkingDateIso,
    required String basicSalary,
    required String totalSalary,
    required String totalEntitlement,
    required List<EosbBreakdownSnapshotItem> breakdown,
    required List<EosbWarningSnapshotItem> warnings,
    required List<EosbViolationSnapshotItem> violations,
  }) {
    return derive(
      inputCompletenessScore: result.explanation.confidenceScore,
      joiningDate: joiningDateIso,
      lastWorkingDate: lastWorkingDateIso,
      basicSalary: basicSalary,
      totalSalary: totalSalary,
      totalEntitlement: totalEntitlement,
      warnings: warnings,
      violations: violations,
      breakdown: breakdown,
    );
  }
}
