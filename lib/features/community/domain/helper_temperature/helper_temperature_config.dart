/// Centralized knobs for Helper Temperature (Part A — pure scoring only).
abstract final class HelperTemperatureConfig {
  /// Neutral starting point; no public tier chip at baseline.
  static const double baseline = 36.5;

  static const double minScore = 30.0;
  static const double maxScore = 60.0;

  // ─── Signal toggles (Part A: accepted answers only) ───────────────────────

  static const bool acceptedAnswersEnabled = true;

  static const bool helpfulVotesEnabled = false;
  static const bool groupLikesEnabled = false;
  static const bool moderationBlocksEnabled = false;
  static const bool lostFoundResolvedEnabled = false;
  static const bool questionUpvotesEnabled = false;

  // ─── Accepted answer gains ────────────────────────────────────────────────

  /// Base marginal gain before diminishing returns.
  static const double acceptedAnswerBaseGain = 2.5;

  /// Each prior counted accept reduces the next marginal gain multiplicatively.
  static const double acceptedAnswerDiminishFactor = 0.35;

  /// Max total score increase from accepted answers on a single UTC calendar day.
  static const double maxDailyGain = 4.0;

  // ─── Decay (idle drift of excess toward baseline) ─────────────────────────

  static const bool decayEnabled = true;

  /// Fraction of excess above baseline removed per full idle day after last credit.
  static const double decayRatePerDay = 0.05;

  // ─── Reserved for later phases (disabled by default) ──────────────────────

  static const double helpfulVoteBaseGain = 0.4;
  static const double groupLikeBaseGain = 0.25;
  static const double lostFoundResolvedGain = 1.0;
  static const double questionUpvoteGain = 0.15;
  static const double moderationBlockPenalty = 0.75;
  static const int moderationBlockRollingWindowDays = 30;
}
