import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_category_icon_chip.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_presentation_tokens.dart';

/// Category / group header with optional see-all affordance.
class GlobalSearchSectionHeader extends StatelessWidget {
  const GlobalSearchSectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.accent,
    this.seeAllLabel,
    this.onSeeAll,
  });

  final String title;
  final IconData? icon;
  final Color? accent;
  final String? seeAllLabel;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final tone = accent ?? AppColors.brandFamilyMain;

    return Semantics(
      header: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            GlobalSearchCategoryIconChip(
              icon: icon!,
              accent: tone,
              size: 36,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Text(
              title,
              style: GlobalSearchPresentationTokens.sectionTitleStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (seeAllLabel != null && onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.brandFamilyText,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                minimumSize: const Size(48, 40),
                tapTargetSize: MaterialTapTargetSize.padded,
              ),
              child: Text(
                seeAllLabel!,
                style: GlobalSearchPresentationTokens.overlineStyle.copyWith(
                  color: AppColors.brandFamilyText,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
