/// Source type for semantic index documents (S12).
enum SearchSemanticSourceType {
  serviceListing,
  job,
  housing,
  business,
}

/// Public searchable content document for semantic indexing (S12).
class SearchSemanticDocument {
  const SearchSemanticDocument({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.searchText,
    required this.sourceType,
    required this.sourceId,
    required this.embeddingVersion,
    required this.embeddingModel,
    required this.embeddingDimensions,
    this.isActive = true,
    this.contentHash = '',
    this.listingLatitude,
    this.listingLongitude,
  });

  final String id;
  final String category;
  final String title;
  final String subtitle;
  final String searchText;
  final SearchSemanticSourceType sourceType;
  final String sourceId;
  final int embeddingVersion;
  final String embeddingModel;
  final int embeddingDimensions;
  final bool isActive;
  final String contentHash;
  final double? listingLatitude;
  final double? listingLongitude;
}
