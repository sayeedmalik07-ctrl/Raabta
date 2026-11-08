import 'dart:math' as math;

import 'package:raabta/features/quick_actions/climate_navigator/data/qatar_outdoor_work_rules.dart';

/// Inputs for on-device WBGT approximation — no network, no AI.
class HeatRiskInputs {
  const HeatRiskInputs({
    required this.airTempC,
    required this.humidityPercent,
    required this.cloudCoverPercent,
    required this.observedAt,
    this.windSpeedMs = 0,
  });

  final double airTempC;
  final int humidityPercent;

  /// 0–100 from OpenWeather `clouds.all`, when available.
  final int cloudCoverPercent;

  /// OpenWeather wind speed (m/s) — modest cooling adjustment when present.
  final double windSpeedMs;

  /// Observation time — converted to Qatar local inside [HeatRiskCalculator].
  final DateTime observedAt;
}

/// Deterministic Qatar heat-risk math (WBGT estimate + labour rules).
///
/// WBGT here is an **approximation** from temperature, humidity, cloud cover,
/// wind, and solar load — **not** a certified ISO 7243 black-globe instrument reading.
abstract final class HeatRiskCalculator {
  /// Re-export for callers that already reference [HeatRiskCalculator].
  static const workStopWbgtThresholdC =
      QatarOutdoorWorkRules.wbgtWorkStopThresholdC;

  /// Qatar is UTC+3 year-round (no DST).
  static const qatarUtcOffset = Duration(hours: 3);

  /// Debug-only override for manual UI verification (see [effectiveWbgtC]).
  static double? debugWbgtOverrideC;

  /// Approximate WBGT (°C): 0.7×Tw + 0.2×Tg + 0.1×Ta.
  ///
  /// Not instrument-grade — label as estimate in all user-facing copy.
  static double estimateWbgtC(HeatRiskInputs inputs) {
    final wetBulb = _estimateWetBulbC(
      inputs.airTempC,
      inputs.humidityPercent,
    );
    final globe = _estimateGlobeTempC(
      airTempC: inputs.airTempC,
      cloudCoverPercent: inputs.cloudCoverPercent,
      windSpeedMs: inputs.windSpeedMs,
      qatarLocal: toQatarLocal(inputs.observedAt),
    );
    final wbgt = 0.7 * wetBulb + 0.2 * globe + 0.1 * inputs.airTempC;
    return (wbgt * 10).roundToDouble() / 10;
  }

  static double effectiveWbgtC(HeatRiskInputs inputs) {
    assert(() {
      if (debugWbgtOverrideC != null) return true;
      return true;
    }());
    if (debugWbgtOverrideC != null) return debugWbgtOverrideC!;
    return estimateWbgtC(inputs);
  }

  /// Work must stop when WBGT is **strictly greater** than 32.1 °C.
  static bool requiresWorkStop(double wbgtC) =>
      wbgtC > QatarOutdoorWorkRules.wbgtWorkStopThresholdC;

  /// 10:00–15:30 Qatar local, 1 June–15 September (inclusive).
  static bool isSummerRestrictedWorkHours(DateTime at) {
    final local = toQatarLocal(at);
    if (!_isSummerRestrictedSeason(local)) return false;
    final minutes = local.hour * 60 + local.minute;
    final startMinutes = QatarOutdoorWorkRules.restrictedStartHour * 60 +
        QatarOutdoorWorkRules.restrictedStartMinute;
    final endMinutes = QatarOutdoorWorkRules.restrictedEndHour * 60 +
        QatarOutdoorWorkRules.restrictedEndMinute;
    return minutes >= startMinutes && minutes <= endMinutes;
  }

  static OutdoorWorkComplianceStatus evaluateCompliance(HeatRiskInputs inputs) {
    final wbgt = effectiveWbgtC(inputs);
    final local = toQatarLocal(inputs.observedAt);
    final inSeason = _isSummerRestrictedSeason(local);
    return OutdoorWorkComplianceStatus(
      isClockBanSeason: inSeason,
      isClockBanWindowActive:
          inSeason && isSummerRestrictedWorkHours(inputs.observedAt),
      isWbgtStopRequired: requiresWorkStop(wbgt),
      wbgtEstimateC: wbgt,
      evaluatedAt: inputs.observedAt,
    );
  }

  static DateTime toQatarLocal(DateTime at) => at.toUtc().add(qatarUtcOffset);

  static bool _isSummerRestrictedSeason(DateTime qatarLocal) {
    final month = qatarLocal.month;
    final day = qatarLocal.day;
    if (month == QatarOutdoorWorkRules.seasonStartMonth &&
        day >= QatarOutdoorWorkRules.seasonStartDay) {
      return true;
    }
    if (month > QatarOutdoorWorkRules.seasonStartMonth &&
        month < QatarOutdoorWorkRules.seasonEndMonth) {
      return true;
    }
    if (month == QatarOutdoorWorkRules.seasonEndMonth &&
        day <= QatarOutdoorWorkRules.seasonEndDay) {
      return true;
    }
    return false;
  }

  /// Plain-language band for UI — based on approximate WBGT.
  static String riskLevelLabel(double wbgtC) {
    if (requiresWorkStop(wbgtC)) return 'work_stop';
    if (wbgtC >= 30) return 'extreme';
    if (wbgtC >= 28) return 'high';
    if (wbgtC >= 26) return 'moderate';
    return 'lower';
  }

  /// Stull (2011) wet-bulb estimate from dry-bulb °C and RH %.
  static double _estimateWetBulbC(double tempC, int humidity) {
    final rh = humidity.clamp(5, 100).toDouble();
    final t = tempC;
    final term1 = t * math.atan(0.151977 * math.sqrt(rh + 8.313659));
    final term2 = math.atan(t + rh);
    final term3 = math.atan(rh - 1.676331);
    final term4 = 0.00391838 * math.pow(rh, 1.5) * math.atan(0.023101 * rh);
    return term1 + term2 - term3 + term4 - 4.686035;
  }

  /// Globe temperature estimate from air temp, cloud cover, wind, and solar hour.
  static double _estimateGlobeTempC({
    required double airTempC,
    required int cloudCoverPercent,
    required double windSpeedMs,
    required DateTime qatarLocal,
  }) {
    final cloud = cloudCoverPercent.clamp(0, 100) / 100.0;
    final solar = _solarLoadFactor(qatarLocal.hour + qatarLocal.minute / 60.0);
    // Approximate black-globe excess above air under Qatar summer sun.
    var globeExcess = solar * (1.0 - cloud * 0.75) * 14.0;
    globeExcess *= _windCoolingFactor(windSpeedMs);
    return airTempC + globeExcess;
  }

  /// Higher wind modestly reduces estimated radiant load (not a full ISO model).
  static double _windCoolingFactor(double windSpeedMs) {
    final w = windSpeedMs.clamp(0.0, 15.0);
    return (1.0 - (w / 15.0) * 0.15).clamp(0.85, 1.0);
  }

  /// 0 overnight → ~1 near solar noon (~13:00 in Qatar).
  static double _solarLoadFactor(double hourDecimal) {
    if (hourDecimal < 5 || hourDecimal > 19) return 0.05;
    const peakHour = 13.0;
    const spread = 4.5;
    final x = (hourDecimal - peakHour) / spread;
    return (math.exp(-0.5 * x * x)).clamp(0.05, 1.0);
  }
}
