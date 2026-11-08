import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

/// Kit-aligned urgency for Visa / Documents deadline lists (semantic colors only).
enum HubDeadlineUrgencyTier {
  /// Under ~30 days — [AppColors.errorBright] family use at implementation.
  critical,

  /// ~30–90 days — amber / gold-adjacent token.
  attention,

  /// 90+ days — success token.
  comfortable,
}

Color hubDeadlineUrgencyColor(HubDeadlineUrgencyTier tier) {
  return switch (tier) {
    HubDeadlineUrgencyTier.critical => AppColors.errorBright,
    HubDeadlineUrgencyTier.attention => AppColors.accentGold,
    HubDeadlineUrgencyTier.comfortable => AppColors.successBright,
  };
}

/// Single deadline summary row: colored rail + title + optional subtitle (dates, meta).
class HubDeadlineUrgencyRow extends StatelessWidget {
  const HubDeadlineUrgencyRow({
    super.key,
    required this.tier,
    required this.title,
    this.subtitle,
    this.semanticsLabel,
  });

  final HubDeadlineUrgencyTier tier;
  final String title;
  final String? subtitle;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final color = hubDeadlineUrgencyColor(tier);
    final label = semanticsLabel ?? title;

    return Semantics(
      container: true,
      label: subtitle != null ? '$label. $subtitle' : label,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(
                end: AppSpacing.sm,
                top: 4,
              ),
              child: SizedBox(
                width: 4,
                height: 36,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.subtitle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textOnGlassMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
