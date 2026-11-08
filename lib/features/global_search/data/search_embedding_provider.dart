import 'package:raabta/features/global_search/domain/search_embedding.dart';
import 'package:raabta/features/global_search/domain/search_semantic_document.dart';
import 'package:raabta/features/global_search/domain/search_semantic_query.dart';

/// Provider-agnostic embedding generation (S12).
abstract class SearchEmbeddingProvider {
  Future<SearchEmbedding?> embedQuery(SearchSemanticQuery query);

  Future<SearchEmbedding?> embedDocument(SearchSemanticDocument document);
}
