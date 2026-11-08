/// Bundled typical price ranges for Qatar — not live market data.
enum FairPriceCategory {
  taxi,
  food,
  tourist,
  transport,
}

class FairPriceGuideItem {
  const FairPriceGuideItem({
    required this.id,
    required this.category,
    required this.minQar,
    required this.maxQar,
    this.matchKeywords = const [],
    this.unitKey,
  });

  final String id;
  final FairPriceCategory category;
  final double minQar;
  final double maxQar;

  /// Lowercase keywords for deterministic bill line matching.
  final List<String> matchKeywords;

  /// Optional l10n suffix key, e.g. `fair_price_unit_per_km`.
  final String? unitKey;

  String categoryKey(FairPriceCategory cat) => switch (cat) {
        FairPriceCategory.taxi => 'fair_price_cat_taxi',
        FairPriceCategory.food => 'fair_price_cat_food',
        FairPriceCategory.tourist => 'fair_price_cat_tourist',
        FairPriceCategory.transport => 'fair_price_cat_transport',
      };

  String get nameKey => 'fair_price_item_$id';
}

enum BillRangeAssessment {
  inTypicalRange,
  somewhatAbove,
  notablyAbove,
  belowTypical,
  unknown,
}

class ParsedBillLine {
  const ParsedBillLine({
    required this.label,
    required this.amountQar,
  });

  final String label;
  final double amountQar;
}

class ParsedTripBill {
  const ParsedTripBill({
    this.totalQar,
    this.store,
    this.lines = const [],
    required this.confidence,
    required this.isPlausible,
  });

  final double? totalQar;
  final String? store;
  final List<ParsedBillLine> lines;
  final double confidence;
  final bool isPlausible;
}

class BillItemComparison {
  const BillItemComparison({
    required this.paidLabel,
    required this.paidAmount,
    this.guideItemId,
    this.guideMin,
    this.guideMax,
    required this.assessment,
  });

  final String paidLabel;
  final double paidAmount;
  final String? guideItemId;
  final double? guideMin;
  final double? guideMax;
  final BillRangeAssessment assessment;
}

class TripBillScanResult {
  const TripBillScanResult({
    required this.parsed,
    required this.comparisons,
    required this.summary,
    required this.usedAi,
  });

  final ParsedTripBill parsed;
  final List<BillItemComparison> comparisons;
  final String summary;
  final bool usedAi;
}
