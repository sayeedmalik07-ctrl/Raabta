/// Summary-only past Part A compliance check from Firestore.
///
/// Full [InsuranceComplianceInput] / [ComplianceCheckResult] were not persisted
/// at write time — only employer-track aggregation fields exist in Firestore.
class InsuranceComplianceHistoryEntry {
  const InsuranceComplianceHistoryEntry({
    required this.id,
    required this.checkedAt,
    required this.companyName,
    required this.hasUnresolvedViolation,
  });

  final String id;
  final DateTime checkedAt;
  final String companyName;
  final bool hasUnresolvedViolation;
}
