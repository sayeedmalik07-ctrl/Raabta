import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/scanner_primitives.dart';

/// Decorative empty-state hero for scanner surfaces.
class ScannerEmptyIllustration extends StatelessWidget {
  const ScannerEmptyIllustration({
    super.key,
    this.icon = Icons.document_scanner_outlined,
    this.size = 120,
  });

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scannerAccent.withValues(alpha: 0.08),
              border: Border.all(
                color: scannerAccent.withValues(alpha: 0.18),
              ),
            ),
          ),
          Container(
            width: size * 0.72,
            height: size * 0.72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cyanGlow.withValues(alpha: 0.1),
              border: Border.all(
                color: AppColors.cyanGlow.withValues(alpha: 0.22),
              ),
            ),
          ),
          Icon(
            icon,
            size: AppSpacing.iconXl,
            color: scannerAccent,
          ),
        ],
      ),
    );
  }
}
