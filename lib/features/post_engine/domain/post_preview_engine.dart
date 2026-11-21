import 'package:raabta/features/post_engine/domain/models/post_schema_models.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';

/// Builds a human-readable preview from schema field values.
class PostPreviewEngine {
  const PostPreviewEngine();

  Map<String, String> buildPreviewRows({
    required PostCategoryFieldSchema schema,
    required Map<String, dynamic> values,
    required String locale,
  }) {
    final rows = <String, String>{};
    for (final field in schema.visibleFields(values)) {
      final raw = values[field.id];
      if (raw == null) continue;
      final label = PostEngineStrings.t(field.labelKey, locale);
      rows[label] = _formatValue(field, raw, locale);
    }
    return rows;
  }

  String _formatValue(PostFieldSchema field, dynamic value, String locale) {
    switch (field.type) {
      case PostFieldType.currency:
        return '$value QAR';
      case PostFieldType.singleSelect:
        if (value is String && field.allowedValueKeys.contains(value)) {
          return PostEngineStrings.t(value, locale);
        }
        return value.toString();
      case PostFieldType.multiSelect:
        if (value is List) {
          return value.map((e) => e.toString()).join(', ');
        }
        return value.toString();
      case PostFieldType.photo:
        if (value is List) return '${value.length} photo(s)';
        return '1 photo';
      default:
        return value.toString();
    }
  }
}
