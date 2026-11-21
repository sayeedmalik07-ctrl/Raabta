import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/post_engine/data/post_schema_firestore_repository.dart';
import 'package:raabta/features/post_engine/domain/models/post_schema_models.dart';
import 'package:raabta/features/post_engine/domain/post_engine.dart';
import 'package:raabta/features/post_engine/domain/post_schema_engine.dart';

final postEngineProvider = Provider<PostEngine>((ref) => PostEngine());

final postSchemaEngineProvider = Provider<PostSchemaEngine>((ref) {
  return ref.watch(postEngineProvider).schema;
});

final postSchemaRepositoryProvider = Provider<PostSchemaFirestoreRepository>((ref) {
  return PostSchemaFirestoreRepository();
});

final postVerticalSchemaProvider = FutureProvider.autoDispose
    .family<PostVerticalSchema, PostVertical>((ref, vertical) async {
  final engine = ref.watch(postSchemaEngineProvider);
  return engine.loadVerticalSchema(vertical);
});

final postCategoryFieldSchemaProvider = FutureProvider.autoDispose.family<
    PostCategoryFieldSchema,
    ({
      PostVertical vertical,
      String categoryPath,
      bool forServiceRequest,
    })>((ref, args) async {
  final engine = ref.watch(postSchemaEngineProvider);
  return engine.resolveCategoryFields(
    vertical: args.vertical,
    categoryPath: args.categoryPath,
    forServiceRequest: args.forServiceRequest,
  );
});
