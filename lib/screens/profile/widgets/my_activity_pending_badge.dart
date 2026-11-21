import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/typography/app_typography.dart';

/// Count badge matching [GlassStatusHeader] notification styling.
class MyActivityPendingBadge extends StatelessWidget {
  const MyActivityPendingBadge({
    super.key,
    required this.count,
  });

  /// Null hides the badge when aggregation is incomplete or unavailable.
  final int? count;

  @override
  Widget build(BuildContext context) {
    if (count == null || count! <= 0) return const SizedBox.shrink();

    final label = count! > 99 ? '99+' : '$count';
    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.roseGlow,
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: AppColors.textPrimary,
          fontSize: 11,
          height: 1,
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
