import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/widgets/score_ring_painter.dart';
import 'package:raabta/features/leaving_qatar/data/leaving_qatar_catalog.dart';
import 'package:raabta/features/leaving_qatar/data/models/leaving_qatar_models.dart';
import 'package:raabta/features/leaving_qatar/presentation/l10n/leaving_qatar_strings.dart';

class LeavingQatarTimelineProgress extends StatelessWidget {
  const LeavingQatarTimelineProgress({
    super.key,
    required this.locale,
    required this.completion,
  });

  final String locale;
  final Map<String, bool> completion;

  @override
  Widget build(BuildContext context) {
    final total = LeavingQatarCatalog.checklist.length;
    final done = LeavingQatarCatalog.checklist
        .where((item) => completion[item.id] == true)
        .length;
    final percent = total == 0 ? 0 : ((done / total) * 100).round();

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.cyanGlow,
      glowIntensity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(72, 72),
                      painter: ScoreRingPainter(
                        progress: percent / 100,
                        strokeWidth: 8,
                        glowColor: AppColors.cyanGlow,
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: AppTypography.subtitle.copyWith(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LeavingQatarStrings.t('lq_timeline_heading', locale),
                      style: AppTypography.subtitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      done == total
                          ? LeavingQatarStrings.t(
                              'lq_timeline_all_done',
                              locale,
                            )
                          : LeavingQatarStrings.tf(
                              'lq_timeline_remaining',
                              locale,
                              {
                                'done': '$done',
                                'total': '$total',
                              },
                            ),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: LeavingQatarTimelineStage.values.map((stage) {
              final stageItems =
                  LeavingQatarCatalog.itemsForStage(stage).toList();
              final stageDone = stageItems
                  .where((item) => completion[item.id] == true)
                  .length;
              final stageTotal = stageItems.length;
              final complete =
                  stageTotal > 0 && stageDone == stageTotal;
              final active = stageTotal > 0 && stageDone > 0 && !complete;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: stage == LeavingQatarTimelineStage.departure
                        ? 0
                        : AppSpacing.xs,
                  ),
                  child: _StageChip(
                    label: _shortStageLabel(stage, locale),
                    complete: complete,
                    active: active,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _shortStageLabel(LeavingQatarTimelineStage stage, String locale) {
    switch (stage) {
      case LeavingQatarTimelineStage.early:
        return LeavingQatarStrings.t('lq_timeline_early_short', locale);
      case LeavingQatarTimelineStage.mid:
        return LeavingQatarStrings.t('lq_timeline_mid_short', locale);
      case LeavingQatarTimelineStage.late:
        return LeavingQatarStrings.t('lq_timeline_late_short', locale);
      case LeavingQatarTimelineStage.departure:
        return LeavingQatarStrings.t('lq_timeline_departure_short', locale);
    }
  }
}

class _StageChip extends StatelessWidget {
  const _StageChip({
    required this.label,
    required this.complete,
    required this.active,
  });

  final String label;
  final bool complete;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = complete
        ? AppColors.emeraldGlow
        : active
            ? AppColors.cyanGlow
            : AppColors.textTertiary;

    return Column(
      children: [
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: color.withValues(alpha: complete || active ? 1 : 0.25),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.caption.copyWith(
            fontSize: 10,
            color: color,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
