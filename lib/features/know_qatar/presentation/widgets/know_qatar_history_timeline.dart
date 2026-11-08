import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/know_qatar/data/models/know_qatar_models.dart';
import 'package:raabta/features/know_qatar/presentation/l10n/know_qatar_strings.dart';

/// Horizontal history timeline — visual pattern inspired by EOSB employment timeline.
class KnowQatarHistoryTimeline extends StatelessWidget {
  const KnowQatarHistoryTimeline({
    super.key,
    required this.milestones,
    required this.locale,
  });

  final List<KnowQatarTimelineMilestone> milestones;
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (milestones.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          KnowQatarStrings.t('kq_timeline_title', locale),
          style: AppTypography.title.copyWith(fontSize: 14),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: AppColors.glassBorder),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.xs,
          ),
          child: SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: milestones.length,
            separatorBuilder: (_, _) => SizedBox(
              width: 24,
              child: Center(
                child: Container(
                  height: 2,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
            ),
            itemBuilder: (context, index) {
              final m = milestones[index];
              final color = Color(m.colorValue);
              return SizedBox(
                width: 148,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: color),
                          ),
                          child: Icon(m.icon, color: color, size: 16),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          KnowQatarStrings.t(m.yearKey, locale),
                          style: AppTypography.caption.copyWith(color: color),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      KnowQatarStrings.t(m.titleKey, locale),
                      style: AppTypography.title.copyWith(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      KnowQatarStrings.t(m.subtitleKey, locale),
                      style: AppTypography.caption,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        ),
      ],
    );
  }
}
