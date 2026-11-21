import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/know_qatar/data/models/know_qatar_models.dart';
import 'package:raabta/features/know_qatar/presentation/l10n/know_qatar_strings.dart';

class KnowQatarLegalCalloutCard extends StatelessWidget {
  const KnowQatarLegalCalloutCard({
    super.key,
    required this.callout,
    required this.locale,
  });

  final KnowQatarLegalCallout callout;
  final String locale;

  Color _severityColor(KnowQatarCalloutSeverity severity) {
    switch (severity) {
      case KnowQatarCalloutSeverity.info:
        return AppColors.textSecondary;
      case KnowQatarCalloutSeverity.warning:
        return AppColors.accentGold;
      case KnowQatarCalloutSeverity.violation:
      case KnowQatarCalloutSeverity.critical:
        return AppColors.errorBright;
    }
  }

  IconData _severityIcon(KnowQatarCalloutSeverity severity) {
    switch (severity) {
      case KnowQatarCalloutSeverity.info:
        return Icons.info_outline;
      case KnowQatarCalloutSeverity.warning:
        return Icons.warning_amber_outlined;
      case KnowQatarCalloutSeverity.violation:
        return Icons.gavel_outlined;
      case KnowQatarCalloutSeverity.critical:
        return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _severityColor(callout.severity);
    final isCritical = callout.severity == KnowQatarCalloutSeverity.critical ||
        callout.severity == KnowQatarCalloutSeverity.violation;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        glowColor: accent,
        glowIntensity: isCritical ? 0.15 : 0.12,
        backgroundColor: accent.withValues(alpha: 0.06),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(_severityIcon(callout.severity), color: accent, size: 18),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    KnowQatarStrings.t(callout.titleKey, locale),
                    style: AppTypography.title.copyWith(
                      color: isCritical ? AppColors.errorBright : accent,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    KnowQatarStrings.t(callout.bodyKey, locale),
                    style: AppTypography.bodySmall.copyWith(height: 1.45),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
