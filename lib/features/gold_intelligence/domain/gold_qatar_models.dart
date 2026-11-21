import 'package:raabta/features/gold_intelligence/domain/gold_qatar_constants.dart';

class GoldQatarSnapshot {
  const GoldQatarSnapshot({
    required this.gold24kQarPerGram,
    required this.gold30dPercentile,
    required this.gold90dPercentile,
    required this.pctVsYesterday,
    required this.pctVs7dAvg,
    this.aiInsight,
    this.aiInsightDisclaimer,
    this.updatedAt,
    this.qarDeltaVsYesterday,
    this.yesterdayClose,
    this.dayHigh,
    this.dayLow,
    this.dayOpen,
    this.spotSource,
    this.isFromCache = false,
    this.isDirectApi = false,
  });

  final double gold24kQarPerGram;
  final int gold30dPercentile;
  final int gold90dPercentile;
  final double pctVsYesterday;
  final double pctVs7dAvg;
  final String? aiInsight;
  final String? aiInsightDisclaimer;
  final DateTime? updatedAt;
  final double? qarDeltaVsYesterday;
  final double? yesterdayClose;
  final double? dayHigh;
  final double? dayLow;
  final double? dayOpen;
  final String? spotSource;
  final bool isFromCache;
  final bool isDirectApi;

  factory GoldQatarSnapshot.fromJson(Map<String, dynamic> json) {
    final price = (json['gold_24k_qar_per_gram'] as num?)?.toDouble() ?? 0;
    final yesterdayClose = (json['yesterday_close'] as num?)?.toDouble();
    DateTime? updated;
    final rawDate = json['date'] ?? json['ai_insight_generated_at'];
    if (rawDate is String) {
      updated = DateTime.tryParse(rawDate);
    }

    final explicitDelta = (json['qar_delta_vs_yesterday'] as num?)?.toDouble();
    final computedDelta =
        explicitDelta ?? (yesterdayClose != null ? price - yesterdayClose : null);

    return GoldQatarSnapshot(
      gold24kQarPerGram: price,
      gold30dPercentile: (json['gold_30d_percentile'] as num?)?.toInt() ?? 50,
      gold90dPercentile: (json['gold_90d_percentile'] as num?)?.toInt() ?? 50,
      pctVsYesterday: (json['pct_vs_yesterday'] as num?)?.toDouble() ?? 0,
      pctVs7dAvg: (json['pct_vs_7d_avg'] as num?)?.toDouble() ?? 0,
      aiInsight: json['ai_insight'] as String?,
      aiInsightDisclaimer: json['ai_insight_disclaimer'] as String?,
      updatedAt: updated,
      qarDeltaVsYesterday: computedDelta,
      yesterdayClose: yesterdayClose,
      dayHigh: (json['day_high'] as num?)?.toDouble(),
      dayLow: (json['day_low'] as num?)?.toDouble(),
      dayOpen: (json['day_open'] as num?)?.toDouble(),
      spotSource: json['spot_source'] as String?,
    );
  }
}

class GoldHistoryPoint {
  const GoldHistoryPoint({required this.date, required this.price});

  final String date;
  final double price;

  factory GoldHistoryPoint.fromJson(Map<String, dynamic> json) {
    return GoldHistoryPoint(
      date: json['date']?.toString() ?? '',
      price: (json['gold_24k_qar_per_gram'] as num?)?.toDouble() ?? 0,
    );
  }
}

class JewelryLockerItem {
  const JewelryLockerItem({
    required this.id,
    required this.itemName,
    required this.purchasePriceQar,
    required this.weightGrams,
    required this.purity,
    this.purchaseDate,
    this.invoicePhotoUrl,
  });

  final String id;
  final String itemName;
  final double purchasePriceQar;
  final double weightGrams;
  final int purity;
  final String? purchaseDate;
  final String? invoicePhotoUrl;

  factory JewelryLockerItem.fromJson(Map<String, dynamic> json) {
    return JewelryLockerItem(
      id: json['id'] as String? ?? '',
      itemName: json['itemName'] as String? ?? '',
      purchasePriceQar: (json['purchasePriceQar'] as num?)?.toDouble() ?? 0,
      weightGrams: (json['weightGrams'] as num?)?.toDouble() ?? 0,
      purity: (json['purity'] as num?)?.toInt() ?? 24,
      purchaseDate: json['purchaseDate'] as String?,
      invoicePhotoUrl: json['invoicePhotoUrl'] as String?,
    );
  }

  double estimatedValueQar(double price24k) =>
      GoldQatarConstants.priceForPurity(price24k, purity) * weightGrams;

  double gainLossQar(double price24k) =>
      estimatedValueQar(price24k) - purchasePriceQar;
}

/// Chart range selector — `today` uses intraday snapshots.
enum GoldChartRange { today, d7, d30, m6, y1 }

extension GoldChartRangeX on GoldChartRange {
  int? get historyDays {
    switch (this) {
      case GoldChartRange.today:
        return null;
      case GoldChartRange.d7:
        return 7;
      case GoldChartRange.d30:
        return 30;
      case GoldChartRange.m6:
        return 180;
      case GoldChartRange.y1:
        return 365;
    }
  }

}
