import 'package:flutter/material.dart';

/// Qatar gold market constants — NOT Saudi (SAR / 3.75 peg).
abstract final class GoldQatarConstants {
  /// Qatar Central Bank USD peg — NOT Saudi 3.75.
  static const qarUsdPeg = 3.64;

  static const gramsPerTroyOz = 31.1034768;
  static const gramsPerTola = 11.6638038;
  static const sovereignGrams = 8.0;
  static const gramsPerKg = 1000.0;

  static const purities = [24, 22, 21, 18];

  /// Qatar jewellery making charge range (%). Souq shops often charge up to ~20%
  /// on intricate pieces; calculator allows up to 25% for custom quotes.
  static const defaultMakingChargePct = 5.0;
  static const minMakingChargePct = 1.0;
  static const maxMakingChargePct = 25.0;

  static double purityMultiplier(int purity) => purity / 24.0;

  static double priceForPurity(double price24k, int purity) =>
      price24k * purityMultiplier(purity);

  /// Common weight rows for the price-by-weight table.
  static const weightRows = [
    (key: '1_gram', grams: 1.0),
    (key: '8_gram_sovereign', grams: sovereignGrams),
    (key: '10_grams', grams: 10.0),
    (key: 'tola', grams: gramsPerTola),
    (key: 'ounce', grams: gramsPerTroyOz),
    (key: '100_grams', grams: 100.0),
    (key: 'kilogram', grams: gramsPerKg),
  ];

  /// Popular quick-reference weights (22K jewellery context).
  static const popularWeights = [
    (key: '1g', grams: 1.0),
    (key: '8g_sovereign', grams: sovereignGrams),
    (key: '10g', grams: 10.0),
    (key: 'tola', grams: gramsPerTola),
  ];
}

enum GoldWeightUnit { gram, tola, sovereign, ounce, kilogram }

extension GoldWeightUnitX on GoldWeightUnit {
  double toGrams(double amount) {
    switch (this) {
      case GoldWeightUnit.gram:
        return amount;
      case GoldWeightUnit.tola:
        return amount * GoldQatarConstants.gramsPerTola;
      case GoldWeightUnit.sovereign:
        return amount * GoldQatarConstants.sovereignGrams;
      case GoldWeightUnit.ounce:
        return amount * GoldQatarConstants.gramsPerTroyOz;
      case GoldWeightUnit.kilogram:
        return amount * GoldQatarConstants.gramsPerKg;
    }
  }

}

enum GoldJewelryType { necklace, ring, bracelet, coin, bar }

extension GoldJewelryTypeX on GoldJewelryType {
  bool get isInvestmentGrade =>
      this == GoldJewelryType.coin || this == GoldJewelryType.bar;

  IconData get icon {
    switch (this) {
      case GoldJewelryType.necklace:
        return Icons.link_rounded;
      case GoldJewelryType.ring:
        return Icons.circle_outlined;
      case GoldJewelryType.bracelet:
        return Icons.watch_rounded;
      case GoldJewelryType.coin:
        return Icons.toll_rounded;
      case GoldJewelryType.bar:
        return Icons.view_column_rounded;
    }
  }

  /// Suggested making-charge defaults for Qatar jewellery vs investment pieces.
  /// Max is [GoldQatarConstants.maxMakingChargePct] — intricate souq pieces can reach ~20%.
  (double defaultPct, double minPct, double maxPct) get makingChargeRange {
    const max = GoldQatarConstants.maxMakingChargePct;
    const min = GoldQatarConstants.minMakingChargePct;
    switch (this) {
      case GoldJewelryType.coin:
      case GoldJewelryType.bar:
        return (0, 0, 0);
      case GoldJewelryType.ring:
        return (5.0, min, max);
      case GoldJewelryType.bracelet:
        return (7.0, min, max);
      case GoldJewelryType.necklace:
        return (12.0, min, max);
    }
  }
}
