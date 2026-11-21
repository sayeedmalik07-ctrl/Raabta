import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/case_timeline/data/checklist/case_timeline_checklist_registry.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_engine_type.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_gap_analyzer.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_entry.dart';
import 'package:raabta/features/case_timeline/presentation/l10n/case_timeline_label_resolver.dart';
import 'package:raabta/features/case_timeline/presentation/l10n/case_timeline_strings.dart';

class CaseTimelineGapPanel extends StatelessWidget {
  const CaseTimelineGapPanel({
    super.key,
    required this.locale,
    required this.engine,
    required this.entries,
    this.eosbIncludeSettlement = true,
  });

  final String locale;
  final CaseTimelineEngineType engine;
  final List<CaseTimelineEntry> entries;
  final bool eosbIncludeSettlement;

  @override
  Widget build(BuildContext context) {
    final checklist = CaseTimelineChecklistRegistry.itemsFor(
      engine,
      eosbIncludeSettlement: eosbIncludeSettlement,
    );
    final gaps = CaseTimelineGapAnalyzer.analyze(
      checklist: checklist,
      entries: entries,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          CaseTimelineStrings.t('ct_gap_heading', locale),
          style: AppTypography.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        ...gaps.map((gap) {
          final title = CaseTimelineLabelResolver.checklistTitle(
            engine,
            gap.def.titleKey,
            locale,
          );
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  gap.covered
                      ? Icons.check_circle_outline
                      : Icons.radio_button_unchecked,
                  size: 18,
                  color: gap.covered
                      ? AppColors.chipEosb
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        gap.covered
                            ? CaseTimelineStrings.t('ct_gap_covered', locale)
                            : CaseTimelineStrings.t('ct_gap_missing', locale),
                        style: AppTypography.caption.copyWith(
                          color: gap.covered
                              ? AppColors.textOnGlassMuted
                              : AppColors.chipLease,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
