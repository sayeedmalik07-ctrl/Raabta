import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/search_analysis.dart';
import 'package:raabta/features/global_search/domain/search_hybrid_ranker.dart';
import 'package:raabta/features/global_search/domain/search_route_parameter_factory.dart';
import 'package:raabta/features/global_search/domain/search_semantic_candidate.dart';
import 'package:raabta/features/global_search/domain/search_semantic_config.dart';
import 'package:raabta/features/global_search/domain/search_semantic_document.dart';

/// Maps semantic candidates to safe FIND results via S4 route architecture (S12).
abstract final class SearchSemanticCandidateMapper {
  static GlobalSearchResultItem? toResultItem({
    required SearchSemanticCandidate candidate,
    required SearchAnalysis analysis,
    required SearchSemanticConfig config,
  }) {
    if (!_isAllowedSource(candidate.sourceType)) return null;
    if (candidate.title.trim().isEmpty) return null;

    final route = _routeFor(candidate);
    if (route == null) return null;

    final category = candidate.category;
    final routeParams = SearchRouteParameterFactory.forCategory(analysis, category);

    final baseScore = SearchHybridRanker.baseScoreForSemanticOnlyCandidate(
      candidate: candidate,
      config: config,
    );

    return GlobalSearchResultItem(
      id: candidate.resultId,
      category: category,
      title: candidate.title,
      subtitle: candidate.subtitle,
      routePath: route,
      score: baseScore,
      searchRouteParameters: routeParams,
      listingLatitude: candidate.listingLatitude,
      listingLongitude: candidate.listingLongitude,
      semanticSimilarity: candidate.semanticSimilarity,
    );
  }

  static bool _isAllowedSource(SearchSemanticSourceType type) {
    return switch (type) {
      SearchSemanticSourceType.serviceListing ||
      SearchSemanticSourceType.job ||
      SearchSemanticSourceType.housing ||
      SearchSemanticSourceType.business =>
        true,
    };
  }

  static String? _routeFor(SearchSemanticCandidate candidate) {
    final id = candidate.sourceId.trim();
    if (id.isEmpty) return null;
    if (!_isSafeId(id)) return null;

    return switch (candidate.sourceType) {
      SearchSemanticSourceType.serviceListing => '/services/listing/$id',
      SearchSemanticSourceType.job => '/jobs',
      SearchSemanticSourceType.housing => '/housing/listing/$id',
      SearchSemanticSourceType.business => '/businesses',
    };
  }

  static bool _isSafeId(String id) {
    if (id.contains('/') || id.contains('?') || id.contains('#')) return false;
    if (id.startsWith('http') || id.startsWith('//')) return false;
    return RegExp(r'^[a-zA-Z0-9_\-]+$').hasMatch(id);
  }
}
