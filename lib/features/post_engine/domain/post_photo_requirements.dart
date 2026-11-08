import 'dart:io';

import 'package:raabta/features/post_engine/domain/models/post_schema_models.dart';
import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';
import 'package:raabta/features/post_engine/domain/post_media_engine.dart';

/// Derives photo requirements from schema — does not invent product rules.
abstract final class PostPhotoRequirements {
  static bool verticalSupportsPhotos(PostVertical vertical) =>
      vertical != PostVertical.jobs;

  static int minPhotoCount(PostCategoryFieldSchema schema, Map<String, dynamic> values) {
    var min = 0;
    for (final field in schema.visibleFields(values)) {
      if (field.type != PostFieldType.photo) continue;
      final fieldMin = field.mediaRequirements?.minCount ?? 0;
      final required = field.required ||
          field.validationRules.contains('required') ||
          field.validationRules.contains('min_photos');
      if (required) {
        min = min < 1 ? 1 : min;
      }
      if (fieldMin > min) min = fieldMin;
    }
    return min;
  }

  static bool requiresPhotos(PostCategoryFieldSchema schema, Map<String, dynamic> values) =>
      minPhotoCount(schema, values) > 0;

  static int resolvedPhotoSlotCount({
    required PostVertical vertical,
    required PostCategoryFieldSchema schema,
    required Map<String, dynamic> values,
  }) {
    if (!verticalSupportsPhotos(vertical)) return 0;
    final paths = PostMediaEngine.normalizePhotoPaths(values['photos']);
    if (paths.isEmpty) return 0;
    if (vertical == PostVertical.services) return 1;
    return paths.length;
  }

  static int countAvailableLocalPhotos(List<String> paths) {
    var count = 0;
    for (final path in paths) {
      if (path.startsWith('http')) {
        count++;
        continue;
      }
      if (File(path).existsSync()) count++;
    }
    return count;
  }
}
