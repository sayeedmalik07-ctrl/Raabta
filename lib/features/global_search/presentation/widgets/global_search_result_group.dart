import 'package:flutter/material.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/search_distance_formatter.dart';
import 'package:raabta/features/global_search/presentation/global_search_category_l10n.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_presentation_tokens.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_result_row.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_section_header.dart';

/// Grouped search hits for one category (top N + see-all affordance).
class GlobalSearchResultGroupView extends StatelessWidget {
  const GlobalSearchResultGroupView({
    super.key,
    required this.group,
    required this.onTapItem,
    required this.onSeeAll,
    this.locale = 'en',
  });

  final GlobalSearchCategoryGroup group;
  final ValueChanged<GlobalSearchResultItem> onTapItem;
  final VoidCallback onSeeAll;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final accent = GlobalSearchPresentationTokens.categoryAccent(group.category);

    return Padding(
      padding: const EdgeInsets.only(
        bottom: GlobalSearchPresentationTokens.sectionBottomGap,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlobalSearchSectionHeader(
            title: GlobalSearchCategoryL10n.label(group.category, locale),
            icon: group.category.icon,
            accent: accent,
            seeAllLabel: group.hasMoreThanShown
                ? GlobalSearchCategoryL10n.seeAllLabel(group.category, locale)
                : null,
            onSeeAll: group.hasMoreThanShown ? onSeeAll : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final item in group.items)
            GlobalSearchResultRow(
              icon: group.category.icon,
              accent: accent,
              title: item.title,
              subtitle: item.subtitle.isNotEmpty ? item.subtitle : null,
              tertiary: SearchDistanceFormatter.labelForMeters(
                item.distanceMeters,
                locale,
              ),
              semanticLabel: _semanticLabel(item),
              onTap: () => onTapItem(item),
            ),
        ],
      ),
    );
  }

  String _semanticLabel(GlobalSearchResultItem item) {
    final distance = SearchDistanceFormatter.semanticDistanceLabel(
      item.distanceMeters,
      locale,
    );
    final parts = <String>[item.title];
    if (item.subtitle.isNotEmpty) parts.add(item.subtitle);
    if (distance.isNotEmpty) parts.add(distance);
    return parts.join(', ');
  }
}
