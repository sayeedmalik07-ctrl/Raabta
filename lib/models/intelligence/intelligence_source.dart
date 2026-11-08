/// Provenance for an intelligence insight — where the signal came from and how trusted it is.
///
/// EOSB uses l10n `ruleKey` / `formulaKey` strings for labour-law citations; it does not
/// define an equivalent model. [LegalSource] (`lib/features/legal_sources/domain/models/legal_source.dart`)
/// tracks admin-maintained law documents in Firestore — a different concern.
class IntelligenceSource {
  const IntelligenceSource({
    required this.type,
    this.reference,
    required this.verificationStatus,
  });

  /// `user` | `official` | `api` | `ai` | `document`
  final String type;

  /// Document ID, URL, law citation, or other stable reference.
  final String? reference;

  /// `unverified` | `pending` | `verified` | `disputed`
  final String verificationStatus;

  Map<String, dynamic> toJson() => {
        'type': type,
        if (reference != null) 'reference': reference,
        'verificationStatus': verificationStatus,
      };

  factory IntelligenceSource.fromJson(Map<String, dynamic> json) {
    return IntelligenceSource(
      type: json['type'] as String? ?? '',
      reference: json['reference'] as String?,
      verificationStatus: json['verificationStatus'] as String? ?? 'unverified',
    );
  }

  IntelligenceSource copyWith({
    String? type,
    String? reference,
    String? verificationStatus,
  }) {
    return IntelligenceSource(
      type: type ?? this.type,
      reference: reference ?? this.reference,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntelligenceSource &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          reference == other.reference &&
          verificationStatus == other.verificationStatus;

  @override
  int get hashCode => Object.hash(type, reference, verificationStatus);
}
