/// Flattened postable category row for Step 1 type-ahead search.
class PostCategorySearchEntry {
  const PostCategorySearchEntry({
    required this.categoryPath,
    required this.leafLabel,
    this.parentLabel,
    this.extraKeywords = const [],
  });

  final String categoryPath;
  final String leafLabel;
  final String? parentLabel;
  final List<String> extraKeywords;

  String get searchableText => [
        leafLabel,
        if (parentLabel != null) parentLabel!,
        ...extraKeywords,
        ...categoryPath.split('.'),
      ].join(' ');
}
