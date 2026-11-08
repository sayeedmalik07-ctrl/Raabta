import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';

import 'food_inspector_empty_illustration.dart';

/// Premium empty / error state for Food Inspector scan surfaces.
class FoodInspectorEmptyState extends StatelessWidget {
  const FoodInspectorEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.qr_code_scanner_rounded,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.compact = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final bool compact;

  static const _accent = AppColors.purpleGlow;

  @override
  Widget build(BuildContext context) {
    final illustrationSize = compact ? 88.0 : 112.0;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: compact ? AppSpacing.md : AppSpacing.xl,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FoodInspectorEmptyIllustration(
              icon: icon,
              size: illustrationSize,
            ),
            SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
            Text(
              title,
              style: compact ? AppTypography.title : AppTypography.headline2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textOnGlassMuted,
              ),
              textAlign: TextAlign.center,
            ),
            if (primaryActionLabel != null && onPrimaryAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              GlassPrimaryButton(
                label: primaryActionLabel!,
                expand: true,
                accentColor: _accent,
                icon: icon,
                onPressed: onPrimaryAction,
              ),
            ],
            if (secondaryActionLabel != null && onSecondaryAction != null) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: onSecondaryAction,
                child: Text(
                  secondaryActionLabel!,
                  style: AppTypography.link.copyWith(color: AppColors.amberGlow),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
