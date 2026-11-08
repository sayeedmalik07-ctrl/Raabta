/// Vector embedding with validation (S12).
class SearchEmbedding {
  const SearchEmbedding({
    required this.values,
    required this.dimensions,
    required this.modelVersion,
    required this.contentHash,
    this.createdAt,
  });

  final List<double> values;
  final int dimensions;
  final String modelVersion;
  final String contentHash;
  final DateTime? createdAt;

  static SearchEmbedding? validated({
    required List<double> values,
    required int expectedDimensions,
    required String modelVersion,
    String contentHash = '',
    DateTime? createdAt,
  }) {
    if (expectedDimensions <= 0) return null;
    if (values.length != expectedDimensions) return null;
    for (final v in values) {
      if (!v.isFinite) return null;
    }
    return SearchEmbedding(
      values: List.unmodifiable(values),
      dimensions: expectedDimensions,
      modelVersion: modelVersion,
      contentHash: contentHash,
      createdAt: createdAt,
    );
  }

  bool get isValid => values.length == dimensions && dimensions > 0;
}
