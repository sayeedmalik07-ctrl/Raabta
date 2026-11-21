import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/models/marketplace_models.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:raabta/services/marketplace_firestore_service.dart';

final marketplaceFirestoreServiceProvider =
    Provider<MarketplaceFirestoreService>((ref) {
  return MarketplaceFirestoreService();
});

final marketplaceListingsProvider =
    FutureProvider.autoDispose<List<MarketplaceListing>>((ref) async {
  if (!FirebaseService.isReady) {
    return fallbackMarketplaceListings();
  }

  try {
    final firestore = ref.watch(marketplaceFirestoreServiceProvider);
    return await firestore.fetchAll();
  } on MarketplaceFirestoreException {
    return fallbackMarketplaceListings();
  } catch (_) {
    return fallbackMarketplaceListings();
  }
});

final marketplaceCategoryListingsProvider = FutureProvider.autoDispose
    .family<List<MarketplaceListing>, String>((ref, categoryId) async {
  final all = await ref.watch(marketplaceListingsProvider.future);
  return all.where((l) => l.categoryId == categoryId).toList();
});

final marketplaceCategoryCountsProvider =
    Provider.autoDispose<Map<String, int>>((ref) {
  final listingsAsync = ref.watch(marketplaceListingsProvider);
  return listingsAsync.maybeWhen(
    data: (listings) => {
      for (final category in marketplaceCategories)
        category.id: marketplaceCountForCategory(listings, category.id),
    },
    orElse: () => {},
  );
});

final marketplaceListingDetailProvider =
    FutureProvider.autoDispose.family<MarketplaceListing?, String>(
        (ref, id) async {
  try {
    if (FirebaseService.isReady) {
      final firestore = ref.watch(marketplaceFirestoreServiceProvider);
      final listing = await firestore.getListing(id);
      if (listing != null) return listing;
    }
  } on MarketplaceFirestoreException {
    // Fall through to cached catalog.
  } catch (_) {
    // Fall through to cached catalog.
  }

  try {
    final listings = await ref.watch(marketplaceListingsProvider.future);
    return listings.firstWhere((listing) => listing.id == id);
  } catch (_) {
    try {
      return fallbackMarketplaceListings().firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }
});
