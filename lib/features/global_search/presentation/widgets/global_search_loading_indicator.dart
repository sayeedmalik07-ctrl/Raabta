import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';

/// Shape-matched loading for Global Search — hub skeletons, not spinners.
class GlobalSearchLoadingIndicator extends StatelessWidget {
  const GlobalSearchLoadingIndicator({
    super.key,
    required this.locale,
    this.compact = false,
    this.refreshing = false,
  });

  final String locale;
  final bool compact;
  final bool refreshing;

  static const _skeletonCount = 4;
  static const _rowHeight = 88.0;

  @override
  Widget build(BuildContext context) {
    final labelKey = refreshing
        ? 'global_search_refreshing'
        : 'global_search_searching';
    final label = AppShellStrings.t(labelKey, locale);

    if (compact) {
      return Semantics(
        label: label,
        liveRegion: true,
        child: const SizedBox(
          width: 64,
          height: 28,
          child: HubLoadingPlaceholder(
            height: 28,
            width: 64,
            silhouette: HubLoadingSilhouette.formTool,
          ),
        ),
      );
    }

    return Semantics(
      label: label,
      liveRegion: true,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < _skeletonCount; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: HubLoadingPlaceholder(
                height: _rowHeight,
                width: double.infinity,
                silhouette: HubLoadingSilhouette.formTool,
              ),
            ),
        ],
      ),
    );
  }
}

/// Refresh affordance above cached results while a search is in flight.
class GlobalSearchRefreshBar extends StatelessWidget {
  const GlobalSearchRefreshBar({
    super.key,
    required this.locale,
  });

  final String locale;

  @override
  Widget build(BuildContext context) {
    final label = AppShellStrings.t('global_search_refreshing', locale);

    return Semantics(
      label: label,
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          children: [
            GlobalSearchLoadingIndicator(
              locale: locale,
              compact: true,
              refreshing: true,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
