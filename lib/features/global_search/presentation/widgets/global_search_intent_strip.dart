import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/global_search/domain/search_intent_interpretation.dart';
import 'package:raabta/features/global_search/presentation/search_intent_interpretation_l10n.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_category_icon_chip.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_presentation_tokens.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';

/// Compact interpretation of what RAABTA understood from the current query.
class GlobalSearchIntentStrip extends StatelessWidget {
  const GlobalSearchIntentStrip({
    super.key,
    required this.interpretation,
    required this.locale,
  });

  final SearchIntentInterpretation interpretation;
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (!interpretation.isMeaningful) return const SizedBox.shrink();

    final header = AppShellStrings.t(
      SearchIntentInterpretationL10n.headerKey(interpretation.header),
      locale,
    );
    final segments = interpretation.segments
        .map((s) => SearchIntentInterpretationL10n.segmentLabel(s, locale))
        .join(' · ');

    return Semantics(
      label: '$header. $segments',
      child: GlassCard(
        padding: GlobalSearchPresentationTokens.cardPadding,
        margin: EdgeInsets.zero,
        borderRadius: GlobalSearchPresentationTokens.cardRadius,
        glowColor: AppColors.brandFamilyMain,
        glowIntensity: HomeCardTier.homeCardGlowIntensity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlobalSearchCategoryIconChip(
              icon: Icons.auto_awesome_outlined,
              accent: AppColors.brandFamilyMain,
              size: 36,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    header,
                    style: GlobalSearchPresentationTokens.overlineStyle,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    segments,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
