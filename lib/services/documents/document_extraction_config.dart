/// Tunable knobs for local-vs-Claude document extraction routing.
class DocumentExtractionConfig {
  DocumentExtractionConfig._();

  /// Minimum local-parser confidence before skipping Claude.
  static const double localExtractionConfidenceThreshold = 0.85;

  /// Receipts vary widely — cap local confidence below the Claude skip threshold
  /// unless multiple strong signals align.
  static const double receiptLocalConfidenceCap = 0.75;

  /// Bill templates need provider + amount + at least one more field for high confidence.
  static const double billLocalHighConfidence = 0.90;
}
