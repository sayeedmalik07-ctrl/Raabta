/// Deterministic price suggestion — median of recent similar listing prices.
class PostPriceSuggester {
  const PostPriceSuggester();

  PostPriceSuggestion? suggestPrice({
    required String categoryPath,
    required List<int> recentPrices,
  }) {
    if (recentPrices.isEmpty) return null;
    final sorted = [...recentPrices]..sort();
    final mid = sorted.length ~/ 2;
    final median = sorted.length.isOdd
        ? sorted[mid]
        : ((sorted[mid - 1] + sorted[mid]) / 2).round();
    return PostPriceSuggestion(
      medianQar: median,
      sampleSize: sorted.length,
      categoryPath: categoryPath,
      source: PostPriceSuggestionSource.deterministic,
    );
  }
}

enum PostPriceSuggestionSource { deterministic, aiFallback }

class PostPriceSuggestion {
  const PostPriceSuggestion({
    required this.medianQar,
    required this.sampleSize,
    required this.categoryPath,
    required this.source,
    this.minQar,
    this.maxQar,
    this.grounded = false,
  });

  final int medianQar;
  final int sampleSize;
  final String categoryPath;
  final PostPriceSuggestionSource source;
  final int? minQar;
  final int? maxQar;
  final bool grounded;

  bool get hasRange =>
      grounded && minQar != null && maxQar != null && minQar != maxQar;
}
