/// Deterministic tokenization for Firestore `searchKeywords` arrays and
/// client-side scoring. No AI — lowercase split, dedupe, min token length.
class SearchKeywordTokenizer {
  SearchKeywordTokenizer._();

  static const minTokenLength = 2;

  /// Tokenizes a single string into lowercase keywords (deduped).
  static List<String> tokenize(String input) {
    if (input.trim().isEmpty) return const [];

    final normalized = input.toLowerCase().replaceAll(
          RegExp(r'[^\w\s\u0600-\u06FF]'),
          ' ',
        );

    final tokens = <String>{};
    for (final raw in normalized.split(RegExp(r'\s+'))) {
      final word = raw.trim();
      if (word.length >= minTokenLength) {
        tokens.add(word);
      }
    }
    return tokens.toList()..sort();
  }

  /// Builds a deduped keyword list from multiple source fields (title, area, etc.).
  static List<String> buildFromFields(Iterable<String> fields) {
    final tokens = <String>{};
    for (final field in fields) {
      tokens.addAll(tokenize(field));
    }
    return tokens.toList()..sort();
  }

  /// First token used for Firestore `array-contains` prefix-style lookup.
  /// Preserves user query word order (not alphabetical).
  static String? primaryQueryToken(String query) {
    if (query.trim().isEmpty) return null;

    final normalized = query.toLowerCase().replaceAll(
          RegExp(r'[^\w\s\u0600-\u06FF]'),
          ' ',
        );

    for (final raw in normalized.split(RegExp(r'\s+'))) {
      final word = raw.trim();
      if (word.length >= minTokenLength) return word;
    }
    return null;
  }

  /// Simple relevance score — higher is better (deterministic).
  static int score({
    required String query,
    required String title,
    String subtitle = '',
  }) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return 0;

    final t = title.toLowerCase();
    final s = subtitle.toLowerCase();
    var score = 0;

    if (t == q) {
      score += 120;
    } else if (t.startsWith(q)) {
      score += 100;
    } else if (t.contains(q)) {
      score += 80;
    }

    for (final token in tokenize(query)) {
      if (t.contains(token)) score += 12;
      if (s.contains(token)) score += 6;
    }

    return score;
  }
}
