import 'dart:math' as math;

import 'package:raabta/features/global_search/data/deterministic_search_embedding_provider.dart';
import 'package:raabta/features/global_search/data/search_semantic_repository.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/search_embedding.dart';
import 'package:raabta/features/global_search/domain/search_semantic_candidate.dart';
import 'package:raabta/features/global_search/domain/search_semantic_document.dart';

/// In-memory semantic index for tests and local development (S12).
class InMemorySearchSemanticRepository implements SearchSemanticRepository {
  InMemorySearchSemanticRepository({
    DeterministicSearchEmbeddingProvider? embeddingProvider,
  }) : _embeddingProvider =
            embeddingProvider ?? DeterministicSearchEmbeddingProvider();

  final DeterministicSearchEmbeddingProvider _embeddingProvider;
  final List<_IndexedDocument> _documents = [];

  Future<void> indexDocument(SearchSemanticDocument document) async {
    if (!document.isActive) return;
    final embedding = await _embeddingProvider.embedDocument(document);
    if (embedding == null) return;
    _documents.removeWhere((d) => d.document.id == document.id);
    _documents.add(_IndexedDocument(document: document, embedding: embedding));
  }

  Future<void> indexDocuments(Iterable<SearchSemanticDocument> docs) async {
    for (final doc in docs) {
      await indexDocument(doc);
    }
  }

  void clear() => _documents.clear();

  @override
  Future<List<SearchSemanticCandidate>> search({
    required SearchEmbedding queryEmbedding,
    SearchSemanticFilters? filters,
    required int limit,
    required double minimumSimilarity,
    required double maximumSimilarity,
  }) async {
    final hits = <SearchSemanticCandidate>[];
    for (final indexed in _documents) {
      final doc = indexed.document;
      if (!doc.isActive) continue;
      if (filters?.embeddingVersion != null &&
          doc.embeddingVersion != filters!.embeddingVersion) {
        continue;
      }
      if (filters?.categories != null &&
          !filters!.categories!.contains(doc.category)) {
        continue;
      }
      if (doc.embeddingDimensions != queryEmbedding.dimensions) continue;

      final similarity = SearchSemanticSimilarity.cosine(
        queryEmbedding.values,
        indexed.embedding.values,
      );
      final category = _categoryForSource(doc.sourceType);
      if (category == null) continue;

      final candidate = SearchSemanticCandidate.validated(
        resultId: _resultIdFor(doc),
        category: category,
        semanticSimilarity: similarity,
        sourceType: doc.sourceType,
        sourceId: doc.sourceId,
        title: doc.title,
        subtitle: doc.subtitle,
        minimumSimilarity: minimumSimilarity,
        maximumSimilarity: maximumSimilarity,
        documentId: doc.id,
        listingLatitude: doc.listingLatitude,
        listingLongitude: doc.listingLongitude,
      );
      if (candidate != null) hits.add(candidate);
    }

    hits.sort((a, b) => b.semanticSimilarity.compareTo(a.semanticSimilarity));
    return hits.take(limit).toList();
  }

  static String _resultIdFor(SearchSemanticDocument doc) {
    return switch (doc.sourceType) {
      SearchSemanticSourceType.serviceListing =>
        'service_listing_${doc.sourceId}',
      SearchSemanticSourceType.job => doc.sourceId,
      SearchSemanticSourceType.housing => doc.sourceId,
      SearchSemanticSourceType.business => doc.sourceId,
    };
  }

  static GlobalSearchCategory? _categoryForSource(
    SearchSemanticSourceType type,
  ) {
    return switch (type) {
      SearchSemanticSourceType.serviceListing =>
        GlobalSearchCategory.services,
      SearchSemanticSourceType.job => GlobalSearchCategory.jobs,
      SearchSemanticSourceType.housing => GlobalSearchCategory.housing,
      SearchSemanticSourceType.business => GlobalSearchCategory.businesses,
    };
  }
}

class _IndexedDocument {
  const _IndexedDocument({
    required this.document,
    required this.embedding,
  });

  final SearchSemanticDocument document;
  final SearchEmbedding embedding;
}

/// Cosine similarity between two vectors (S12).
abstract final class SearchSemanticSimilarity {
  static double cosine(List<double> a, List<double> b) {
    if (a.length != b.length || a.isEmpty) return 0;
    var dot = 0.0;
    var normA = 0.0;
    var normB = 0.0;
    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    if (normA <= 0 || normB <= 0) return 0;
    final sim = dot / (math.sqrt(normA) * math.sqrt(normB));
    if (!sim.isFinite) return 0;
    return sim.clamp(-1.0, 1.0);
  }
}
