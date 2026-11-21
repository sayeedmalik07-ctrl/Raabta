import 'package:raabta/features/post_engine/domain/models/post_schema_models.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';

class PostQualityItem {
  const PostQualityItem({
    required this.id,
    required this.labelKey,
    required this.complete,
    this.weight = 1,
  });

  final String id;
  final String labelKey;
  final bool complete;
  final int weight;
}

class PostQualityScore {
  const PostQualityScore({
    required this.percent,
    required this.items,
    required this.missingMessages,
    required this.canPublish,
  });

  final int percent;
  final List<PostQualityItem> items;
  final List<String> missingMessages;
  final bool canPublish;
}

/// Computes listing completeness from schema + field values.
class PostQualityEngine {
  const PostQualityEngine();

  PostQualityScore evaluate({
    required PostCategoryFieldSchema schema,
    required Map<String, dynamic> values,
    required String locale,
    List<String> photoRecommendations = const [],
  }) {
    final items = <PostQualityItem>[];
    var earned = 0;
    var total = 0;

    final visible = schema.visibleFields(values);

    for (final field in visible) {
      final complete = _isComplete(field, values);
      final weight = field.required ? 2 : 1;
      total += weight;
      if (complete) earned += weight;
      items.add(
        PostQualityItem(
          id: field.id,
          labelKey: field.labelKey,
          complete: complete,
          weight: weight,
        ),
      );
    }

    final missing = <String>[];
    for (final field in visible) {
      if (!_isComplete(field, values)) {
        final label = PostEngineStrings.t(field.labelKey, locale);
        if (field.type == PostFieldType.photo) {
          final min = field.mediaRequirements?.minCount ?? 1;
          final count = _photoCount(values[field.id]);
          if (count < min) {
            missing.add(
              PostEngineStrings.format(
                'quality_missing_photos',
                locale,
                params: {
                  'needed': '${min - count}',
                  'min': '$min',
                },
              ),
            );
          } else {
            missing.add(
              PostEngineStrings.format(
                'quality_missing_field',
                locale,
                params: {'field': label},
              ),
            );
          }
        } else {
          missing.add(
            PostEngineStrings.format(
              'quality_missing_field',
              locale,
              params: {'field': label},
            ),
          );
        }
      }
    }

    if (photoRecommendations.isNotEmpty) {
      for (final tip in photoRecommendations) {
        missing.add(tip);
      }
    }

    final percent = total == 0 ? 0 : ((earned / total) * 100).round();
    final requiredComplete = visible
        .where((f) => f.required)
        .every((f) => _isComplete(f, values));

    return PostQualityScore(
      percent: percent,
      items: items,
      missingMessages: missing,
      canPublish: requiredComplete && percent >= 60,
    );
  }

  bool _isComplete(PostFieldSchema field, Map<String, dynamic> values) {
    final v = values[field.id];
    switch (field.type) {
      case PostFieldType.photo:
        final min = field.mediaRequirements?.minCount ?? (field.required ? 1 : 0);
        return _photoCount(v) >= min;
      case PostFieldType.multiSelect:
      case PostFieldType.stringList:
        return v is List && v.isNotEmpty;
      case PostFieldType.openingHours:
        return v is Map && v.isNotEmpty;
      case PostFieldType.boolean:
        return true;
      default:
        return v != null && v.toString().trim().isNotEmpty;
    }
  }

  int _photoCount(dynamic raw) {
    if (raw is List) return raw.length;
    if (raw != null && raw.toString().isNotEmpty) return 1;
    return 0;
  }
}
