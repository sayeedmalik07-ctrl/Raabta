import 'package:raabta/core/search/search_keyword_tokenizer.dart';
import 'package:raabta/data/search/business_search_index.dart';
import 'package:raabta/features/community/data/community_group_registry.dart';
import 'package:raabta/features/exchange_locator/domain/models/branch_filters.dart';
import 'package:raabta/features/global_search/data/service_listings_search_provider.dart';
import 'package:raabta/features/global_search/data/search_query_helpers.dart';
import 'package:raabta/features/daily_utilities/arabic_phrases/arabic_phrases_search_index.dart';
import 'package:raabta/features/global_search/data/tools_search_index.dart';
import 'package:raabta/features/global_search/domain/global_search_dependencies.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/config/monetization_state.dart';
import 'package:raabta/features/global_search/domain/global_search_provider.dart';
import 'package:raabta/features/global_search/domain/static_search_entry.dart';
import 'package:raabta/features/money_comparator/data/money_search_index.dart';
import 'package:raabta/features/trip_planner/data/qatar_places_catalog.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_plan.dart';
import 'package:raabta/features/visa/data/visa_search_index.dart';
import 'package:raabta/providers/business_providers.dart';
import 'package:raabta/providers/jobs_providers.dart';
import 'package:raabta/screens/marketplace/data/marketplace_search_index.dart';
import 'package:raabta/screens/services/data/services_search_index.dart';

/// Reusable provider that searches a co-located static catalog.
class StaticCatalogSearchProvider implements GlobalSearchProvider {
  const StaticCatalogSearchProvider({
    required this.providerId,
    required this.searchCategory,
    required this.catalog,
    required this.routePrefixes,
  });

  final String providerId;
  final GlobalSearchCategory searchCategory;
  final List<StaticSearchEntry> catalog;
  final List<String> routePrefixes;

  @override
  String get id => providerId;

  @override
  GlobalSearchCategory get category => searchCategory;

  @override
  List<String> get coveredRoutePrefixes => routePrefixes;

  @override
  Future<GlobalSearchCategoryGroup> search({
    required String query,
    required GlobalSearchDependencies deps,
    String? userId,
  }) async {
    final matches = searchStaticCatalog(query, catalog, locale: deps.locale)
        .map(
          (e) => GlobalSearchResultItem(
            id: e.id,
            category: e.category,
            title: e.localizedTitle(deps.locale),
            subtitle: e.localizedSubtitle(deps.locale),
            routePath: e.routePath,
            score: e.scoreFor(query, locale: deps.locale),
          ),
        )
        .toList();
    return SearchQueryHelpers.buildGroup(
      category: searchCategory,
      allMatches: matches,
    );
  }
}

// ─── Legacy providers (migrated from GlobalSearchRepository) ───────────────

class JobsSearchProvider implements GlobalSearchProvider {
  const JobsSearchProvider();

  @override
  String get id => 'jobs';

  @override
  GlobalSearchCategory get category => GlobalSearchCategory.jobs;

  @override
  List<String> get coveredRoutePrefixes => const ['/jobs'];

  @override
  Future<GlobalSearchCategoryGroup> search({
    required String query,
    required GlobalSearchDependencies deps,
    String? userId,
  }) async {
    final q = query.toLowerCase();
    final matches = filterJobs(source: deps.jobsCatalog, query: q)
        .map(
          (j) => GlobalSearchResultItem(
            id: j.id,
            category: GlobalSearchCategory.jobs,
            title: j.title,
            subtitle: '${j.company} · ${j.location}',
            routePath: '/jobs',
            score: SearchKeywordTokenizer.score(
              query: query,
              title: j.title,
              subtitle: '${j.company} ${j.location}',
            ),
          ),
        )
        .toList();
    return SearchQueryHelpers.buildGroup(
      category: GlobalSearchCategory.jobs,
      allMatches: matches,
    );
  }
}

