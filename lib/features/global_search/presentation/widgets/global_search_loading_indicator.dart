import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

/// Restrained loading indicator for Global Search — respects reduced motion.
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

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final labelKey = refreshing
        ? 'global_search_refreshing'
        : 'global_search_searching';
    final label = AppShellStrings.t(labelKey, locale);

    final indicator = reduceMotion
        ? Icon(
            Icons.hourglass_top_rounded,
            size: compact ? 18 : 22,
            color: AppColors.cyanGlow,
          )
        : SizedBox(
            width: compact ? 18 : 22,
            height: compact ? 18 : 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.cyanGlow,
            ),
          );

    if (compact) {
      return Semantics(
        label: label,
        liveRegion: true,
        child: indicator,
      );
    }

    return Semantics(
      label: label,
      liveRegion: true,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            indicator,
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Thin refresh bar shown above cached results while a search is in flight.
class GlobalSearchRefreshBar extends StatelessWidget {
  const GlobalSearchRefreshBar({
    super.key,
    required this.locale,
  });

  final String locale;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
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
            if (!reduceMotion)
              const SizedBox(
                width: 48,
                child: LinearProgressIndicator(minHeight: 2),
              ),
          ],
        ),
      ),
    );
  }
}
