/// Sanitized query payload for embedding (S12).
class SearchSemanticQuery {
  const SearchSemanticQuery({
    required this.sanitizedText,
    required this.embeddingVersion,
    required this.expectedDimensions,
    required this.modelVersion,
  });

  final String sanitizedText;
  final int embeddingVersion;
  final int expectedDimensions;
  final String modelVersion;

  bool get isEligibleForEmbedding {
    final trimmed = sanitizedText.trim();
    if (trimmed.length < 2) return false;
    return true;
  }

  String get cacheKey =>
      '$embeddingVersion|$expectedDimensions|$modelVersion|${sanitizedText.trim().toLowerCase()}';
}
