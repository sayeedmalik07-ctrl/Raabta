import 'package:raabta/features/post_engine/domain/post_price_suggester.dart';
import 'package:raabta/models/marketplace_models.dart';

/// Minimum live listings required before showing a grounded price range.
const int marketplaceComparableMinSamples = 3;

/// Recency window for comparable marketplace listings.
const Duration marketplaceComparableRecency = Duration(days: 90);

/// Deterministic comparable-price query against Raabta marketplace listings.
class MarketplaceComparablePriceQuery {
  const MarketplaceComparablePriceQuery({PostPriceSuggester? suggester})
      : _suggester = suggester ?? const PostPriceSuggester();

  final PostPriceSuggester _suggester;

  MarketplaceComparablePriceResult query({
    required String categoryLeafId,
    required String? condition,
    required List<MarketplaceListing> allListings,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final cutoff = clock.subtract(marketplaceComparableRecency);
    final normalizedCondition = _normalizeCondition(condition);

    final matchIds = _comparableCategoryIds(categoryLeafId);
    final prices = <int>[];
    for (final listing in allListings) {
      if (!matchIds.contains(listing.categoryId)) continue;
      if (!_matchesCondition(listing.condition, normalizedCondition)) continue;
      final price = _parsePriceQar(listing);
      if (price == null || price <= 0) continue;
      if (!_isRecent(listing, cutoff)) continue;
      prices.add(price);
    }

    if (prices.length < marketplaceComparableMinSamples) {
      return MarketplaceComparablePriceResult.insufficient(
        categoryPath: categoryLeafId,
        sampleSize: prices.length,
      );
    }

    prices.sort();
    final minQar = prices.first;
    final maxQar = prices.last;
    final median = _suggester.suggestPrice(
      categoryPath: categoryLeafId,
      recentPrices: prices,
    );

    return MarketplaceComparablePriceResult.grounded(
      categoryPath: categoryLeafId,
      minQar: minQar,
      maxQar: maxQar,
      medianQar: median?.medianQar ?? prices[prices.length ~/ 2],
      sampleSize: prices.length,
    );
  }

  static int? _parsePriceQar(MarketplaceListing listing) {
    final raw = listing.price.replaceAll(RegExp(r'[^0-9.]'), '');
    if (raw.isEmpty) return null;
    return double.tryParse(raw)?.round();
  }

  static bool _isRecent(MarketplaceListing listing, DateTime cutoff) {
    final posted = listing.posted.toLowerCase();
    if (posted.contains('just now') ||
        posted.contains('min ago') ||
        posted.contains('h ago') ||
        posted.contains('today') ||
        posted.contains('yesterday')) {
      return true;
    }
    if (posted.contains('d ago')) {
      final days = int.tryParse(posted.replaceAll(RegExp(r'[^0-9]'), ''));
      if (days != null) return days <= marketplaceComparableRecency.inDays;
    }
    return true;
  }

  static String? _normalizeCondition(String? raw) {
    final value = raw?.trim().toLowerCase();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  static bool _matchesCondition(String listingCondition, String? target) {
    if (target == null || target.isEmpty) return true;
    return listingCondition.trim().toLowerCase() == target;
  }

  /// Maps post-schema leaf ids to legacy hub category ids when needed.
  static Set<String> _comparableCategoryIds(String categoryLeafId) {
    const aliases = <String, Set<String>>{
      'mobiles': {'mobiles', 'mobiles_tablets', 'tablets'},
      'tablets': {'tablets', 'mobiles_tablets', 'mobiles'},
      'cars': {'cars', 'cars_bikes'},
      'motorcycles_bikes': {'motorcycles_bikes', 'cars_bikes'},
    };
    return aliases[categoryLeafId] ?? {categoryLeafId};
  }
}

class MarketplaceComparablePriceResult {
  const MarketplaceComparablePriceResult._({
    required this.categoryPath,
    required this.sampleSize,
    required this.grounded,
    this.minQar,
    this.maxQar,
    this.medianQar,
  });

  factory MarketplaceComparablePriceResult.grounded({
    required String categoryPath,
    required int minQar,
    required int maxQar,
    required int medianQar,
    required int sampleSize,
  }) {
    return MarketplaceComparablePriceResult._(
      categoryPath: categoryPath,
      sampleSize: sampleSize,
      grounded: true,
      minQar: minQar,
      maxQar: maxQar,
      medianQar: medianQar,
    );
  }

  factory MarketplaceComparablePriceResult.insufficient({
    required String categoryPath,
    required int sampleSize,
  }) {
    return MarketplaceComparablePriceResult._(
      categoryPath: categoryPath,
      sampleSize: sampleSize,
      grounded: false,
    );
  }

  final String categoryPath;
  final int sampleSize;
  final bool grounded;
  final int? minQar;
  final int? maxQar;
  final int? medianQar;

  PostPriceSuggestion? toSuggestion() {
    if (!grounded || medianQar == null) return null;
    return PostPriceSuggestion(
      medianQar: medianQar!,
      sampleSize: sampleSize,
      categoryPath: categoryPath,
      source: PostPriceSuggestionSource.deterministic,
      minQar: minQar,
      maxQar: maxQar,
      grounded: true,
    );
  }
}
