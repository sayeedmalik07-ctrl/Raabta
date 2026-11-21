/// Decayed affinity from a recent global search query (S10).
class SearchRecentSearchSignal {
  const SearchRecentSearchSignal({
    required this.normalizedQuery,
    required this.weight,
  });

  final String normalizedQuery;
  final double weight;
}

/// Result of personalization scoring for one candidate (S10).
class SearchPersonalizationScore {
  const SearchPersonalizationScore({
    this.bonus = 0,
    this.usedExplicitPreference = false,
  });

  final int bonus;
  final bool usedExplicitPreference;

  static const neutral = SearchPersonalizationScore();
}
