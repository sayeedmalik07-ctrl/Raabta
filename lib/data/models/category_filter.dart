/// Reusable category chip for list filters (businesses, jobs, marketplace).
class CategoryFilter {
  const CategoryFilter({
    required this.label,
    required this.emoji,
    this.filter,
  });

  final String label;
  final String emoji;

  /// When null, shows all items. Otherwise matches category or tag field.
  final String? filter;
}
