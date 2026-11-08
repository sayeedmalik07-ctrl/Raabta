import 'package:flutter/foundation.dart';
import 'package:raabta/features/post_engine/domain/models/post_schema_models.dart';
import 'package:raabta/features/post_engine/domain/post_schema_value_coercion.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';

/// Debug-only validation tracing for Post Engine flows.
abstract final class PostValidationDebug {
  static void logStart({
    required String vertical,
    required String categoryPath,
    required String? schemaGroupId,
  }) {
    if (!kDebugMode) return;
    debugPrint('VALIDATE START');
    debugPrint('vertical=$vertical');
    debugPrint('category=$categoryPath');
    debugPrint('schema group=${schemaGroupId ?? '(none)'}');
  }

  static void logField({
    required PostFieldSchema field,
    required dynamic rawValue,
    required dynamic normalizedValue,
    required String locale,
    required String? error,
  }) {
    if (!kDebugMode) return;
    final label = PostEngineStrings.t(field.labelKey, locale);
    debugPrint(
      'field key=${field.id} label=$label required=${field.required} '
      'raw=${_safe(rawValue)} normalized=${_safe(normalizedValue)} '
      'validation=${error == null ? 'pass' : 'fail'} '
      '${error == null ? '' : 'error=$error'}',
    );
  }

  static void logResult({
    required bool isValid,
    required Map<String, String> errors,
  }) {
    if (!kDebugMode) return;
    debugPrint('VALIDATE RESULT');
    debugPrint('isValid=$isValid');
    debugPrint('error count=${errors.length}');
    debugPrint('errors map=${errors.isEmpty ? '{}' : errors}');
  }

  static void logNavigation({
    required String nextRoute,
    required bool allowed,
    String? reason,
  }) {
    if (!kDebugMode) return;
    debugPrint('NAVIGATION ATTEMPT');
    debugPrint('next route=$nextRoute');
    debugPrint('navigation result=${allowed ? 'allowed' : 'blocked'}');
    if (reason != null && reason.isNotEmpty) {
      debugPrint('reason=$reason');
    }
  }

  static String _safe(dynamic value) {
    if (value == null) return '(null)';
    if (value is List) return 'List(${value.length})';
    if (value is Map) return 'Map(${value.length})';
    final text = value.toString();
    if (text.length > 80) return '${text.substring(0, 77)}...';
    return text;
  }

  static dynamic normalize(PostFieldSchema field, dynamic raw) =>
      PostSchemaValueCoercion.coerceForField(field, raw);
}
