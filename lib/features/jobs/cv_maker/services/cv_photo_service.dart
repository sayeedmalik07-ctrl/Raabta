import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Per-CV photo storage — reuses [ImagePicker] like Bill Tracker / Doc Scanner.
class CvPhotoService {
  final _picker = ImagePicker();

  Future<String?> pickAndSaveForCv({
    required String cvId,
    required ImageSource source,
  }) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final cvDir = Directory('${dir.path}/cv_photos');
    if (!await cvDir.exists()) await cvDir.create(recursive: true);

    final dot = picked.path.lastIndexOf('.');
    final ext = dot >= 0 ? picked.path.substring(dot) : '.jpg';
    final dest = '${cvDir.path}/$cvId$ext';
    await File(picked.path).copy(dest);
    return dest;
  }

  Future<String?> uploadToStorage({
    required String cvId,
    required String localPath,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    try {
      final ref = FirebaseStorage.instance.ref(
        'cv_photos/$uid/$cvId${localPath.contains('.') ? localPath.substring(localPath.lastIndexOf('.')) : '.jpg'}',
      );
      await ref.putFile(File(localPath));
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('[CvPhotoService] upload failed: $e');
      return null;
    }
  }

  Future<void> deleteLocal(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }
}

final cvPhotoServiceProvider = Provider((ref) => CvPhotoService());
