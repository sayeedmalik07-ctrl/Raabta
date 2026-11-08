import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raabta/features/post_engine/domain/models/post_publish_models.dart';
import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';
import 'package:raabta/features/post_engine/domain/post_schema_value_coercion.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:raabta/services/housing_firestore_service.dart';
import 'package:raabta/services/marketplace_firestore_service.dart';
import 'package:raabta/data/repositories/businesses_repository.dart';
import 'package:raabta/screens/services/data/service_listings_repository.dart';

enum PostPhotoPickSource { gallery, camera }

class PostPhotoUploadResult {
  const PostPhotoUploadResult({
    required this.photoUrls,
    required this.uploadedIndexes,
  });

  final List<String> photoUrls;
  final List<int> uploadedIndexes;
}

/// Smart media — reuses existing vertical Storage upload paths (no duplicate OCR).
class PostMediaEngine {
  PostMediaEngine({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;
  MarketplaceFirestoreService? _marketplace;
  HousingFirestoreService? _housing;
  ServiceListingsRepository? _services;
  BusinessesRepository? _businesses;

  /// Shows gallery/camera chooser then returns picked local files.
  Future<List<File>> pickPhotosWithSource({
    required BuildContext context,
    int maxCount = 10,
  }) async {
    final source = await showModalBottomSheet<PostPhotoPickSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PhotoSourceSheet(maxCount: maxCount),
    );
    if (source == null) return const [];
    return pickPhotos(maxCount: maxCount, source: source);
  }

  Future<List<File>> pickPhotos({
    int maxCount = 10,
    PostPhotoPickSource source = PostPhotoPickSource.gallery,
  }) async {
    try {
      if (source == PostPhotoPickSource.camera) {
        final picked = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
        if (picked == null) return const [];
        return [File(picked.path)];
      }

      final picked = await _picker.pickMultiImage(imageQuality: 85);
      if (picked.isNotEmpty) {
        return picked.take(maxCount).map((x) => File(x.path)).toList();
      }

      // Some platforms/simulators only support single-image pick.
      final single = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (single == null) return const [];
      return [File(single.path)];
    } catch (e) {
      debugPrint('PostMediaEngine.pickPhotos failed: $e');
      rethrow;
    }
  }

  Future<File?> pickSinglePhoto() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return null;
    return File(picked.path);
  }

  /// Category-aware photo tips (Phase 11 recommendations).
  List<String> photoRecommendations({
    required PostVertical vertical,
    required String categoryPath,
  }) {
    if (vertical == PostVertical.marketplace) {
      if (categoryPath.contains('vehicles') || categoryPath.contains('cars')) {
        return const [
          'Add rear, interior, and dashboard photos for vehicle listings',
        ];
      }
      if (categoryPath.contains('mobiles') || categoryPath.contains('electronics')) {
        return const ['Add front, back, and screen-on photos'];
      }
    }
    if (vertical == PostVertical.housing) {
      return const [
        'Add kitchen and bathroom photos to improve your listing',
      ];
    }
    return const [];
  }

  /// Legacy upload — uploads all available local paths in order (tests may stub).
  Future<List<String>> uploadPhotos({
    required PostVertical vertical,
    required String listingId,
    required List<String> localPaths,
    required String ownerUserId,
  }) async {
    final slotCount = vertical == PostVertical.services
        ? (localPaths.isEmpty ? 0 : 1)
        : localPaths.length;
    final result = await uploadPhotosForPublish(
      vertical: vertical,
      listingId: listingId,
      localPaths: localPaths,
      ownerUserId: ownerUserId,
      slotCount: slotCount,
      minRequired: 0,
    );
    return result.photoUrls;
  }

