import 'package:flutter/foundation.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/heat_risk_calculator.dart';

/// Provisional UX margin around on-device WBGT **estimates** (Part 1B).
///
/// **Not** a validated confidence interval or error bound for Raabta's formula.
/// Literature on spatial/temporal WBGT variability (e.g. Bernard & Barrow, 2013,
/// on practical WBGT limits; and 2024 microclimate / site-variation heat-stress
/// studies) motivates showing *possible* nearby conditions — those sources do
/// **not** validate this app's Stull + synthetic-solar approximation.
abstract final class WbgtEstimateUncertainty {
  static const provisionalMarginC = 2.0;

  static const nonLegalBandOrder = <String>[
    'lower',
    'moderate',
    'high',
    'extreme',
  ];

  static ({double low, double high}) approximateRange(double estimateC) {
    final low = estimateC - provisionalMarginC;
    final high = estimateC + provisionalMarginC;
    return (low: low, high: high);
  }

  /// Upper edge of the approximate range mapped to a band key (may include
  /// `work_stop` for display math only — never used for legal proximity UX).
  @visibleForTesting
  static String upperBandKey(double estimateC) =>
      HeatRiskCalculator.riskLevelLabel(estimateC + provisionalMarginC);

  /// When [estimate] + margin reaches a higher **non-legal** band, returns that
  /// band key for "Close to …" guidance. Never returns `work_stop` and never
  /// signals proximity to the 32.1 °C workplace rule.
  static String? closeToNonLegalBandKey(double estimateC) {
    final current = HeatRiskCalculator.riskLevelLabel(estimateC);
    final upper = upperBandKey(estimateC);
    if (upper == current) return null;
    if (upper == 'work_stop') return null;
    if (!nonLegalBandOrder.contains(upper) ||
        !nonLegalBandOrder.contains(current)) {
      return null;
    }
    final currentIdx = nonLegalBandOrder.indexOf(current);
    final upperIdx = nonLegalBandOrder.indexOf(upper);
    if (upperIdx > currentIdx) return upper;
    return null;
  }

  static int bandRank(String levelKey) {
    switch (levelKey) {
      case 'work_stop':
        return 5;
      case 'extreme':
        return 4;
      case 'high':
        return 3;
      case 'moderate':
        return 2;
      case 'lower':
        return 1;
      default:
        return 0;
    }
  }

  /// Meter reading caution: higher local reading may surface stronger guidance.
  /// Returns null when meter band is not above [estimateBandKey].
  static String? meterCautionBandKey({
    required double meterWbgtC,
    required String estimateBandKey,
  }) {
    final meterKey = HeatRiskCalculator.riskLevelLabel(meterWbgtC);
    if (bandRank(meterKey) <= bandRank(estimateBandKey)) return null;
    return meterKey;
  }
}