class HousingSearchProvider implements GlobalSearchProvider {
  const HousingSearchProvider();

  @override
  String get id => 'housing';

  @override
  GlobalSearchCategory get category => GlobalSearchCategory.housing;

  @override
  List<String> get coveredRoutePrefixes => const ['/housing'];

  @override
  Future<GlobalSearchCategoryGroup> search({
    required String query,
    required GlobalSearchDependencies deps,
    String? userId,
  }) async {
    final db = deps.firestore;
    if (db == null) {
      return const GlobalSearchCategoryGroup(
        category: GlobalSearchCategory.housing,
        items: [],
        failed: true,
      );
    }

    final token = SearchKeywordTokenizer.primaryQueryToken(query);
    try {
      final docs = await SearchQueryHelpers.fetchWithKeywordFallback(
        db.collection('listings'),
        token: token,
        equalityFilters: {'status': 'approved'},
      );
      final q = query.toLowerCase();
      final matches = <GlobalSearchResultItem>[];
      for (final doc in docs) {
        final data = doc.data();
        final title = data['title'] as String? ?? '';
        final area = data['area'] as String? ?? '';
        final type = data['type'] as String? ?? '';
        final haystack = '$title $area $type'.toLowerCase();
        if (!SearchQueryHelpers.matchesQuery(q, haystack, token)) continue;
        matches.add(
          GlobalSearchResultItem(
            id: doc.id,
            category: GlobalSearchCategory.housing,
            title: title,
            subtitle: '$area · $type',
            routePath: '/housing/listing/${doc.id}',
            score: SearchKeywordTokenizer.score(
              query: query,
              title: title,
              subtitle: '$area $type',
            ),
          ),
        );
      }
      return SearchQueryHelpers.buildGroup(
        category: GlobalSearchCategory.housing,
        allMatches: matches,
      );
    } catch (_) {
      return const GlobalSearchCategoryGroup(
        category: GlobalSearchCategory.housing,
        items: [],
        failed: true,
      );
    }
  }
}

class CommunitySearchProvider implements GlobalSearchProvider {
  const CommunitySearchProvider();

  @override
  String get id => 'community';

  @override
  GlobalSearchCategory get category => GlobalSearchCategory.community;

  @override
  List<String> get coveredRoutePrefixes => const ['/community'];

  @override
  Future<GlobalSearchCategoryGroup> search({
    required String query,
    required GlobalSearchDependencies deps,
    String? userId,
  }) async {
    final db = deps.firestore;
    final q = query.toLowerCase();
    final token = SearchKeywordTokenizer.primaryQueryToken(query);
    final matches = <GlobalSearchResultItem>[];

    for (final group in CommunityGroupRegistry.all) {
      final haystack = '${group.name} ${group.emoji}'.toLowerCase();
      if (!haystack.contains(q)) continue;
      matches.add(
        GlobalSearchResultItem(
          id: group.id,
          category: GlobalSearchCategory.community,
          title: group.name,
          subtitle: 'Group · ${group.members} members',
          routePath: '/community',
          score: SearchKeywordTokenizer.score(query: query, title: group.name),
        ),
      );
    }

    if (db != null) {
      for (final spec in _communityCollections) {
        try {
          final docs = await SearchQueryHelpers.fetchWithKeywordFallback(
            db.collection(spec.collection),
            token: token,
            equalityFilters: spec.filters,
          );
          for (final doc in docs) {
            final data = doc.data();
            final title = data[spec.titleField] as String? ?? '';
            final extra = spec.subtitleBuilder(data);
            final haystack = '$title $extra'.toLowerCase();
            if (!SearchQueryHelpers.matchesQuery(q, haystack, token)) continue;
            matches.add(
              GlobalSearchResultItem(
                id: doc.id,
                category: GlobalSearchCategory.community,
                title: title,
                subtitle: extra,
                routePath: spec.route,
                score: SearchKeywordTokenizer.score(
                  query: query,
                  title: title,
                  subtitle: extra,
                ),
              ),
            );
          }
        } catch (_) {}
      }
    }

    return SearchQueryHelpers.buildGroup(
      category: GlobalSearchCategory.community,
      allMatches: matches,
    );
  }
}

