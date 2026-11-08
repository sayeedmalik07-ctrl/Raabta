/// A single static FAQ entry for Islamic Q&A.
class IslamicFaqEntry {
  const IslamicFaqEntry({
    required this.id,
    required this.category,
    required this.keywordsByLocale,
    required this.answerKey,
    this.deepLinkRoute,
    this.deepLinkLabelKey,
  });

  final String id;
  final String category;
  final Map<String, List<String>> keywordsByLocale;

  /// Key into [IslamicFaqStrings].
  final String answerKey;

  /// Optional in-app screen to open (e.g. Ramadan Companion).
  final String? deepLinkRoute;

  /// Label key in [PrayerStrings] for the deep-link button.
  final String? deepLinkLabelKey;

  Iterable<String> keywordsFor(String locale) {
    final localeKeys = keywordsByLocale[locale] ?? const <String>[];
    final english = keywordsByLocale['English'] ?? const <String>[];
    return {...localeKeys, ...english};
  }
}
