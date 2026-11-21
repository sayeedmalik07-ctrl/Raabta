import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';

/// Hub sub-screen kit saved-search row (title, subtitle, optional badge, alerts switch).
class HubSavedSearchRow extends StatelessWidget {
  const HubSavedSearchRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.active,
    required this.onActiveChanged,
    this.newMatchLabel,
    this.onMore,
  });

  final String title;
  final String subtitle;
  final bool active;
  final ValueChanged<bool> onActiveChanged;
  final String? newMatchLabel;
  final VoidCallback? onMore;

  static const rowKey = Key('hub_saved_search_row');

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.subtitle.copyWith(fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (newMatchLabel != null && newMatchLabel!.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.sm),
            StatusBadge(
              label: newMatchLabel!,
              color: AppColors.brandFamilyMain,
            ),
          ],
          Switch.adaptive(
            value: active,
            onChanged: onActiveChanged,
            activeColor: AppColors.brandFamilyMain,
          ),
          if (onMore != null)
            IconButton(
              onPressed: onMore,
              icon: Icon(Icons.more_horiz, color: AppColors.textSecondary),
              tooltip: MaterialLocalizations.of(context).showMenuTooltip,
            ),
        ],
      ),
    );
  }
}
