import 'package:raabta/features/post_engine/domain/models/post_schema_models.dart';
import 'package:raabta/features/post_engine/domain/post_schema_value_coercion.dart';
import 'package:raabta/features/post_engine/domain/post_validation_debug.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';

/// Schema-driven validation for post forms.
class PostValidationEngine {
  const PostValidationEngine();

  /// Returns map of fieldId → localized error message. Empty map = valid.
  Map<String, String> validate({
    required PostCategoryFieldSchema schema,
    required Map<String, dynamic> values,
    required String locale,
    bool debug = false,
    String? debugVertical,
    String? debugCategoryPath,
  }) {
    if (debug) {
      PostValidationDebug.logStart(
        vertical: debugVertical ?? 'unknown',
        categoryPath: debugCategoryPath ?? schema.categoryPath,
        schemaGroupId: schema.schemaGroupId,
      );
    }

    final errors = <String, String>{};
    for (final field in schema.visibleFields(values)) {
      final raw = values[field.id];
      final normalized = PostValidationDebug.normalize(field, raw);
      final error = _validateField(field, raw, normalized, locale);
      if (debug) {
        PostValidationDebug.logField(
          field: field,
          rawValue: raw,
          normalizedValue: normalized,
          locale: locale,
          error: error,
        );
      }
      if (error != null) errors[field.id] = error;
    }

    if (debug) {
      PostValidationDebug.logResult(
        isValid: errors.isEmpty,
        errors: errors,
      );
    }

    return errors;
  }

  String? _validateField(
    PostFieldSchema field,
    dynamic raw,
    dynamic normalized,
    String locale,
  ) {
    final rules = field.validationRules;
    if (field.required || rules.contains('required')) {
      if (!_hasValue(field, normalized)) {
        return _requiredMessage(field, locale);
      }
    }

    if (normalized == null) return null;

    for (final rule in rules) {
      final err = _applyRule(field, raw, normalized, rule, locale);
      if (err != null) return err;
    }
    if (field.type == PostFieldType.photo) {
      return _maxPhotosError(field, raw, locale);
    }
    return null;
  }

  String _requiredMessage(PostFieldSchema field, String locale) {
    final label = PostEngineStrings.t(field.labelKey, locale);
    switch (field.type) {
      case PostFieldType.singleSelect:
      case PostFieldType.location:
        return PostEngineStrings.format(
          'error_required_select',
          locale,
          params: {'field': label},
        );
      case PostFieldType.photo:
        return PostEngineStrings.t('error_required_photos', locale);
      default:
        return PostEngineStrings.format(
          'error_required_field',
          locale,
          params: {'field': label},
        );
    }
  }

  bool _hasValue(PostFieldSchema field, dynamic value) {
    switch (field.type) {
      case PostFieldType.photo:
        return _photoCount(value) > 0;
      case PostFieldType.multiSelect:
      case PostFieldType.stringList:
        if (value is List) return value.isNotEmpty;
        return PostSchemaValueCoercion.asStringList(value).isNotEmpty;
      case PostFieldType.openingHours:
        if (value is! Map || value.isEmpty) return false;
        return value.values.any((day) {
          if (day is! Map) return false;
          if (day['closed'] == true) return false;
          final open = day['open']?.toString().trim() ?? '';
          final close = day['close']?.toString().trim() ?? '';
          return open.isNotEmpty && close.isNotEmpty;
        });
      case PostFieldType.boolean:
        return true;
      default:
        return value != null && value.toString().trim().isNotEmpty;
    }
  }

  int _photoCount(dynamic value) =>
      PostSchemaValueCoercion.asStringList(
        PostSchemaValueCoercion.extractPhotoRaw(value),
      ).length;

  String? _maxPhotosError(
    PostFieldSchema field,
    dynamic raw,
    String locale,
  ) {
    final max = field.mediaRequirements?.maxCount;
    if (max == null || max <= 0) return null;
    final count = _photoCount(raw);
    if (count <= max) return null;
    return PostEngineStrings.format(
      'error_max_photos',
      locale,
      params: {'max': '$max'},
    );
  }

  String? _applyRule(
    PostFieldSchema field,
    dynamic raw,
    dynamic normalized,
    String rule,
    String locale,
  ) {
    if (rule == 'min_length') {
      final text = normalized?.toString() ?? '';
      if (text.trim().length < 10) {
        final label = PostEngineStrings.t(field.labelKey, locale);
        return PostEngineStrings.format(
          'error_min_length_field',
          locale,
          params: {'field': label, 'min': '10'},
        );
      }
    }
    if (rule == 'min_value') {
      final n = _asNum(normalized);
      if (n == null || n < 1) {
        final label = PostEngineStrings.t(field.labelKey, locale);
        return PostEngineStrings.format(
          'error_min_value_field',
          locale,
          params: {'field': label},
        );
      }
    }
    if (rule == 'min_photos' && field.type == PostFieldType.photo) {
      final min = field.mediaRequirements?.minCount ?? 1;
      final count = _photoCount(raw);
      if (count < min) {
        return PostEngineStrings.format(
          'error_min_photos',
          locale,
          params: {'min': '$min'},
        );
      }
    }
    if (rule == 'email') {
      final text = normalized?.toString() ?? '';
      if (!text.contains('@')) {
        return PostEngineStrings.t('error_email', locale);
      }
    }
    if (rule == 'phone') {
      final text = normalized?.toString() ?? '';
      if (text.trim().length < 8) {
        return PostEngineStrings.t('error_phone', locale);
      }
    }
    if (rule == 'url') {
      final text = normalized?.toString().trim() ?? '';
      if (text.isEmpty) return null;
      final lower = text.toLowerCase();
      if (!lower.startsWith('http://') && !lower.startsWith('https://')) {
        return PostEngineStrings.t('error_url', locale);
      }
    }
    return null;
  }

  num? _asNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value.toString());
  }
}
