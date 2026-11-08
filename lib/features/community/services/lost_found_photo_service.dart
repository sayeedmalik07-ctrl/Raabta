import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:raabta/services/firebase_service.dart';

class LostFoundPhotoUploadResult {
  const LostFoundPhotoUploadResult({
    required this.downloadUrl,
    required this.storagePath,
  });

  final String downloadUrl;
  final String storagePath;
}

/// Compresses and uploads a single Lost & Found listing photo (Part A).
class LostFoundPhotoService {
  LostFoundPhotoService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  static const int maxEdgePx = 1600;
  static const int jpegQuality = 82;
  static const int maxCompressedBytes = 1536 * 1024;

  static const allowedExtensions = {'.jpg', '.jpeg', '.png', '.webp'};

  @visibleForTesting
  static Uint8List compressBytes(Uint8List input) {
    final decoded = img.decodeImage(input);
    if (decoded == null) {
      throw LostFoundPhotoException('unsupported_image');
    }

    img.Image working = decoded;
    final longest = working.width > working.height ? working.width : working.height;
    if (longest > maxEdgePx) {
      if (working.width >= working.height) {
        working = img.copyResize(working, width: maxEdgePx);
      } else {
        working = img.copyResize(working, height: maxEdgePx);
      }
    }

    var quality = jpegQuality;
    Uint8List out = Uint8List.fromList(img.encodeJpg(working, quality: quality));
    while (out.length > maxCompressedBytes && quality > 55) {
      quality -= 5;
      out = Uint8List.fromList(img.encodeJpg(working, quality: quality));
    }
    if (out.length > maxCompressedBytes) {
      throw LostFoundPhotoException('image_too_large');
    }
    return out;
  }

  static String extensionForPath(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1) return '.jpg';
    final ext = path.substring(dot).toLowerCase();
    return allowedExtensions.contains(ext) ? ext : '.jpg';
  }

  Future<LostFoundPhotoUploadResult> uploadListingPhoto({
    required String ownerUserId,
    required File file,
  }) async {
    if (!FirebaseService.isReady) {
      throw LostFoundPhotoException('storage_unavailable');
    }
    if (ownerUserId.isEmpty) {
      throw LostFoundPhotoException('auth_required');
    }

    final ext = extensionForPath(file.path);
    if (!allowedExtensions.contains(ext)) {
      throw LostFoundPhotoException('unsupported_image');
    }

    final bytes = await file.readAsBytes();
    final compressed = compressBytes(bytes);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';
    final storagePath = 'lost_and_found_photos/$ownerUserId/$fileName';
    final ref = _storage.ref().child(storagePath);

    await ref.putData(
      compressed,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final url = await ref.getDownloadURL();
    return LostFoundPhotoUploadResult(
      downloadUrl: url,
      storagePath: storagePath,
    );
  }

  Future<void> deleteUploadedPhoto(String storagePath) async {
    if (!FirebaseService.isReady || storagePath.isEmpty) return;
    try {
      await _storage.ref().child(storagePath).delete();
    } catch (_) {
      // Best-effort orphan cleanup only.
    }
  }
}

class LostFoundPhotoException implements Exception {
  LostFoundPhotoException(this.code);
  final String code;
}
