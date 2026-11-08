import 'package:raabta/features/post_engine/domain/models/post_schema_models.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';

/// Leaf service category paths for AI service-request extraction prompts.
abstract final class PostServiceRequestCategoryCatalog {
  static List<({String path, String label})> leafEntries(
    PostVerticalSchema schema,
    String locale,
  ) {
    final entries = <({String path, String label})>[];

    void walk(PostCategoryNode node, String prefix) {
      final path = prefix.isEmpty ? node.id : '$prefix.${node.id}';
      if (node.leaf) {
        entries.add((
          path: path,
          label: PostEngineStrings.label(
            node.labelKey,
            locale,
            fallback: node.fallbackLabel,
          ),
        ));
      } else {
        for (final child in node.children) {
          walk(child, path);
        }
      }
    }

    for (final root in schema.categories) {
      walk(root, '');
    }
    return entries;
  }

  static String compactPromptList(
    PostVerticalSchema schema,
    String locale,
  ) {
    final buffer = StringBuffer();
    for (final entry in leafEntries(schema, locale)) {
      buffer.writeln('- ${entry.path}: ${entry.label}');
    }
    return buffer.toString().trim();
  }
}
