/// Tunable thresholds for Bill Tracker amount anomaly detection (Part C).
abstract final class BillAnomalyThresholds {
  /// Minimum calendar months of baseline history before alerting.
  static const int minHistoryMonths = 3;

  /// Rolling window for baseline average (months).
  static const int rollingWindowMonths = 6;

  /// Minimum prior bills required for a baseline (excluding the bill under test).
  static const int minBaselineBillCount = 3;

  /// Alert when current amount exceeds rolling average by this fraction (0.30 = 30%).
  static const double spikeThresholdFraction = 0.30;

  /// Approximate days per month for history span checks.
  static const int daysPerMonth = 30;
}
