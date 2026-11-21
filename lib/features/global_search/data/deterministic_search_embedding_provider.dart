import 'dart:math' as math;

import 'package:raabta/features/global_search/data/search_embedding_provider.dart';
import 'package:raabta/features/global_search/domain/search_embedding.dart';
import 'package:raabta/features/global_search/domain/search_semantic_document.dart';
import 'package:raabta/features/global_search/domain/search_semantic_query.dart';

/// Deterministic hash-based embeddings for tests and local development only (S12).
class DeterministicSearchEmbeddingProvider implements SearchEmbeddingProvider {
  DeterministicSearchEmbeddingProvider({
    this.modelVersion = 'raabta-deterministic-v1',
  });

  final String modelVersion;

  @override
  Future<SearchEmbedding?> embedQuery(SearchSemanticQuery query) async {
    if (!query.isEligibleForEmbedding) return null;
    return _buildEmbedding(
      query.sanitizedText,
      query.expectedDimensions,
      query.sanitizedText,
    );
  }

  @override
  Future<SearchEmbedding?> embedDocument(SearchSemanticDocument document) async {
    if (document.searchText.trim().isEmpty) return null;
    return _buildEmbedding(
      document.searchText,
      document.embeddingDimensions,
      document.contentHash.isNotEmpty
          ? document.contentHash
          : document.searchText,
    );
  }

  SearchEmbedding? _buildEmbedding(
    String text,
    int dimensions,
    String contentHash,
  ) {
    if (dimensions <= 0) return null;
    final vec = List<double>.filled(dimensions, 0);
    final tokens = text.toLowerCase().split(RegExp(r'\s+'));
    for (var i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      if (token.isEmpty) continue;
      final bucket = token.hashCode.abs() % dimensions;
      vec[bucket] += (token.hashCode.abs() % 997) / 997.0;
    }
    _normalize(vec);
    return SearchEmbedding.validated(
      values: vec,
      expectedDimensions: dimensions,
      modelVersion: modelVersion,
      contentHash: contentHash,
      createdAt: DateTime.now(),
    );
  }

  static void _normalize(List<double> vec) {
    var sumSq = 0.0;
    for (final v in vec) {
      sumSq += v * v;
    }
    if (sumSq <= 0) {
      vec[0] = 1.0;
      return;
    }
    final norm = math.sqrt(sumSq);
    for (var i = 0; i < vec.length; i++) {
      vec[i] /= norm;
    }
  }
}
