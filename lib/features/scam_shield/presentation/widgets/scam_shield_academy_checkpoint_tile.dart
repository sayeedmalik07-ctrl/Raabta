import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

/// Concierge-style checkpoint tile for Academy walkthrough.
class ScamShieldAcademyCheckpointTile extends StatelessWidget {
  const ScamShieldAcademyCheckpointTile({
    super.key,
    required this.title,
    required this.explain,
    required this.exampleLabel,
    required this.example,
    required this.whyLabel,
    required this.why,
    required this.markReadLabel,
    required this.completed,
    required this.isCurrent,
    this.trailing,
    this.extra,
    this.onMarkRead,
  });

  final String title;
  final String explain;
  final String exampleLabel;
  final String example;
  final String whyLabel;
  final String why;
  final String markReadLabel;
  final bool completed;
  final bool isCurrent;
  final Widget? trailing;
  final Widget? extra;
  final VoidCallback? onMarkRead;

  @override
  Widget build(BuildContext context) {
    final accent = completed ? AppColors.chipEosb : AppColors.cyanGlow;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        glowColor: isCurrent ? accent : null,
        glowIntensity: isCurrent ? 0.14 : 0.04,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  completed
                      ? Icons.check_circle_outline
                      : Icons.radio_button_unchecked,
                  color: accent,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(title, style: AppTypography.subtitle),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(explain, style: AppTypography.bodySmall),
            if (extra != null) ...[
              const SizedBox(height: AppSpacing.sm),
              extra!,
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(
              exampleLabel,
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(example, style: AppTypography.bodySmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              whyLabel,
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(why, style: AppTypography.bodySmall),
            if (!completed && onMarkRead != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: onMarkRead,
                  child: Text(markReadLabel),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
