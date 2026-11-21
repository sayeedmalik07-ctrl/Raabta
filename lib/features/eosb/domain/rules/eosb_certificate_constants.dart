/// Truth Certificate versioning — calculation ruleset, not app release.
abstract final class EosbRulesetVersion {
  static const current = 'eosb-rules-v1';
}

/// Immutable snapshot schema version. Increment when fingerprint payload changes.
abstract final class EosbCertificateSchemaVersion {
  static const current = 2;
}

/// Primary labour-law catalog entry for EOSB gratuity and core entitlements.
abstract final class EosbCertificateLegalCatalog {
  static const primaryLawId = 'law_14_2004';
  static const supplementaryLaw9Id = 'law_9_2026';
  static const molGuidanceId = 'mol_guidance';
}

/// Phase 1/2 trust state — server-side status after registration.
enum EosbCertificateTrustState {
  /// Generated locally; not registered online.
  visualEstimate,

  /// Registered on Raabta server — publicly verifiable.
  registeredOnline,

  /// Admin-revoked — record retained, verification shows revoked.
  revoked,

  /// Replaced by a newer registered certificate (ruleset/version migration).
  superseded,
}

/// Estimate confidence band — not legal certainty.
enum EosbCertificateConfidenceBand {
  high,
  medium,
  low,
}
