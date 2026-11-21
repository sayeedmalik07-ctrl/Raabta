import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/scam_shield/domain/scam_stop_signal_engine.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';

/// Hard STOP interrupt — high-contrast treatment on existing error palette.
class ScamShieldStopBanner extends StatelessWidget {
  const ScamShieldStopBanner({
    super.key,
    required this.stop,
    required this.locale,
  });

  final ScamStopSignalResult stop;
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (!stop.triggered) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.errorBright.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.errorBright,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.block, color: AppColors.errorBright, size: 28),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  ScamShieldStrings.t(stop.headlineKey, locale),
                  style: AppTypography.headline2.copyWith(
                    color: AppColors.errorBright,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          if (stop.explanationKey != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              ScamShieldStrings.t(stop.explanationKey!, locale),
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
