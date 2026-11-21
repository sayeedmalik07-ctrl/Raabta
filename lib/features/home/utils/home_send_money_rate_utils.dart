import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'package:raabta/features/home/l10n/home_currency_rail_strings.dart';
import 'package:raabta/services/exchange_rate_service.dart';

/// All app remittance codes for Home pills — same order as [targetCurrencyCodes].
const homeSendMoneyKitSegmentCodes = targetCurrencyCodes;

/// Fallback/error paths stamp [ExchangeRates.lastUpdated] with [DateTime.now].
/// Timestamps inside this window are treated as freshly minted (non-authoritative).
const homeSendMoneyFreshFallbackTimestampThreshold = Duration(minutes: 2);

/// Minimum |weekly %| shown on Home (label uses one decimal place).
const homeSendMoneyMinWeeklyChangePercent = 0.05;

/// Minimum rate range (QAR→home units) to show a market sparkline.
const homeSendMoneyMinSparklineRateRange = 0.01;

/// Resolves display currency for the Home card (supported remittance codes only).
String homeSendMoneyDisplayCurrency(String selectedCode) {
  return normalizeSelectedCurrencyCode(selectedCode);
}

/// Mid-market/open.er-api sourced — not house-specific remittance quotes.
bool homeSendMoneyRatesAreLive(ExchangeRates rates) {
  if (rates.isDirectApi) return true;
  return !rates.isFallback && rates.rates.isNotEmpty;
}

double? homeSendMoneyRateForCurrency(
  ExchangeRates rates,
  String currencyCode,
) {
  final code = currencyCode.toUpperCase();
  final quoted = rates.rates[code];
  if (quoted != null) return quoted;
  if (rates.isFallback) return kFallbackRates[code];
  return null;
}

/// Weekly % from first→last valid observations; null if unavailable.
double? homeSendMoneyWeeklyChangePercent(List<RateHistoryPoint> points) {
  final valid = points.where((p) => p.rate != null).toList();
  if (valid.length < 2) return null;
  final first = valid.first.rate!;
  final last = valid.last.rate!;
  if (first == 0) return null;
  return ((last - first) / first) * 100;
}

/// Weekly % for UI — null when insignificant or unavailable.
double? homeSendMoneyDisplayWeeklyChangePercent(
  List<RateHistoryPoint>? marketHistory,
) {
  if (marketHistory == null) return null;
  final percent = homeSendMoneyWeeklyChangePercent(marketHistory);
  if (percent == null) return null;
  if (percent.abs() < homeSendMoneyMinWeeklyChangePercent) return null;
  return percent;
}

List<double> homeSendMoneySparklineValues(List<RateHistoryPoint> points) {
  return points.map((p) => p.rate).whereType<double>().toList();
}

bool homeSendMoneyShouldShowSparkline(List<double> values) {
  if (values.length < 2) return false;
  final minV = values.reduce((a, b) => a < b ? a : b);
  final maxV = values.reduce((a, b) => a > b ? a : b);
  return (maxV - minV) >= homeSendMoneyMinSparklineRateRange;
}

List<double>? homeSendMoneyDisplaySparklineValues(
  List<RateHistoryPoint>? historyPoints,
) {
  if (historyPoints == null) return null;
  if (historyPoints.where((p) => p.rate != null).length < 2) return null;
  final values = homeSendMoneySparklineValues(historyPoints);
  if (values.length < 2) return null;
  return values;
}

/// Indicative 7-day shape when market history is missing (kit sparkline slot).
List<double> homeSendMoneyFallbackSparklineValues(double anchorRate) {
  final scale = (anchorRate * 0.0035).clamp(0.03, 0.18);
  return List.generate(7, (i) {
    final wobble = math.sin(i * 0.92) * scale + (i - 3) * scale * 0.28;
    return double.parse((anchorRate + wobble).toStringAsFixed(2));
  });
}

/// Home exchange-rates card — market history only (no synthetic fallback).
List<double>? homeSendMoneyHomeCardSparklineValues(
  List<RateHistoryPoint>? marketHistory,
) {
  final values = homeSendMoneyDisplaySparklineValues(marketHistory);
  if (values == null) return null;
  if (!homeSendMoneyShouldShowSparkline(values)) return null;
  return values;
}

/// Resolves chart values from history; synthetic shape only when [rates] are offline.
List<double>? homeSendMoneyResolvedSparklineValues({
  required double anchorRate,
  List<RateHistoryPoint>? historyPoints,
  ExchangeRates? rates,
}) {
  final fromHistory = homeSendMoneyDisplaySparklineValues(historyPoints);
  if (fromHistory != null) return fromHistory;
  final offline = rates == null || !homeSendMoneyRatesAreLive(rates);
  if (!offline) return null;
  return homeSendMoneyFallbackSparklineValues(anchorRate);
}

/// True when [rates.isFallback] and [lastUpdated] was likely set at fetch time.
@visibleForTesting
bool homeSendMoneyIsFreshlyMintedFallbackTimestamp(
  ExchangeRates rates, {
  DateTime? now,
}) {
  if (!rates.isFallback) return false;
  final clock = now ?? DateTime.now();
  final delta = clock.difference(rates.lastUpdated);
  if (delta.isNegative) {
    return delta.abs() <= homeSendMoneyFreshFallbackTimestampThreshold;
  }
  return delta <= homeSendMoneyFreshFallbackTimestampThreshold;
}

String homeSendMoneyUpdatedMinutesLabel(int minutes, String locale) {
  if (minutes <= 0) {
    return HomeCurrencyRailStrings.t('home_currency_updated_now', locale);
  }
  if (minutes == 1) {
    return HomeCurrencyRailStrings.t('home_currency_updated_one_minute', locale);
  }
  return HomeCurrencyRailStrings.format(
    'home_currency_updated_minutes',
    locale,
    params: {'minutes': '$minutes'},
  );
}

/// Footer freshness line for the Home send-money card.
String homeSendMoneyRatesUpdatedLabel(
  ExchangeRates rates,
  String locale, {
  DateTime? now,
}) {
  if (homeSendMoneyIsFreshlyMintedFallbackTimestamp(rates, now: now)) {
    return HomeCurrencyRailStrings.t('home_currency_updated_indicative', locale);
  }
  final minutes =
      (now ?? DateTime.now()).difference(rates.lastUpdated).inMinutes.abs();
  return homeSendMoneyUpdatedMinutesLabel(minutes, locale);
}

String homeSendMoneyWeeklyChangeLabel(double percent, String locale) {
  final sign = percent >= 0 ? '+' : '';
  return HomeCurrencyRailStrings.format(
    'home_currency_weekly_change',
    locale,
    params: {
      'sign': sign,
      'percent': percent.toStringAsFixed(1),
    },
  );
}
