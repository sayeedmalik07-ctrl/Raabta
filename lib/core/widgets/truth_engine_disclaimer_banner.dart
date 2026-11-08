import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

/// Shared disclaimer presentation for Truth Engine surfaces.
enum TruthEngineDisclaimerStyle {
  /// Strong legal-warning treatment (EOSB, Health Insurance).
  legalWarning,

  /// Calmer engine-context treatment with optional law disambiguation line.
  engineContext,
}

class TruthEngineDisclaimerBanner extends StatelessWidget {
  const TruthEngineDisclaimerBanner({
    super.key,
    required this.text,
    this.style = TruthEngineDisclaimerStyle.legalWarning,
    this.accentColor = AppColors.warning,
    this.disambiguationText,
  });

  final String text;
  final TruthEngineDisclaimerStyle style;
  final Color accentColor;
  final String? disambiguationText;

  @override
  Widget build(BuildContext context) {
    if (style == TruthEngineDisclaimerStyle.legalWarning) {
      return GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        backgroundColor: AppColors.warning.withValues(alpha: 0.1),
        glowColor: AppColors.warning,
        glowIntensity: 0.08,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: AppTypography.bodySmall.copyWith(color: AppColors.warning),
              ),
            ),
          ],
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: accentColor.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 18, color: accentColor),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  text,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (disambiguationText != null && disambiguationText!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              disambiguationText!,
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
