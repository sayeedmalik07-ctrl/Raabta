/// Phase 3 — Raabta HMAC signing contract (server-side only).
///
/// ## What signing proves
///
/// - Raabta issued the **public verification record** stored on the server.
/// - The record fields have not been tampered with **on the server** since signing.
///
/// ## What signing does NOT prove
///
/// - PDF or share-card image integrity (offline edits are possible).
/// - Legal entitlement or government certification.
/// - That employer/QID/salary data is true (those fields are never on the public record).
///
/// ## Algorithm
///
/// - HMAC-SHA256 over canonical JSON of signable public fields (ASCII-sorted keys).
/// - Secret: `EOSB_CERTIFICATE_SIGNING_KEY` (server env only — never in the app).
/// - Stored as lowercase hex in `recordSignature` with `signatureVersion`.
///
/// Verification is performed by the Raabta server; the Flutter client displays
/// `signatureValid` from the public verify API response.
abstract final class EosbCertificateRecordSigning {
  static const signatureVersion = 1;

  /// Fields included in the HMAC payload when present (matches server order).
  static const signableFieldOrder = [
    'certificateId',
    'certificateStatus',
    'estimatedEntitlement',
    'currency',
    'eosbRulesetVersion',
    'legalSourceVersion',
    'legalSourceSummary',
    'legalSourceVerifiedDate',
    'confidenceBand',
    'calculationFingerprint',
    'generatedAt',
    'registeredAt',
    'recordVersion',
    'schemaVersion',
    'revokedAt',
    'revocationReason',
    'supersededBy',
  ];
}
