/// Public API response for anonymized scam pattern aggregates (Part D).
class ScamPatternAreaAggregates {
  const ScamPatternAreaAggregates({
    required this.area,
    required this.patterns,
  });

  static const empty = ScamPatternAreaAggregates(area: '', patterns: []);

  final String area;

  /// Threshold-cleared archetype counts only — never partial/below-k values.
  final List<ScamPatternArchetypeAggregate> patterns;

  bool get hasData => patterns.isNotEmpty;

  factory ScamPatternAreaAggregates.fromJson(Map<String, dynamic> json) {
    final area = json['area'] as String? ?? '';
    final raw = json['patterns'] as List<dynamic>? ?? [];
    final patterns = raw
        .map(
          (e) => ScamPatternArchetypeAggregate.fromJson(
            e as Map<String, dynamic>,
          ),
        )
        .toList();
    return ScamPatternAreaAggregates(area: area, patterns: patterns);
  }
}

class ScamPatternArchetypeAggregate {
  const ScamPatternArchetypeAggregate({
    required this.archetypeId,
    required this.reporterCount,
    required this.lastUpdated,
  });

  final String archetypeId;
  final int reporterCount;
  final String? lastUpdated;

  factory ScamPatternArchetypeAggregate.fromJson(Map<String, dynamic> json) {
    return ScamPatternArchetypeAggregate(
      archetypeId: json['archetypeId'] as String? ?? '',
      reporterCount: (json['reporterCount'] as num?)?.toInt() ?? 0,
      lastUpdated: json['lastUpdated'] as String?,
    );
  }
}
