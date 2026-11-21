import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raabta/features/exchange_locator/data/exchange_locator_firestore_repository.dart';
import 'package:raabta/features/exchange_locator/data/exchange_locator_local_cache.dart';
import 'package:raabta/features/exchange_locator/data/exchange_locator_storage_service.dart';
import 'package:raabta/features/exchange_locator/domain/exchange_queue_logic.dart';
import 'package:raabta/features/exchange_locator/domain/models/branch_filters.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_branch.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_company.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_review.dart';
import 'package:raabta/features/exchange_locator/domain/repositories/exchange_locator_repository.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_location_service.dart';

final exchangeLocatorPrefsProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

final exchangeLocatorCacheProvider =
    FutureProvider<ExchangeLocatorLocalCache>((ref) async {
  final prefs = await ref.watch(exchangeLocatorPrefsProvider.future);
  return ExchangeLocatorLocalCache(prefs);
});

final exchangeLocatorRepositoryProvider =
    FutureProvider<ExchangeLocatorRepository>((ref) async {
  final cache = await ref.watch(exchangeLocatorCacheProvider.future);
  return ExchangeLocatorFirestoreRepository(cache: cache);
});

final exchangeLocatorStorageProvider =
    Provider<ExchangeLocatorStorage>((ref) {
  return ExchangeLocatorStorageService();
});

final exchangeLocatorLocationServiceProvider =
    Provider<PrayerLocationService>((ref) => PrayerLocationService());

class CompaniesPageState {
  const CompaniesPageState({
    this.companies = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = true,
    this.lastId,
  });

  final List<ExchangeCompany> companies;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasMore;
  final String? lastId;

  CompaniesPageState copyWith({
    List<ExchangeCompany>? companies,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasMore,
    String? lastId,
  }) {
    return CompaniesPageState(
      companies: companies ?? this.companies,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      lastId: lastId ?? this.lastId,
    );
  }
}

class CompaniesNotifier extends StateNotifier<CompaniesPageState> {
  CompaniesNotifier(this._ref) : super(const CompaniesPageState(isLoading: true)) {
    loadInitial();
  }

  final Ref _ref;

  Future<ExchangeLocatorRepository> get _repo async =>
      _ref.read(exchangeLocatorRepositoryProvider.future);

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: null, companies: []);
    try {
      final repo = await _repo;
      final page = await repo.fetchCompanies();
      state = CompaniesPageState(
        companies: page.items,
        hasMore: page.hasMore,
        lastId: page.lastDocumentId,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.lastId == null) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final repo = await _repo;
      final page = await repo.fetchCompanies(startAfterId: state.lastId);
      state = state.copyWith(
        companies: [...state.companies, ...page.items],
        hasMore: page.hasMore,
        lastId: page.lastDocumentId,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> refresh() => loadInitial();
}

final companiesNotifierProvider =
    StateNotifierProvider.autoDispose<CompaniesNotifier, CompaniesPageState>(
  (ref) => CompaniesNotifier(ref),
);

final companyDetailProvider =
    FutureProvider.autoDispose.family<ExchangeCompany?, String>((ref, id) async {
  final repo = await ref.watch(exchangeLocatorRepositoryProvider.future);
  return repo.fetchCompany(id);
});

final companyBranchesProvider =
    FutureProvider.autoDispose.family<List<ExchangeBranch>, String>(
  (ref, companyId) async {
    final repo = await ref.watch(exchangeLocatorRepositoryProvider.future);
    final page = await repo.fetchBranches(companyId: companyId, limit: 100);
    return page.items;
  },
);

final branchDetailProvider =
    FutureProvider.autoDispose.family<ExchangeBranch?, String>((ref, id) async {
  final repo = await ref.watch(exchangeLocatorRepositoryProvider.future);
  final branch = await repo.fetchBranch(id);
  if (branch != null) {
    final cache = await ref.read(exchangeLocatorCacheProvider.future);
    await cache.recordRecentVisit(branch);
    await cache.cacheQueueSnapshot(branch);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await repo.recordRecentVisitRemote(userId: user.uid, branch: branch);
      } catch (_) {
        // Offline — local recent visit still recorded.
      }
    }
  }
  return branch;
});

/// Pull-model queue refresh — no Firestore snapshot listeners.
final branchQueueRefreshProvider =
    FutureProvider.autoDispose.family<ExchangeBranch?, String>((ref, id) async {
  final repo = await ref.watch(exchangeLocatorRepositoryProvider.future);
  final branch = await repo.fetchBranch(id);
  if (branch != null) {
    final cache = await ref.read(exchangeLocatorCacheProvider.future);
    await cache.cacheQueueSnapshot(branch);
  }
  ref.invalidate(branchDetailProvider(id));
  return branch;
});

final recentCrowdReportsProvider =
    FutureProvider.autoDispose.family<List<CrowdReportSample>, String>(
  (ref, branchId) async {
    final repo = await ref.watch(exchangeLocatorRepositoryProvider.future);
    return repo.fetchRecentCrowdReports(branchId);
  },
);

final branchFinderFiltersProvider =
    StateProvider.autoDispose<BranchFinderFilters>(
  (ref) => const BranchFinderFilters(),
);

class BranchFinderNotifier extends StateNotifier<AsyncValue<List<ExchangeBranch>>> {
  BranchFinderNotifier(this._ref) : super(const AsyncValue.loading()) {
    search();
  }

  final Ref _ref;

