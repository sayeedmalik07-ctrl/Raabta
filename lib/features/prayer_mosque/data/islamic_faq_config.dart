/// Tunable knobs for Islamic Q&A FAQ vs Claude routing.
abstract final class IslamicFaqConfig {
  /// Minimum match score (0–1) before serving a static FAQ answer.
  static const double matchConfidenceThreshold = 0.72;

  /// When two entries score within this gap, treat as ambiguous → Claude.
  static const double ambiguityGap = 0.15;
}
