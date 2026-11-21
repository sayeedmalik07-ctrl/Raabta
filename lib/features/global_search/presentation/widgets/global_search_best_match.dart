import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/search_best_match.dart';
import 'package:raabta/features/global_search/domain/search_distance_formatter.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_presentation_tokens.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_result_row.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_section_header.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';

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
    final accent = GlobalSearchPresentationTokens.categoryAccent(item.category);
    final distanceLabel = SearchDistanceFormatter.labelForMeters(
      bestMatch.distanceMeters ?? item.distanceMeters,
      locale,
    );
    final distanceSemantic = SearchDistanceFormatter.semanticDistanceLabel(
      bestMatch.distanceMeters ?? item.distanceMeters,
      locale,
    );

    return Padding(
      padding: const EdgeInsets.only(
        bottom: GlobalSearchPresentationTokens.sectionBottomGap,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlobalSearchSectionHeader(
            title: AppShellStrings.t('global_search_best_match', locale),
            icon: item.category.icon,
            accent: AppColors.brandFamilyMain,
          ),
          const SizedBox(height: AppSpacing.sm),
          GlobalSearchResultRow(
            icon: item.category.icon,
            accent: accent,
            title: item.title,
            subtitle: item.subtitle.isNotEmpty ? item.subtitle : null,
            tertiary: [
              reason,
              ?distanceLabel,
            ].join(' · '),
            glowColor: AppColors.brandFamilyMain,
            glowIntensity: HomeCardTier.contextualGlowIntensity,
            semanticLabel:
                '${AppShellStrings.t('global_search_best_match', locale)}. '
                '${item.title}. ${item.subtitle}. $reason'
                '${distanceSemantic.isNotEmpty ? '. $distanceSemantic' : ''}',
            onTap: () => onTapItem(item),
          ),
        ],
      ),
    );
  }
}
