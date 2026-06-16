import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/models/housing_models.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:raabta/services/housing_firestore_service.dart';
import 'package:raabta/services/listings_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final listingsApiServiceProvider = Provider<ListingsApiService>((ref) {
  return ListingsApiService();
});

final housingFiltersProvider =
    StateProvider<HousingFilters>((ref) => const HousingFilters());

final housingListingsProvider =
    FutureProvider.autoDispose<List<HousingListing>>((ref) async {
  final filters = ref.watch(housingFiltersProvider);
  final api = ref.watch(listingsApiServiceProvider);

  try {
    if (FirebaseService.isReady) {
      final firestore = HousingFirestoreService();
      return await firestore.fetchListings(filters);
    }
    return await api.fetchListings(filters);
  } on ListingsApiException {
    return _filterFallbackListings(filters);
  } catch (_) {
    try {
      return await api.fetchListings(filters);
    } catch (_) {
      return _filterFallbackListings(filters);
    }
  }
});

final housingListingDetailProvider =
    FutureProvider.autoDispose.family<HousingListing?, String>((ref, id) async {
  final api = ref.watch(listingsApiServiceProvider);

  try {
    if (FirebaseService.isReady) {
      final firestore = HousingFirestoreService();
      final listing = await firestore.getListing(id);
      if (listing != null) return listing;
    }
    return await api.getListing(id);
  } catch (_) {
    try {
      return await api.getListing(id);
    } catch (_) {
      try {
        return fallbackHousingListings().firstWhere((l) => l.id == id);
      } catch (_) {
        return null;
      }
    }
  }
});

final savedListingIdsProvider =
    StateNotifierProvider<SavedListingsNotifier, Set<String>>((ref) {
  return SavedListingsNotifier();
});

class SavedListingsNotifier extends StateNotifier<Set<String>> {
  SavedListingsNotifier() : super({}) {
    _load();
  }

  static const _key = 'saved_housing_listings';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_key) ?? [];
      state = saved.toSet();
    } catch (_) {}
  }

  Future<void> toggle(String listingId) async {
    final updated = Set<String>.from(state);
    if (updated.contains(listingId)) {
      updated.remove(listingId);
    } else {
      updated.add(listingId);
    }
    state = updated;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, updated.toList());
    } catch (_) {}
  }

  bool isSaved(String listingId) => state.contains(listingId);
}

List<HousingListing> _filterFallbackListings(HousingFilters filters) {
  var listings = fallbackHousingListings()
      .where((l) => l.status == ListingStatus.approved)
      .toList();

  if (filters.area != null && filters.area!.isNotEmpty) {
    listings = listings
        .where((l) => l.area.toLowerCase() == filters.area!.toLowerCase())
        .toList();
  }

  if (filters.type != ListingType.all) {
    listings = listings.where((l) => l.type == filters.type).toList();
  }

  listings = listings
      .where(
        (l) =>
            l.pricePerMonth >= filters.minPrice.round() &&
            l.pricePerMonth <= filters.maxPrice.round(),
      )
      .toList();

  if (filters.gender != GenderPreference.any) {
    listings =
        listings.where((l) => l.genderPreference == filters.gender).toList();
  }

  if (filters.nationality != NationalityPreference.any) {
    listings = listings
        .where((l) => l.nationalityPreference == filters.nationality)
        .toList();
  }

  if (filters.searchQuery.trim().isNotEmpty) {
    final q = filters.searchQuery.toLowerCase();
    listings = listings
        .where(
          (l) =>
              l.title.toLowerCase().contains(q) ||
              l.area.toLowerCase().contains(q),
        )
        .toList();
  }

  return listings;
}

class HousingRepository {
  HousingRepository(this._api);

  final ListingsApiService _api;

  Future<HousingListing> createListing(CreateListingRequest request) async {
    if (FirebaseService.isReady) {
      final firestore = HousingFirestoreService();
      return firestore.createListing(request);
    }
    return _api.createListing(request);
  }

  Future<void> reportListing(String id, ListingReport report) async {
    await _api.reportListing(id, report);
  }
}

final housingRepositoryProvider = Provider<HousingRepository>((ref) {
  return HousingRepository(ref.watch(listingsApiServiceProvider));
});
