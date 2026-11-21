import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/exchange_locator/domain/repositories/exchange_locator_repository.dart';
import 'package:raabta/features/exchange_locator/presentation/providers/exchange_locator_providers.dart';
import 'package:raabta/features/global_search/data/global_search_repository.dart';
import 'package:raabta/features/global_search/data/recent_searches_cache.dart';
import 'package:raabta/features/global_search/data/search_personalization_provider.dart';
import 'package:raabta/features/global_search/data/search_recent_query_repository.dart';
import 'package:raabta/features/global_search/domain/search_autocomplete_result.dart';
import 'package:raabta/features/global_search/domain/search_autocomplete_service.dart';
import 'package:raabta/features/global_search/domain/search_recent_query.dart';
import 'package:raabta/features/global_search/domain/global_search_dependencies.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/data/search_location_provider.dart';
import 'package:raabta/features/global_search/domain/search_context.dart';
import 'package:raabta/features/global_search/domain/search_location_context.dart';
import 'package:raabta/features/global_search/utils/search_debouncer.dart';
import 'package:raabta/features/trip_planner/data/trip_planner_repository.dart';
import 'package:raabta/features/trip_planner/providers/trip_planner_providers.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/business_providers.dart';
import 'package:raabta/providers/jobs_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/ai/smart_search_service.dart';
import 'package:raabta/features/profile/privacy/providers/privacy_providers.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/services/firebase_service.dart';

final globalSearchRepositoryProvider = Provider<GlobalSearchRepository>((ref) {
  return GlobalSearchRepository();
});

final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
  return RecentSearchesNotifier();
});

class RecentSearchesNotifier extends StateNotifier<List<String>> {
  RecentSearchesNotifier() : super(const []) {
    _load();
  }

  Future<void> _load() async {
    await RecentSearchesCache.instance.init();
    state = RecentSearchesCache.instance.load();
  }

  Future<void> add(String query) async {
    await SearchRecentQueryRepository.addRecentQuery(query);
    state = RecentSearchesCache.instance.load();
  }

  Future<void> remove(String query) async {
    await RecentSearchesCache.instance.remove(query);
    state = RecentSearchesCache.instance.load();
  }

  Future<void> clearAll() async {
    await RecentSearchesCache.instance.clear();
    state = const [];
  }
}

final globalSearchOnlineProvider = Provider<bool>((ref) {
  return FirebaseService.isReady;
});

final searchLocationProvider = Provider<SearchLocationReader>((ref) {
  return SearchLocationProvider();
});

typedef GlobalSearchState = ({
  String query,
  GlobalSearchResponse? response,
  bool isSearching,
  bool offlineBanner,
});

class GlobalSearchNotifier extends StateNotifier<GlobalSearchState> {
  GlobalSearchNotifier(this._ref)
      : _debouncer = SearchDebouncer(),
        super((
          query: '',
          response: null,
          isSearching: false,
          offlineBanner: false,
        ));

  final Ref _ref;
  final SearchDebouncer _debouncer;

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  void setQuery(String value) {
    state = (
      query: value,
      response: state.response,
      isSearching: value.trim().length >= GlobalSearchRepository.minQueryLength,
      offlineBanner: state.offlineBanner,
    );

    _debouncer.cancel();
    final trimmed = value.trim();
    if (trimmed.length < GlobalSearchRepository.minQueryLength) {
      state = (
        query: value,
        response: null,
        isSearching: false,
        offlineBanner: state.offlineBanner,
      );
      return;
    }

    final isOnline = _ref.read(globalSearchOnlineProvider);
    if (!isOnline) {
      state = (
        query: value,
        response: null,
        isSearching: false,
        offlineBanner: true,
      );
      return;
    }

    state = (
      query: value,
      response: state.response,
      isSearching: true,
      offlineBanner: false,
    );

    _debouncer.run(() => _runSearch(trimmed));
  }

  String _searchAuthScopeFromUid(String? uid) {
    return (uid != null && uid.isNotEmpty) ? uid : 'guest';
  }

  String _currentSearchAuthScope() {
    return _searchAuthScopeFromUid(_ref.read(currentUserProvider)?.uid);
  }

