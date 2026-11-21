import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/eosb/domain/models/employer_track_record_lookup.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/employer_track_record_panel.dart';

/// Shared aggregate display for Employer Track Record (Parts D + F).
///
/// [showInsufficientData] — when true (proactive lookup), shows the generic
/// below-threshold message. When false (reactive intake), hides entirely.
class EmployerTrackRecordResultCard extends StatelessWidget {
  const EmployerTrackRecordResultCard({
    super.key,
    required this.lookup,
    required this.locale,
    this.showInsufficientData = false,
  });

  final EmployerTrackRecordLookup lookup;
  final String locale;
  final bool showInsufficientData;

  @override
  Widget build(BuildContext context) {
    if (lookup.isAvailable) {
      final total = lookup.totalCalculations ?? 0;
      final violations = lookup.violationFlaggedCount ?? 0;
      final body = formatEmployerTrackRecordBody(
        locale: locale,
        totalCalculations: total,
        violationFlaggedCount: violations,
      );
      final velocityLine = lookup.increasedReportsSignal
          ? formatEmployerTrackRecordVelocityLine(
              locale: locale,
              windowDays: lookup.velocityWindowDays ?? 21,
            )
          : null;

      return _CardShell(
        body: body,
        velocityLine: velocityLine,
        locale: locale,
        icon: Icons.analytics_outlined,
      );
    }

    if (!showInsufficientData) {
      return const SizedBox.shrink();
    }

    return _CardShell(
      body: EosbStrings.t('employer_track_record_insufficient', locale),
      locale: locale,
      icon: Icons.info_outline_rounded,
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.body,
    required this.locale,
    required this.icon,
    this.velocityLine,
  });

  final String body;
  final String? velocityLine;
  final String locale;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.brandFamilyMain,
      glowIntensity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(body, style: AppTypography.bodySmall),
                    if (velocityLine != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        velocityLine!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            EosbStrings.t('employer_track_record_disclaimer', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
