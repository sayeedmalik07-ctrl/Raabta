import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/data/mock/businesses_mock_data.dart';
import 'package:raabta/data/models/business_listing.dart';
import 'package:raabta/data/repositories/businesses_repository.dart';
import 'package:raabta/features/business/domain/business_category_catalog.dart';
import 'package:raabta/providers/auth_providers.dart';

final businessesRepositoryProvider = Provider<BusinessesRepository>((ref) {
  return BusinessesRepository();
});

/// Dev-only mock seed — never enabled in release builds.
///
/// Run with: `--dart-define=RAABTA_INCLUDE_MOCK_BUSINESSES=true`
@visibleForTesting
bool get includeMockBusinessCatalog =>
    kDebugMode &&
    const bool.fromEnvironment(
      'RAABTA_INCLUDE_MOCK_BUSINESSES',
      defaultValue: false,
    );

List<BusinessListing> sortBusinessCatalog(List<BusinessListing> businesses) {
  final sorted = List<BusinessListing>.from(businesses);
  sorted.sort((a, b) {
    final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return bTime.compareTo(aTime);
  });
  return sorted;
}

/// Production browse reads Firestore only. Mock seed merges only when
/// [includeMockBusinessCatalog] is explicitly enabled in debug.
List<BusinessListing> mergeBusinessCatalog(List<BusinessListing> firestore) {
  if (!includeMockBusinessCatalog) {
    return sortBusinessCatalog(firestore);
  }

  final byId = <String, BusinessListing>{
    for (final business in kMockBusinesses) business.id: business,
  };
  for (final business in firestore) {
    byId[business.id] = business;
  }
  return sortBusinessCatalog(byId.values.toList());
}

final businessCatalogProvider = StreamProvider<List<BusinessListing>>((ref) {
  return ref
      .watch(businessesRepositoryProvider)
      .watchActiveBusinesses()
      .map(mergeBusinessCatalog);
});

/// Businesses owned by the signed-in user (for job posting linkage — not directory browse).
final userOwnedBusinessesProvider =
    StreamProvider.autoDispose<List<BusinessListing>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null || uid.isEmpty) {
    return Stream.value(const []);
  }
  return ref.watch(businessesRepositoryProvider).watchUserBusinesses(uid).map(
        (rows) => rows
            .map(
              (row) => BusinessListing.fromFirestoreMap(
                Map<String, dynamic>.from(row),
                row['id'] as String,
              ),
            )
            .toList(),
      );
});

List<BusinessListing> filterBusinesses({
  required List<BusinessListing> source,
  required String query,
  String? categoryFilter,
}) {
  var list = source;
  if (query.isNotEmpty) {
    list = list.where((b) => b.searchableText.contains(query)).toList();
  }
  if (categoryFilter == 'ramadan_iftar') {
    list = list.where((b) => b.hasIftarTag).toList();
  } else if (categoryFilter != null) {
    list = list
        .where(
          (b) => BusinessCategoryCatalog.matchesFilter(
            storedCategory: b.category,
            storedCategoryId: b.categoryId,
            filterLeafId: categoryFilter,
          ),
        )
        .toList();
  }
  return list;
}
