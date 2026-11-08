import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/core/search/search_keyword_tokenizer.dart';
import 'package:raabta/features/global_search/data/search_query_helpers.dart';
import 'package:raabta/features/global_search/domain/global_search_dependencies.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/global_search_provider.dart';
import 'package:raabta/features/global_search/domain/service_search_terminology.dart';
import 'package:raabta/screens/services/models/service_listing.dart';

/// Live Firestore search for user-posted service listings (S3 / S3.1).
class ServiceListingsSearchProvider implements GlobalSearchProvider {
  const ServiceListingsSearchProvider();

  /// Bounded indexed candidate fetch (status + searchKeywords).
  static const indexedFetchLimit = SearchQueryHelpers.fetchLimit;

  /// Bounded legacy fallback fetch (recent active listings).
  static const legacyFetchLimit = SearchQueryHelpers.fetchLimit;

  /// Maximum Firestore reads per global search for this provider.
  static const maxFirestoreReadsPerSearch = 2;

  @override
  String get id => 'service_listings';

  @override
  GlobalSearchCategory get category => GlobalSearchCategory.services;

  @override
  List<String> get coveredRoutePrefixes => const ['/services/listing'];

  @override
  Future<GlobalSearchCategoryGroup> search({
    required String query,
    required GlobalSearchDependencies deps,
    String? userId,
  }) async {
    final db = deps.firestore;
    if (db == null) {
      return const GlobalSearchCategoryGroup(
        category: GlobalSearchCategory.services,
        items: [],
        failed: true,
      );
    }

    final cleanedQuery = ServiceSearchTerminology.cleanServiceQuery(query);
    final token = SearchKeywordTokenizer.primaryQueryToken(cleanedQuery);
    final q = cleanedQuery.toLowerCase();

    try {
      final collection = db.collection('service_listings');
      var firestoreReads = 0;

      final indexedDocs = token != null
          ? await _fetchIndexedCandidates(
              collection: collection,
              token: token,
            )
          : <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      if (token != null) firestoreReads++;

      final indexedMatches = _mapListingMatches(
        docs: indexedDocs,
        cleanedQuery: cleanedQuery,
        q: q,
        token: token,
      );

      final mergedById = <String, GlobalSearchResultItem>{
        for (final item in indexedMatches) item.id: item,
      };

      final needsFallback = indexedMatches.length <
          SearchQueryHelpers.perCategoryDisplayLimit;
      if (needsFallback && firestoreReads < maxFirestoreReadsPerSearch) {
        final legacyDocs = await _fetchLegacyCandidates(collection: collection);
        firestoreReads++;

        final legacyMatches = _mapListingMatches(
          docs: legacyDocs,
          cleanedQuery: cleanedQuery,
          q: q,
          token: token,
        );

        for (final item in legacyMatches) {
          mergedById.putIfAbsent(item.id, () => item);
        }
      }

      return SearchQueryHelpers.buildGroup(
        category: GlobalSearchCategory.services,
        allMatches: mergedById.values.toList(),
      );
    } catch (_) {
      return const GlobalSearchCategoryGroup(
        category: GlobalSearchCategory.services,
        items: [],
        failed: true,
      );
    }
  }

  static Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      _fetchIndexedCandidates({
    required CollectionReference<Map<String, dynamic>> collection,
    required String token,
  }) async {
    try {
      final snap = await collection
          .where('status', isEqualTo: 'active')
          .where('searchKeywords', arrayContains: token)
          .limit(indexedFetchLimit)
          .get();
      return snap.docs;
    } catch (_) {
      // Missing index or field — caller may use legacy fallback.
      return const [];
    }
  }

  static Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      _fetchLegacyCandidates({
    required CollectionReference<Map<String, dynamic>> collection,
  }) async {
    final snap = await collection
        .where('status', isEqualTo: 'active')
        .limit(legacyFetchLimit)
        .get();
    return snap.docs;
  }

  static List<GlobalSearchResultItem> _mapListingMatches({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    required String cleanedQuery,
    required String q,
    required String? token,
  }) {
    final matches = <GlobalSearchResultItem>[];
    for (final doc in docs) {
      final listing = ServiceListing.fromFirestore(doc);
      if (listing.status != 'active') continue;

      final item = _toResultItem(
        listing: listing,
        cleanedQuery: cleanedQuery,
        q: q,
        token: token,
      );
      if (item != null) matches.add(item);
    }
    return matches;
  }

  static GlobalSearchResultItem? _toResultItem({
    required ServiceListing listing,
    required String cleanedQuery,
    required String q,
    required String? token,
  }) {
    final title = listing.displayTitle;
    final subtitleParts = <String>[
      if (listing.providerName.isNotEmpty) listing.providerName,
      if (listing.area.isNotEmpty) listing.area,
      if (listing.serviceCategory.isNotEmpty) listing.serviceCategory,
    ];
    final subtitle = subtitleParts.join(' · ');
    final haystack = [
      title,
      listing.description,
      listing.serviceName,
      listing.serviceCategory,
      listing.providerName,
      listing.area,
    ].join(' ').toLowerCase();

    if (!SearchQueryHelpers.matchesQuery(q, haystack, token)) return null;

    return GlobalSearchResultItem(
      id: 'service_listing_${listing.id}',
      category: GlobalSearchCategory.services,
      title: title,
      subtitle: subtitle,
      routePath: '/services/listing/${listing.id}',
      score: SearchKeywordTokenizer.score(
        query: cleanedQuery,
        title: title,
        subtitle: subtitle,
      ),
      listingLatitude: listing.latitude,
      listingLongitude: listing.longitude,
    );
  }
}
