import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';
import 'package:raabta/features/quick_actions/climate_navigator/data/qatar_outdoor_work_rules.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/heat_risk_calculator.dart';
import 'dart:convert';

// ─── Weather model ────────────────────────────────────────

class QatarWeather {
  final double tempC;
  final double feelsLikeC;
  final int humidity;
  final String description;
  final double heatIndexC;
  final int uvIndex;
  final double windSpeedMs;
  final bool isPeakHeat;
  final bool dataAvailable;
  final bool isFallback;
  final bool cached;
  final int cloudCover;
  final DateTime fetchedAt;

  const QatarWeather({
    required this.tempC,
    required this.feelsLikeC,
    required this.humidity,
    required this.description,
    required this.heatIndexC,
    required this.uvIndex,
    required this.windSpeedMs,
    required this.isPeakHeat,
    required this.dataAvailable,
    required this.isFallback,
    this.cached = false,
    this.cloudCover = 0,
    required this.fetchedAt,
  });

  factory QatarWeather.fromJson(Map<String, dynamic> j) {
    DateTime fetchedAt = DateTime.now();
    try {
      if (j['fetchedAt'] != null) {
        fetchedAt = DateTime.parse(j['fetchedAt'] as String);
      }
    } catch (_) {}

    return QatarWeather(
      tempC: (j['tempC'] as num?)?.toDouble() ?? 38,
      feelsLikeC: (j['feelsLikeC'] as num?)?.toDouble() ?? 45,
      humidity: (j['humidity'] as num?)?.toInt() ?? 55,
      description: j['description'] as String? ?? 'Hot',
      heatIndexC: (j['heatIndexC'] as num?)?.toDouble() ?? 45,
      uvIndex: (j['uvIndex'] as num?)?.toInt() ?? 9,
      windSpeedMs: (j['windSpeedMs'] as num?)?.toDouble() ?? 3,
      isPeakHeat: j['isPeakHeat'] as bool? ?? true,
      dataAvailable: j['dataAvailable'] as bool? ?? false,
      isFallback:
          j['isFallback'] as bool? ?? j['fallback'] as bool? ?? false,
      cached: j['cached'] as bool? ?? false,
      cloudCover: (j['cloudCover'] as num?)?.toInt() ?? 0,
      fetchedAt: fetchedAt,
    );
  }

  HeatRiskInputs get _heatRiskInputs => HeatRiskInputs(
        airTempC: tempC,
        humidityPercent: humidity,
        cloudCoverPercent: cloudCover,
        windSpeedMs: windSpeedMs,
        observedAt: fetchedAt,
      );

  /// Approximate WBGT (°C) — on-device estimate, not ISO 7243 instrument WBGT.
  double get wbgtEstimateC =>
      HeatRiskCalculator.effectiveWbgtC(_heatRiskInputs);

  OutdoorWorkComplianceStatus get outdoorWorkCompliance =>
      HeatRiskCalculator.evaluateCompliance(_heatRiskInputs);

  bool get requiresWorkStop =>
      HeatRiskCalculator.requiresWorkStop(wbgtEstimateC);

  bool get isSummerRestrictedNow =>
      HeatRiskCalculator.isSummerRestrictedWorkHours(fetchedAt);

  String get wbgtRiskLevelKey =>
      HeatRiskCalculator.riskLevelLabel(wbgtEstimateC);

  Color get wbgtAccentColor {
    switch (wbgtRiskLevelKey) {
      case 'work_stop':
        return const Color(0xFFFF4757);
      case 'extreme':
        return const Color(0xFFE63946);
      case 'high':
        return const Color(0xFFFF6B35);
      case 'moderate':
        return const Color(0xFFFFB627);
      default:
        return const Color(0xFF2DC653);
    }
  }

  // Safe offline fallback — screen never crashes
  factory QatarWeather.fallback() => QatarWeather(
        tempC: 38,
        feelsLikeC: 45,
        humidity: 55,
        description: 'Hot (no connection)',
        heatIndexC: 45,
        uvIndex: 9,
        windSpeedMs: 3,
        isPeakHeat: true,
        dataAvailable: false,
        isFallback: true,
        cached: false,
        cloudCover: 0,
        fetchedAt: DateTime.now(),
      );

  // ── Heat risk label and color ─────────────────────────
  String get heatRiskLabel {
    if (heatIndexC >= 54) return 'EXTREME DANGER';
    if (heatIndexC >= 46) return 'DANGER';
    if (heatIndexC >= 38) return 'EXTREME CAUTION';
    if (heatIndexC >= 32) return 'CAUTION';
    return 'SAFE';
  }

  Color get heatRiskColor {
    if (heatIndexC >= 54) return const Color(0xFFE63946);
    if (heatIndexC >= 46) return const Color(0xFFFF6B35);
    if (heatIndexC >= 38) return const Color(0xFFFFB627);
    if (heatIndexC >= 32) return const Color(0xFF7BC67E);
    return const Color(0xFF2DC653);
  }

  String get heatRiskEmoji {
    if (heatIndexC >= 54) return '🔴';
    if (heatIndexC >= 46) return '🟠';
    if (heatIndexC >= 38) return '🟡';
    if (heatIndexC >= 32) return '🟢';
    return '✅';
  }

  // Outdoor safety recommendation
  String get outdoorAdvice {
    if (heatIndexC >= 54) {
      return 'DO NOT go outdoors. '
          'Heatstroke risk within minutes.';
    }
    if (heatIndexC >= 46) {
      return 'Avoid outdoors 10AM–5PM. '
          'Extreme heat — limit exposure to 10 min.';
    }
    if (heatIndexC >= 38) {
      return 'Avoid outdoors 11AM–4PM. '
          'Carry water. Seek shade constantly.';
    }
    if (heatIndexC >= 32) {
      return 'Early morning or evening outdoor activity only. '
          'Stay hydrated.';
    }
    return 'Pleasant conditions. '
        'Normal outdoor activity is fine.';
  }

  // UV risk label
  String get uvLabel {
    if (uvIndex >= 11) return 'Extreme';
    if (uvIndex >= 8) return 'Very High';
    if (uvIndex >= 6) return 'High';
    if (uvIndex >= 3) return 'Moderate';
    return 'Low';
  }

  // Summary string injected into Claude prompt
  String toPromptContext() =>
      'LIVE Qatar weather (Doha): '
      'Temperature ${tempC.toStringAsFixed(1)}°C, '
      'feels like ${feelsLikeC.toStringAsFixed(1)}°C, '
      'humidity $humidity%, '
      'heat index ${heatIndexC.toStringAsFixed(1)}°C '
      '($heatRiskLabel), '
      'UV index $uvIndex ($uvLabel), '
      'wind ${windSpeedMs.toStringAsFixed(1)} m/s. '
      '${isPeakHeat ? "⚠️ PEAK HEAT ACTIVE — prioritize indoor routes." : "Comfortable conditions — standard routing applies."}';
}

// ─── Riverpod FutureProvider ──────────────────────────────
// Fetches from Railway backend — never directly from OpenWeather

final qatarWeatherProvider = FutureProvider<QatarWeather>(
  (ref) async {
    try {
      final backendUrl = '${AppConfig.backendUrl}/weather/qatar';

      final response = await http
          .get(Uri.parse(backendUrl))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return QatarWeather.fromJson(json);
      }

      return QatarWeather.fallback();
    } catch (_) {
      return QatarWeather.fallback();
    }
  },
);
