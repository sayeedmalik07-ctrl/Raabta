import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/global_search/domain/search_autocomplete_result.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_section_header.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_suggestion_tile.dart';

/// Compact autocomplete panel below the Global Search field (S8).
class GlobalSearchAutocompleteView extends StatelessWidget {
  const GlobalSearchAutocompleteView({
    super.key,
    required this.suggestions,
    required this.locale,
    required this.onSelect,
    required this.onRemoveRecent,
    required this.onClearRecent,
    this.showClearRecent = false,
  });

  final List<SearchAutocompleteResult> suggestions;
  final String locale;
  final ValueChanged<SearchAutocompleteResult> onSelect;
  final ValueChanged<String> onRemoveRecent;
  final VoidCallback onClearRecent;
  final bool showClearRecent;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlobalSearchSectionHeader(
          title: AppShellStrings.t('global_search_suggestions', locale),
          icon: Icons.tips_and_updates_outlined,
          accent: AppColors.brandFamilyMain,
          seeAllLabel: showClearRecent
              ? AppShellStrings.t('global_search_clear_recent', locale)
              : null,
          onSeeAll: showClearRecent ? onClearRecent : null,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final item in suggestions)
          item.isRecent
              ? GlobalSearchSuggestionTile.recent(
                  query: item.displayText,
                  locale: locale,
                  onTap: () => onSelect(item),
                  onRemove: () => onRemoveRecent(item.submitQuery),
                )
              : GlobalSearchSuggestionTile.suggestion(
                  title: item.displayText,
                  subtitle: item.subtitle,
                  icon: item.icon ?? Icons.search_rounded,
                  locale: locale,
                  onTap: () => onSelect(item),
                  context: context,
                ),
      ],
    );
  }
}
