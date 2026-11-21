import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/icons/post_vertical_icons.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_text_field.dart';
import 'package:raabta/features/post_engine/domain/models/post_schema_models.dart';
import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';
import 'package:raabta/features/post_engine/domain/post_category_search_copy.dart';
import 'package:raabta/features/post_engine/domain/post_category_search_entry.dart';
import 'package:raabta/features/post_engine/domain/post_category_search_index.dart';
import 'package:raabta/features/post_engine/domain/post_category_tree_utils.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';
import 'package:raabta/screens/services/models/service_listing.dart';
import 'package:raabta/features/post_engine/presentation/providers/post_schema_providers.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_flow_step_indicator.dart';

/// Step 1 — category search + combined tree picker (Part 5 + Part 6).
class PostCombinedCategoryStep extends ConsumerStatefulWidget {
  const PostCombinedCategoryStep({
    super.key,
    required this.vertical,
    required this.locale,
    required this.onCategorySelected,
    this.totalSteps = 3,
    this.serviceListingType,
  });

  final PostVertical vertical;
  final String locale;
  final ValueChanged<String> onCategorySelected;
  final int totalSteps;

  /// Services provider vs. request — ignored for other verticals.
  final ServiceListingType? serviceListingType;

  @override
  ConsumerState<PostCombinedCategoryStep> createState() =>
      _PostCombinedCategoryStepState();
}

class _PostCombinedCategoryStepState
    extends ConsumerState<PostCombinedCategoryStep> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final schemaAsync = ref.watch(postVerticalSchemaProvider(widget.vertical));

    return schemaAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: Text(PostEngineStrings.t('schema_load_error', widget.locale)),
      ),
      data: (schema) {
        final index = PostCategorySearchIndex.buildFromSchema(
          schema,
          locale: widget.locale,
        );
        final suggestions = PostCategorySearchIndex.search(
          _query,
          index,
          locale: widget.locale,
        );
        final roots = PostCategoryTreeUtils.displayRoots(schema.categories);

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            PostFlowStepIndicator(
              currentStep: 1,
              totalSteps: widget.totalSteps,
              stepLabelKey: 'flow_step_category',
              locale: widget.locale,
            ),
            const SizedBox(height: AppSpacing.lg),
            GlassTextField(
              controller: _searchController,
              label: PostCategorySearchCopy.label(
                widget.vertical,
                widget.locale,
                serviceListingType: widget.serviceListingType,
              ),
              hint: PostCategorySearchCopy.hint(
                widget.vertical,
                widget.locale,
                serviceListingType: widget.serviceListingType,
              ),
              icon: Icons.search_rounded,
              onChanged: (value) => setState(() => _query = value),
            ),
            if (_query.trim().length >= PostCategorySearchIndex.minQueryLength) ...[
              const SizedBox(height: AppSpacing.md),
              if (suggestions.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    PostEngineStrings.t(
                      'category_search_no_results',
                      widget.locale,
                    ),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              else
                ...suggestions.map(
                  (entry) => _SearchSuggestionTile(
                    entry: entry,
                    locale: widget.locale,
                    onTap: () => widget.onCategorySelected(entry.categoryPath),
                  ),
                ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Text(
              PostEngineStrings.t('category_search_or_browse', widget.locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...roots.map(
              (node) => _CategorySection(
                node: node,
                parentPath: _parentPathFor(node, schema.categories, roots),
                locale: widget.locale,
                onSelected: widget.onCategorySelected,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Reconstruct parent prefix when wrapper groups were skipped.
  static String _parentPathFor(
    PostCategoryNode node,
    List<PostCategoryNode> originalRoots,
    List<PostCategoryNode> displayRoots,
  ) {
    if (displayRoots == originalRoots) return '';
    if (originalRoots.length == 1) return originalRoots.first.id;
    return '';
  }
}

class _SearchSuggestionTile extends StatelessWidget {
  const _SearchSuggestionTile({
    required this.entry,
    required this.locale,
    required this.onTap,
  });

  final PostCategorySearchEntry entry;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final leafId = entry.categoryPath.split('.').last;
    final subtitle = entry.parentLabel;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: AppColors.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          dense: true,
          leading: Icon(
            PostVerticalIcons.forCategoryId(leafId),
            color: AppColors.cyanGlow,
          ),
          title: Text(entry.leafLabel, style: AppTypography.body),
          subtitle: subtitle == null
              ? null
              : Text(subtitle, style: AppTypography.caption),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.node,
    required this.parentPath,
    required this.locale,
    required this.onSelected,
  });

  final PostCategoryNode node;
  final String parentPath;
  final String locale;
  final ValueChanged<String> onSelected;

  String get _path =>
      PostCategoryTreeUtils.pathFor(node, parentPath: parentPath);

  @override
  Widget build(BuildContext context) {
    final label = PostEngineStrings.label(
      node.labelKey,
      locale,
      fallback: node.fallbackLabel,
    );
    final hasChildren = node.children.isNotEmpty && !node.leaf;

    if (!hasChildren && PostCategoryTreeUtils.isPostable(node)) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: _LeafTile(
          label: label,
          categoryId: node.id,
          onTap: () => onSelected(_path),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: AppColors.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          leading: Icon(
            PostVerticalIcons.forCategoryId(node.id),
            color: AppColors.cyanGlow,
          ),
          title: Text(label, style: AppTypography.body),
          initiallyExpanded: false,
          children: node.children.map((child) {
            final childPath = PostCategoryTreeUtils.pathFor(
              child,
              parentPath: _path,
            );
            final childLabel = PostEngineStrings.label(
              child.labelKey,
              locale,
              fallback: child.fallbackLabel,
            );
            return ListTile(
              leading: Icon(
                PostVerticalIcons.forCategoryId(child.id),
                size: AppSpacing.iconMd,
                color: AppColors.textSecondary,
              ),
              title: Text(childLabel, style: AppTypography.body),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () => onSelected(childPath),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _LeafTile extends StatelessWidget {
  const _LeafTile({
    required this.label,
    required this.categoryId,
    required this.onTap,
  });

  final String label;
  final String categoryId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: AppColors.surface.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      leading: Icon(
        PostVerticalIcons.forCategoryId(categoryId),
        color: AppColors.cyanGlow,
      ),
      title: Text(label, style: AppTypography.body),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      onTap: onTap,
    );
  }
}
