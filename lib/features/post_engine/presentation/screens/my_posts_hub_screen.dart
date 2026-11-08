import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_locale_notifier.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/post_engine/domain/models/my_post_item.dart';
import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';
import 'package:raabta/features/post_engine/presentation/providers/my_posts_providers.dart';
import 'package:raabta/providers/auth_providers.dart';

/// Universal My Posts hub — drafts + published listings across all verticals.
class MyPostsHubScreen extends ConsumerStatefulWidget {
  const MyPostsHubScreen({super.key});

  @override
  ConsumerState<MyPostsHubScreen> createState() => _MyPostsHubScreenState();
}

class _MyPostsHubScreenState extends ConsumerState<MyPostsHubScreen> {
  MyPostsTab _tab = MyPostsTab.all;
  PostVertical? _verticalFilter;

  String _verticalLabel(PostVertical v, String locale) => switch (v) {
        PostVertical.housing => PostEngineStrings.t('filter_housing', locale),
        PostVertical.jobs => PostEngineStrings.t('filter_jobs', locale),
        PostVertical.business => PostEngineStrings.t('filter_business', locale),
        PostVertical.services => PostEngineStrings.t('filter_services', locale),
        PostVertical.marketplace =>
          PostEngineStrings.t('filter_marketplace', locale),
      };

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appLocaleProvider);
    final uid = ref.watch(currentUserProvider)?.uid ?? '';
    final postsAsync = ref.watch(myPostsProvider(uid));

    return GlassScreenScaffold(
      title: PostEngineStrings.t('my_posts_title', locale),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              children: MyPostsTab.values.map((tab) {
                final selected = _tab == tab;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: FilterChip(
                    label: Text(PostEngineStrings.t(tab.labelKey(), locale)),
                    selected: selected,
                    onSelected: (_) => setState(() => _tab = tab),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              children: [
                FilterChip(
                  label: Text(PostEngineStrings.t('tab_all', locale)),
                  selected: _verticalFilter == null,
                  onSelected: (_) => setState(() => _verticalFilter = null),
                ),
                ...PostVertical.values.map(
                  (v) => Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.xs),
                    child: FilterChip(
                      label: Text(_verticalLabel(v, locale)),
                      selected: _verticalFilter == v,
                      onSelected: (_) => setState(() => _verticalFilter = v),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: postsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.cyanGlow),
              ),
              error: (_, _) => Center(
                child: GlassEmptyState(
                  icon: Icons.error_outline,
                  title: PostEngineStrings.t('schema_load_error', locale),
                  description: '',
                ),
              ),
              data: (items) {
                final filtered = items
                    .where((i) => _tab.matches(i))
                    .where((i) => i.matchesVerticalFilter(_verticalFilter))
                    .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: GlassEmptyState(
                      icon: Icons.post_add_outlined,
                      title: PostEngineStrings.t('tab_drafts', locale),
                      description: PostEngineStrings.t('pick_category', locale),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return ListTile(
                      tileColor: AppColors.surface.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      leading: Text(
                        _verticalEmoji(item.vertical),
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(item.title, style: AppTypography.body),
                      subtitle: Text(
                        '${_verticalLabel(item.vertical, locale)} · ${item.status}',
                        style: AppTypography.caption,
                      ),
                      trailing: item.kind == MyPostItemKind.draft
                          ? const Icon(Icons.edit_note)
                          : const Icon(Icons.chevron_right),
                      onTap: () {
                        if (item.route != null) {
                          final route = item.route!;
                          if (item.vertical == PostVertical.jobs &&
                              route.contains('/applications')) {
                            context.push(route, extra: item.title);
                          } else {
                            context.push(route);
                          }
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _verticalEmoji(PostVertical v) => switch (v) {
        PostVertical.housing => '🏠',
        PostVertical.jobs => '💼',
        PostVertical.business => '🏪',
        PostVertical.services => '🔧',
        PostVertical.marketplace => '🛒',
      };
}
