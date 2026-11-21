import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/instant_answer.dart';
import 'package:raabta/features/global_search/presentation/global_search_directional_icons.dart';
import 'package:raabta/features/global_search/presentation/instant_answer_l10n.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_presentation_tokens.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_section_header.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';

/// Deterministic instant answer card — presentation only (Batch 3).
class GlobalSearchInstantAnswerView extends StatelessWidget {
  const GlobalSearchInstantAnswerView({
    super.key,
    required this.answer,
    required this.locale,
    required this.fromCache,
    required this.onTapItem,
  });

  final InstantAnswer answer;
  final String locale;
  final bool fromCache;
  final ValueChanged<GlobalSearchResultItem> onTapItem;

  @override
  Widget build(BuildContext context) {
    final heading = InstantAnswerL10n.heading(locale);
    final primary = InstantAnswerL10n.primaryLine(answer, locale);
    final supporting = InstantAnswerL10n.supportingLine(answer, locale);
    final actionLabel = InstantAnswerL10n.actionLabel(answer, locale);
    final actionItem = answer.actionItem;
    final semanticLabel = InstantAnswerL10n.semanticLabel(
      answer,
      locale,
      fromCache: fromCache,
    );
    final accent = actionItem != null
        ? GlobalSearchPresentationTokens.categoryAccent(actionItem.category)
        : AppColors.brandFamilyMain;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: GlobalSearchPresentationTokens.sectionBottomGap,
      ),
      child: Semantics(
        container: true,
        label: semanticLabel,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlobalSearchSectionHeader(
              title: heading,
              icon: Icons.lightbulb_outline_rounded,
              accent: AppColors.brandFamilyMain,
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(
              onTap: actionItem != null ? () => onTapItem(actionItem) : null,
              padding: const EdgeInsets.all(AppSpacing.md),
              borderRadius: GlobalSearchPresentationTokens.cardRadius,
              glowColor: AppColors.brandFamilyMain,
              glowIntensity: HomeCardTier.homeCardGlowIntensity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Text(
                      primary,
                      style: AppTypography.title.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (supporting != null && supporting.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    ExcludeSemantics(
                      child: Text(
                        supporting,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textOnGlassMuted,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  if (fromCache) ...[
                    const SizedBox(height: AppSpacing.xs),
                    ExcludeSemantics(
                      child: Text(
                        AppShellStrings.t(
                          'global_search_instant_answer_cached',
                          locale,
                        ),
                        style: GlobalSearchPresentationTokens.overlineStyle,
                      ),
                    ),
                  ],
                  if (actionLabel != null && actionItem != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    ExcludeSemantics(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            actionLabel,
                            style: AppTypography.bodySmall.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            GlobalSearchDirectionalIcons.chevronForward(context),
                            size: 16,
                            color: accent,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
