import 'package:flutter/material.dart';

import 'package:raabta/features/global_search/domain/search_action_id.dart';
import 'package:raabta/features/global_search/domain/search_analysis.dart';
import 'package:raabta/features/global_search/domain/search_ask_ai_result.dart';
import 'package:raabta/features/global_search/domain/search_best_match.dart';
import 'package:raabta/features/global_search/domain/search_route_parameters.dart';

/// Kind of global search hit — destinations remain the default (S2).
enum GlobalSearchResultKind {
  destination,
  action,
  calculation,
  savedItem,
  askAi,
}

/// Top-level buckets shown in grouped global search results.
enum GlobalSearchCategory {
  actions('Actions', Icons.bolt_rounded),
  jobs('Jobs', Icons.work_outline_rounded),
  housing('Housing', Icons.home_outlined),
  community('Community', Icons.groups_outlined),
  documents('Document Vault', Icons.folder_copy_outlined),
  exchange('Exchange Locator', Icons.currency_exchange_rounded),
  mosques('Prayer & Mosques', Icons.mosque_outlined),
  tripPlanner('Trip Planner', Icons.map_outlined),
  businesses('Business', Icons.storefront_outlined),
  marketplace('Marketplace', Icons.shopping_bag_outlined),
  visa('Visa & Documents', Icons.description_outlined),
  health('Health Insurance', Icons.local_hospital_outlined),
  money('Money Hub', Icons.account_balance_wallet_outlined),
  tools('Tools & Utilities', Icons.build_outlined),
  services('Services', Icons.handyman_outlined);

  const GlobalSearchCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  /// Deep-link to the feature's own search/list screen ("see all").
  String get seeAllRoute => switch (this) {
        GlobalSearchCategory.actions => '/global-search',
        GlobalSearchCategory.jobs => '/jobs',
        GlobalSearchCategory.housing => '/housing',
        GlobalSearchCategory.community => '/community',
        GlobalSearchCategory.documents => '/document-vault',
        GlobalSearchCategory.exchange => '/money?tab=2&locatorTab=1',
        GlobalSearchCategory.mosques => '/prayer-mosque/mosques',
        GlobalSearchCategory.tripPlanner => '/trip-planner/search',
        GlobalSearchCategory.businesses => '/businesses',
        GlobalSearchCategory.marketplace => '/marketplace',
        GlobalSearchCategory.visa => '/visa',
        GlobalSearchCategory.health => '/health-insurance',
        GlobalSearchCategory.money => '/money',
        GlobalSearchCategory.tools => '/home',
        GlobalSearchCategory.services => '/services',
      };
}

/// A single searchable hit within a category group.
class GlobalSearchResultItem {
  const GlobalSearchResultItem({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.routePath,
    required this.score,
    this.useHousingDetailNavigator = false,
    this.resultKind = GlobalSearchResultKind.destination,
    this.actionId,
    this.actionPayload,
    this.queryParameters,
    this.confidence,
    this.searchRouteParameters,
    this.listingLatitude,
    this.listingLongitude,
    this.distanceMeters,
    this.semanticSimilarity,
  });

  final String id;
  final GlobalSearchCategory category;
  final String title;
  final String subtitle;
  final String routePath;
  final int score;

  /// Housing detail is not on GoRouter — open via [HousingDetailScreen].
  final bool useHousingDetailNavigator;

  /// S2 — defaults to [GlobalSearchResultKind.destination] for provider hits.
  final GlobalSearchResultKind resultKind;
  final SearchActionId? actionId;
  final Map<String, String>? actionPayload;
  final Map<String, String>? queryParameters;
  final double? confidence;

  /// S4 — typed FIND destination parameters (encoded at navigation time).
  final SearchRouteParameters? searchRouteParameters;

  /// S6 — optional listing coordinates for local proximity ranking only.
  final double? listingLatitude;
  final double? listingLongitude;

  /// S6 — computed distance from user location (meters); never sent remotely.
  final int? distanceMeters;

  /// S12 — optional semantic similarity metadata (local ranking only).
  final double? semanticSimilarity;

  bool get isAction =>
      resultKind == GlobalSearchResultKind.action ||
      resultKind == GlobalSearchResultKind.calculation;

  bool get isAskAi => resultKind == GlobalSearchResultKind.askAi;
}

/// Results for one category (may be omitted when [failed] is true).
class GlobalSearchCategoryGroup {
  const GlobalSearchCategoryGroup({
    required this.category,
    required this.items,
    this.totalMatched = 0,
    this.failed = false,
    this.seeAllRouteParameters,
  });

  final GlobalSearchCategory category;
  final List<GlobalSearchResultItem> items;
  final int totalMatched;
  final bool failed;

  /// S4 — optional structured parameters for the category see-all route.
  final SearchRouteParameters? seeAllRouteParameters;

  bool get hasMoreThanShown => totalMatched > items.length;
}

/// Full response from a global search query.
class GlobalSearchResponse {
  const GlobalSearchResponse({
    required this.query,
    required this.groups,
    this.actions = const [],
    this.fromCache = false,
    this.offline = false,
    this.analysis,
    this.bestMatch,
    this.locationUnavailable = false,
    this.askAiOffer,
  });

  final String query;
  final List<GlobalSearchCategoryGroup> groups;

  /// S2 — high-intent action results shown before category groups.
  final List<GlobalSearchResultItem> actions;
  final bool fromCache;
  final bool offline;

  /// Deterministic pre-router output — not shown in UI (S1).
  final SearchAnalysis? analysis;

  /// S5 — strongest FIND result highlight (optional).
  final SearchBestMatch? bestMatch;

  /// S6 — nearMe query without usable device location.
  final bool locationUnavailable;

  /// S9 — optional ASK AI fallback offer (no network until user taps).
  final SearchAskAiResult? askAiOffer;

  bool get isEmpty =>
      actions.isEmpty &&
      groups.every((g) => g.items.isEmpty || g.failed);

  List<GlobalSearchResultItem> get allItems => [
        ...actions,
        ...groups.expand((g) => g.items),
      ];

  GlobalSearchResponse copyWith({
    List<GlobalSearchCategoryGroup>? groups,
    List<GlobalSearchResultItem>? actions,
    bool? fromCache,
    bool? offline,
    SearchAnalysis? analysis,
    SearchBestMatch? bestMatch,
    bool clearBestMatch = false,
    bool? locationUnavailable,
    SearchAskAiResult? askAiOffer,
    bool clearAskAiOffer = false,
  }) {
    return GlobalSearchResponse(
      query: query,
      groups: groups ?? this.groups,
      actions: actions ?? this.actions,
      fromCache: fromCache ?? this.fromCache,
      offline: offline ?? this.offline,
      analysis: analysis ?? this.analysis,
      bestMatch: clearBestMatch ? null : (bestMatch ?? this.bestMatch),
      locationUnavailable: locationUnavailable ?? this.locationUnavailable,
      askAiOffer: clearAskAiOffer ? null : (askAiOffer ?? this.askAiOffer),
    );
  }
}
