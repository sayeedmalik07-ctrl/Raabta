import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/background/animated_aurora_background.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/hub/hub_landing_header.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/features/saved_search/domain/saved_search.dart';
import 'package:raabta/features/saved_search/domain/saved_search_vertical.dart';
import 'package:raabta/features/saved_search/l10n/saved_search_strings.dart';
import 'package:raabta/features/saved_search/presentation/saved_search_criteria_summary.dart';
import 'package:raabta/features/saved_search/presentation/widgets/hub_saved_search_row.dart';
import 'package:raabta/features/saved_search/providers/saved_search_providers.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';

class SavedSearchesScreen extends ConsumerWidget {
  const SavedSearchesScreen({super.key});

  static const screenKey = Key('hub_saved_searches_screen');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final searchesAsync = ref.watch(userSavedSearchesProvider);

    return AnimatedAuroraBackground(
      child: Scaffold(
        key: screenKey,
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HubLandingHeader(
                key: const Key('hub_saved_searches_header'),
                title: SavedSearchStrings.t('saved_searches_title', locale),
                subtitle: SavedSearchStrings.t('saved_searches_subtitle', locale),
                onBack: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: searchesAsync.when(
                  loading: () => const Center(
                    child: HubLoadingPlaceholder(
                      width: 280,
                      height: 120,
                    ),
                  ),
                  error: (error, stackTrace) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: GlassEmptyState(
                        accent: GlassEmptyStateAccent.brand,
                        icon: Icons.error_outline,
                        title: SavedSearchStrings.t('saved_searches_title', locale),
                        description: SavedSearchStrings.t(
                          'saved_searches_empty',
                          locale,
                        ),
                      ),
                    ),
                  ),
                  data: (searches) {
                    if (searches.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: GlassEmptyState(
                            key: const Key('hub_saved_searches_empty'),
                            accent: GlassEmptyStateAccent.brand,
                            icon: Icons.bookmark_border,
                            title: SavedSearchStrings.t(
                              'saved_searches_empty_title',
                              locale,
                            ),
                            description: SavedSearchStrings.t(
                              'saved_searches_empty',
                              locale,
                            ),
                          ),
                        ),
                      );
                    }

                    final grouped = <SavedSearchVertical, List<SavedSearch>>{};
                    for (final search in searches) {
                      grouped.putIfAbsent(search.vertical, () => []).add(search);
                    }

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.md,
                        AppSpacing.xl,
                        AppSpacing.xxl,
                      ),
                      children: [
                        for (final vertical in SavedSearchVertical.values)
                          if (grouped.containsKey(vertical)) ...[
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                                top: AppSpacing.sm,
                              ),
                              child: Text(
                                SavedSearchStrings.verticalLabel(vertical, locale),
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            for (final search in grouped[vertical]!)
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: HubSavedSearchRow(
                                  key: Key('hub_saved_search_${search.id}'),
                                  title: search.name,
                                  subtitle: savedSearchCriteriaSummary(
                                    search,
                                    locale,
                                  ),
                                  active: search.active,
                                  onActiveChanged: (value) => _setActive(
                                    ref,
                                    search,
                                    value,
                                  ),
                                  onMore: () => _showRowMenu(
                                    context,
                                    ref,
                                    search,
                                    locale,
                                  ),
                                ),
                              ),
                          ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _setActive(
    WidgetRef ref,
    SavedSearch search,
    bool active,
  ) async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    await ref.read(savedSearchRepositoryProvider).setActive(
          uid: uid,
          searchId: search.id,
          active: active,
        );
  }

  Future<void> _showRowMenu(
    BuildContext context,
    WidgetRef ref,
    SavedSearch search,
    String locale,
  ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Material(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              color: AppColors.surface,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.drive_file_rename_outline),
                    title: Text(
                      SavedSearchStrings.t('saved_searches_rename', locale),
                    ),
                    onTap: () => Navigator.pop(ctx, 'rename'),
                  ),
                  ListTile(
                    leading: Icon(Icons.delete_outline, color: AppColors.error),
                    title: Text(
                      SavedSearchStrings.t('saved_searches_delete', locale),
                      style: TextStyle(color: AppColors.error),
                    ),
                    onTap: () => Navigator.pop(ctx, 'delete'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (action == 'rename') {
      await _rename(context, ref, search, locale);
    } else if (action == 'delete') {
      await _delete(ref, search, locale, context);
    }
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    SavedSearch search,
    String locale,
  ) async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;

    final controller = TextEditingController(text: search.name);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(SavedSearchStrings.t('saved_searches_rename', locale)),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    final name = controller.text.trim();
    if (name.isEmpty) return;

    await ref.read(savedSearchRepositoryProvider).rename(
          uid: uid,
          searchId: search.id,
          name: name,
        );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(SavedSearchStrings.t('saved_searches_renamed', locale)),
      ),
    );
  }

  Future<void> _delete(
    WidgetRef ref,
    SavedSearch search,
    String locale,
    BuildContext context,
  ) async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;

    await ref.read(savedSearchRepositoryProvider).delete(
          uid: uid,
          searchId: search.id,
        );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(SavedSearchStrings.t('saved_searches_deleted', locale)),
      ),
    );
  }
}
