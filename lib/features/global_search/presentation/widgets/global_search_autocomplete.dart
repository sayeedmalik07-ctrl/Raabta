import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/global_search/domain/search_autocomplete_result.dart';
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
        Semantics(
          header: true,
          child: Row(
            children: [
              Text(
                AppShellStrings.t('global_search_suggestions', locale),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (showClearRecent)
                TextButton(
                  onPressed: onClearRecent,
                  child: Text(
                    AppShellStrings.t('global_search_clear_recent', locale),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
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
