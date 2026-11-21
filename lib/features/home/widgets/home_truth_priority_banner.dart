import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/domain/truth_home_priority.dart';
import 'package:raabta/features/home/utils/home_truth_chip_navigation.dart';
import 'package:raabta/features/home/widgets/home_tool_rail_titles.dart';

/// Supplementary Know-your-rights priority (below Today hero — never replaces Expat Score).
class HomeTruthPriorityBanner extends StatelessWidget {
  const HomeTruthPriorityBanner({
    super.key,
    required this.priority,
    required this.locale,
  });

  final TruthHomePriority priority;
  final String locale;

  @visibleForTesting
  static String accessibilityLabel({
    required String title,
    required String statusText,
  }) =>
      '$title, $statusText';

  @override
  Widget build(BuildContext context) {
    if (priority is! TruthHomePriorityReady) {
      return const SizedBox.shrink();
    }
    final status = (priority as TruthHomePriorityReady).status;
    final title = HomeToolRailTitles.forRoute(status.engine.homeRoute, locale);
    final route = resolveTruthChipTapRoute(status);
    final semanticsLabel = accessibilityLabel(
      title: title,
      statusText: status.statusText,
    );
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Semantics(
        button: true,
        label: semanticsLabel,
        child: ExcludeSemantics(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push(route),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Ink(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                color: AppColors.goldFamilyMain.withValues(alpha: 0.08),
                border: Border.all(
                  color: AppColors.goldFamilyMain.withValues(alpha: 0.28),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.goldFamilyText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          status.statusText,
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 12.5,
                            color: AppColors.textOnGlassSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isRtl ? Icons.chevron_left : Icons.chevron_right,
                    color: AppColors.textOnGlassMuted,
                  ),
                ],
              ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
