import 'package:raabta/features/trip_planner/data/doha_transit_fares_config.dart';
import 'package:raabta/features/trip_planner/domain/models/fair_price_models.dart';

/// Versioned bundled reference — refresh periodically (see file header sources).
abstract final class FairPriceGuideCatalog {
  static const version = '2026-08-1';

  /// Display date aligned with [version] — Raabta research refresh, not live market data.
  static const catalogLastVerified = '2026-08-01';

  /// Sources (build-time research, Aug 2026):
  /// - Karwa/Mowasalat tariffs: marhaba.qa, expatfocus.com (QAR 7 + 1.8 km, QAR 1.60/1.90 per km, HIA QAR 25)
  /// - Airport–city reference: welcomepickups.com (~QAR 47 typical)
  /// - Food: qatarliving.com budget eats, travelwithhello.com 2026 guide
  /// - Desert safari: aligned with Trip Planner catalog (~QAR 350) + typical tour range
  /// - Museum: qatarguides.qa / qatarliving.com (non-resident QAR 25; some venues list up to QAR 50)
  /// - Metro: [DohaTransitFaresConfig.standardSingleJourneyQar] (official policy bundle)
  static final items = <FairPriceGuideItem>[
    FairPriceGuideItem(
      id: 'karwa_day_start',
      category: FairPriceCategory.taxi,
      minQar: 7,
      maxQar: 7,
      matchKeywords: ['karwa', 'taxi', 'meter', 'mowasalat'],
      unitKey: 'fair_price_unit_trip_start',
    ),
    FairPriceGuideItem(
      id: 'karwa_per_km_day',
      category: FairPriceCategory.taxi,
      minQar: 1.6,
      maxQar: 1.6,
      matchKeywords: ['km', 'kilometer', 'distance'],
      unitKey: 'fair_price_unit_per_km',
    ),
    FairPriceGuideItem(
      id: 'karwa_airport_start',
      category: FairPriceCategory.taxi,
      minQar: 25,
      maxQar: 25,
      matchKeywords: ['airport', 'hia', 'hamad'],
      unitKey: 'fair_price_unit_airport_start',
    ),
    FairPriceGuideItem(
      id: 'karwa_airport_city',
      category: FairPriceCategory.taxi,
      minQar: 40,
      maxQar: 55,
      matchKeywords: ['airport', 'city', 'doha'],
    ),
    FairPriceGuideItem(
      id: 'karwa_minimum',
      category: FairPriceCategory.taxi,
      minQar: 7,
      maxQar: 10,
      matchKeywords: ['minimum', 'min fare', 'short'],
    ),
    FairPriceGuideItem(
      id: 'shawarma_wrap',
      category: FairPriceCategory.food,
      minQar: 7,
      maxQar: 15,
      matchKeywords: ['shawarma', 'شاورما', 'wrap'],
    ),
    FairPriceGuideItem(
      id: 'biryani_plate',
      category: FairPriceCategory.food,
      minQar: 12,
      maxQar: 25,
      matchKeywords: ['biryani', 'biryan', 'بiryani', 'rice'],
    ),
    FairPriceGuideItem(
      id: 'water_bottle',
      category: FairPriceCategory.food,
      minQar: 1,
      maxQar: 3,
      matchKeywords: ['water', 'ماء', 'aqua', '500ml', '330ml'],
    ),
    FairPriceGuideItem(
      id: 'karak_tea',
      category: FairPriceCategory.food,
      minQar: 1,
      maxQar: 6,
      matchKeywords: ['karak', 'tea', 'coffee', 'chai', 'كاري'],
    ),
    FairPriceGuideItem(
      id: 'cafeteria_meal',
      category: FairPriceCategory.food,
      minQar: 15,
      maxQar: 30,
      matchKeywords: ['meal', 'thali', 'curry', 'grill', 'mandi'],
    ),
    FairPriceGuideItem(
      id: 'desert_safari_half_day',
      category: FairPriceCategory.tourist,
      minQar: 250,
      maxQar: 450,
      matchKeywords: ['safari', 'desert', 'dune', 'inland sea'],
    ),
    FairPriceGuideItem(
      id: 'museum_adult_visitor',
      category: FairPriceCategory.tourist,
      minQar: 25,
      maxQar: 50,
      matchKeywords: ['museum', 'gallery', 'exhibition', 'qm', 'qatar museums'],
    ),
    FairPriceGuideItem(
      id: 'metro_single_ride',
      category: FairPriceCategory.transport,
      minQar: DohaTransitFaresConfig.standardSingleJourneyQar,
      maxQar: DohaTransitFaresConfig.standardSingleJourneyQar,
      matchKeywords: ['metro', 'qatar rail', 'gold line', 'red line'],
      unitKey: 'fair_price_unit_per_ride',
    ),
  ];

  static FairPriceGuideItem? byId(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  static List<FairPriceGuideItem> forCategory(FairPriceCategory category) =>
      items.where((i) => i.category == category).toList();

  static FairPriceGuideItem? matchLine(String label) {
    final lower = label.toLowerCase();
    FairPriceGuideItem? best;
    var bestScore = 0;
    for (final item in items) {
      for (final kw in item.matchKeywords) {
        if (lower.contains(kw.toLowerCase()) && kw.length > bestScore) {
          best = item;
          bestScore = kw.length;
        }
      }
    }
    return best;
  }
}
