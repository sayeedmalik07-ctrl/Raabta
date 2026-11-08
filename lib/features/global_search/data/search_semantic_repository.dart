import 'package:raabta/features/global_search/domain/search_embedding.dart';
import 'package:raabta/features/global_search/domain/search_semantic_candidate.dart';

/// Filters for semantic retrieval (S12).
class SearchSemanticFilters {
  const SearchSemanticFilters({
    this.categories,
    this.embeddingVersion,
  });

  final Set<String>? categories;
  final int? embeddingVersion;
}

/// Provider-agnostic semantic vector retrieval (S12).
abstract class SearchSemanticRepository {
  Future<List<SearchSemanticCandidate>> search({
    required SearchEmbedding queryEmbedding,
    SearchSemanticFilters? filters,
    required int limit,
    required double minimumSimilarity,
    required double maximumSimilarity,
  });
}
