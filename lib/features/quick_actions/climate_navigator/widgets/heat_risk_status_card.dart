import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/quick_actions/climate_navigator/l10n/climate_strings.dart';
import 'package:raabta/features/quick_actions/climate_navigator/models/qatar_weather.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/climate_primitives.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/hydration_reminder_toggle.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/outdoor_work_compliance_panel.dart';

/// WBGT estimate + Qatar labour heat rules — deterministic, no AI.
class HeatRiskStatusCard extends StatelessWidget {
  const HeatRiskStatusCard({
    super.key,
    required this.weather,
    required this.locale,
    this.onOpenGuide,
  });

  final QatarWeather weather;
  final String locale;

  /// Opens offline heat-illness guide (Part C).
  final VoidCallback? onOpenGuide;

  @override
  Widget build(BuildContext context) {
    final wbgt = weather.wbgtEstimateC;
    final levelKey = weather.wbgtRiskLevelKey;
    final accent = _accentForLevel(levelKey);
    final showWorkStop = weather.requiresWorkStop;
    final showSummerHours = weather.isSummerRestrictedNow;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      glowColor: accent,
      glowIntensity: showWorkStop ? 0.18 : 0.08,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ClimateStrings.t('wbgt_title', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${wbgt.toStringAsFixed(1)}°C',
                style: AppTypography.title.copyWith(
                  color: accent,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  ClimateStrings.wbgtRiskLabel(levelKey, locale),
                  style: AppTypography.caption.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            ClimateStrings.t('wbgt_approx_note', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${ClimateStrings.t('heat_index_label', locale)}: '
            '${weather.heatIndexC.toStringAsFixed(1)}°C',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (showWorkStop) ...[
            const SizedBox(height: 12),
            ClimateHapticOnReveal(
              child: ClimateEntranceReveal(
                child: _AlertBox(
                  title: ClimateStrings.t('work_stop_alert_title', locale),
                  body: ClimateStrings.t('work_stop_alert_body', locale),
                  color: AppColors.errorBright,
                ),
              ),
            ),
          ],
          if (showSummerHours) ...[
            const SizedBox(height: 10),
            ClimateEntranceReveal(
              delay: const Duration(milliseconds: 80),
              child: _AlertBox(
                title: ClimateStrings.t('summer_hours_alert_title', locale),
                body: ClimateStrings.t('summer_hours_alert_body', locale),
                color: AppColors.accentGold,
              ),
            ),
          ],
          OutdoorWorkCompliancePanel(
            weather: weather,
            locale: locale,
          ),
          const SizedBox(height: 4),
          HydrationReminderToggle(locale: locale),
          if (onOpenGuide != null) ...[
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: onOpenGuide,
              icon: const Icon(Icons.menu_book_outlined, size: 18),
              label: Text(ClimateStrings.t('open_guide', locale)),
            ),
          ],
          if (kDebugMode) ...[
            const SizedBox(height: 8),
            Text(
              'Debug: set HeatRiskCalculator.debugWbgtOverrideC > 32.1 to test work-stop UI',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _accentForLevel(String levelKey) {
    switch (levelKey) {
      case 'work_stop':
        return AppColors.errorBright;
      case 'extreme':
        return AppColors.error;
      case 'high':
        return AppColors.heatOrange;
      case 'moderate':
        return AppColors.accentGold;
      default:
        return AppColors.successBright;
    }
  }
}

class _AlertBox extends StatelessWidget {
  const _AlertBox({
    required this.title,
    required this.body,
    required this.color,
  });

  final String title;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
