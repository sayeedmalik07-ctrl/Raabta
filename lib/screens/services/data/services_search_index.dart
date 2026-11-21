import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/static_search_entry.dart';

/// Services classifieds — static category discoverability.
abstract final class ServicesSearchIndex {
  static List<StaticSearchEntry> get all => [
        const StaticSearchEntry(
          id: 'services_home',
          title: 'Services Classifieds',
          subtitle: 'Find or post a service',
          keywords: ['services', 'classified', 'handyman', 'repair', 'cleaning'],
          routePath: '/services',
          category: GlobalSearchCategory.services,
        ),
        const StaticSearchEntry(
          id: 'services_post',
          title: 'Post a Service Listing',
          subtitle: 'Services · offer your skill',
          keywords: ['post', 'service', 'listing', 'offer', 'advertise'],
          routePath: '/services/post',
          category: GlobalSearchCategory.services,
        ),
        const StaticSearchEntry(
          id: 'services_my_listings',
          title: 'My Service Listings',
          subtitle: 'Services · manage your posts',
          keywords: ['my listings', 'services', 'manage'],
          routePath: '/services/my-listings',
          category: GlobalSearchCategory.services,
        ),
      ];
}
