/// Deterministic Lost & Found match policy (Stage 2 — no AI).
abstract final class LostFoundMatchPolicy {
  /// Maximum opposite-type candidates examined per run (server-enforced).
  static const maxCandidateQueryLimit = 50;

  /// Inclusive day window between lost/found [dateOccurred] values.
  static const maxDateWindowDays = 21;

  /// Minimum score (inclusive) to persist a match.
  static const matchScoreThreshold = 45;

  /// Subcollections under `lost_and_found/{itemId}` (no new top-level family).
  static const matchesSubcollection = 'lf_matches';
  static const dismissalsSubcollection = 'lf_match_dismissals';

  /// Stable pair id for idempotency and dismissal keys.
  static String pairId(String itemIdA, String itemIdB) {
    final ids = [itemIdA, itemIdB]..sort();
    return '${ids[0]}__${ids[1]}';
  }
}
