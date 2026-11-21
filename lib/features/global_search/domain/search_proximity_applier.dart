import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/search_analysis.dart';
import 'package:raabta/features/global_search/domain/search_location_context.dart';
import 'package:raabta/features/global_search/domain/search_proximity_ranker.dart';

/// Applies nearMe proximity metadata and Services reordering (S6).
abstract final class SearchProximityApplier {
  static GlobalSearchResponse apply({
    required GlobalSearchResponse response,
    required SearchAnalysis analysis,
    SearchLocationContext? location,
  }) {
    if (!SearchProximityRanker.shouldApply(analysis)) {
      return response;
    }

    final locationUnavailable = location == null;
    final updatedGroups = response.groups.map((group) {
      if (group.category != GlobalSearchCategory.services || location == null) {
        return group;
      }
      return _reorderServicesGroup(group, location);
    }).toList();

    return response.copyWith(
      groups: updatedGroups,
      locationUnavailable: locationUnavailable,
    );
  }

  static GlobalSearchCategoryGroup _reorderServicesGroup(
    GlobalSearchCategoryGroup group,
    SearchLocationContext location,
  ) {
    final enriched = group.items.map((item) {
      final meters = SearchProximityRanker.distanceMetersForItem(
        item: item,
        location: location,
      );
      if (meters == null) return item;
      return GlobalSearchResultItem(
        id: item.id,
        category: item.category,
        title: item.title,
        subtitle: item.subtitle,
        routePath: item.routePath,
        score: item.score,
        useHousingDetailNavigator: item.useHousingDetailNavigator,
        resultKind: item.resultKind,
        actionId: item.actionId,
        actionPayload: item.actionPayload,
        queryParameters: item.queryParameters,
        confidence: item.confidence,
        searchRouteParameters: item.searchRouteParameters,
        listingLatitude: item.listingLatitude,
        listingLongitude: item.listingLongitude,
        distanceMeters: meters,
      );
    }).toList();

    enriched.sort((a, b) {
      final aRank = a.score +
          SearchProximityRanker.proximityBonusForItem(
            item: a,
            location: location,
          );
      final bRank = b.score +
          SearchProximityRanker.proximityBonusForItem(
            item: b,
            location: location,
          );
      final byRank = bRank.compareTo(aRank);
      if (byRank != 0) return byRank;

      final aDist = a.distanceMeters ?? 1 << 30;
      final bDist = b.distanceMeters ?? 1 << 30;
      return aDist.compareTo(bDist);
    });

    return GlobalSearchCategoryGroup(
      category: group.category,
      items: enriched,
      totalMatched: group.totalMatched,
      failed: group.failed,
      seeAllRouteParameters: group.seeAllRouteParameters,
    );
  }
}
