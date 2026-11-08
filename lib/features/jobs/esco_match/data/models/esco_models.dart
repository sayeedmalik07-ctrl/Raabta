/// ESCO taxonomy models — sourced from official EU ESCO v1.2.1 occupation↔skill graph.
enum EscoConceptType {
  skill,
  occupation,
}

/// How confidently free text mapped to an ESCO concept.
enum EscoMatchConfidence {
  exact,
  alias,
  fuzzy,
  none,
}

/// A bundled ESCO skill concept with EN/AR preferred labels.
class EscoSkillDef {
  const EscoSkillDef({
    required this.uri,
    required this.labelEn,
    required this.labelAr,
    this.altLabelsEn = const [],
  });

  final String uri;
  final String labelEn;
  final String labelAr;
  final List<String> altLabelsEn;

  EscoConceptType get conceptType => EscoConceptType.skill;

  /// Stable short id derived from ESCO URI (UUID segment).
  String get id => uri.split('/').last;
}

/// A bundled ESCO occupation with linked essential/optional skills.
class EscoOccupationDef {
  const EscoOccupationDef({
    required this.uri,
    required this.code,
    required this.labelEn,
    required this.labelAr,
    this.altLabelsEn = const [],
    this.essentialSkillUris = const [],
    this.optionalSkillUris = const [],
  });

  final String uri;
  final String code;
  final String labelEn;
  final String labelAr;
  final List<String> altLabelsEn;
  final List<String> essentialSkillUris;
  final List<String> optionalSkillUris;

  EscoConceptType get conceptType => EscoConceptType.occupation;

  String get id => uri.split('/').last;

  List<String> get allLinkedSkillUris => [
        ...essentialSkillUris,
        ...optionalSkillUris,
      ];
}

/// Result of mapping user-entered free text to a bundled ESCO concept.
class EscoNormalizationResult {
  const EscoNormalizationResult({
    required this.input,
    required this.confidence,
    this.skill,
    this.occupation,
    this.matchedLabel,
    this.score = 0,
  });

  final String input;
  final EscoMatchConfidence confidence;
  final EscoSkillDef? skill;
  final EscoOccupationDef? occupation;
  final String? matchedLabel;

  /// Similarity score 0–100 (0 when [confidence] is [EscoMatchConfidence.none]).
  final int score;

  bool get isMatched => confidence != EscoMatchConfidence.none;

  EscoConceptType? get conceptType {
    if (skill != null) return EscoConceptType.skill;
    if (occupation != null) return EscoConceptType.occupation;
    return null;
  }

  String? get resolvedUri => skill?.uri ?? occupation?.uri;

  String labelForLocale(String locale) {
    final useArabic = locale.toLowerCase().contains('arabic') ||
        locale.toLowerCase() == 'ar';
    if (skill != null) {
      return useArabic && skill!.labelAr.isNotEmpty
          ? skill!.labelAr
          : skill!.labelEn;
    }
    if (occupation != null) {
      return useArabic && occupation!.labelAr.isNotEmpty
          ? occupation!.labelAr
          : occupation!.labelEn;
    }
    return input;
  }
}

/// Lookup index entry built once from [EscoCatalog].
class EscoLabelIndexEntry {
  const EscoLabelIndexEntry({
    required this.normalizedLabel,
    required this.conceptType,
    required this.uri,
    required this.isAlias,
  });

  final String normalizedLabel;
  final EscoConceptType conceptType;
  final String uri;
  final bool isAlias;
}
