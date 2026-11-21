import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/quick_actions/climate_navigator/l10n/climate_strings.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/climate_acclimatization_schedule.dart';

/// A2 — NIOSH/OSHA exposure % from saved Qatar start date (no hours assumed).
class AcclimatizationSchedulePanel extends StatelessWidget {
  const AcclimatizationSchedulePanel({
    super.key,
    required this.locale,
    required this.startDate,
    this.referenceNow,
  });

  final String locale;
  final DateTime startDate;
  final DateTime? referenceNow;

  @override
  Widget build(BuildContext context) {
    final snap = ClimateAcclimatizationSchedule.snapshot(
      startDate: startDate,
      referenceNow: referenceNow,
    );

    final guidance = _guidanceFor(snap);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          ClimateStrings.t('acclimat_schedule_disclaimer_occupational', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          ClimateStrings.t('acclimat_schedule_disclaimer_not_proof', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            height: 1.35,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          ClimateStrings.t('acclimat_schedule_disclaimer_risk', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            height: 1.35,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.md),
        if (snap.phase == AcclimatizationSchedulePhase.notStarted) ...[
          Text(
            ClimateStrings.t('acclimat_schedule_not_started', locale),
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ] else ...[
          Text(
            ClimateStrings.format(
              'acclimat_schedule_plan_day',
              locale,
              params: {'day': '${snap.planDay}'},
            ),
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (snap.showExposurePercent) ...[
            Text(
              ClimateStrings.format(
                'acclimat_schedule_exposure_cap',
                locale,
                params: {'percent': '${snap.exposurePercent}'},
              ),
              style: AppTypography.body.copyWith(
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              ClimateStrings.t('acclimat_schedule_baseline_explainer', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            guidance,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        Text(
          ClimateStrings.t('acclimat_schedule_source', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  String _guidanceFor(AcclimatizationScheduleSnapshot snap) {
    switch (snap.phase) {
      case AcclimatizationSchedulePhase.notStarted:
        return ClimateStrings.t('acclimat_schedule_guidance_not_started', locale);
      case AcclimatizationSchedulePhase.ramp:
        return ClimateStrings.format(
          'acclimat_schedule_guidance_ramp',
          locale,
          params: {'percent': '${snap.exposurePercent}'},
        );
      case AcclimatizationSchedulePhase.fullExposureSupervision:
        return ClimateStrings.t(
          'acclimat_schedule_guidance_supervision',
          locale,
        );
      case AcclimatizationSchedulePhase.afterSupervisionWindow:
        return ClimateStrings.t(
          'acclimat_schedule_guidance_after_supervision',
          locale,
        );
    }
  }
}
