import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/static_search_entry.dart';
import 'package:raabta/models/marketplace_models.dart';

/// Static marketplace categories and fallback listings for global search.
abstract final class MarketplaceSearchIndex {
  static List<StaticSearchEntry> get all {
    final entries = <StaticSearchEntry>[
      for (final cat in marketplaceCategories)
        StaticSearchEntry(
          id: 'marketplace_cat_${cat.id}',
          title: cat.name,
          subtitle: 'Marketplace category',
          keywords: [cat.name, cat.id.replaceAll('_', ' '), 'marketplace', 'buy', 'sell'],
          routePath: '/marketplace/category/${cat.id}',
          category: GlobalSearchCategory.marketplace,
        ),
    ];

    for (final listing in fallbackMarketplaceListings()) {
      entries.add(
        StaticSearchEntry(
          id: 'marketplace_${listing.id}',
          title: listing.title,
          subtitle: '${listing.price} · ${listing.area}',
          keywords: [
            listing.title,
            listing.area,
            listing.condition,
            listing.categoryId,
            'marketplace',
            'classified',
          ],
          routePath: '/marketplace/category/${listing.categoryId}',
          category: GlobalSearchCategory.marketplace,
        ),
      );
    }
    return entries;
  }
}
