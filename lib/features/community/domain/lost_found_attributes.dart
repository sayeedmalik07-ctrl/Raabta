import 'package:flutter/foundation.dart';

/// Structured listing attributes for Lost & Found (Stage 1 — manual entry).
@immutable
class LostFoundListingAttributes {
  const LostFoundListingAttributes({
    required this.category,
    this.colors = const [],
    this.brand,
    this.itemType,
    this.marks,
    this.confidence,
  });

  final String category;
  final List<String> colors;
  final String? brand;
  final String? itemType;
  final String? marks;

  /// Optional; for future AI suggestions only — not verification.
  final double? confidence;

  bool get blocksPhoto => LostFoundCategory.blocksPhoto(category);
}

abstract final class LostFoundCategory {
  static const bag = 'bag';
  static const wallet = 'wallet';
  static const phoneElectronics = 'phone_electronics';
  static const keys = 'keys';
  static const jewellery = 'jewellery';
  static const clothing = 'clothing';
  static const pet = 'pet';
  static const vehicleItem = 'vehicle_item';
  static const documentsCards = 'documents_cards';
  static const other = 'other';

  static const all = [
    bag,
    wallet,
    phoneElectronics,
    keys,
    jewellery,
    clothing,
    pet,
    vehicleItem,
    documentsCards,
    other,
  ];

  static String? normalize(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    if (all.contains(trimmed)) return trimmed;
    return null;
  }

  static bool blocksPhoto(String? category) =>
      normalize(category) == documentsCards;

  static String labelKey(String category) => 'community_lf_cat_$category';
}

abstract final class LostFoundColorPalette {
  static const all = [
    'black',
    'white',
    'brown',
    'blue',
    'red',
    'green',
    'yellow',
    'gray',
    'silver',
    'gold',
    'multicolor',
  ];

  static const maxSelected = 3;

  static String labelKey(String colorId) => 'community_lf_color_$colorId';
}

abstract final class LostFoundAttributesValidation {
  static const maxBrandLength = 60;
  static const maxItemTypeLength = 80;
  static const maxMarksLength = 120;

  static LostFoundListingAttributes? parseUserInput({
    String? categoryRaw,
    Iterable<String>? colorsRaw,
    String? brand,
    String? itemType,
    String? marks,
    double? confidence,
  }) {
    final category = LostFoundCategory.normalize(categoryRaw);
    if (category == null) return null;

    final colors = <String>[];
    if (colorsRaw != null) {
      for (final raw in colorsRaw) {
        final c = raw.trim().toLowerCase();
        if (c.isEmpty) continue;
        if (!LostFoundColorPalette.all.contains(c)) continue;
        if (colors.contains(c)) continue;
        colors.add(c);
        if (colors.length >= LostFoundColorPalette.maxSelected) break;
      }
    }

    final brandOut = _trimOptional(brand, maxBrandLength);
    final itemTypeOut = _trimOptional(itemType, maxItemTypeLength);
    final marksOut = _trimOptional(marks, maxMarksLength);

    double? conf;
    if (confidence != null && confidence.isFinite) {
      conf = confidence.clamp(0.0, 1.0);
    }

    return LostFoundListingAttributes(
      category: category,
      colors: colors,
      brand: brandOut,
      itemType: itemTypeOut,
      marks: marksOut,
      confidence: conf,
    );
  }

  static LostFoundListingAttributes? parseFirestoreMap(
    Map<String, dynamic>? raw,
  ) {
    if (raw == null || raw.isEmpty) return null;
    return parseUserInput(
      categoryRaw: raw['category'] as String?,
      colorsRaw: (raw['colors'] as List?)?.map((e) => e.toString()),
      brand: raw['brand'] as String?,
      itemType: raw['item_type'] as String?,
      marks: raw['marks'] as String?,
      confidence: (raw['confidence'] as num?)?.toDouble(),
    );
  }

  static Map<String, dynamic>? toFirestore(LostFoundListingAttributes? attrs) {
    if (attrs == null) return null;
    final normalized = parseUserInput(
      categoryRaw: attrs.category,
      colorsRaw: attrs.colors,
      brand: attrs.brand,
      itemType: attrs.itemType,
      marks: attrs.marks,
      confidence: attrs.confidence,
    );
    if (normalized == null) return null;

    return {
      'category': normalized.category,
      if (normalized.colors.isNotEmpty) 'colors': normalized.colors,
      if (normalized.brand != null) 'brand': normalized.brand,
      if (normalized.itemType != null) 'item_type': normalized.itemType,
      if (normalized.marks != null) 'marks': normalized.marks,
      if (normalized.confidence != null) 'confidence': normalized.confidence,
    };
  }

  static String? _trimOptional(String? value, int maxLen) {
    if (value == null) return null;
    final t = value.trim();
    if (t.isEmpty) return null;
    if (t.length > maxLen) return t.substring(0, maxLen);
    return t;
  }
}
