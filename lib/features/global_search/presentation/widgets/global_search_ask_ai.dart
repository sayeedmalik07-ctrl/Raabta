import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/features/global_search/domain/search_ask_ai_result.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_presentation_tokens.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_result_row.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';

/// ASK RAABTA AI card — explicit user action only (S9).
class GlobalSearchAskAiView extends StatelessWidget {
  const GlobalSearchAskAiView({
    super.key,
    required this.offer,
    required this.onTap,
  });

  final SearchAskAiResult offer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantics = '${offer.displayTitle}. ${offer.displaySubtitle}';

    return Padding(
      padding: const EdgeInsets.only(
        bottom: GlobalSearchPresentationTokens.sectionBottomGap,
      ),
      child: GlobalSearchResultRow(
        icon: Icons.auto_awesome_outlined,
        accent: AppColors.brandFamilyMain,
        glowColor: AppColors.brandFamilyMain,
        glowIntensity: HomeCardTier.contextualGlowIntensity,
        title: offer.displayTitle,
        subtitle:
            offer.displaySubtitle.isNotEmpty ? offer.displaySubtitle : null,
        semanticLabel: semantics,
        onTap: onTap,
      ),
    );
  }
}
