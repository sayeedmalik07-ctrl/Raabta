/// Tunable knobs for Ask Qatar "Already asked?" lookup and AI ranking.
abstract final class AskQatarSimilarQuestionConfig {
  static const int minTitleLengthForLookup = 12;
  static const Duration debounceDelay = Duration(milliseconds: 800);
  static const Duration clientCacheTtl = Duration(minutes: 15);

  static const int maxCandidateFetch = 50;
  static const int maxLocalCandidates = 5;
  static const int maxDisplay = 3;

  /// Minimum local overlap score (token hits) to count as a candidate.
  static const int minOverlapScore = 2;

  /// Require at least this many scored candidates before calling Claude.
  static const int minCandidatesForAiRanking = 2;

  /// Max Claude ranking calls per user per UTC hour (separate from moderation aiCalls).
  static const int maxAskQatarSimilarRankCallsPerUserPerHour = 12;

  /// English + common community stop words (extend per locale as needed).
  static const Set<String> stopWords = {
    'a', 'an', 'the', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of',
    'is', 'are', 'was', 'were', 'be', 'been', 'being', 'have', 'has', 'had',
    'do', 'does', 'did', 'will', 'would', 'could', 'should', 'may', 'might',
    'can', 'i', 'me', 'my', 'we', 'our', 'you', 'your', 'he', 'she', 'it',
    'they', 'them', 'their', 'this', 'that', 'these', 'those', 'what', 'which',
    'who', 'whom', 'how', 'when', 'where', 'why', 'any', 'anyone', 'someone',
    'please', 'help', 'need', 'qatar', 'doha', 'about', 'with', 'from', 'into',
    'ka', 'ki', 'ke', 'ko', 'se', 'mein', 'hai', 'kya', 'aur', 'ya', 'par',
    'في', 'من', 'على', 'إلى', 'هل', 'ما', 'عن',
  };
}
