/// Community-sourced halal label data from Open Food Facts — not a certification verdict.
class HalalProductInfo {
  const HalalProductInfo({
    required this.communityLabels,
    required this.rawTags,
    required this.ingredientsToBeAwareOf,
  });

  /// Human-readable label strings attributed to OFF contributors.
  final List<String> communityLabels;

  /// Raw OFF `labels_tags` entries that matched halal-related patterns.
  final List<String> rawTags;

  /// Objective ingredient mentions — informational only, not halal/haram rulings.
  final List<IngredientAwarenessItem> ingredientsToBeAwareOf;

  bool get hasCommunityHalalData => communityLabels.isNotEmpty;

  static const empty = HalalProductInfo(
    communityLabels: [],
    rawTags: [],
    ingredientsToBeAwareOf: [],
  );
}

class IngredientAwarenessItem {
  const IngredientAwarenessItem({
    required this.ingredientKey,
    required this.matchedTerm,
  });

  /// Stable l10n key suffix, e.g. `awareness_gelatin`.
  final String ingredientKey;

  /// Term matched in the ingredients list.
  final String matchedTerm;
}
