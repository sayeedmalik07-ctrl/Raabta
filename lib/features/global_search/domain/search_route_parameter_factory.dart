import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/search_analysis.dart';
import 'package:raabta/features/global_search/domain/search_route_parameters.dart';
import 'package:raabta/services/ai/smart_search_service.dart';

/// Maps [SearchAnalysis] to category-scoped [SearchRouteParameters] (S4).
abstract final class SearchRouteParameterFactory {
  static SearchRouteParameters? forCategory(
    SearchAnalysis analysis,
    GlobalSearchCategory category,
  ) {
    return switch (category) {
      GlobalSearchCategory.jobs => _forJobs(analysis),
      GlobalSearchCategory.housing => _forHousing(analysis),
      GlobalSearchCategory.services => _forServices(analysis),
      GlobalSearchCategory.businesses => _forBusiness(analysis),
      GlobalSearchCategory.visa => _forVisa(analysis),
      _ => null,
    };
  }

  static SearchRouteParameters? _forJobs(SearchAnalysis analysis) {
    if (!_intentMatches(analysis.intent, {SearchIntent.findJob})) {
      return null;
    }
    final params = SearchRouteParameters(
      area: analysis.area,
      minSalary: analysis.minSalary,
      maxSalary: analysis.maxSalary,
      jobCategory: analysis.jobCategory,
      jobQuery: analysis.jobTitle,
    );
    return params.isEmpty ? null : params;
  }

  static SearchRouteParameters? _forHousing(SearchAnalysis analysis) {
    if (!_intentMatches(analysis.intent, {SearchIntent.findHousing})) {
      return null;
    }
    final params = SearchRouteParameters(
      area: analysis.area,
      minPrice: analysis.minPrice,
      maxPrice: analysis.maxPrice,
      propertyType: analysis.propertyType,
      bedrooms: analysis.bedrooms,
    );
    return params.isEmpty ? null : params;
  }

  static SearchRouteParameters? _forServices(SearchAnalysis analysis) {
    if (!_intentMatches(analysis.intent, {SearchIntent.findService})) {
      return null;
    }
    final params = SearchRouteParameters(
      area: analysis.area,
      serviceTrade: analysis.serviceTrade,
    );
    return params.isEmpty ? null : params;
  }

  static SearchRouteParameters? _forBusiness(SearchAnalysis analysis) {
    if (!_intentMatches(
      analysis.intent,
      {SearchIntent.findBusiness, SearchIntent.findDoctor},
    )) {
      return null;
    }
    final params = SearchRouteParameters(
      area: analysis.area,
      businessQuery: analysis.businessCategory,
    );
    return params.isEmpty ? null : params;
  }

  static SearchRouteParameters? _forVisa(SearchAnalysis analysis) {
    if (!_intentMatches(analysis.intent, {SearchIntent.visaQuestion})) {
      return null;
    }
    if (analysis.visaTopic == null || analysis.visaTopic!.isEmpty) {
      return null;
    }
    return SearchRouteParameters(visaTopic: analysis.visaTopic);
  }

  static bool _intentMatches(SearchIntent intent, Set<SearchIntent> allowed) {
    return allowed.contains(intent);
  }
}
