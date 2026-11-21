/// How a user-entered insurer / TPA / plan name was resolved.
enum InsurerLookupMatchType {
  /// Exact match to a MOPH-licensed insurer legal name.
  directInsurer,

  /// Matched via insurer alias (e.g. "QIC" → Qatar Insurance Company).
  aliasMatch,

  /// Branded plan name mapped to a single underlying insurer.
  brandedPlan,

  /// TPA mapped to one known underlying insurer.
  tpaMapped,

  /// TPA name recognized but underlying insurer cannot be determined.
  tpaAmbiguous,

  /// User chose manual review / free-text not in catalogue.
  manualReview,

  /// No match — user should use manual review fallback.
  notFound,
}

/// A TPA or branded plan entry in the lookup catalogue.
class TpaOrPlanMapping {
  const TpaOrPlanMapping({
    required this.id,
    required this.displayName,
    required this.type,
    this.underlyingInsurers = const [],
    this.aliases = const [],
    this.notes,
  });

  final String id;
  final String displayName;

  /// `tpa` or `brandedPlan`
  final String type;
  final List<String> underlyingInsurers;
  final List<String> aliases;
  final String? notes;

  bool get isTpa => type == 'tpa';
  bool get isBrandedPlan => type == 'brandedPlan';

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'displayName': displayName,
        'type': type,
        'underlyingInsurers': underlyingInsurers,
        'aliases': aliases,
        if (notes != null) 'notes': notes,
      };

  factory TpaOrPlanMapping.fromFirestore(Map<String, dynamic> data) {
    return TpaOrPlanMapping(
      id: data['id'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      type: data['type'] as String? ?? 'tpa',
      underlyingInsurers: (data['underlyingInsurers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      aliases: (data['aliases'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      notes: data['notes'] as String?,
    );
  }
}

/// Result of resolving a user query against insurers + TPA/plan mappings.
class InsurerLookupResult {
  const InsurerLookupResult({
    required this.query,
    required this.matchType,
    this.resolvedInsurerName,
    this.cardLabel,
    this.possibleInsurers = const [],
    this.userMessage,
    this.isMophRegistered,
  });

  final String query;
  final InsurerLookupMatchType matchType;

  /// Underlying MOPH insurer used for compliance registration check.
  final String? resolvedInsurerName;

  /// Label printed on the user's card (may differ from legal insurer name).
  final String? cardLabel;
  final List<String> possibleInsurers;
  final String? userMessage;
  final bool? isMophRegistered;

  bool get canRunRegistrationCheck =>
      resolvedInsurerName != null && resolvedInsurerName!.trim().isNotEmpty;

  bool get isManualReview =>
      matchType == InsurerLookupMatchType.manualReview ||
      matchType == InsurerLookupMatchType.notFound;
}

/// Full snapshot: insurers, aliases, TPA/plan mappings, freshness.
class MophInsurerLookupSnapshot {
  const MophInsurerLookupSnapshot({
    required this.insurers,
    required this.insurerAliases,
    required this.tpaMappings,
    required this.lastVerified,
    this.insurerRegulatoryBodies = const {},
    this.qfcRegisteredInsurers = const [],
  });

  final List<String> insurers;
  final Map<String, String> insurerAliases;
  final List<TpaOrPlanMapping> tpaMappings;
  final DateTime lastVerified;

  /// Canonical insurer name → `qcb` (default) or `qfcra`.
  final Map<String, String> insurerRegulatoryBodies;

  /// QFC-registered insurers (may overlap MOPH list or be separate entities).
  final List<String> qfcRegisteredInsurers;
}
