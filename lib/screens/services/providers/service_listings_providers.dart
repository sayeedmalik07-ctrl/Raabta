import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/screens/services/data/service_listings_repository.dart';
import 'package:raabta/screens/services/models/service_listing.dart';

final serviceListingsRepositoryProvider =
    Provider<ServiceListingsRepository>((ref) {
  return ServiceListingsRepository();
});

/// Customer browse (providers) vs. provider find-work browse (requests).
final servicesBrowseListingTypeProvider =
    StateProvider<ServiceListingType>((ref) => ServiceListingType.provider);

final recentServiceListingsProvider =
    StreamProvider.autoDispose<List<ServiceListing>>((ref) {
  final listingType = ref.watch(servicesBrowseListingTypeProvider);
  return ref
      .watch(serviceListingsRepositoryProvider)
      .watchRecentListings(listingType: listingType);
});

final categoryServiceListingsProvider = StreamProvider.autoDispose
    .family<List<ServiceListing>, ServiceListingFilter>((ref, filter) {
  return ref.watch(serviceListingsRepositoryProvider).watchCategoryListings(
        categoryId: filter.categoryId,
        serviceName: filter.serviceName,
        listingType: filter.listingType,
      );
});

final userServiceListingsProvider =
    StreamProvider.autoDispose.family<List<ServiceListing>, String>((ref, uid) {
  if (uid.isEmpty) return Stream.value(const []);
  return ref.watch(serviceListingsRepositoryProvider).watchUserListings(uid);
});

final serviceListingDetailProvider =
    FutureProvider.autoDispose.family<ServiceListing?, String>((ref, id) {
  if (id.isEmpty) return Future.value(null);
  return ref.watch(serviceListingsRepositoryProvider).fetchListing(id);
});
