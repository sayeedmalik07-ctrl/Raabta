import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/search_distance_formatter.dart';
import 'package:raabta/features/global_search/presentation/global_search_category_l10n.dart';
import 'package:raabta/features/global_search/presentation/global_search_directional_icons.dart';

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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Row(
              children: [
                Icon(group.category.icon, size: 20, color: AppColors.cyanGlow),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  GlobalSearchCategoryL10n.label(group.category, locale),
                  style: AppTypography.title,
                ),
                const Spacer(),
                if (group.hasMoreThanShown)
                  TextButton(
                    onPressed: onSeeAll,
                    child: Text(
                      GlobalSearchCategoryL10n.seeAllLabel(group.category, locale),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final item in group.items)
            GlassCard(
              onTap: () => onTapItem(item),
              margin: const EdgeInsets.only(bottom: AppSpacing.xs),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: _semanticLabel(item),
                      button: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.subtitle.isNotEmpty)
                            Text(
                              item.subtitle,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (item.distanceMeters != null)
                            Text(
                              SearchDistanceFormatter.labelForMeters(
                                    item.distanceMeters,
                                    locale,
                                  ) ??
                                  '',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ),
                  Icon(GlobalSearchDirectionalIcons.chevronForward(context)),
                ],
              ),
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
