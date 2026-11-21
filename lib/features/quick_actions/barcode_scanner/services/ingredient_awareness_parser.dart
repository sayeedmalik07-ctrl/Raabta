import '../models/halal_product_info.dart';

/// Flags ingredient terms some Muslim consumers review — not halal/haram verdicts.
abstract final class IngredientAwarenessParser {
  static const _patterns = <({String term, String key})>[
    (term: 'gelatin', key: 'awareness_gelatin'),
    (term: 'pork', key: 'awareness_pork'),
    (term: 'bacon', key: 'awareness_pork'),
    (term: 'lard', key: 'awareness_lard'),
    (term: 'pepsin', key: 'awareness_pepsin'),
    (term: 'rennet', key: 'awareness_rennet'),
    (term: 'carmine', key: 'awareness_carmine'),
    (term: 'cochineal', key: 'awareness_carmine'),
    (term: 'e120', key: 'awareness_carmine'),
    (term: 'wine', key: 'awareness_alcohol'),
    (term: 'beer', key: 'awareness_alcohol'),
    (term: 'rum', key: 'awareness_alcohol'),
    (term: 'whiskey', key: 'awareness_alcohol'),
    (term: 'whisky', key: 'awareness_alcohol'),
    (term: 'ethanol', key: 'awareness_alcohol'),
    (term: 'vanilla extract', key: 'awareness_alcohol_extract'),
  ];

  static List<IngredientAwarenessItem> parse(String ingredientsText) {
    final lower = ingredientsText.toLowerCase();
    if (lower.trim().isEmpty) return const [];

    final found = <String, IngredientAwarenessItem>{};
    for (final entry in _patterns) {
      if (!lower.contains(entry.term)) continue;
      found.putIfAbsent(
        entry.key,
        () => IngredientAwarenessItem(
          ingredientKey: entry.key,
          matchedTerm: entry.term,
        ),
      );
    }
    return found.values.toList(growable: false);
  }
}