class _CommunityCollectionSpec {
  const _CommunityCollectionSpec({
    required this.collection,
    required this.titleField,
    required this.subtitleBuilder,
    required this.route,
    this.filters = const {},
  });

  final String collection;
  final String titleField;
  final String Function(Map<String, dynamic> data) subtitleBuilder;
  final String route;
  final Map<String, Object?> filters;
}

String _askQatarSubtitle(Map<String, dynamic> _) => 'Ask Qatar';

String _communityEventSubtitle(Map<String, dynamic> d) =>
    'Event · ${d['location'] ?? ''}';

String _lostFoundSubtitle(Map<String, dynamic> d) =>
    'Lost & Found · ${d['itemDescription'] ?? ''}';

String _groupPostSubtitle(Map<String, dynamic> _) => 'Group post';

final _communityCollections = [
  _CommunityCollectionSpec(
    collection: 'ask_qatar_questions',
    titleField: 'title',
    subtitleBuilder: _askQatarSubtitle,
    route: '/community',
  ),
  _CommunityCollectionSpec(
    collection: 'community_events',
    titleField: 'title',
    subtitleBuilder: _communityEventSubtitle,
    route: '/community/events',
    filters: {'status': 'approved'},
  ),
  _CommunityCollectionSpec(
    collection: 'lost_and_found',
    titleField: 'title',
    subtitleBuilder: _lostFoundSubtitle,
    route: '/community',
    filters: {'status': 'open'},
  ),
  _CommunityCollectionSpec(
    collection: 'community_group_posts',
    titleField: 'text',
    subtitleBuilder: _groupPostSubtitle,
    route: '/community',
  ),
];

class DocumentsSearchProvider implements GlobalSearchProvider {
  const DocumentsSearchProvider();

  @override
  String get id => 'documents';

  @override
  GlobalSearchCategory get category => GlobalSearchCategory.documents;

  @override
  List<String> get coveredRoutePrefixes =>
      const ['/document-vault', '/scanner'];

  @override
  Future<GlobalSearchCategoryGroup> search({
    required String query,
    required GlobalSearchDependencies deps,
    String? userId,
  }) async {
    if (userId == null || userId.isEmpty || deps.firestore == null) {
      return const GlobalSearchCategoryGroup(
        category: GlobalSearchCategory.documents,
        items: [],
      );
    }

    final q = query.toLowerCase();
    try {
      final snap = await deps.firestore!
          .collection('scanned_documents')
          .where('userId', isEqualTo: userId)
          .limit(SearchQueryHelpers.fetchLimit)
          .get();

      final matches = <GlobalSearchResultItem>[];
      for (final doc in snap.docs) {
        final d = doc.data();
        final name =
            (d['displayName'] as String? ?? d['holderName'] as String? ?? '')
                .trim();
        final ocr = d['ocrText'] as String? ?? '';
        final category = d['category'] as String? ?? '';
        final tags =
            ((d['tags'] as List?) ?? const []).map((e) => e.toString()).join(' ');
        final haystack = '$name $ocr $category $tags'.toLowerCase();
        if (!haystack.contains(q)) continue;

        matches.add(
          GlobalSearchResultItem(
            id: doc.id,
            category: GlobalSearchCategory.documents,
            title: name.isEmpty ? 'Document' : name,
            subtitle: category.isEmpty ? 'Document Vault' : category,
            routePath: '/document-vault/${doc.id}',
            score: SearchKeywordTokenizer.score(
              query: query,
              title: name,
              subtitle: '$category $tags',
            ),
          ),
        );
      }
      return SearchQueryHelpers.buildGroup(
        category: GlobalSearchCategory.documents,
        allMatches: matches,
      );
    } catch (_) {
      return const GlobalSearchCategoryGroup(
        category: GlobalSearchCategory.documents,
        items: [],
        failed: true,
      );
    }
  }
}

