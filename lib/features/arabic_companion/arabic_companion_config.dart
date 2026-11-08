/// Arabic Companion — phrasebook (offline) + live AI translation (capped).
abstract final class ArabicCompanionConfig {
  static const aiRequestType = 'arabic_companion';

  /// Free-tier Claude calls per calendar month (cache misses only).
  static const freeMonthlyAiLimit = 10;

  /// Shared Firestore collection for cross-user translation cache.
  static const translationsCacheCollection = 'arabic_translations_cache';
}
