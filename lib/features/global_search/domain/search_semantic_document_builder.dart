import 'package:raabta/features/global_search/domain/search_semantic_document.dart';

/// Builds public semantic documents from listing data (S12).
abstract final class SearchSemanticDocumentBuilder {
  static SearchSemanticDocument serviceListing({
    required String id,
    required String title,
    required String category,
    required String description,
    String area = '',
    double? latitude,
    double? longitude,
    int embeddingVersion = 1,
    int embeddingDimensions = 64,
    String embeddingModel = 'raabta-deterministic-v1',
  }) {
    final searchText = _join([title, category, description, area]);
    return SearchSemanticDocument(
      id: 'semantic_service_$id',
      category: 'services',
      title: title,
      subtitle: category,
      searchText: searchText,
      sourceType: SearchSemanticSourceType.serviceListing,
      sourceId: id,
      embeddingVersion: embeddingVersion,
      embeddingModel: embeddingModel,
      embeddingDimensions: embeddingDimensions,
      contentHash: searchText.hashCode.toString(),
      listingLatitude: latitude,
      listingLongitude: longitude,
    );
  }

  static SearchSemanticDocument job({
    required String id,
    required String title,
    required String company,
    required String location,
    String category = '',
    int embeddingVersion = 1,
    int embeddingDimensions = 64,
    String embeddingModel = 'raabta-deterministic-v1',
  }) {
    final searchText = _join([title, company, location, category]);
    return SearchSemanticDocument(
      id: 'semantic_job_$id',
      category: 'jobs',
      title: title,
      subtitle: '$company · $location',
      searchText: searchText,
      sourceType: SearchSemanticSourceType.job,
      sourceId: id,
      embeddingVersion: embeddingVersion,
      embeddingModel: embeddingModel,
      embeddingDimensions: embeddingDimensions,
      contentHash: searchText.hashCode.toString(),
    );
  }

  static SearchSemanticDocument housing({
    required String id,
    required String title,
    required String area,
    required String type,
    String description = '',
    int embeddingVersion = 1,
    int embeddingDimensions = 64,
    String embeddingModel = 'raabta-deterministic-v1',
  }) {
    final searchText = _join([title, area, type, description]);
    return SearchSemanticDocument(
      id: 'semantic_housing_$id',
      category: 'housing',
      title: title,
      subtitle: '$area · $type',
      searchText: searchText,
      sourceType: SearchSemanticSourceType.housing,
      sourceId: id,
      embeddingVersion: embeddingVersion,
      embeddingModel: embeddingModel,
      embeddingDimensions: embeddingDimensions,
      contentHash: searchText.hashCode.toString(),
    );
  }

  static SearchSemanticDocument business({
    required String id,
    required String name,
    required String category,
    required String location,
    int embeddingVersion = 1,
    int embeddingDimensions = 64,
    String embeddingModel = 'raabta-deterministic-v1',
  }) {
    final searchText = _join([name, category, location]);
    return SearchSemanticDocument(
      id: 'semantic_business_$id',
      category: 'business',
      title: name,
      subtitle: '$category · $location',
      searchText: searchText,
      sourceType: SearchSemanticSourceType.business,
      sourceId: id,
      embeddingVersion: embeddingVersion,
      embeddingModel: embeddingModel,
      embeddingDimensions: embeddingDimensions,
      contentHash: searchText.hashCode.toString(),
    );
  }

  static String _join(List<String> parts) {
    return parts
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .join(' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
