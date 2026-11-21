import 'package:flutter/material.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_suggestion_tile.dart';

/// Idle recent searches or empty prompt (Phase 1 chrome only).
class GlobalSearchIdleBody extends StatelessWidget {
  const GlobalSearchIdleBody({
    super.key,
    required this.recent,
    required this.locale,
    required this.onTap,
    required this.onRemove,
    this.header,
  });

  final List<String> recent;
  final String locale;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onRemove;
  final String? header;

  @override
  Widget build(BuildContext context) {
    if (recent.isEmpty) {
      return ListView(
        children: [
          Semantics(
            label: AppShellStrings.t('global_search_idle_hint', locale),
            child: GlassEmptyState(
              accent: GlassEmptyStateAccent.brand,
              icon: Icons.manage_search_rounded,
              title: AppShellStrings.t('global_search_title', locale),
              description: AppShellStrings.t('global_search_idle_hint', locale),
            ),
          ),
        ],
      );
    }

    final sectionTitle = header ?? AppShellStrings.t('global_search_recent', locale);

    return ListView(
      children: [
        HomeSectionHeader(
          title: sectionTitle,
          compact: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final q in recent)
          GlobalSearchSuggestionTile.recent(
            query: q,
            locale: locale,
            onTap: () => onTap(q),
            onRemove: () => onRemove(q),
          ),
      ],
    );
  }
}
