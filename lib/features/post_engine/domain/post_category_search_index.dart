import 'package:raabta/core/search/search_keyword_tokenizer.dart';
import 'package:raabta/features/post_engine/domain/models/post_schema_models.dart';
import 'package:raabta/features/post_engine/domain/post_category_search_aliases.dart';
import 'package:raabta/features/post_engine/domain/post_category_search_entry.dart';
import 'package:raabta/features/post_engine/domain/post_category_tree_utils.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';

/// Client-side category search index — built from cached vertical schema.
abstract final class PostCategorySearchIndex {
  static const minQueryLength = 2;
  static const defaultLimit = 8;

  static List<PostCategorySearchEntry> buildFromSchema(
    PostVerticalSchema schema, {
    required String locale,
  }) {
    final entries = <PostCategorySearchEntry>[];

    void walk(
      List<PostCategoryNode> nodes, {
      required String parentPath,
      String? parentLabel,
    }) {
      for (final node in nodes) {
        final path = PostCategoryTreeUtils.pathFor(
          node,
          parentPath: parentPath,
        );
        final label = PostEngineStrings.label(
          node.labelKey,
          locale,
          fallback: node.fallbackLabel,
        );
        final englishLabel = locale == 'English'
            ? label
            : PostEngineStrings.label(
                node.labelKey,
                'English',
                fallback: node.fallbackLabel,
              );

        final hasChildren = node.children.isNotEmpty && !node.leaf;
        if (hasChildren) {
          walk(
            node.children,
            parentPath: path,
            parentLabel: label,
          );
          continue;
        }

        if (!_isPostable(schema, path, node)) continue;

        entries.add(
          PostCategorySearchEntry(
            categoryPath: path,
            leafLabel: label,
            parentLabel: parentLabel,
            extraKeywords: [
              englishLabel,
              if (node.fallbackLabel != null) node.fallbackLabel!,
              ...PostCategorySearchAliases.forPath(path),
            ],
          ),
        );
      }
    }

    walk(schema.categories, parentPath: '');
    return entries;
  }

  static bool _isPostable(
    PostVerticalSchema schema,
    String path,
    PostCategoryNode node,
  ) {
    return schema.categoryOverrides.containsKey(path) ||
        PostCategoryTreeUtils.isPostable(node);
  }

  static List<PostCategorySearchEntry> search(
    String query,
    List<PostCategorySearchEntry> catalog, {
    required String locale,
    int limit = defaultLimit,
  }) {
    final q = query.trim();
    if (q.length < minQueryLength) return const [];

    final ranked = <({PostCategorySearchEntry entry, int score})>[];
    for (final entry in catalog) {
      final score = _scoreEntry(entry, q, locale);
      if (score > 0) {
        ranked.add((entry: entry, score: score));
      }
    }

    ranked.sort((a, b) => b.score.compareTo(a.score));
    return ranked.take(limit).map((r) => r.entry).toList();
  }

  static int _scoreEntry(
    PostCategorySearchEntry entry,
    String query,
    String locale,
  ) {
    final q = query.toLowerCase();
    final haystack = entry.searchableText.toLowerCase();

    var score = SearchKeywordTokenizer.score(
      query: query,
      title: entry.leafLabel,
      subtitle: '${entry.parentLabel ?? ''} ${entry.extraKeywords.join(' ')}',
    );

    if (_containsOrPrefix(q, entry.leafLabel.toLowerCase())) {
      score += 40;
    }
    if (entry.parentLabel != null &&
        _containsOrPrefix(q, entry.parentLabel!.toLowerCase())) {
      score += 20;
    }

    for (final keyword in entry.extraKeywords) {
      if (_containsOrPrefix(q, keyword.toLowerCase())) {
        score += 30;
      }
    }

    if (_containsOrPrefix(q, haystack)) {
      score += 10;
    }

    final tokens = SearchKeywordTokenizer.tokenize(q);
    if (tokens.isNotEmpty && tokens.every((t) => haystack.contains(t))) {
      score += 15;
    }

    return score;
  }

  static bool _containsOrPrefix(String query, String text) {
    if (text.isEmpty || query.isEmpty) return false;
    if (text.contains(query)) return true;
    for (final word in text.split(RegExp(r'[\s_/]+'))) {
      if (word.startsWith(query)) return true;
      if (query.length >= 3 && word.length >= query.length) {
        if (word.startsWith(query)) return true;
      }
    }
    return false;
  }
}