class ExchangeSearchProvider implements GlobalSearchProvider {
  const ExchangeSearchProvider();

  @override
  String get id => 'exchange';

  @override
  GlobalSearchCategory get category => GlobalSearchCategory.exchange;

  @override
  List<String> get coveredRoutePrefixes =>
      const ['/exchange-locator', '/money'];

  @override
  Future<GlobalSearchCategoryGroup> search({
    required String query,
    required GlobalSearchDependencies deps,
    String? userId,
  }) async {
    final repo = deps.exchangeRepository;
    if (repo == null) {
      return const GlobalSearchCategoryGroup(
        category: GlobalSearchCategory.exchange,
        items: [],
      );
    }

    try {
      final page = await repo.fetchBranches(
        filters: BranchFinderFilters(searchQuery: query),
        limit: SearchQueryHelpers.fetchLimit,
      );
      final matches = page.items
          .map(
            (b) => GlobalSearchResultItem(
              id: b.id,
              category: GlobalSearchCategory.exchange,
              title: b.branchName,
              subtitle: b.companyName ?? b.area,
              routePath: '/exchange-locator/branch/${b.id}',
              score: SearchKeywordTokenizer.score(
                query: query,
                title: b.branchName,
                subtitle: '${b.companyName} ${b.area}',
              ),
            ),
          )
          .toList();
      return SearchQueryHelpers.buildGroup(
        category: GlobalSearchCategory.exchange,
        allMatches: matches,
      );
    } catch (_) {
      return const GlobalSearchCategoryGroup(
        category: GlobalSearchCategory.exchange,
        items: [],
        failed: true,
      );
    }
  }
}

class MosquesSearchProvider implements GlobalSearchProvider {
  const MosquesSearchProvider();

  @override
  String get id => 'mosques';

  @override
  GlobalSearchCategory get category => GlobalSearchCategory.mosques;

  @override
  List<String> get coveredRoutePrefixes => const ['/prayer-mosque'];

  @override
  Future<GlobalSearchCategoryGroup> search({
    required String query,
    required GlobalSearchDependencies deps,
    String? userId,
  }) async {
    const dohaLat = 25.2854;
    const dohaLng = 51.5310;
    final places = deps.mosqueDataSource.nearby(
      latitude: dohaLat,
      longitude: dohaLng,
      query: query,
      radiusKm: 120,
    );
    final matches = places
        .map(
          (m) => GlobalSearchResultItem(
            id: m.id,
            category: GlobalSearchCategory.mosques,
            title: m.name,
            subtitle: m.address,
            routePath: '/prayer-mosque/mosque/${m.id}',
            score: SearchKeywordTokenizer.score(
              query: query,
              title: m.name,
              subtitle: m.address,
            ),
          ),
        )
        .toList();
    return SearchQueryHelpers.buildGroup(
      category: GlobalSearchCategory.mosques,
      allMatches: matches,
    );
  }
}

class TripPlannerSearchProvider implements GlobalSearchProvider {
  const TripPlannerSearchProvider();

  @override
  String get id => 'trip_planner';

  @override
  GlobalSearchCategory get category => GlobalSearchCategory.tripPlanner;

  @override
  List<String> get coveredRoutePrefixes => const ['/trip-planner'];

