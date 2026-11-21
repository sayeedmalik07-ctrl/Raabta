import 'package:flutter/material.dart';

import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

/// Unified error state with optional retry and dismiss actions.
class GlassErrorState extends StatelessWidget {
  const GlassErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.onDismiss,
    this.retryLabel = 'Retry',
    this.dismissLabel = 'Dismiss',
  });

  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final String retryLabel;
  final String dismissLabel;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      glowColor: AppColors.error,
      glowIntensity: 0.12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: AppSpacing.iconMd,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.body,
                ),
              ),
            ],
          ),
          if (onRetry != null || onDismiss != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                if (onRetry != null)
                  Expanded(
                    child: GlassCard(
                      onTap: onRetry,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      borderRadius: AppSpacing.radiusMd,
                      child: Text(
                        retryLabel,
                        style: AppTypography.subtitle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                if (onRetry != null && onDismiss != null)
                  const SizedBox(width: AppSpacing.sm),
                if (onDismiss != null)
                  Expanded(
                    child: GlassCard(
                      onTap: onDismiss,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      borderRadius: AppSpacing.radiusMd,
                      child: Text(
                        dismissLabel,
                        style: AppTypography.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
