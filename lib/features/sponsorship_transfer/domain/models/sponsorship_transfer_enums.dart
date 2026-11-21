/// Result line severity for transfer readiness checks.
enum TransferReadinessStatus {
  compliant,
  warning,
  critical,
  needsVerification,
  informational,
}

enum TransferContractType {
  fixedTerm,
  indefinite,
}

enum FormalNoticeStatus {
  yes,
  no,
  notSure,
}

/// Whether the worker is still within probation with the current employer.
enum ProbationPeriodStatus {
  yes,
  no,
  notSure,
}

/// Residence permit timing relative to MOI Decree 51/2020 grace window.
enum PermitWindowStatus {
  valid,
  graceWindow,
  outsideGrace,
  unknown,
}
