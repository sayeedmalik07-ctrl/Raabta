import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/icons/post_vertical_icons.dart';
import 'package:raabta/core/l10n/app_locale_notifier.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/post_engine/domain/models/post_schema_models.dart';
import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';
import 'package:raabta/features/post_engine/presentation/providers/post_schema_providers.dart';

/// Category tree picker — first step of schema-driven posting flows.
class PostCategoryPickerScreen extends ConsumerWidget {
  const PostCategoryPickerScreen({
    super.key,
    required this.vertical,
    this.parentPath = '',
  });

  final PostVertical vertical;
  final String parentPath;

  static String postRoute(PostVertical vertical, {String? category, String? parent}) {
    final segment = switch (vertical) {
      PostVertical.business => 'businesses',
      _ => vertical.id,
    };
    final base = '/$segment/post';
    if (category != null && category.isNotEmpty) {
      return '$base?category=$category';
    }
    if (parent != null && parent.isNotEmpty) {
      return '$base?parent=$parent';
    }
    return base;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final schemaAsync = ref.watch(postVerticalSchemaProvider(vertical));

    return GlassScreenScaffold(
      title: PostEngineStrings.t('pick_category', locale),
      body: schemaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Text(PostEngineStrings.t('schema_load_error', locale)),
        ),
        data: (schema) {
          final nodes = _nodesAtPath(schema.categories, parentPath);
          if (nodes.isEmpty) {
            return Center(
              child: Text(PostEngineStrings.t('schema_load_error', locale)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: nodes.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final node = nodes[index];
              final path = parentPath.isEmpty ? node.id : '$parentPath.${node.id}';
              final label = PostEngineStrings.label(
                node.labelKey,
                locale,
                fallback: node.fallbackLabel,
              );
              final hasChildren = node.children.isNotEmpty && !node.leaf;

              return ListTile(
                tileColor: AppColors.surface.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                leading: Icon(
                  PostVerticalIcons.forCategoryId(node.id),
                  color: AppColors.cyanGlow,
                ),
                title: Text(label, style: AppTypography.body),
                trailing: Icon(
                  hasChildren
                      ? Icons.chevron_right_rounded
                      : Icons.arrow_forward_ios_rounded,
                  size: hasChildren ? 24 : 14,
                ),
                onTap: () {
                  if (hasChildren) {
                    context.push(postRoute(vertical, parent: path));
                  } else {
                    context.push(postRoute(vertical, category: path));
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  List<PostCategoryNode> _nodesAtPath(
    List<PostCategoryNode> roots,
    String path,
  ) {
    if (path.isEmpty) return roots;
    final parts = path.split('.');
    PostCategoryNode? current;
    for (final root in roots) {
      if (root.id == parts.first) {
        current = root;
        break;
      }
    }
    if (current == null) return const [];
    for (var i = 1; i < parts.length; i++) {
      current = current!.children.cast<PostCategoryNode?>().firstWhere(
            (c) => c?.id == parts[i],
            orElse: () => null,
          );
      if (current == null) return const [];
    }
    if (current!.children.isEmpty && current.leaf) return [current];
    return current.children;
  }
}
