import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/search_best_match.dart';
import 'package:raabta/features/global_search/domain/search_distance_formatter.dart';
import 'package:raabta/features/global_search/presentation/global_search_directional_icons.dart';

/// Compact BEST MATCH highlight above category groups (S5).
class GlobalSearchBestMatchView extends StatelessWidget {
  const GlobalSearchBestMatchView({
    super.key,
    required this.bestMatch,
    required this.locale,
    required this.onTapItem,
  });

  final SearchBestMatch bestMatch;
  final String locale;
  final ValueChanged<GlobalSearchResultItem> onTapItem;

  @override
  Widget build(BuildContext context) {
    final item = bestMatch.result;
    final reason = AppShellStrings.t(bestMatch.reasonKey, locale);
    final distanceLabel = SearchDistanceFormatter.labelForMeters(
      bestMatch.distanceMeters ?? item.distanceMeters,
      locale,
    );
    final distanceSemantic = SearchDistanceFormatter.semanticDistanceLabel(
      bestMatch.distanceMeters ?? item.distanceMeters,
      locale,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              AppShellStrings.t('global_search_best_match', locale),
              style: AppTypography.title,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Semantics(
            button: true,
            label:
                '${AppShellStrings.t('global_search_best_match', locale)}. '
                '${item.title}. ${item.subtitle}. $reason'
                '${distanceSemantic.isNotEmpty ? '. $distanceSemantic' : ''}',
            child: GlassCard(
              onTap: () => onTapItem(item),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              glowColor: AppColors.cyanGlow,
              glowIntensity: 0.12,
              child: Row(
                children: [
                  Icon(
                    item.category.icon,
                    size: 22,
                    color: AppColors.cyanGlow,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w700,
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
                        Text(
                          reason,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.cyanGlow,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (distanceLabel != null)
                          Text(
                            distanceLabel,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Icon(GlobalSearchDirectionalIcons.chevronForward(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
