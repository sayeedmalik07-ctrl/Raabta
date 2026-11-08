import 'package:raabta/features/post_engine/domain/models/post_schema_models.dart';

/// Normalizes dynamic / JS-interop values at Post Engine form boundaries.
abstract final class PostSchemaValueCoercion {
  /// Safely converts [raw] to [List<String>] — never throws, never uses casts.
  static List<String> asStringList(dynamic raw) {
    if (raw == null) return const [];
    if (raw is String) {
      final trimmed = raw.trim();
      return trimmed.isEmpty ? const [] : [trimmed];
    }
    if (raw is Iterable) {
      final results = <String>[];
      for (final item in raw) {
        if (item == null) continue;
        final text = item.toString().trim();
        if (text.isNotEmpty) results.add(text);
      }
      return results;
    }
    final text = raw.toString().trim();
    return text.isEmpty ? const [] : [text];
  }

  /// Extracts photo path list from plain lists or structured AI/analysis payloads.
  static dynamic extractPhotoRaw(dynamic raw) {
    if (raw is! Map) return raw;
    final map = Map<String, dynamic>.from(raw);
    for (final key in ['paths', 'photoUrls', 'localPaths', 'photos']) {
      final nested = map[key];
      if (nested != null) return nested;
    }
    return const [];
  }

  /// When AI/analysis marks a category mismatch, returns a user-facing message.
  static String? photoCategoryMismatchMessage(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final mismatch = map['categoryMismatch'] == true ||
        map['categoryMatch'] == false ||
        map['matchesCategory'] == false;
    if (!mismatch) return null;
    final message = map['message']?.toString().trim();
    if (message != null && message.isNotEmpty) return message;
    return 'photo_category_mismatch';
  }

  /// Coerces outbound/inbound field values to schema-safe shapes.
  static dynamic coerceForField(PostFieldSchema field, dynamic raw) {
    switch (field.type) {
      case PostFieldType.photo:
        return asStringList(extractPhotoRaw(raw));
      case PostFieldType.multiSelect:
      case PostFieldType.stringList:
        return asStringList(raw);
      case PostFieldType.openingHours:
        if (raw is Map) return Map<String, dynamic>.from(raw);
        return raw;
      case PostFieldType.singleSelect:
      case PostFieldType.location:
        if (raw is Iterable && raw is! String) {
          final list = asStringList(raw);
          return list.isEmpty ? null : list.first;
        }
        final text = raw?.toString().trim();
        return text == null || text.isEmpty ? null : text;
      case PostFieldType.boolean:
        if (raw is bool) return raw;
        if (raw == null) return false;
        return raw.toString().toLowerCase() == 'true';
      case PostFieldType.number:
      case PostFieldType.currency:
        if (raw == null) return null;
        if (raw is num) return raw;
        final text = raw.toString().trim();
        return text.isEmpty ? null : text;
      default:
        if (raw == null) return null;
        final text = raw.toString().trim();
        return text.isEmpty ? null : text;
    }
  }

  /// Dropdown / select options from Firestore or resolver — always [List<String>].
  static List<String> optionKeys(dynamic raw) {
    return asStringList(raw);
  }

  /// Parses grid keys like `bed_3` or `bath_11_plus` into a numeric count.
  static int? parseGridCount(dynamic raw) {
    final key = raw?.toString().trim();
    if (key == null || key.isEmpty) return null;
    if (key.endsWith('_plus')) {
      final parts = key.split('_');
      if (parts.length >= 2) {
        return int.tryParse(parts[parts.length - 2]);
      }
    }
    final parts = key.split('_');
    if (parts.length >= 2) {
      return int.tryParse(parts.last);
    }
    return int.tryParse(key);
  }

  static bool isFurnished(dynamic raw) {
    return raw?.toString() == 'furnished_full' || raw?.toString() == 'furnished_semi';
  }
}
