enum EosbContractType { unlimited, limited }

/// Worker category under amended Labour Law scope (Law No. 9 of 2026).
enum EosbEmploymentCategory {
  fullTime,
  partTime,
  freelance,
}

enum EosbTerminationType {
  employerTermination,
  employeeResignation,
  mutualSeparation,
  retirement,
  companyClosure,
  contractExpiry,
}

/// Narrow summary-dismissal grounds — only [unlawfulStrikeIncitement] affects gratuity.
enum EosbSummaryDismissalGround {
  none,
  unlawfulStrikeIncitement,
}

enum EosbWarningSeverity { info, warning, violation, critical }

enum EosbDocumentType {
  disputeLetterEn,
  disputeLetterAr,
  settlementReview,
  hrRequest,
  labourComplaintDraft,
  personalReport,
  eosbPdf,
}