  Future<void> search() async {
    state = const AsyncValue.loading();
    try {
      final repo = await _ref.read(exchangeLocatorRepositoryProvider.future);
      final filters = _ref.read(branchFinderFiltersProvider);
      final page = await repo.fetchBranches(filters: filters, limit: 50);
      var branches = page.items;

      if (filters.sort == BranchSortOption.nearest ||
          filters.nearbyOnly) {
        final loc = await _ref.read(smartNearbyLocationProvider.future);
        if (loc != null) {
          branches = ExchangeLocatorFirestoreRepository.sortByDistance(
            branches,
            loc.latitude,
            loc.longitude,
          );
        }
      }

      state = AsyncValue.data(branches);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final branchFinderProvider = StateNotifierProvider.autoDispose<
    BranchFinderNotifier, AsyncValue<List<ExchangeBranch>>>(
  (ref) => BranchFinderNotifier(ref),
);

final mapBranchesProvider =
    FutureProvider.autoDispose<List<ExchangeBranch>>((ref) async {
  // One-time get() + 15-min local cache — never a collection snapshot listener.
  final repo = await ref.watch(exchangeLocatorRepositoryProvider.future);
  return repo.fetchAllBranchesForMap();
});

/// Explicit map refresh — bypasses branch cache TTL.
Future<List<ExchangeBranch>> refreshMapBranches(WidgetRef ref) async {
  final repo = await ref.read(exchangeLocatorRepositoryProvider.future);
  final branches = await repo.refreshBranchesForMap();
  ref.invalidate(mapBranchesProvider);
  return branches;
}

final branchReviewsProvider = FutureProvider.autoDispose
    .family<PaginatedResult<ExchangeReview>, String>((ref, branchId) async {
  final repo = await ref.watch(exchangeLocatorRepositoryProvider.future);
  final sort = ref.watch(reviewSortProvider);
  return repo.fetchReviews(branchId: branchId, sort: sort);
});

final reviewSortProvider =
    StateProvider.autoDispose<ExchangeReviewSort>((ref) => ExchangeReviewSort.recent);

final favoriteBranchIdsProvider = StreamProvider.autoDispose<Set<String>>((ref) async* {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    yield {};
    return;
  }
  final repo = await ref.watch(exchangeLocatorRepositoryProvider.future);
  yield* repo.watchFavoriteBranchIds(user.uid);
});

final favoriteBranchesProvider =
    FutureProvider.autoDispose<List<ExchangeBranch>>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];
  final repo = await ref.watch(exchangeLocatorRepositoryProvider.future);
  return repo.fetchFavoriteBranches(user.uid);
});

final recentVisitsProvider =
    FutureProvider.autoDispose<List<ExchangeBranch>>((ref) async {
  final cache = await ref.watch(exchangeLocatorCacheProvider.future);
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    try {
      final repo = await ref.watch(exchangeLocatorRepositoryProvider.future);
      final remote = await repo.fetchRecentVisitsRemote(user.uid);
      if (remote.isNotEmpty) return remote;
    } catch (_) {}
  }

  final ids = cache.loadRecentVisitIds();
  return ids.map(cache.loadRecentBranch).whereType<ExchangeBranch>().toList();
});

class SmartNearbyState {
  const SmartNearbyState({
    this.latitude,
    this.longitude,
    this.label,
    this.permissionDenied = false,
    this.isLoading = false,
  });

  final double? latitude;
  final double? longitude;
  final String? label;
  final bool permissionDenied;
  final bool isLoading;

  bool get hasLocation => latitude != null && longitude != null;
}

class SmartNearbyNotifier extends StateNotifier<SmartNearbyState> {
  SmartNearbyNotifier(this._locationService)
      : super(const SmartNearbyState(isLoading: true)) {
    resolve();
  }

  final PrayerLocationService _locationService;

  Future<void> resolve() async {
    state = const SmartNearbyState(isLoading: true);
    final granted = await _locationService.ensurePermission();
    if (!granted) {
      state = const SmartNearbyState(permissionDenied: true);
      return;
    }
    try {
      final result = await _locationService.resolve(autoLocation: true);
      state = SmartNearbyState(
        latitude: result.latitude,
        longitude: result.longitude,
        label: result.label,
      );
    } catch (_) {
      state = const SmartNearbyState(permissionDenied: true);
    }
  }
}

final smartNearbyNotifierProvider = StateNotifierProvider.autoDispose<
    SmartNearbyNotifier, SmartNearbyState>((ref) {
  return SmartNearbyNotifier(ref.read(exchangeLocatorLocationServiceProvider));
});

final smartNearbyLocationProvider =
    FutureProvider.autoDispose<PrayerLocationResult?>((ref) async {
  final nearby = ref.watch(smartNearbyNotifierProvider);
  if (!nearby.hasLocation) return null;
  return PrayerLocationResult(
    latitude: nearby.latitude!,
    longitude: nearby.longitude!,
    label: nearby.label ?? 'Your location',
    source: PrayerLocationSource.gps,
  );
});

final nearbyBranchesProvider =
    FutureProvider.autoDispose<List<ExchangeBranch>>((ref) async {
  final loc = await ref.watch(smartNearbyLocationProvider.future);
  if (loc == null) return [];
  final repo = await ref.watch(exchangeLocatorRepositoryProvider.future);
  final page = await repo.fetchBranches(limit: 100);
  final sorted = ExchangeLocatorFirestoreRepository.sortByDistance(
    page.items,
    loc.latitude,
    loc.longitude,
  );
  return sorted.take(5).toList();
});

// Map and queue status use pull + cache only — no unbounded Firestore listeners.
// Favorites use a scoped user subcollection listener (small, user-specific).