  Future<void> _runSearch(String query) async {
    final searchAuthScope = _currentSearchAuthScope();

    ExchangeLocatorRepository? exchangeRepo;
    TripPlannerRepository? tripRepo;
    try {
      exchangeRepo = await _ref.read(exchangeLocatorRepositoryProvider.future);
    } catch (_) {}
    try {
      tripRepo = await _ref.read(tripPlannerRepositoryProvider.future);
    } catch (_) {}

    final repo = _ref.read(globalSearchRepositoryProvider);
    repo.updateDependencies(
      GlobalSearchDependencies(
        exchangeRepository: exchangeRepo,
        tripPlannerRepository: tripRepo,
        locale: _ref.read(userLanguageProvider),
        jobsCatalog: _ref.read(jobsCatalogProvider).valueOrNull ?? const [],
        businessesCatalog:
            _ref.read(businessCatalogProvider).valueOrNull ?? const [],
      ),
    );

    final profile = _ref.read(userAIProfileProvider);
    final analysis =
        _ref.read(smartSearchServiceProvider).analyze(query, profile: profile);

    final uid = _ref.read(currentUserProvider)?.uid;
    final isOnline = _ref.read(globalSearchOnlineProvider);

    SearchLocationContext? location;
    if (analysis.nearMe && isOnline) {
      location = await _ref.read(searchLocationProvider).getCurrentLocation();
    }

    final privacy = _ref.read(privacySettingsProvider).valueOrNull;
    final personalizationEnabled =
        privacy?.aiPersonalizationEnabled ?? true;
    final recentQueries = _ref.read(recentSearchesProvider);
    final personalization = SearchPersonalizationProvider.build(
      profile: profile,
      personalizationEnabled: personalizationEnabled,
      recentQueries: recentQueries,
    );

    final response = await repo.searchWithContext(
      context: SearchContext(
        query: query,
        analysis: analysis,
        location: location,
        personalization: personalization,
      ),
      userId: uid,
      isOnline: isOnline,
    );

    if (state.query.trim() != query) return;
    if (_currentSearchAuthScope() != searchAuthScope) return;

    state = (
      query: query,
      response: response,
      isSearching: false,
      offlineBanner: response.offline,
    );

    if (!response.offline && !response.isEmpty) {
      await _ref.read(recentSearchesProvider.notifier).add(query);
    }
  }

  Future<void> rerunRecent(String query) async {
    state = (
      query: query,
      response: null,
      isSearching: true,
      offlineBanner: false,
    );
    await _runSearch(query);
  }

  void refreshForLocaleChange() {
    final trimmed = state.query.trim();
    if (trimmed.length < GlobalSearchRepository.minQueryLength) return;
    if (state.response == null && !state.isSearching) return;
    unawaited(rerunRecent(trimmed));
  }

  /// Clears visible results when auth scope changes (P0).
  void resetForAuthTransition() {
    _debouncer.cancel();
    state = (
      query: state.query,
      response: null,
      isSearching: false,
      offlineBanner: false,
    );
  }
}

final globalSearchProvider =
    StateNotifierProvider<GlobalSearchNotifier, GlobalSearchState>((ref) {
  final notifier = GlobalSearchNotifier(ref);
  ref.listen<String>(userLanguageProvider, (previous, next) {
    if (previous != null && previous != next) {
      notifier.refreshForLocaleChange();
    }
  });
  ref.listen<String?>(
    currentUserProvider.select((user) => user?.uid),
    (previous, next) {
      if (previous != next) {
        ref.read(globalSearchRepositoryProvider).clearSessionCache();
        notifier.resetForAuthTransition();
      }
    },
  );
  return notifier;
});

SearchDebouncer createSearchDebouncerForTests() => SearchDebouncer();

final searchAutocompleteProvider = Provider.family<
    List<SearchAutocompleteResult>,
    ({String query, List<String> recent, String locale})>((ref, params) {
  final recent = params.recent
      .map((q) => SearchRecentQuery(text: q, recordedAt: DateTime.now()))
      .toList();
  return SearchAutocompleteService.suggest(
    rawQuery: params.query,
    recentQueries: recent,
    locale: params.locale,
  );
});