  @override
  Future<GlobalSearchCategoryGroup> search({
    required String query,
    required GlobalSearchDependencies deps,
    String? userId,
  }) async {
    final q = query.toLowerCase();
    final matches = <GlobalSearchResultItem>[];

    for (final place in QatarPlacesCatalog.search(query)) {
      matches.add(
        GlobalSearchResultItem(
          id: place.id,
          category: GlobalSearchCategory.tripPlanner,
          title: place.title,
          subtitle: place.address ?? 'Attraction',
          routePath: '/trip-planner/place/${place.id}',
          score: SearchKeywordTokenizer.score(
            query: query,
            title: place.title,
            subtitle: place.description,
          ),
        ),
      );
    }

    final tripRepo = deps.tripPlannerRepository;
    if (tripRepo != null) {
      try {
        final trips = await tripRepo.loadTrips();
        for (final trip in trips) {
          if (!_tripMatches(q, trip)) continue;
          matches.add(
            GlobalSearchResultItem(
              id: trip.id,
              category: GlobalSearchCategory.tripPlanner,
              title: trip.title,
              subtitle: 'Saved trip · ${trip.days.length} days',
              routePath: '/trip-planner/itinerary/${trip.id}',
              score: SearchKeywordTokenizer.score(query: query, title: trip.title),
            ),
          );
        }
      } catch (_) {}
    }

    return SearchQueryHelpers.buildGroup(
      category: GlobalSearchCategory.tripPlanner,
      allMatches: matches,
    );
  }

  bool _tripMatches(String q, TripPlan trip) {
    if (trip.title.toLowerCase().contains(q)) return true;
    for (final day in trip.days) {
      if (day.title.toLowerCase().contains(q)) return true;
      for (final activity in day.activities) {
        final haystack = '${activity.title} ${activity.description}'.toLowerCase();
        if (haystack.contains(q)) return true;
      }
    }
    return false;
  }
}

// ─── New providers (previously missing from global search) ───────────────────

class BusinessesSearchProvider implements GlobalSearchProvider {
  const BusinessesSearchProvider();

  @override
  String get id => 'businesses';

  @override
  GlobalSearchCategory get category => GlobalSearchCategory.businesses;

  @override
  List<String> get coveredRoutePrefixes {
    if (MonetizationState.showPremiumTierUi) {
      return const ['/businesses', '/business-advertise'];
    }
    return const ['/businesses'];
  }

  @override
  Future<GlobalSearchCategoryGroup> search({
    required String query,
    required GlobalSearchDependencies deps,
    String? userId,
  }) async {
    final q = query.toLowerCase();
    final matches = <GlobalSearchResultItem>[];

    // Static category entries
    for (final entry in BusinessSearchIndex.categoryEntries) {
      if (!entry.matches(query, locale: deps.locale)) continue;
      matches.add(
        GlobalSearchResultItem(
          id: entry.id,
          category: GlobalSearchCategory.businesses,
          title: entry.localizedTitle(deps.locale),
          subtitle: entry.localizedSubtitle(deps.locale),
          routePath: entry.routePath,
          score: entry.scoreFor(query, locale: deps.locale),
        ),
      );
    }

    // Dynamic catalog — same stream as Businesses screen (Firestore; mock debug opt-in).
    for (final b in filterBusinesses(source: deps.businessesCatalog, query: q)) {
      matches.add(
        GlobalSearchResultItem(
          id: b.id,
          category: GlobalSearchCategory.businesses,
          title: b.name,
          subtitle: '${b.category} · ${b.location}',
          routePath: '/businesses',
          score: SearchKeywordTokenizer.score(
            query: query,
            title: b.name,
            subtitle: '${b.category} ${b.location}',
          ),
        ),
      );
    }

    return SearchQueryHelpers.buildGroup(
      category: GlobalSearchCategory.businesses,
      allMatches: matches,
    );
  }
}

class HealthInsuranceSearchProvider implements GlobalSearchProvider {
  const HealthInsuranceSearchProvider();

