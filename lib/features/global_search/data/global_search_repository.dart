import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:raabta/features/exchange_locator/data/exchange_locator_firestore_repository.dart';
import 'package:raabta/features/global_search/data/search_provider_registration.dart';
import 'package:raabta/features/global_search/domain/global_search_dependencies.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/global_search_provider.dart';
import 'package:raabta/features/global_search/domain/intent_relevance_boost.dart';
import 'package:raabta/features/global_search/domain/search_action_result_builder.dart';
import 'package:raabta/features/global_search/domain/search_ask_ai_result_builder.dart';
import 'package:raabta/features/global_search/domain/search_analysis.dart';
import 'package:raabta/features/global_search/domain/search_best_match_ranker.dart';
import 'package:raabta/features/global_search/domain/search_context.dart';
import 'package:raabta/features/global_search/domain/search_proximity_applier.dart';
import 'package:raabta/features/global_search/domain/search_structured_route_applier.dart';
import 'package:raabta/features/global_search/data/search_semantic_service.dart';
import 'package:raabta/features/global_search/domain/search_semantic_config.dart';
import 'package:raabta/features/global_search/data/search_query_helpers.dart';
import 'package:raabta/services/ai/smart_search_service.dart';
import 'package:raabta/services/firebase_service.dart';

/// Firestore-native, cost-bounded global search across registered providers.
///
/// Each category is queried independently and in parallel via
/// [GlobalSearchProviderRegistry]. Providers self-register in
/// [registerAllSearchProviders] — see `SEARCH_REGISTRATION.md`.
class GlobalSearchRepository {
  GlobalSearchRepository({
    FirebaseFirestore? firestore,
    GlobalSearchDependencies? dependencies,
    SearchSemanticService? semanticService,
    SearchSemanticConfig semanticConfig = SearchSemanticConfig.production,
    Duration? providerSearchTimeout,
  })  : _semanticService = semanticService ??
            SearchSemanticService(config: semanticConfig),
        _providerSearchTimeout = providerSearchTimeout ??
            GlobalSearchRepositoryConstants.providerSearchTimeout,
        _deps = dependencies ??
            GlobalSearchDependencies(
              firestore: firestore ??
                  (FirebaseService.isReady
                      ? FirebaseFirestore.instance
                      : null),
              exchangeRepository: ExchangeLocatorFirestoreRepository(),
            ) {
    registerAllSearchProviders();
  }

  GlobalSearchDependencies _deps;
  final SearchSemanticService _semanticService;
  final Duration _providerSearchTimeout;

  GlobalSearchDependencies get dependencies => _deps;

  /// Refreshes injected catalogs/repos without recreating the repository session.
  void updateDependencies(GlobalSearchDependencies deps) {
    _deps = deps;
  }

  static const minQueryLength = GlobalSearchRepositoryConstants.minQueryLength;
  static const perCategoryDisplayLimit =
      GlobalSearchRepositoryConstants.perCategoryDisplayLimit;
  static const fetchLimit = GlobalSearchRepositoryConstants.fetchLimit;

  final Map<String, GlobalSearchResponse> _sessionCache = {};
  int parallelInvocationCount = 0;

  List<GlobalSearchProvider> get _providers =>
      GlobalSearchProviderRegistry.providers;

  Future<GlobalSearchResponse> search({
    required String query,
    SearchAnalysis? analysis,
    String? userId,
    required bool isOnline,
  }) {
    return searchWithContext(
      context: SearchContext(
        query: query,
        analysis: analysis ?? SearchAnalysis.empty(),
      ),
      userId: userId,
      isOnline: isOnline,
    );
  }

  Future<GlobalSearchResponse> searchWithContext({
    required SearchContext context,
    String? userId,
    required bool isOnline,
  }) async {
    final normalized = context.query.trim();
    if (normalized.length < minQueryLength) {
      return GlobalSearchResponse(
        query: normalized,
        groups: const [],
        actions: const [],
        analysis: context.analysis,
      );
    }

    final cacheKey = buildSessionCacheKey(
      userId: userId,
      normalizedQuery: normalized,
    );
    if (_sessionCache.containsKey(cacheKey)) {
      final cached = _sessionCache[cacheKey]!;
      return _finalizeResponse(
        cached.copyWith(fromCache: true, analysis: context.analysis),
        context,
        isOnline: isOnline,
      );
    }

    if (!isOnline) {
      return _attachActions(
        GlobalSearchResponse(
          query: normalized,
          groups: const [],
          offline: true,
          analysis: context.analysis,
        ),
        context.analysis,
      );
    }

    parallelInvocationCount = 0;
    final futures = _providers
        .map(
          (p) => _guardedSearch(
            () => p.search(query: normalized, deps: _deps, userId: userId),
          ),
        )
        .toList();

    final results = await Future.wait(futures);
    final groups = _mergeCategoryGroups(
      results.whereType<GlobalSearchCategoryGroup>().toList(),
    );
    final raw = GlobalSearchResponse(
      query: normalized,
      groups: groups,
      analysis: context.analysis,
    );
    final response = await _finalizeResponse(raw, context, isOnline: isOnline);
    _sessionCache[cacheKey] = raw;
    return response;
  }

