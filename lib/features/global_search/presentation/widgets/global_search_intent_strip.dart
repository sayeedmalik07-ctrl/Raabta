import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/global_search/domain/search_intent_interpretation.dart';
import 'package:raabta/features/global_search/presentation/search_intent_interpretation_l10n.dart';

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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        margin: EdgeInsets.zero,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 18,
              color: AppColors.cyanGlow.withValues(alpha: 0.9),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    header,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
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
