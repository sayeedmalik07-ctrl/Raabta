import 'package:raabta/data/categories/business_categories.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/static_search_entry.dart';

/// Business directory category filters as searchable destinations.
abstract final class BusinessSearchIndex {
  static List<StaticSearchEntry> get categoryEntries => [
        for (final cat in kBusinessCategories)
          if (cat.filter != null)
            StaticSearchEntry(
              id: 'business_cat_${cat.filter}',
              title: cat.label,
              subtitle: 'Business directory',
              keywords: [
                cat.label,
                cat.filter!,
                'business',
                'directory',
                'shop',
                'store',
              ],
              routePath: '/businesses?tag=${cat.filter}',
              category: GlobalSearchCategory.businesses,
            ),
        const StaticSearchEntry(
          id: 'businesses_all',
          title: 'Business Directory',
          subtitle: 'Browse local businesses in Qatar',
          keywords: ['business', 'directory', 'shop', 'restaurant', 'salon'],
          routePath: '/businesses',
          category: GlobalSearchCategory.businesses,
        ),
      ];
}
