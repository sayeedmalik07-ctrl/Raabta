import 'package:raabta/features/global_search/domain/search_analysis.dart';
import 'package:raabta/features/global_search/domain/search_location_context.dart';
import 'package:raabta/features/global_search/domain/search_personalization_context.dart';

/// Query + deterministic analysis passed into the search orchestration layer.
class SearchContext {
  const SearchContext({
    required this.query,
    required this.analysis,
    this.location,
    this.personalization,
  });

  final String query;
  final SearchAnalysis analysis;

  /// S6 — optional device location for nearMe proximity (local only).
  final SearchLocationContext? location;

  /// S10 — optional local personalization signals (nullable / neutral by default).
  final SearchPersonalizationContext? personalization;

  String get normalizedQuery => analysis.normalizedQuery.isNotEmpty
      ? analysis.normalizedQuery
      : query.trim().toLowerCase();
}
