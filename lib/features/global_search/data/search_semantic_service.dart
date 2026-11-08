import 'package:raabta/features/global_search/data/disabled_search_semantic_repository.dart';
import 'package:raabta/features/global_search/data/deterministic_search_embedding_provider.dart';
import 'package:raabta/features/global_search/data/search_embedding_provider.dart';
import 'package:raabta/features/global_search/data/search_semantic_embedding_cache.dart';
import 'package:raabta/features/global_search/data/search_semantic_repository.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/search_context.dart';
import 'package:raabta/features/global_search/domain/search_embedding.dart';
import 'package:raabta/features/global_search/domain/search_hybrid_merger.dart';
import 'package:raabta/features/global_search/domain/search_semantic_candidate.dart';
import 'package:raabta/features/global_search/domain/search_semantic_config.dart';
import 'package:raabta/features/global_search/domain/search_semantic_eligibility.dart';
import 'package:raabta/features/global_search/domain/search_semantic_privacy_sanitizer.dart';
import 'package:raabta/features/global_search/domain/search_semantic_query.dart';

/// Orchestrates S12 semantic candidate retrieval and hybrid merge.
class SearchSemanticService {
  SearchSemanticService({
    SearchSemanticConfig config = SearchSemanticConfig.production,
    SearchEmbeddingProvider? embeddingProvider,
    SearchSemanticRepository? repository,
    SearchSemanticEmbeddingCache? cache,
  })  : config = config,
        _embeddingProvider = embeddingProvider ??
            DeterministicSearchEmbeddingProvider(
              modelVersion: config.embeddingModel,
            ),
        _repository = repository ?? const DisabledSearchSemanticRepository(),
        _cache = cache ??
            SearchSemanticEmbeddingCache(
              ttlSeconds: config.queryCacheTtlSeconds,
            );

  final SearchSemanticConfig config;
  final SearchEmbeddingProvider _embeddingProvider;
  final SearchSemanticRepository _repository;
  final SearchSemanticEmbeddingCache _cache;

  String? _inFlightCacheKey;
  int embeddingCallsThisSearch = 0;

  Future<GlobalSearchResponse> maybeEnhance({
    required GlobalSearchResponse response,
    required SearchContext context,
    required bool isOnline,
  }) async {
    embeddingCallsThisSearch = 0;

    final findResults = _findResults(response);
    if (!SearchSemanticEligibility.shouldRun(
      config: config,
      analysis: context.analysis,
      findResults: findResults,
      isOnline: isOnline,
      fromCache: response.fromCache,
    )) {
      return response;
    }

    final sanitized = SearchSemanticPrivacySanitizer.sanitize(
      context.analysis.originalQuery,
    );
    if (sanitized == null) return response;

    final semanticQuery = SearchSemanticQuery(
      sanitizedText: sanitized,
      embeddingVersion: config.embeddingVersion,
      expectedDimensions: config.expectedDimensions,
      modelVersion: config.embeddingModel,
    );
    if (!semanticQuery.isEligibleForEmbedding) return response;

    final embedding = await _embedQueryOnce(semanticQuery);
    if (embedding == null) return response;

    List<SearchSemanticCandidate> candidates;
    try {
      candidates = await _repository
          .search(
            queryEmbedding: embedding,
            filters: SearchSemanticFilters(
              categories: SearchSemanticEligibility.categoriesForIntent(
                context.analysis,
              ),
              embeddingVersion: config.embeddingVersion,
            ),
            limit: config.maxCandidates,
            minimumSimilarity: config.minimumSimilarity,
            maximumSimilarity: config.maximumSimilarity,
          )
          .timeout(Duration(seconds: config.requestTimeoutSeconds));
    } catch (_) {
      return response;
    }

    return SearchHybridMerger.merge(
      response: response,
      candidates: candidates,
      analysis: context.analysis,
      config: config,
    );
  }

  Future<SearchEmbedding?> _embedQueryOnce(SearchSemanticQuery query) async {
    if (embeddingCallsThisSearch >= config.maxQueryEmbeddingCalls) {
      return null;
    }

    final cacheKey = query.cacheKey;
    final cached = _cache.get(
      cacheKey,
      embeddingVersion: config.embeddingVersion,
    );
    if (cached != null) return cached;

    if (_inFlightCacheKey == cacheKey) return null;
    _inFlightCacheKey = cacheKey;
    try {
      embeddingCallsThisSearch++;
      final embedding = await _embeddingProvider
          .embedQuery(query)
          .timeout(Duration(seconds: config.requestTimeoutSeconds));
      if (embedding != null &&
          embedding.dimensions == config.expectedDimensions) {
        _cache.put(
          cacheKey: cacheKey,
          embedding: embedding,
          embeddingVersion: config.embeddingVersion,
        );
      }
      return embedding;
    } catch (_) {
      return null;
    } finally {
      if (_inFlightCacheKey == cacheKey) {
        _inFlightCacheKey = null;
      }
    }
  }

  static List<GlobalSearchResultItem> _findResults(
    GlobalSearchResponse response,
  ) {
    return response.groups
        .where((g) => !g.failed)
        .expand((g) => g.items)
        .where(
          (item) =>
              !item.isAction &&
              item.resultKind == GlobalSearchResultKind.destination,
        )
        .toList();
  }
}
