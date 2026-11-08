import '../models/halal_product_info.dart';

/// Reads halal-related community labels from Open Food Facts product JSON.
abstract final class OpenFoodFactsHalalParser {
  static final _halalTagPattern = RegExp(r'halal', caseSensitive: false);

  static HalalProductInfo parse({
    required Map<String, dynamic> product,
    required List<IngredientAwarenessItem> awarenessItems,
  }) {
    final tags = _readTags(product);
    final halalTags =
        tags.where((t) => _halalTagPattern.hasMatch(t)).toList(growable: false);

    final labels = _communityLabels(product, halalTags);

    return HalalProductInfo(
      communityLabels: labels,
      rawTags: halalTags,
      ingredientsToBeAwareOf: awarenessItems,
    );
  }

  static List<String> _readTags(Map<String, dynamic> product) {
    final raw = product['labels_tags'];
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).toList(growable: false);
  }

  static List<String> _communityLabels(
    Map<String, dynamic> product,
    List<String> halalTags,
  ) {
    if (halalTags.isEmpty) return const [];

    final labelsField = product['labels']?.toString() ?? '';
    final fromField = labelsField
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && _halalTagPattern.hasMatch(s))
        .toList();

    if (fromField.isNotEmpty) return fromField;

    return halalTags.map(_tagToDisplayLabel).toList(growable: false);
  }

  static String _tagToDisplayLabel(String tag) {
    final slug = tag.contains(':') ? tag.split(':').last : tag;
    return slug
        .replaceAll('-', ' ')
        .split(' ')
        .map((w) =>
            w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }
}
