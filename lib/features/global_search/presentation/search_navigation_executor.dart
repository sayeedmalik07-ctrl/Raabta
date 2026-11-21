import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/search_route_builder.dart';
import 'package:raabta/features/global_search/domain/search_route_parameters.dart';
import 'package:raabta/features/global_search/presentation/search_action_executor.dart';

/// Unified Global Search result navigation — FIND + ACTION (S4).
abstract final class SearchNavigationExecutor {
  static void open(BuildContext context, GlobalSearchResultItem item) {
    if (item.isAction) {
      SearchActionExecutor.execute(context, item);
      return;
    }

    final basePath = item.routePath.split('?').first;
    final path = item.searchRouteParameters != null &&
            SearchRouteBuilder.isStructuredHubRoute(basePath)
        ? SearchRouteBuilder.build(basePath, item.searchRouteParameters)
        : item.routePath;

    context.push(path);
  }

  static void openSeeAll(
    BuildContext context,
    GlobalSearchCategoryGroup group,
  ) {
    final basePath = group.category.seeAllRoute.split('?').first;
    final existingQuery = Uri.parse(
      group.category.seeAllRoute.startsWith('/')
          ? group.category.seeAllRoute
          : '/${group.category.seeAllRoute}',
    ).queryParameters;

    final params = group.seeAllRouteParameters;
    if (params != null && !params.isEmpty) {
      final merged = SearchRouteParameters.fromQueryMap(existingQuery)
          .copyWith(
            area: params.area,
            minPrice: params.minPrice,
            maxPrice: params.maxPrice,
            minSalary: params.minSalary,
            maxSalary: params.maxSalary,
            jobCategory: params.jobCategory,
            jobQuery: params.jobQuery,
            employmentType: params.employmentType,
            serviceTrade: params.serviceTrade,
            propertyType: params.propertyType,
            bedrooms: params.bedrooms,
            businessTag: params.businessTag,
            businessQuery: params.businessQuery,
            visaTopic: params.visaTopic,
          );
      context.push(SearchRouteBuilder.build(basePath, merged));
      return;
    }

    context.push(group.category.seeAllRoute);
  }
}
