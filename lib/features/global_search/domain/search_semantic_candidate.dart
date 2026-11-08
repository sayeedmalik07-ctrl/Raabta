import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/search_semantic_document.dart';

/// Semantic retrieval hit — no routes or navigation (S12).
class SearchSemanticCandidate {
  const SearchSemanticCandidate({
    required this.resultId,
    required this.category,
    required this.semanticSimilarity,
    required this.sourceType,
    required this.sourceId,
    required this.title,
    required this.subtitle,
    this.documentId,
    this.listingLatitude,
    this.listingLongitude,
  });

  final String resultId;
  final GlobalSearchCategory category;
  final double semanticSimilarity;
  final SearchSemanticSourceType sourceType;
  final String sourceId;
  final String title;
  final String subtitle;
  final String? documentId;
  final double? listingLatitude;
  final double? listingLongitude;

  static SearchSemanticCandidate? validated({
    required String resultId,
    required GlobalSearchCategory category,
    required double semanticSimilarity,
    required SearchSemanticSourceType sourceType,
    required String sourceId,
    required String title,
    required String subtitle,
    required double minimumSimilarity,
    required double maximumSimilarity,
    String? documentId,
    double? listingLatitude,
    double? listingLongitude,
  }) {
    if (resultId.trim().isEmpty || sourceId.trim().isEmpty) return null;
    if (!semanticSimilarity.isFinite) return null;
    if (semanticSimilarity < minimumSimilarity ||
        semanticSimilarity > maximumSimilarity) {
      return null;
    }
    return SearchSemanticCandidate(
      resultId: resultId,
      category: category,
      semanticSimilarity: semanticSimilarity,
      sourceType: sourceType,
      sourceId: sourceId,
      title: title.trim(),
      subtitle: subtitle.trim(),
      documentId: documentId,
      listingLatitude: listingLatitude,
      listingLongitude: listingLongitude,
    );
  }
}
