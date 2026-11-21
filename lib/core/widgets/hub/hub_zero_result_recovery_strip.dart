import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';

/// Kit zero-result recovery line (HUB §4 States) — one relaxed filter + undo.
class HubZeroResultRecoveryStrip extends StatelessWidget {
  const HubZeroResultRecoveryStrip({
    super.key,
    required this.message,
    required this.undoLabel,
    required this.onUndo,
  });

  final String message;
  final String undoLabel;
  final VoidCallback onUndo;

  static const stripKey = Key('hub_zero_result_recovery_strip');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        0,
      ),
      child: Material(
        key: stripKey,
        color: AppColors.textPrimary.withValues(
          alpha: HubLayoutTokens.noticeBannerTintAlpha,
        ),
        borderRadius: BorderRadius.circular(HubLayoutTokens.noticeBannerRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.caption.copyWith(
                    fontSize: HubLayoutTokens.noticeBannerFontSize,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: onUndo,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.brandFamilyMain,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  minimumSize: const Size(48, 36),
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
                child: Text(undoLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
