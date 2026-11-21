/// Status of a tracked legal source in the admin maintenance checklist.
enum LegalSourceStatus {
  active,
  amended,
  superseded,
}

extension LegalSourceStatusX on LegalSourceStatus {
  /// Firestore / API serialization — ACTIVE, AMENDED, SUPERSEDED.
  String get firestoreValue => switch (this) {
        LegalSourceStatus.active => 'ACTIVE',
        LegalSourceStatus.amended => 'AMENDED',
        LegalSourceStatus.superseded => 'SUPERSEDED',
      };

  static LegalSourceStatus fromFirestore(String? raw) {
    if (raw == null || raw.isEmpty) return LegalSourceStatus.active;
    final normalized = raw.trim();
    switch (normalized) {
      case 'ACTIVE':
      case 'active':
      case 'current':
        return LegalSourceStatus.active;
      case 'AMENDED':
      case 'amended':
      case 'needsReview':
        return LegalSourceStatus.amended;
      case 'SUPERSEDED':
      case 'superseded':
        return LegalSourceStatus.superseded;
      default:
        return LegalSourceStatus.active;
    }
  }
}

/// One law or guidance document referenced by Truth Engines / labour RAG.
///
/// Versioning: when a law is replaced, mark the old entry `SUPERSEDED` with
/// [supersededBy] pointing at the new document id. New entries may still set
/// [supersedes] for backward-compatible amendment chains.
class LegalSource {
  const LegalSource({
    required this.id,
    required this.lawIdentifier,
    required this.shortDescription,
    this.dateEnacted,
    this.dateLastVerified,
    required this.sourceUrl,
    this.status = LegalSourceStatus.active,
    this.effectiveFrom,
    this.supersedes,
    this.supersededBy,
  });

  final String id;
  final String lawIdentifier;
  final String shortDescription;
  final DateTime? dateEnacted;
  final DateTime? dateLastVerified;
  final String sourceUrl;
  final LegalSourceStatus status;
  /// When this rule/law version took effect, if independently verified.
  final DateTime? effectiveFrom;
  /// Prior `legal_sources` document id this entry replaces or amends.
  final String? supersedes;
  /// When [status] is SUPERSEDED, the id of the replacement entry.
  final String? supersededBy;

  Map<String, dynamic> toFirestore() => {
        'lawIdentifier': lawIdentifier,
        'shortDescription': shortDescription,
        'dateEnacted': dateEnacted?.toIso8601String(),
        'dateLastVerified': dateLastVerified?.toIso8601String(),
        'sourceUrl': sourceUrl,
        'status': status.firestoreValue,
        if (effectiveFrom != null)
          'effectiveFrom': effectiveFrom!.toIso8601String(),
        if (supersedes != null && supersedes!.isNotEmpty) 'supersedes': supersedes,
        if (supersededBy != null && supersededBy!.isNotEmpty)
          'supersededBy': supersededBy,
      };

  factory LegalSource.fromFirestore(String id, Map<String, dynamic> data) {
    return LegalSource(
      id: id,
      lawIdentifier: data['lawIdentifier'] as String? ?? id,
      shortDescription: data['shortDescription'] as String? ?? '',
      dateEnacted: DateTime.tryParse(data['dateEnacted']?.toString() ?? ''),
      dateLastVerified:
          DateTime.tryParse(data['dateLastVerified']?.toString() ?? ''),
      sourceUrl: data['sourceUrl'] as String? ?? '',
      status: LegalSourceStatusX.fromFirestore(data['status'] as String?),
      effectiveFrom:
          DateTime.tryParse(data['effectiveFrom']?.toString() ?? ''),
      supersedes: data['supersedes'] as String?,
      supersededBy: data['supersededBy'] as String?,
    );
  }

  LegalSource copyWith({
    String? lawIdentifier,
    String? shortDescription,
    DateTime? dateEnacted,
    DateTime? dateLastVerified,
    LegalSourceStatus? status,
    String? sourceUrl,
    DateTime? effectiveFrom,
    String? supersedes,
    String? supersededBy,
  }) {
    return LegalSource(
      id: id,
      lawIdentifier: lawIdentifier ?? this.lawIdentifier,
      shortDescription: shortDescription ?? this.shortDescription,
      dateEnacted: dateEnacted ?? this.dateEnacted,
      dateLastVerified: dateLastVerified ?? this.dateLastVerified,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      status: status ?? this.status,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      supersedes: supersedes ?? this.supersedes,
      supersededBy: supersededBy ?? this.supersededBy,
    );
  }
}
