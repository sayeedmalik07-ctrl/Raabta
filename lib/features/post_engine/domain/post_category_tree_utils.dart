import 'package:raabta/features/post_engine/domain/models/post_schema_models.dart';

/// Helpers for flattening category trees in the combined picker step.
abstract final class PostCategoryTreeUtils {
  /// Skips single-item wrapper groups (e.g. housing → housing.room).
  static List<PostCategoryNode> displayRoots(List<PostCategoryNode> roots) {
    if (roots.length == 1 &&
        roots.first.children.isNotEmpty &&
        !roots.first.leaf) {
      return roots.first.children;
    }
    return roots;
  }

  static String pathFor(PostCategoryNode node, {String parentPath = ''}) {
    return parentPath.isEmpty ? node.id : '$parentPath.${node.id}';
  }

  static bool isPostable(PostCategoryNode node) =>
      node.leaf || (node.children.isEmpty && node.schemaGroupId != null);
}
