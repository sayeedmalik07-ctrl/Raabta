/// Deterministic markup math — zero AI, pure rate comparison.
import 'package:raabta/features/money_comparator/data/models/remittance_provider_rate_model.dart';

abstract final class RemittanceTruthCalculator {
  /// Provider effective rate: mid-market minus hidden FX spread.
  static double providerEffectiveRate({
    required double midMarketRate,
    required double fxMarginPercent,
  }) {
    if (midMarketRate <= 0) return 0;
    return midMarketRate * (1 - fxMarginPercent / 100);
  }

  /// Foreign currency recipient gets after spread + flat fee (fee deducted in QAR terms).
  static double recipientGetsForeign({
    required double amountSentQar,
    required double midMarketRate,
    required double fxMarginPercent,
    required double flatFeeQar,
  }) {
    final effectiveRate = providerEffectiveRate(
      midMarketRate: midMarketRate,
      fxMarginPercent: fxMarginPercent,
    );
    final foreignBeforeFee = amountSentQar * effectiveRate;
    final feeInForeign = flatFeeQar * effectiveRate;
    return (foreignBeforeFee - feeInForeign).clamp(0, double.infinity);
  }

  /// Hidden markup in QAR — spread loss only (excludes disclosed flat fee).
  static double hiddenMarkupQar({
    required double amountSentQar,
    required double midMarketRate,
    required double fxMarginPercent,
  }) {
    if (midMarketRate <= 0 || amountSentQar <= 0) return 0;
    final midGets = amountSentQar * midMarketRate;
    final providerGets = amountSentQar *
        providerEffectiveRate(
          midMarketRate: midMarketRate,
          fxMarginPercent: fxMarginPercent,
        );
    final foreignLoss = midGets - providerGets;
    return (foreignLoss / midMarketRate).clamp(0, double.infinity);
  }

  /// Total cost in QAR = hidden spread loss + flat fee.
  static double totalCostQar({
    required double amountSentQar,
    required double midMarketRate,
    required double fxMarginPercent,
    required double flatFeeQar,
  }) {
    return hiddenMarkupQar(
          amountSentQar: amountSentQar,
          midMarketRate: midMarketRate,
          fxMarginPercent: fxMarginPercent,
        ) +
        flatFeeQar;
  }

  /// Total cost as percentage of send amount.
  static double totalCostPercent({
    required double amountSentQar,
    required double totalCostQar,
  }) {
    if (amountSentQar <= 0) return 0;
    return (totalCostQar / amountSentQar) * 100;
  }
}

class RemittanceProviderComparisonRow {
  const RemittanceProviderComparisonRow({
    required this.provider,
    required this.midMarketRate,
    required this.providerEffectiveRate,
    required this.recipientGetsForeign,
    required this.hiddenMarkupQar,
    required this.totalCostQar,
    required this.totalCostPercent,
  });

  final RemittanceProviderRate provider;
  final double midMarketRate;
  final double providerEffectiveRate;
  final double recipientGetsForeign;
  final double hiddenMarkupQar;
  final double totalCostQar;
  final double totalCostPercent;
}
