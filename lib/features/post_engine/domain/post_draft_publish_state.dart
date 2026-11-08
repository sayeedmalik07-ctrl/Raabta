import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/post_engine/domain/models/post_publish_models.dart';

/// Publish session fields stored inside the Post Engine Hive draft payload.
abstract final class PostDraftPublishState {
  static const schemaVersion = 2;

  static const publishIdKey = '_publishId';
  static const listingIdKey = '_listingId';
  static const publishPhaseKey = '_publishPhase';
  static const uploadedPhotoIndexesKey = '_uploadedPhotoIndexes';
  static const attachedPhotoUrlsKey = '_attachedPhotoUrls';
  static const sideEffectsEmittedKey = '_publishSideEffectsEmitted';

  static const metaKeys = {
    '_vertical',
    '_categoryPath',
    '_schemaVersion',
    publishIdKey,
    listingIdKey,
    publishPhaseKey,
    uploadedPhotoIndexesKey,
    attachedPhotoUrlsKey,
    sideEffectsEmittedKey,
  };

  static String generatePublishId([FirebaseFirestore? firestore]) {
    final db = firestore ?? FirebaseFirestore.instance;
    return db.collection('marketplace_listings').doc().id;
  }

  static String? publishId(Map<String, dynamic> draft) =>
      draft[publishIdKey]?.toString();

  static String? listingId(Map<String, dynamic> draft) =>
      draft[listingIdKey]?.toString();

  static PostPublishPhase phase(Map<String, dynamic> draft) =>
      PostPublishPhase.fromStorage(draft[publishPhaseKey]?.toString());

  static bool sideEffectsEmitted(Map<String, dynamic> draft) =>
      draft[sideEffectsEmittedKey] == true;

  static List<int> uploadedPhotoIndexes(Map<String, dynamic> draft) {
    final raw = draft[uploadedPhotoIndexesKey];
    if (raw is! List) return const [];
    return raw.map((e) => int.tryParse(e.toString()) ?? -1).where((i) => i >= 0).toList();
  }

  static List<String> attachedPhotoUrls(Map<String, dynamic> draft) {
    final raw = draft[attachedPhotoUrlsKey];
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
  }

  static Map<String, dynamic> apply({
    required Map<String, dynamic> draft,
    String? publishId,
    String? listingId,
    PostPublishPhase? publishPhase,
    List<int>? uploadedPhotoIndexes,
    List<String>? attachedPhotoUrls,
    bool? sideEffectsEmitted,
    bool clearPublishSession = false,
  }) {
    final next = Map<String, dynamic>.from(draft);
    next['_schemaVersion'] = schemaVersion;

    if (clearPublishSession) {
      for (final key in [
        publishIdKey,
        listingIdKey,
        publishPhaseKey,
        uploadedPhotoIndexesKey,
        attachedPhotoUrlsKey,
        sideEffectsEmittedKey,
      ]) {
        next.remove(key);
      }
      return next;
    }

    if (publishId != null) next[publishIdKey] = publishId;
    if (listingId != null) next[listingIdKey] = listingId;
    if (publishPhase != null) next[publishPhaseKey] = publishPhase.storageValue;
    if (uploadedPhotoIndexes != null) {
      next[uploadedPhotoIndexesKey] = uploadedPhotoIndexes;
    }
    if (attachedPhotoUrls != null) {
      next[attachedPhotoUrlsKey] = attachedPhotoUrls;
    }
    if (sideEffectsEmitted != null) {
      next[sideEffectsEmittedKey] = sideEffectsEmitted;
    }
    return next;
  }

  static Map<String, dynamic> stripMeta(Map<String, dynamic> draft) {
    final next = Map<String, dynamic>.from(draft);
    for (final key in metaKeys) {
      next.remove(key);
    }
    return next;
  }
}