  /// Deterministic indexed uploads for idempotent publish/resume.
  Future<PostPhotoUploadResult> uploadPhotosForPublish({
    required PostVertical vertical,
    required String listingId,
    required List<String> localPaths,
    required String ownerUserId,
    required int slotCount,
    List<String> existingAttachedUrls = const [],
    int minRequired = 0,
  }) async {
    if (vertical == PostVertical.jobs) {
      return const PostPhotoUploadResult(
        photoUrls: [],
        uploadedIndexes: [],
      );
    }

    final effectiveSlots = vertical == PostVertical.services
        ? (slotCount > 0 ? 1 : 0)
        : slotCount;
    final slotUrls = List<String?>.filled(effectiveSlots, null);
    final uploadedIndexes = <int>[];
    var needsFirebaseUpload = false;

    for (var i = 0; i < effectiveSlots; i++) {
      if (i < existingAttachedUrls.length &&
          existingAttachedUrls[i].startsWith('http')) {
        slotUrls[i] = existingAttachedUrls[i];
        continue;
      }

      final path = i < localPaths.length ? localPaths[i] : null;
      if (path == null || path.isEmpty) {
        if (i < minRequired) {
          throw PostPublishMediaException(
            'Required photo at slot $i is unavailable locally',
            missingPhotoIndex: i,
          );
        }
        continue;
      }

      if (path.startsWith('http')) {
        slotUrls[i] = path;
        continue;
      }

      final file = File(path);
      if (!file.existsSync()) {
        if (i < minRequired) {
          throw PostPublishMediaException(
            'Required photo at slot $i is unavailable locally',
            missingPhotoIndex: i,
          );
        }
        continue;
      }
      needsFirebaseUpload = true;
    }

    if (needsFirebaseUpload && !FirebaseService.isReady) {
      throw StateError('Firebase is not ready');
    }

    for (var i = 0; i < effectiveSlots; i++) {
      if (slotUrls[i] != null) continue;
      final path = localPaths[i];
      final file = File(path);
      if (!file.existsSync()) continue;
      slotUrls[i] = await _uploadOne(
        vertical: vertical,
        listingId: listingId,
        ownerUserId: ownerUserId,
        file: file,
        photoIndex: i,
      );
      uploadedIndexes.add(i);
    }

    final photoUrls = <String>[];
    for (final url in slotUrls) {
      if (url != null && url.isNotEmpty) {
        photoUrls.add(url);
      }
    }

    if (minRequired > 0 && photoUrls.length < minRequired) {
      throw PostPublishMediaException(
        'At least $minRequired photo(s) required but only ${photoUrls.length} available',
      );
    }

    return PostPhotoUploadResult(
      photoUrls: photoUrls,
      uploadedIndexes: uploadedIndexes,
    );
  }

  Future<String> _uploadOne({
    required PostVertical vertical,
    required String listingId,
    required String ownerUserId,
    required File file,
    required int photoIndex,
  }) async {
    switch (vertical) {
      case PostVertical.marketplace:
        _marketplace ??= MarketplaceFirestoreService();
        return _marketplace!.uploadPhoto(
          file,
          listingId: listingId,
          photoIndex: photoIndex,
        );
      case PostVertical.housing:
        _housing ??= HousingFirestoreService();
        return _housing!.uploadPhoto(
          file,
          listingId: listingId,
          photoIndex: photoIndex,
        );
      case PostVertical.services:
        _services ??= ServiceListingsRepository();
        return _services!.uploadListingPhoto(
          file: file,
          uid: ownerUserId,
          listingId: listingId,
          photoIndex: photoIndex,
        );
      case PostVertical.business:
        _businesses ??= BusinessesRepository();
        return _businesses!.uploadPhoto(
          file,
          businessId: listingId,
          photoIndex: photoIndex,
        );
      case PostVertical.jobs:
        return '';
    }
  }

  /// Normalizes field value: local paths stay local until publish uploads them.
  static List<String> normalizePhotoPaths(dynamic raw) {
    return PostSchemaValueCoercion.asStringList(
      PostSchemaValueCoercion.extractPhotoRaw(raw),
    );
  }

  static String? currentUserId() => FirebaseAuth.instance.currentUser?.uid;
}

class _PhotoSourceSheet extends StatelessWidget {
  const _PhotoSourceSheet({required this.maxCount});

  final int maxCount;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(maxCount > 1 ? 'Choose from gallery' : 'Choose photo'),
              onTap: () => Navigator.pop(context, PostPhotoPickSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, PostPhotoPickSource.camera),
            ),
          ],
        ),
      ),
    );
  }
}
