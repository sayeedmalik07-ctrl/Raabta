import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/quick_actions/climate_navigator/data/qatar_outdoor_work_rules.dart'
    show OutdoorWorkComplianceStatus, QatarOutdoorWorkRules;
import 'package:raabta/features/quick_actions/climate_navigator/l10n/climate_strings.dart';
import 'package:raabta/features/quick_actions/climate_navigator/models/qatar_weather.dart';

/// Yes/No outdoor-work restriction status with separate clock-ban vs WBGT lines.
class OutdoorWorkCompliancePanel extends StatelessWidget {
  const OutdoorWorkCompliancePanel({
    super.key,
    required this.weather,
    required this.locale,
  });

  final QatarWeather weather;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final compliance = weather.outdoorWorkCompliance;
    final restricted = compliance.isOutdoorWorkRestricted;
    final accent =
        restricted ? AppColors.errorBright : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 24),
        Text(
          ClimateStrings.t('compliance_restricted_question', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _YesNoBadge(
              label: restricted
                  ? ClimateStrings.t('compliance_yes', locale)
                  : ClimateStrings.t('compliance_no', locale),
              color: accent,
              emphasized: true,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _StatusLine(
          label: ClimateStrings.t('compliance_clock_ban_label', locale),
          value: _clockBanLine(compliance),
          active: compliance.isClockBanWindowActive,
        ),
        const SizedBox(height: 8),
        _StatusLine(
          label: ClimateStrings.t('compliance_wbgt_label', locale),
          value: _wbgtLine(compliance),
          active: compliance.isWbgtStopRequired,
        ),
        if (compliance.isOffSeason) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.textSecondary.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              ClimateStrings.t('compliance_off_season_note', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          ClimateStrings.format(
            'compliance_regulation_cite',
            locale,
            params: {
              'decision': QatarOutdoorWorkRules.regulationCitation,
              'ministry': QatarOutdoorWorkRules.ministryName,
              'season': QatarOutdoorWorkRules.seasonRangeLabel,
              'window': QatarOutdoorWorkRules.restrictedWindowLabel,
              'threshold':
                  QatarOutdoorWorkRules.wbgtWorkStopThresholdC.toString(),
            },
          ),
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            height: 1.35,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          ClimateStrings.t('compliance_shaded_exception_note', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary.withValues(alpha: 0.85),
            height: 1.35,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          ClimateStrings.t('compliance_disclaimer', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary.withValues(alpha: 0.75),
            height: 1.35,
            fontSize: 10,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  String _clockBanLine(OutdoorWorkComplianceStatus compliance) {
    if (compliance.isOffSeason) {
      return ClimateStrings.t('compliance_clock_ban_off_season', locale);
    }
    if (compliance.isClockBanWindowActive) {
      return ClimateStrings.format(
        'compliance_clock_ban_active',
        locale,
        params: {'window': QatarOutdoorWorkRules.restrictedWindowLabel},
      );
    }
    return ClimateStrings.format(
      'compliance_clock_ban_inactive',
      locale,
      params: {'window': QatarOutdoorWorkRules.restrictedWindowLabel},
    );
  }

  String _wbgtLine(OutdoorWorkComplianceStatus compliance) {
    if (compliance.isWbgtStopRequired) {
      return ClimateStrings.format(
        'compliance_wbgt_active',
        locale,
        params: {
          'wbgt': compliance.wbgtEstimateC.toStringAsFixed(1),
          'threshold':
              QatarOutdoorWorkRules.wbgtWorkStopThresholdC.toString(),
        },
      );
    }
    return ClimateStrings.format(
      'compliance_wbgt_inactive',
      locale,
      params: {
        'wbgt': compliance.wbgtEstimateC.toStringAsFixed(1),
        'threshold': QatarOutdoorWorkRules.wbgtWorkStopThresholdC.toString(),
      },
    );
  }
}

class _YesNoBadge extends StatelessWidget {
  const _YesNoBadge({
    required this.label,
    required this.color,
    required this.emphasized,
  });

  final String label;
  final Color color;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: emphasized ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: AppTypography.subtitle.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.label,
    required this.value,
    required this.active,
  });

  final String label;
  final String value;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.errorBright : AppColors.successBright;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          active ? Icons.warning_amber_rounded : Icons.check_circle_outline,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary.withValues(alpha: 0.85),
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
