import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/post_engine/data/post_schema_local_cache.dart';
import 'package:raabta/features/post_engine/domain/models/post_schema_models.dart';
import 'package:raabta/services/firebase_service.dart';

class PostSchemaFirestoreRepository {
  PostSchemaFirestoreRepository({
    FirebaseFirestore? firestore,
    PostSchemaLocalCache? cache,
  })  : _firestore = firestore ??
            (FirebaseService.isReady ? FirebaseFirestore.instance : null),
        _cache = cache ?? PostSchemaLocalCache.instance;

  static const collection = 'post_schemas';

  final FirebaseFirestore? _firestore;
  final PostSchemaLocalCache _cache;

  CollectionReference<Map<String, dynamic>>? get _ref =>
      _firestore?.collection(collection);

  /// Cache-first load; refreshes from Firestore when online and stale/missing.
  Future<PostVerticalSchema> fetchVerticalSchema(
    String verticalId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = _cache.load(verticalId);
      if (cached != null && _firestore == null) {
        return cached;
      }
      if (cached != null && _cache.isFresh(verticalId)) {
        final ref = _ref;
        if (ref != null) {
          try {
            final snap = await ref.doc(verticalId).get(
                  const GetOptions(source: Source.server),
                );
            if (snap.exists && snap.data() != null) {
              final remoteVersion =
                  (snap.data()!['version'] as num?)?.toInt() ?? 1;
              if (remoteVersion <= cached.version) {
                return cached;
              }
            } else {
              return cached;
            }
          } catch (_) {
            return cached;
          }
        } else {
          return cached;
        }
      }
    }

    final ref = _ref;
    if (ref == null) {
      final cached = _cache.load(verticalId);
      if (cached != null) return cached;
      throw PostSchemaLoadException(
        'No schema available offline for $verticalId',
        kind: PostSchemaLoadExceptionKind.offlineNoCache,
      );
    }

    try {
      final snap = await ref.doc(verticalId).get();
      if (!snap.exists || snap.data() == null) {
        final cached = _cache.load(verticalId);
        if (cached != null) return cached;
        throw PostSchemaLoadException(
          'Schema not found for $verticalId',
          kind: PostSchemaLoadExceptionKind.notFound,
        );
      }

      final schema = PostVerticalSchema.fromJson({
        ...snap.data()!,
        'verticalId': verticalId,
      });
      await _cache.save(schema);
      return schema;
    } on PostSchemaLoadException {
      rethrow;
    } catch (e) {
      final cached = _cache.load(verticalId);
      if (cached != null) return cached;
      throw PostSchemaLoadException(
        'Failed to load schema: $e',
        kind: PostSchemaLoadExceptionKind.network,
      );
    }
  }

  Stream<PostVerticalSchema?> watchVerticalSchema(String verticalId) {
    final ref = _ref;
    if (ref == null) {
      return Stream.value(_cache.load(verticalId));
    }

    return ref.doc(verticalId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) {
        return _cache.load(verticalId);
      }
      final schema = PostVerticalSchema.fromJson({
        ...snap.data()!,
        'verticalId': verticalId,
      });
      _cache.save(schema);
      return schema;
    });
  }

  Future<void> upsertVerticalSchema(PostVerticalSchema schema) async {
    final ref = _ref;
    if (ref == null) {
      throw StateError('Firestore not ready');
    }
    await ref.doc(schema.verticalId).set(schema.toJson(), SetOptions(merge: true));
    await _cache.save(schema);
  }
}

enum PostSchemaLoadExceptionKind {
  offlineNoCache,
  notFound,
  network,
}

class PostSchemaLoadException implements Exception {
  PostSchemaLoadException(this.message, {required this.kind});
  final String message;
  final PostSchemaLoadExceptionKind kind;

  @override
  String toString() => message;
}
