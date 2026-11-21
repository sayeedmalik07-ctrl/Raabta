/// Deterministic matching weights — zero AI.
abstract final class BuddyMatchingWeights {
  static const sameNationality = 100;
  static const sharedLanguageEach = 15;
  static const sharedLanguageCap = 45;
  static const sameArea = 25;
  static const sharedInterestEach = 10;
  static const sharedInterestCap = 30;

  static const yearsBandScores = {
    'under_1_year': 0,
    '1_3_years': 10,
    '3_plus_years': 20,
  };
}
