import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/search_analysis.dart';
import 'package:raabta/features/global_search/domain/search_route_parameter_factory.dart';
import 'package:raabta/features/global_search/domain/search_route_parameters.dart';
import 'package:raabta/services/ai/smart_search_service.dart';

/// Attaches structured FIND route parameters to search responses (S4).
abstract final class SearchStructuredRouteApplier {
  static GlobalSearchResponse apply(
    GlobalSearchResponse response,
    SearchAnalysis analysis,
  ) {
    if (analysis.intent == SearchIntent.unknown &&
        !_hasStructuredFields(analysis)) {
      return response;
    }

    final groups = response.groups.map((group) {
      final params = SearchRouteParameterFactory.forCategory(
        analysis,
        group.category,
      );
      if (params == null) return group;

      final updatedItems = group.items
          .map((item) => _attachToItem(item, params))
          .toList();

      return GlobalSearchCategoryGroup(
        category: group.category,
        items: updatedItems,
        totalMatched: group.totalMatched,
        failed: group.failed,
        seeAllRouteParameters: params,
      );
    }).toList();

    return GlobalSearchResponse(
      query: response.query,
      groups: groups,
      actions: response.actions,
      fromCache: response.fromCache,
      offline: response.offline,
      analysis: analysis,
      locationUnavailable: response.locationUnavailable,
    );
  }

  static bool _hasStructuredFields(SearchAnalysis analysis) {
    return analysis.area != null ||
        analysis.minPrice != null ||
        analysis.maxPrice != null ||
        analysis.minSalary != null ||
        analysis.maxSalary != null ||
        analysis.jobCategory != null ||
        analysis.jobTitle != null ||
        analysis.propertyType != null ||
        analysis.bedrooms != null ||
        analysis.serviceTrade != null ||
        analysis.businessCategory != null ||
        analysis.visaTopic != null;
  }

  static GlobalSearchResultItem _attachToItem(
    GlobalSearchResultItem item,
    SearchRouteParameters params,
  ) {
    if (item.isAction) return item;

    final basePath = item.routePath.split('?').first;
    if (!_isHubOrCategoryRoute(basePath)) return item;

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
      searchRouteParameters: params,
      listingLatitude: item.listingLatitude,
      listingLongitude: item.listingLongitude,
      distanceMeters: item.distanceMeters,
    );
  }

  static bool _isHubOrCategoryRoute(String path) {
    if (path == '/jobs' ||
        path == '/housing' ||
        path == '/services' ||
        path == '/businesses') {
      return true;
    }
    return path == '/visa';
  }
}
