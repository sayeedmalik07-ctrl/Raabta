import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/post_engine/domain/post_engine.dart';
import 'package:raabta/models/admin_report_model.dart';
import 'package:raabta/models/housing_models.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:raabta/services/housing_firestore_service.dart';
import 'package:raabta/services/listings_api_service.dart';
import 'package:raabta/services/report_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final listingsApiServiceProvider = Provider<ListingsApiService>((ref) {
  return ListingsApiService();
});

final housingFiltersProvider =
    StateProvider<HousingFilters>((ref) => const HousingFilters());

List<HousingListing> filterHousingListings(
  List<HousingListing> source,
  HousingFilters filters,
) {
  var listings = source;

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

  if (filters.minBedrooms != null && filters.minBedrooms! > 0) {
    listings =
        listings.where((l) => l.bedrooms >= filters.minBedrooms!).toList();
  }

  if (filters.searchQuery.trim().isNotEmpty) {
    final q = filters.searchQuery.toLowerCase();
    listings = listings
        .where(
          (l) =>
              l.title.toLowerCase().contains(q) ||
              l.area.toLowerCase().contains(q) ||
              l.description.toLowerCase().contains(q),
        )
        .toList();
  }

  return listings;
}

Future<List<HousingListing>> _fetchOfflineHousingCatalog(
  Ref ref,
  HousingFilters filters,
) async {
  final api = ref.read(listingsApiServiceProvider);

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
}

final housingListingsProvider =
    StreamProvider.autoDispose<List<HousingListing>>((ref) {
  final filters = ref.watch(housingFiltersProvider);

  if (FirebaseService.isReady) {
    final firestore = HousingFirestoreService();
    final area = filters.area?.trim();
    final areaFilter =
        (area != null && area.isNotEmpty) ? areaSlug(area) : null;

    return firestore.watchApprovedListings(areaSlugFilter: areaFilter).map(
          (listings) => filterHousingListings(listings, filters),
        );
  }

  return Stream.fromFuture(_fetchOfflineHousingCatalog(ref, filters));
});

final userHousingListingsProvider =
    StreamProvider.autoDispose.family<List<HousingListing>, String>((ref, uid) {
  if (!FirebaseService.isReady || uid.isEmpty) {
    return Stream.value(const []);
  }

  return HousingFirestoreService().watchUserListings(uid);
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
  return SavedListingsNotifier(ref);
});

class SavedListingsNotifier extends StateNotifier<Set<String>> {
  SavedListingsNotifier(this._ref) : super({}) {
    _load();
  }

  final Ref _ref;
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
    final adding = !updated.contains(listingId);
    if (adding) {
      updated.add(listingId);
    } else {
      updated.remove(listingId);
    }
    state = updated;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, updated.toList());
    } catch (_) {}

    if (adding) {
      unawaited(
        _ref.read(userAIProfileProvider.notifier).trackSave('housing', listingId),
      );
      unawaited(
        Future(() => PostEngine().analytics.trackSave(
              listingId: listingId,
              verticalId: 'housing',
            )),
      );
    }
  }

  bool isSaved(String listingId) => state.contains(listingId);
}

List<HousingListing> _filterFallbackListings(HousingFilters filters) {
  return filterHousingListings(
    fallbackHousingListings()
        .where((l) => l.status == ListingStatus.approved)
        .toList(),
    filters,
  );
}

class HousingRepository {
  HousingRepository(
    this._api, {
    ReportService? reportService,
  }) : _reportService = reportService ?? ReportService();

  final ListingsApiService _api;
  final ReportService _reportService;

  Future<HousingListing> createListing(CreateListingRequest request) async {
    if (FirebaseService.isReady) {
      final firestore = HousingFirestoreService();
      return firestore.createListing(request);
    }
    return _api.createListing(request);
  }

  Future<void> attachPhotos(String listingId, List<String> photoUrls) async {
    if (FirebaseService.isReady) {
      final firestore = HousingFirestoreService();
      await firestore.attachPhotos(listingId, photoUrls);
      return;
    }
  }

  Future<void> reportListing(
    String id,
    ListingReport report, {
    String? listingTitle,
  }) async {
    final isScamReport = report.reason.toLowerCase().contains('scam');
    try {
      if (isScamReport) {
        await _api.reportScam(
          listingId: id,
          reason: report.reason,
          details: report.details,
          reporterContact: report.reporterContact,
        );
      } else {
        await _api.reportListing(id, report);
      }
      return;
    } catch (_) {
      await _reportService.submitReport(
        type: AdminReportType.listing,
        title: 'Listing report: ${listingTitle ?? id}',
        description: [
          report.reason,
          if (report.details.isNotEmpty) report.details,
        ].join('\n'),
        targetId: id,
        targetType: 'listing',
        reporterContact:
            report.reporterContact.isEmpty ? null : report.reporterContact,
      );
    }
  }

  Future<ScamScanResult> scanListingScam({
    String? listingId,
    required CreateListingRequest request,
  }) {
    return _api.scanScam(
      listingId: listingId,
      title: request.title,
      description: request.description,
      price: request.pricePerMonth,
      area: request.area,
      contactPhone: request.phone,
      photos: request.photoUrls,
      bedrooms: request.bedrooms,
      type: request.type.name,
    );
  }
}

final housingRepositoryProvider = Provider<HousingRepository>((ref) {
  return HousingRepository(ref.watch(listingsApiServiceProvider));
});
