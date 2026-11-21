import 'package:raabta/features/money_comparator/data/models/corridor_report_model.dart';

/// Deterministic rolling-average math for corridor aggregates — no AI.
class CorridorAggregateLogic {
  CorridorAggregateLogic._();

  /// Minimum community reports before showing a ranked estimate.
  static const int minReportsForRanking = 3;

  /// Result of incrementally updating a rolling mean.
  static ({int count, double average}) updateRollingAverage({
    required int currentCount,
    required double currentAverage,
    required double newValue,
  }) {
    final newCount = currentCount + 1;
    if (currentCount <= 0) {
      return (count: newCount, average: newValue);
    }
    final updated =
        currentAverage + (newValue - currentAverage) / newCount;
    return (count: newCount, average: updated);
  }

  /// Destination currency received per 1 QAR sent (net of fee).
  static double effectiveRateFromReport(CorridorReport report) {
    final netQar = report.amountSentQar - report.feePaidQar;
    if (netQar <= 0 || report.amountRecipientGot <= 0) return 0;
    return report.amountRecipientGot / netQar;
  }

  /// Estimate recipient amount for a new send amount using aggregate averages.
  static double estimateRecipientGets({
    required double amountSentQar,
    required double avgFeePaidQar,
    required double avgEffectiveRate,
  }) {
    final net = amountSentQar - avgFeePaidQar;
    if (net <= 0 || avgEffectiveRate <= 0) return 0;
    return net * avgEffectiveRate;
  }

  /// Recipient-gets per 100 QAR sent (for display copy).
  static double recipientGetsPer100Qar({
    required double avgEffectiveRate,
    required double avgFeePaidQar,
  }) {
    return estimateRecipientGets(
      amountSentQar: 100,
      avgFeePaidQar: avgFeePaidQar,
      avgEffectiveRate: avgEffectiveRate,
    );
  }

  /// Whether an aggregate has enough data to rank.
  static bool hasEnoughData(int reportCount) =>
      reportCount >= minReportsForRanking;

  /// Light sanity check before write — returns warning message or null.
  static String? validateReportSanity(CorridorReport draft) {
    if (draft.amountSentQar <= 0) return 'Enter the amount you sent.';
    if (draft.amountRecipientGot <= 0) {
      return 'Enter what the recipient received.';
    }
    if (draft.feePaidQar < 0) return 'Fee cannot be negative.';
    if (draft.feePaidQar >= draft.amountSentQar) {
      return 'Fee looks too high compared to amount sent.';
    }
    final rate = effectiveRateFromReport(draft);
    if (rate <= 0) return 'Check amounts — recipient total looks invalid.';
    // Very loose upper bound to catch typos (e.g. extra zero).
    if (rate > 500) {
      return 'Recipient amount seems unusually high — please double-check.';
    }
    if (draft.deliveryHours < 0 || draft.deliveryHours > 720) {
      return 'Delivery time should be between 0 and 720 hours.';
    }
    return null;
  }
}
