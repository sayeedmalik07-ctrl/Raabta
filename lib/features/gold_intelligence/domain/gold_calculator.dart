import 'package:raabta/features/gold_intelligence/domain/gold_qatar_constants.dart';

/// Pure Dart gold purchase/resale math — no AI, no VAT on bars/coins (Qatar).
class GoldCalculatorResult {
  const GoldCalculatorResult({
    required this.goldValueQar,
    required this.makingChargeQar,
    required this.vatQar,
    required this.totalPurchaseQar,
    required this.resaleEstimateQar,
    required this.profitLossQar,
    required this.weightGrams,
    required this.purity,
    required this.pricePerGramQar,
    required this.makingChargePct,
  });

  final double goldValueQar;
  final double makingChargeQar;
  final double vatQar;
  final double totalPurchaseQar;
  final double resaleEstimateQar;
  final double profitLossQar;
  final double weightGrams;
  final int purity;
  final double pricePerGramQar;
  final double makingChargePct;

  double get premiumOverMetalQar => totalPurchaseQar - goldValueQar;

  double get premiumPct =>
      goldValueQar > 0 ? (premiumOverMetalQar / goldValueQar) * 100 : 0;

  double get metalSharePct =>
      totalPurchaseQar > 0 ? (goldValueQar / totalPurchaseQar) * 100 : 100;

  double get makingSharePct =>
      totalPurchaseQar > 0 ? (makingChargeQar / totalPurchaseQar) * 100 : 0;
}

enum GoldCalculatorMode { purchase, resale }

abstract final class GoldCalculator {
  static GoldCalculatorResult compute({
    required double price24kQarPerGram,
    required double weightGrams,
    required int purity,
    required GoldJewelryType itemType,
    double makingChargePct = GoldQatarConstants.defaultMakingChargePct,
    bool applyVat = false,
    double vatPct = 0,
    double? userPurchasePriceQar,
  }) {
    final pricePerGram =
        GoldQatarConstants.priceForPurity(price24kQarPerGram, purity);
    final goldValue = pricePerGram * weightGrams;

    final makingApplies = !itemType.isInvestmentGrade;
    final effectiveMakingPct = makingApplies ? makingChargePct : 0.0;
    final makingCharge =
        makingApplies ? goldValue * (makingChargePct / 100) : 0.0;

    var subtotal = goldValue + makingCharge;
    var vatQar = 0.0;
    if (applyVat && vatPct > 0 && makingApplies) {
      vatQar = subtotal * (vatPct / 100);
    }
    final total = subtotal + vatQar;

    final resale = goldValue;
    final purchaseRef = userPurchasePriceQar ?? total;
    final pl = resale - purchaseRef;

    return GoldCalculatorResult(
      goldValueQar: goldValue,
      makingChargeQar: makingCharge,
      vatQar: vatQar,
      totalPurchaseQar: total,
      resaleEstimateQar: resale,
      profitLossQar: pl,
      weightGrams: weightGrams,
      purity: purity,
      pricePerGramQar: pricePerGram,
      makingChargePct: effectiveMakingPct,
    );
  }
}
