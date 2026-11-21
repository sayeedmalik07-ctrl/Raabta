import 'package:raabta/features/global_search/data/search_semantic_repository.dart';
import 'package:raabta/features/global_search/domain/search_embedding.dart';
import 'package:raabta/features/global_search/domain/search_semantic_candidate.dart';

/// Safe no-op repository when vector backend is unavailable (S12).
class DisabledSearchSemanticRepository implements SearchSemanticRepository {
  const DisabledSearchSemanticRepository();

  @override
  Future<List<SearchSemanticCandidate>> search({
    required SearchEmbedding queryEmbedding,
    SearchSemanticFilters? filters,
    required int limit,
    required double minimumSimilarity,
    required double maximumSimilarity,
  }) async {
    return const [];
  }
}