  Future<GlobalSearchResponse> _finalizeResponse(
    GlobalSearchResponse raw,
    SearchContext context, {
    required bool isOnline,
  }) async {
    final boosted = _applyIntentBoost(raw, context.analysis);
    final routed = SearchStructuredRouteApplier.apply(boosted, context.analysis);
    final proxied = SearchProximityApplier.apply(
      response: routed,
      analysis: context.analysis,
      location: context.location,
    );
    final hybrid = await _semanticService.maybeEnhance(
      response: proxied,
      context: context,
      isOnline: isOnline && !raw.offline,
    );
    return _attachAskAiOffer(
      _attachActions(
        _attachBestMatch(hybrid, context),
        context.analysis,
      ),
      context,
      isOnline: isOnline && !raw.offline,
    );
  }

  GlobalSearchResponse _attachBestMatch(
    GlobalSearchResponse response,
    SearchContext context,
  ) {
    final findResults = response.groups
        .where((g) => !g.failed)
        .expand((g) => g.items)
        .where(
          (item) =>
              !item.isAction &&
              item.resultKind == GlobalSearchResultKind.destination,
        )
        .toList();

    final bestMatch = SearchBestMatchRanker.rank(
      analysis: context.analysis,
      findResults: findResults,
      location: context.location,
      personalization: context.personalization,
    );

    return response.copyWith(bestMatch: bestMatch, clearBestMatch: bestMatch == null);
  }

  GlobalSearchResponse _attachActions(
    GlobalSearchResponse response,
    SearchAnalysis analysis,
  ) {
    final actions = SearchActionResultBuilder.build(
      analysis: analysis,
      locale: _deps.locale,
    );
    return response.copyWith(actions: actions);
  }

  GlobalSearchResponse _attachAskAiOffer(
    GlobalSearchResponse response,
    SearchContext context, {
    required bool isOnline,
  }) {
    final offer = SearchAskAiResultBuilder.build(
      analysis: context.analysis,
      response: response,
      locale: _deps.locale,
      isOnline: isOnline,
    );
    return response.copyWith(
      askAiOffer: offer,
      clearAskAiOffer: offer == null,
    );
  }

  /// Combines multiple provider groups that share a category (e.g. static + live Services).
  List<GlobalSearchCategoryGroup> _mergeCategoryGroups(
    List<GlobalSearchCategoryGroup> groups,
  ) {
    if (groups.length <= 1) return groups;

    final merged = <GlobalSearchCategory, GlobalSearchCategoryGroup>{};
    for (final group in groups) {
      final existing = merged[group.category];
      if (existing == null) {
        merged[group.category] = group;
        continue;
      }

      final combinedItems = [...existing.items, ...group.items]
        ..sort((a, b) => b.score.compareTo(a.score));
      merged[group.category] = GlobalSearchCategoryGroup(
        category: group.category,
        items: combinedItems.take(perCategoryDisplayLimit).toList(),
        totalMatched: existing.totalMatched + group.totalMatched,
        failed: existing.items.isEmpty &&
            group.items.isEmpty &&
            existing.failed &&
            group.failed,
        seeAllRouteParameters:
            existing.seeAllRouteParameters ?? group.seeAllRouteParameters,
      );
    }

    return merged.values.toList();
  }

  GlobalSearchResponse _applyIntentBoost(
    GlobalSearchResponse response,
    SearchAnalysis analysis,
  ) {
    if (analysis.intent == SearchIntent.unknown) return response;

    final boostedGroups = response.groups.map((group) {
      final boost = IntentRelevanceBoost.forCategory(group.category, analysis);
      if (boost == 0 || group.items.isEmpty) return group;

      final boostedItems = group.items
          .map(
            (item) => GlobalSearchResultItem(
              id: item.id,
              category: item.category,
              title: item.title,
              subtitle: item.subtitle,
              routePath: item.routePath,
              score: item.score + boost,
              useHousingDetailNavigator: item.useHousingDetailNavigator,
              resultKind: item.resultKind,
              actionId: item.actionId,
              actionPayload: item.actionPayload,
              queryParameters: item.queryParameters,
              confidence: item.confidence,
              searchRouteParameters: item.searchRouteParameters,
              listingLatitude: item.listingLatitude,
              listingLongitude: item.listingLongitude,
              distanceMeters: item.distanceMeters,
              semanticSimilarity: item.semanticSimilarity,
            ),
          )
          .toList()
        ..sort((a, b) => b.score.compareTo(a.score));

      return GlobalSearchCategoryGroup(
        category: group.category,
        items: boostedItems.take(perCategoryDisplayLimit).toList(),
        totalMatched: group.totalMatched,
        failed: group.failed,
        seeAllRouteParameters: group.seeAllRouteParameters,
      );
    }).toList();

    boostedGroups.sort((a, b) {
      final aTop = a.items.isEmpty ? 0 : a.items.first.score;
      final bTop = b.items.isEmpty ? 0 : b.items.first.score;
      return bTop.compareTo(aTop);
    });

    return GlobalSearchResponse(
      query: response.query,
      groups: boostedGroups,
      fromCache: response.fromCache,
      offline: response.offline,
      analysis: analysis,
    );
  }

  Future<GlobalSearchCategoryGroup?> _guardedSearch(
    Future<GlobalSearchCategoryGroup> Function() fn,
  ) async {
    parallelInvocationCount++;
    try {
      return await fn().timeout(_providerSearchTimeout);
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// UID-scoped session cache key — isolates guest and authenticated users (P0).
  @visibleForTesting
  static String buildSessionCacheKey({
    required String? userId,
    required String normalizedQuery,
  }) {
    final scope =
        (userId != null && userId.isNotEmpty) ? userId : 'guest';
    return '$scope::${normalizedQuery.toLowerCase()}';
  }

  void clearSessionCache() => _sessionCache.clear();
}
