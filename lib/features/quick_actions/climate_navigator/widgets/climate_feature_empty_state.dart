import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/climate_empty_illustration.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/climate_primitives.dart';

/// Premium empty state with illustration, copy, and optional CTA.
class ClimateFeatureEmptyState extends StatelessWidget {
  const ClimateFeatureEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.thermostat_rounded,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final illustrationSize = compact ? 88.0 : 120.0;

    return ClimateEntranceReveal(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: compact ? AppSpacing.md : AppSpacing.lg,
        ),
        child: Column(
          children: [
            ClimateEmptyIllustration(icon: icon, size: illustrationSize),
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
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              GlassPrimaryButton(
                label: actionLabel!,
                expand: true,
                accentColor: climateAccent,
                icon: icon,
                onPressed: () {
                  climateLightHaptic();
                  onAction!();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
