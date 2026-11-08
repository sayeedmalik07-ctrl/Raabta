import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/quick_actions/climate_navigator/data/qatar_outdoor_work_rules.dart';
import 'package:raabta/features/quick_actions/climate_navigator/l10n/climate_strings.dart';

/// B1 — static Qatar heat worker rights (Ministerial Decision 17/2021); no reporting UI.
class HeatWorkerRightsCard extends StatelessWidget {
  const HeatWorkerRightsCard({super.key, required this.locale});

  final String locale;

  static final _ruleParams = {
    'season': QatarOutdoorWorkRules.seasonRangeLabel,
    'window': QatarOutdoorWorkRules.restrictedWindowLabel,
    'threshold': QatarOutdoorWorkRules.wbgtWorkStopThresholdC.toString(),
    'decision': QatarOutdoorWorkRules.regulationCitation,
    'ministry': QatarOutdoorWorkRules.ministryName,
  };

  @override
  Widget build(BuildContext context) {
    final bullets = [
      ClimateStrings.format('rights_bullet_art1_definitions', locale,
          params: _ruleParams),
      ClimateStrings.format('rights_bullet_art2_seasonal_restriction', locale,
          params: _ruleParams),
      ClimateStrings.format(
          'rights_bullet_art1_shaded_ventilated_qualification', locale,
          params: _ruleParams),
      ClimateStrings.format('rights_bullet_art4_3_water', locale,
          params: _ruleParams),
      ClimateStrings.format('rights_bullet_art4_4_shade_rest', locale,
          params: _ruleParams),
      ClimateStrings.format('rights_bullet_art4_8_wbgt_adoption', locale,
          params: _ruleParams),
      ClimateStrings.format('rights_bullet_art4_9_wbgt_stop', locale,
          params: _ruleParams),
      ClimateStrings.format('rights_bullet_art6_stop_complaint_supervisor', locale,
          params: _ruleParams),
      ClimateStrings.format('rights_bullet_art6_protection', locale,
          params: _ruleParams),
      ClimateStrings.format('rights_bullet_art7_penalties', locale,
          params: _ruleParams),
    ];

    return Semantics(
      container: true,
      label: ClimateStrings.t('section_worker_rights_title', locale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BannerBox(
            child: Text(
              ClimateStrings.t('rights_applicability_art8_banner', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            ClimateStrings.t('rights_disclaimer_informational', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ClimateStrings.t('rights_wbgt_workplace_vs_estimate', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Text(
            ClimateStrings.t('rights_binding_law_heading', locale),
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...bullets.map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                text,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ClimateStrings.t('rights_guidance_nonbinding_note', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            ClimateStrings.format('rights_source_cite', locale,
                params: _ruleParams),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            ClimateStrings.t('rights_al_meezan_verify_note', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerBox extends StatelessWidget {
  const _BannerBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.22),
        ),
      ),
      child: child,
    );
  }
}
