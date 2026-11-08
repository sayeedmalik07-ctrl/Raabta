import 'package:raabta/features/eosb/domain/models/eosb_enums.dart';

/// Outcome of a single deterministic compliance check item.
enum HealthComplianceStatus {
  compliant,
  violation,
  needsVerification,
  informational,
  notApplicable,
}

/// Maps [HealthComplianceStatus] to EOSB Legal Warnings visual severity.
EosbWarningSeverity severityForHealthStatus(HealthComplianceStatus status) {
  switch (status) {
    case HealthComplianceStatus.compliant:
      return EosbWarningSeverity.info;
    case HealthComplianceStatus.violation:
      return EosbWarningSeverity.critical;
    case HealthComplianceStatus.needsVerification:
      return EosbWarningSeverity.warning;
    case HealthComplianceStatus.informational:
      return EosbWarningSeverity.info;
    case HealthComplianceStatus.notApplicable:
      return EosbWarningSeverity.info;
  }
}
