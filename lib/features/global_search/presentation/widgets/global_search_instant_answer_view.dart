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

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Semantics(
        container: true,
        label: semanticLabel,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                heading,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            GlassCard(
              onTap: actionItem != null ? () => onTapItem(actionItem) : null,
              padding: const EdgeInsets.all(AppSpacing.md),
              glowColor: AppColors.cyanGlow,
              glowIntensity: 0.1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Text(
                      primary,
                      style: AppTypography.title.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (supporting != null && supporting.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    ExcludeSemantics(
                      child: Text(
                        supporting,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  if (fromCache) ...[
                    const SizedBox(height: 4),
                    ExcludeSemantics(
                      child: Text(
                        AppShellStrings.t(
                          'global_search_instant_answer_cached',
                          locale,
                        ),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
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
                              color: AppColors.cyanGlow,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            GlobalSearchDirectionalIcons.chevronForward(context),
                            size: 16,
                            color: AppColors.cyanGlow,
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
