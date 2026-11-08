import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/quick_actions/climate_navigator/data/wbgt_estimate_uncertainty.dart';
import 'package:raabta/features/quick_actions/climate_navigator/l10n/climate_strings.dart';
import 'package:raabta/features/quick_actions/climate_navigator/presentation/climate_wbgt_status_presentation.dart';

/// Approximate range and non-legal "close to" band messaging (Part 1B).
class ClimateWbgtUncertaintyBlock extends StatelessWidget {
  const ClimateWbgtUncertaintyBlock({
    super.key,
    required this.estimateC,
    required this.locale,
  });

  final double estimateC;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final range = WbgtEstimateUncertainty.approximateRange(estimateC);
    final closeTo = WbgtEstimateUncertainty.closeToNonLegalBandKey(estimateC);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          ClimateStrings.format(
            'uncertainty_approx_range',
            locale,
            params: {
              'low': range.low.toStringAsFixed(1),
              'high': range.high.toStringAsFixed(1),
              'margin':
                  WbgtEstimateUncertainty.provisionalMarginC.toStringAsFixed(1),
            },
          ),
          style: AppTypography.caption.copyWith(
            color: AppColors.textOnGlassMuted,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          ClimateStrings.t('uncertainty_site_variation_note', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
            height: 1.35,
          ),
        ),
        if (closeTo != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ClimateWbgtStatusPresentation.accentForLevel(closeTo)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: ClimateWbgtStatusPresentation.accentForLevel(closeTo)
                    .withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ClimateStrings.format(
                    'uncertainty_close_to_title',
                    locale,
                    params: {
                      'level': ClimateStrings.t(
                        ClimateWbgtStatusPresentation.shortLabelKeyForLevel(
                          closeTo,
                        ),
                        locale,
                      ),
                    },
                  ),
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: ClimateWbgtStatusPresentation.accentForLevel(closeTo),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ClimateStrings.t(
                    ClimateWbgtStatusPresentation.guidanceKeyForLevel(closeTo),
                    locale,
                  ),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textOnGlassSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 6),
        Text(
          ClimateStrings.t('uncertainty_provisional_margin_note', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
            fontSize: 10,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
