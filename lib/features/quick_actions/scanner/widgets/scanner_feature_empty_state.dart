import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/scanner_empty_illustration.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/scanner_primitives.dart';

/// Premium empty state with illustration, copy, and optional CTA.
class ScannerFeatureEmptyState extends StatelessWidget {
  const ScannerFeatureEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.document_scanner_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return ScannerEntranceReveal(
      child: Column(
        children: [
          ScannerEmptyIllustration(icon: icon),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: AppTypography.headline2,
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
              accentColor: scannerAccent,
              icon: icon,
              onPressed: () {
                scannerLightHaptic();
                onAction!();
              },
            ),
          ],
        ],
      ),
    );
  }
}
