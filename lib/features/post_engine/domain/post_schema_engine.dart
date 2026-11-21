import 'package:raabta/features/post_engine/data/post_schema_firestore_repository.dart';
import 'package:raabta/features/post_engine/domain/models/post_schema_models.dart';
import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';
import 'package:raabta/features/post_engine/domain/post_schema_resolver.dart';

/// Loads, caches, and resolves Firestore-driven post category schemas.
class PostSchemaEngine {
  PostSchemaEngine({
    PostSchemaFirestoreRepository? repository,
    PostSchemaResolver? resolver,
  })  : _repository = repository ?? PostSchemaFirestoreRepository(),
        _resolver = resolver ?? const PostSchemaResolver();

  final PostSchemaFirestoreRepository _repository;
  final PostSchemaResolver _resolver;

  Future<PostVerticalSchema> loadVerticalSchema(
    PostVertical vertical, {
    bool forceRefresh = false,
  }) {
    return _repository.fetchVerticalSchema(vertical.id, forceRefresh: forceRefresh);
  }

  Future<PostCategoryFieldSchema> resolveCategoryFields({
    required PostVertical vertical,
    required String categoryPath,
    bool forServiceRequest = false,
    bool forceRefresh = false,
  }) async {
    final schema = await loadVerticalSchema(vertical, forceRefresh: forceRefresh);
    return _resolver.resolve(
      schema: schema,
      categoryPath: categoryPath,
      vertical: vertical,
      forServiceRequest: forServiceRequest,
    );
  }

  Stream<PostVerticalSchema?> watchVerticalSchema(PostVertical vertical) {
    return _repository.watchVerticalSchema(vertical.id);
  }

  PostCategoryNode? findCategory(
    PostVerticalSchema schema,
    String categoryPath,
  ) {
    return schema.findCategoryByPath(categoryPath);
  }
}
