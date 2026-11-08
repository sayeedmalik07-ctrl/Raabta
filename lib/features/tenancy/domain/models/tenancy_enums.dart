/// Tenancy Truth Engine — domain enums.
///
/// NOTE: [TenancyLegalSource.law8_2026] amends property leasing (Law 4/2008).
/// Law No. 9 of 2026 is a separate labour-law amendment tracked in EOSB — never merge.
enum TenancyPropertyType {
  residential,
  commercial,
}

enum TenancyRegistrationStatus {
  yes,
  no,
  notSure,
}

enum TenancyComplianceStatus {
  compliant,
  violation,
  needsVerification,
  informational,
  critical,
}

/// Firestore / legal_sources document ids for this feature only.
enum TenancyLegalSource {
  law4_2008('law_4_2008_tenancy'),
  law8_2026('law_8_2026_tenancy');

  const TenancyLegalSource(this.documentId);

  final String documentId;
}
