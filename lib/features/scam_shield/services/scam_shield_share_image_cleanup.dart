import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Best-effort deletion of ScamShield-owned share image copies only.
abstract final class ScamShieldShareImageCleanup {
  static const _shareSubdir = 'scam_shield_share';
  static const ownedFileNamePrefix = 'share_';
  static const defaultStaleMinAge = Duration(days: 7);

  static Directory? _ownedRootOverride;

  /// Text is authoritative when both text and image are shared — OCR is skipped.
  static bool shouldPurgeWithoutOcr({
    required bool hasText,
    required bool hasImage,
  }) =>
      hasText && hasImage;

  @visibleForTesting
  static void setOwnedRootForTest(Directory? root) {
    _ownedRootOverride = root;
  }

  static Future<Directory> ownedTempRoot() async {
    if (_ownedRootOverride != null) {
      return _ownedRootOverride!;
    }
    final base = await getTemporaryDirectory();
    final root = Directory(
      '${base.path}${Platform.pathSeparator}$_shareSubdir',
    );
    if (!await root.exists()) {
      await root.create(recursive: true);
    }
    return root;
  }

  /// Copies an OS share attachment into an app-owned temp file for safe cleanup.
  static Future<String?> adoptShareImage(String? sourcePath) async {
    if (sourcePath == null || sourcePath.trim().isEmpty) return null;
    final source = File(sourcePath);
    if (!await source.exists()) return null;

    try {
      final root = await ownedTempRoot();
      final ext = _fileExtension(sourcePath);
      final destPath =
          '${root.path}${Platform.pathSeparator}share_${DateTime.now().microsecondsSinceEpoch}$ext';
      await source.copy(destPath);
      return destPath;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> isOwnedShareFile(String path) async {
    try {
      final root = await ownedTempRoot();
      final rootPath = await _canonicalPath(root.path);
      final filePath = await _canonicalPath(path);
      if (rootPath == null || filePath == null) return false;
      return _isPathUnderRoot(filePath, rootPath);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> bestEffortDeleteOwnedFile(String path) async {
    if (!await isOwnedShareFile(path)) return false;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (_) {
      // Best-effort only.
    }
    return false;
  }

  /// Deletes stale files under the share temp root only (prefix [ownedFileNamePrefix]).
  static Future<int> purgeStaleOwnedFiles({
    Duration minAge = defaultStaleMinAge,
    DateTime? now,
  }) async {
    final clock = now ?? DateTime.now();
    var deleted = 0;
    try {
      final root = await ownedTempRoot();
      if (!await root.exists()) return 0;

      await for (final entity in root.list(followLinks: false)) {
        if (entity is! File) continue;
        final name = entity.uri.pathSegments.isNotEmpty
            ? entity.uri.pathSegments.last
            : entity.path.split(Platform.pathSeparator).last;
        if (!name.startsWith(ownedFileNamePrefix)) continue;
        if (!await isOwnedShareFile(entity.path)) continue;

        final modified = await entity.lastModified();
        if (clock.difference(modified) < minAge) continue;

        if (await bestEffortDeleteOwnedFile(entity.path)) {
          deleted++;
        }
      }
    } catch (_) {
      // Best-effort only.
    }
    return deleted;
  }

  @visibleForTesting
  static bool isPathUnderRootForTest(String filePath, String rootPath) {
    return _isPathUnderRoot(
      File(filePath).absolute.path,
      Directory(rootPath).absolute.path,
    );
  }

  static String _fileExtension(String path) {
    final dot = path.lastIndexOf('.');
    if (dot <= 0 || dot >= path.length - 1) return '';
    return path.substring(dot);
  }

  static Future<String?> _canonicalPath(String path) async {
    final entityType = FileSystemEntity.typeSync(path);
    if (entityType == FileSystemEntityType.notFound) {
      return null;
    }
    try {
      if (entityType == FileSystemEntityType.directory) {
        return Directory(path).resolveSymbolicLinksSync();
      }
      return File(path).resolveSymbolicLinksSync();
    } catch (_) {
      return File(path).absolute.path;
    }
  }

  static bool _isPathUnderRoot(String filePath, String rootPath) {
    final file = File(filePath).absolute.path;
    final root = Directory(rootPath).absolute.path;
    if (file == root) return false;
    final prefix =
        root.endsWith(Platform.pathSeparator) ? root : '$root${Platform.pathSeparator}';
    return file.startsWith(prefix);
  }
}