  static const _entries = [
    StaticSearchEntry(
      id: 'health_insurance_engine',
      titleKey: 'search_health_insurance_title',
      subtitleKey: 'search_health_insurance_subtitle',
      routePath: '/health-insurance',
      category: GlobalSearchCategory.health,
      keywords: ['health', 'insurance', 'moph', 'employer', 'compliance', 'law 22'],
    ),
    StaticSearchEntry(
      id: 'health_insurance_navigation',
      titleKey: 'search_health_navigation_title',
      subtitleKey: 'search_health_navigation_subtitle',
      routePath: '/health-insurance',
      category: GlobalSearchCategory.health,
      keywords: ['hospital', 'hmc', 'hamad', 'emergency', '999', 'health card', 'doctor', 'clinic'],
    ),
  ];

  @override
  String get id => 'health_insurance';

  @override
  GlobalSearchCategory get category => GlobalSearchCategory.health;

  @override
  List<String> get coveredRoutePrefixes => const ['/health-insurance'];

  @override
  Future<GlobalSearchCategoryGroup> search({
    required String query,
    required GlobalSearchDependencies deps,
    String? userId,
  }) async {
    final matches = <GlobalSearchResultItem>[];

    for (final entry in _entries) {
      if (!entry.matches(query, locale: deps.locale)) continue;
      matches.add(
        GlobalSearchResultItem(
          id: entry.id,
          category: GlobalSearchCategory.health,
          title: entry.localizedTitle(deps.locale),
          subtitle: entry.localizedSubtitle(deps.locale),
          routePath: entry.routePath,
          score: entry.scoreFor(query, locale: deps.locale),
        ),
      );
    }

    return SearchQueryHelpers.buildGroup(
      category: GlobalSearchCategory.health,
      allMatches: matches,
    );
  }
}

/// Registers every search provider. Called once at app/search bootstrap.
void registerAllSearchProviders() {
  if (GlobalSearchProviderRegistry.isBootstrapped) return;

  final providers = <GlobalSearchProvider>[
    JobsSearchProvider(),
    HousingSearchProvider(),
    CommunitySearchProvider(),
    DocumentsSearchProvider(),
    ExchangeSearchProvider(),
    MosquesSearchProvider(),
    TripPlannerSearchProvider(),
    BusinessesSearchProvider(),
    StaticCatalogSearchProvider(
      providerId: 'marketplace',
      searchCategory: GlobalSearchCategory.marketplace,
      catalog: MarketplaceSearchIndex.all,
      routePrefixes: ['/marketplace'],
    ),
    StaticCatalogSearchProvider(
      providerId: 'visa',
      searchCategory: GlobalSearchCategory.visa,
      catalog: VisaSearchIndex.all,
      routePrefixes: ['/visa'],
    ),
    HealthInsuranceSearchProvider(),
    StaticCatalogSearchProvider(
      providerId: 'money',
      searchCategory: GlobalSearchCategory.money,
      catalog: MoneySearchIndex.all,
      routePrefixes: ['/money', '/money-services', '/exchange-locator'],
    ),
    StaticCatalogSearchProvider(
      providerId: 'tools',
      searchCategory: GlobalSearchCategory.tools,
      catalog: ToolsSearchIndex.all,
      routePrefixes: [
        '/scanner',
        '/bill-splitter',
        '/eosb',
        '/ramadan',
        '/driving',
        '/premium',
        '/arabic-companion',
        '/tenancy',
        '/sponsorship-transfer',
      ],
    ),
    StaticCatalogSearchProvider(
      providerId: 'arabic_companion',
      searchCategory: GlobalSearchCategory.tools,
      catalog: ArabicPhrasesSearchIndex.all,
      routePrefixes: ['/arabic-companion'],
    ),
    StaticCatalogSearchProvider(
      providerId: 'services',
      searchCategory: GlobalSearchCategory.services,
      catalog: ServicesSearchIndex.all,
      routePrefixes: ['/services'],
    ),
    const ServiceListingsSearchProvider(),
  ];

  for (final p in providers) {
    GlobalSearchProviderRegistry.register(p);
  }
  GlobalSearchProviderRegistry.markBootstrapped();
}
