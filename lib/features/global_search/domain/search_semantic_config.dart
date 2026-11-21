import 'package:flutter/foundation.dart';

/// Controlled semantic search settings (S12).
class SearchSemanticConfig {
  const SearchSemanticConfig({
    this.enabled = false,
    this.maxQueryEmbeddingCalls = 1,
    this.maxCandidates = 12,
    this.minimumSimilarity = 0.70,
    this.maximumSimilarity = 1.0,
    this.maxSemanticBonus = 12,
    this.queryCacheTtlSeconds = 300,
    this.embeddingVersion = 1,
    this.expectedDimensions = 64,
    this.embeddingModel = 'raabta-deterministic-v1',
    this.requestTimeoutSeconds = 10,
  });

  final bool enabled;
  final int maxQueryEmbeddingCalls;
  final int maxCandidates;
  final double minimumSimilarity;
  final double maximumSimilarity;
  final int maxSemanticBonus;
  final int queryCacheTtlSeconds;
  final int embeddingVersion;
  final int expectedDimensions;
  final String embeddingModel;
  final int requestTimeoutSeconds;

  /// Production default — semantic retrieval disabled until backend is ready.
  static const production = SearchSemanticConfig(enabled: false);
}

/// Runtime feature flag override (tests / staged rollout).
abstract final class SearchSemanticFeatureFlag {
  static bool? overrideEnabled;

  static bool isEnabled(SearchSemanticConfig config) {
    return overrideEnabled ?? config.enabled;
  }

  @visibleForTesting
  static void resetForTests() => overrideEnabled = null;
}
