import 'dart:async';
import 'dart:convert';
import 'package:raabta/core/colors/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';

export 'package:raabta/features/home/data/selected_currency_notifier.dart';

class ExchangeRates {
  const ExchangeRates({
    required this.rates,
    required this.lastUpdated,
    this.isFallback = false,
    this.isDirectApi = false,
  });

  final Map<String, double> rates;
  final DateTime lastUpdated;
  final bool isFallback;
  final bool isDirectApi;
}

class RateHistoryPoint {
  const RateHistoryPoint({required this.date, this.rate});

  final String date;
  final double? rate;
}

/// History series with source metadata (Home sparkline / weekly change).
class RateHistorySeries {
  const RateHistorySeries({
    required this.points,
    required this.isMarketSourced,
  });

  final List<RateHistoryPoint> points;
  final bool isMarketSourced;
}

class ExchangeHouseRate {
  const ExchangeHouseRate({
    required this.name,
    required this.rate,
    required this.fee,
    required this.rating,
    required this.hasApp,
    this.website,
  });

  final String name;
  final double rate;
  final String fee;
  final double rating;
  final bool hasApp;
  final String? website;
}

class CurrencyInfo {
  const CurrencyInfo({
    required this.code,
    required this.country,
    required this.flag,
    required this.name,
    required this.chartColor,
  });

  final String code;
  final String country;
  final String flag;
  final String name;
  final Color chartColor;
}

const List<String> targetCurrencyCodes = [
  'INR',
  'PKR',
  'BDT',
  'NPR',
  'PHP',
  'EGP',
  'KES',
  'LKR',
];

/// Bill Splitter home-currency options (QAR base via open.er-api.com).
const List<String> billSplitterCurrencyCodes = [
  'INR',
  'PHP',
  'GBP',
  'USD',
  'EUR',
  'BDT',
  'PKR',
  'EGP',
  'LKR',
  'NPR',
  'KES',
  'MYR',
  'SGD',
  'AED',
  'SAR',
];

const Map<String, double> kBillSplitterFallbackRates = {
  'INR': 22.6,
  'PHP': 14.7,
  'GBP': 0.21,
  'USD': 0.274,
  'EUR': 0.25,
  'BDT': 30.1,
  'PKR': 76.0,
  'EGP': 13.3,
  'LKR': 82.5,
  'NPR': 36.2,
  'KES': 35.4,
  'MYR': 1.27,
  'SGD': 0.37,
  'AED': 1.00,
  'SAR': 1.03,
};

const Map<String, double> kFallbackRates = {
  'INR': 22.80,
  'PKR': 76.50,
  'BDT': 30.20,
  'NPR': 36.50,
  'PHP': 16.30,
  'EGP': 13.90,
  'KES': 37.10,
  'LKR': 8.50,
};

const List<CurrencyInfo> raabtaCurrencies = [
  CurrencyInfo(
    code: 'INR',
    country: 'India',
    flag: '🇮🇳',
    name: 'Indian Rupee',
    chartColor: AppColors.heatOrange,
  ),
  CurrencyInfo(
    code: 'PKR',
    country: 'Pakistan',
    flag: '🇵🇰',
    name: 'Pakistani Rupee',
    chartColor: Color(0xFF00C853),
  ),
  CurrencyInfo(
    code: 'BDT',
    country: 'Bangladesh',
    flag: '🇧🇩',
    name: 'Bangladeshi Taka',
    chartColor: Color(0xFF00D4FF),
  ),
  CurrencyInfo(
    code: 'NPR',
    country: 'Nepal',
    flag: '🇳🇵',
    name: 'Nepalese Rupee',
    chartColor: Color(0xFFAB47BC),
  ),
  CurrencyInfo(
    code: 'PHP',
    country: 'Philippines',
    flag: '🇵🇭',
    name: 'Philippine Peso',
    chartColor: AppColors.accentGold,
  ),
  CurrencyInfo(
    code: 'EGP',
    country: 'Egypt',
    flag: '🇪🇬',
    name: 'Egyptian Pound',
    chartColor: Color(0xFFEF5350),
  ),
  CurrencyInfo(
    code: 'KES',
    country: 'Kenya',
    flag: '🇰🇪',
    name: 'Kenyan Shilling',
    chartColor: Color(0xFF26A69A),
  ),
  CurrencyInfo(
    code: 'LKR',
    country: 'Sri Lanka',
    flag: '🇱🇰',
    name: 'Sri Lankan Rupee',
    chartColor: Color(0xFF7C4DFF),
  ),
];

class ExchangeRateService {
  static const _backendBase = '${AppConfig.backendUrl}/api/exchange';
  static const _directLatestUrl = 'https://open.er-api.com/v6/latest/QAR';

  ExchangeRates? _ratesCache;
  final Map<String, RateHistorySeries> _historyCache = {};
  final Map<String, List<ExchangeHouseRate>> _compareCache = {};

  Map<String, double> _filterRatesForCodes(
    Map<String, dynamic> allRates,
    List<String> codes,
    Map<String, double> fallbacks,
  ) {
    final filtered = <String, double>{};
    for (final code in codes) {
      final value = allRates[code];
      if (value != null) {
        filtered[code] = (value as num).toDouble();
      } else if (fallbacks.containsKey(code)) {
        filtered[code] = fallbacks[code]!;
      }
    }
    return filtered;
  }

  Future<Map<String, double>?> _fetchDirectRatesForCodes(
    List<String> codes,
    Map<String, double> fallbacks,
  ) async {
    try {
      final response = await http
          .get(Uri.parse(_directLatestUrl))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['result'] != 'success') return null;

      final rates = _filterRatesForCodes(
        data['rates'] as Map<String, dynamic>,
        codes,
        fallbacks,
      );
      return rates.isEmpty ? null : rates;
    } catch (e) {
      debugPrint('⚠️ direct rates fetch error: $e');
      return null;
    }
  }

  Future<Map<String, double>?> _fetchDirectRates() async {
    return _fetchDirectRatesForCodes(targetCurrencyCodes, kFallbackRates);
  }

  /// Live QAR→home rates for Bill Splitter currencies (shared open.er-api.com).
  Future<ExchangeRates> fetchBillSplitterRates() async {
    final direct = await _fetchDirectRatesForCodes(
      billSplitterCurrencyCodes,
      kBillSplitterFallbackRates,
    );
    if (direct != null && direct.isNotEmpty) {
      return ExchangeRates(
        rates: direct,
        lastUpdated: DateTime.now(),
        isDirectApi: true,
      );
    }
    return ExchangeRates(
      rates: Map<String, double>.from(kBillSplitterFallbackRates),
      lastUpdated: DateTime.now(),
      isFallback: true,
    );
  }

  Future<ExchangeRates> fetchRates() async {
    if (_ratesCache != null) {
      final age = DateTime.now().difference(_ratesCache!.lastUpdated).inMinutes;
      if (age < 30) return _ratesCache!;
    }

    try {
      final response = await http
          .get(Uri.parse('$_backendBase/rates'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rawRates = data['rates'] as Map<String, dynamic>;
        final rates = rawRates.map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        );
        _ratesCache = ExchangeRates(
          rates: rates,
          lastUpdated: DateTime.parse(data['lastUpdated'] as String),
          isFallback: data['fallback'] == true || data['stale'] == true,
        );
        return _ratesCache!;
      }
    } catch (e) {
      debugPrint('⚠️ fetchRates backend error: $e');
    }

    final directRates = await _fetchDirectRates();
    if (directRates != null) {
      _ratesCache = ExchangeRates(
        rates: directRates,
        lastUpdated: DateTime.now(),
        isDirectApi: true,
      );
      return _ratesCache!;
    }

    _ratesCache = ExchangeRates(
      rates: kFallbackRates,
      lastUpdated: DateTime.now(),
      isFallback: true,
    );
    return _ratesCache!;
  }

  Future<List<RateHistoryPoint>> _fetchDirectHistory(String currency) async {
    final today = DateTime.now();
    final futures = List.generate(7, (i) async {
      final d = DateTime(today.year, today.month, today.day - (6 - i));
      final dateStr =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      try {
        final response = await http
            .get(Uri.parse('https://open.er-api.com/v6/$dateStr/QAR'))
            .timeout(const Duration(seconds: 6));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final rate = data['rates']?[currency];
          return RateHistoryPoint(
            date: dateStr,
            rate: rate != null ? (rate as num).toDouble() : null,
          );
        }
      } catch (_) {}
      return RateHistoryPoint(date: dateStr, rate: null);
    });

    final results = await Future.wait(futures);
    double? lastKnown = _ratesCache?.rates[currency] ?? kFallbackRates[currency];
    return results.map((point) {
      if (point.rate != null) {
        lastKnown = point.rate;
      }
      return RateHistoryPoint(date: point.date, rate: point.rate ?? lastKnown);
    }).toList();
  }

  List<RateHistoryPoint> _syntheticHistory(String currency) {
    final base = _ratesCache?.rates[currency] ?? kFallbackRates[currency] ?? 1.0;
    return List.generate(7, (i) {
      final d = DateTime.now().subtract(Duration(days: 6 - i));
      final variation = (i - 3) * 0.02;
      return RateHistoryPoint(
        date: d.toIso8601String().split('T').first,
        rate: double.parse((base + variation).toStringAsFixed(4)),
      );
    });
  }

  Future<List<RateHistoryPoint>> fetchHistory(String currencyCode) async {
    return (await fetchHistorySeries(currencyCode)).points;
  }

  Future<RateHistorySeries> fetchHistorySeries(String currencyCode) async {
    final key = currencyCode.toUpperCase();

    if (_historyCache.containsKey(key)) {
      return _historyCache[key]!;
    }

    try {
      final response = await http
          .get(Uri.parse('$_backendBase/history/$key'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list = (data['history'] as List).map((item) {
          final map = item as Map<String, dynamic>;
          return RateHistoryPoint(
            date: map['date'] as String,
            rate: map['rate'] != null
                ? (map['rate'] as num).toDouble()
                : null,
          );
        }).toList();
        if (list.where((p) => p.rate != null).length >= 2) {
          final series = RateHistorySeries(
            points: list,
            isMarketSourced: true,
          );
          _historyCache[key] = series;
          return series;
        }
      }
    } catch (e) {
      debugPrint('⚠️ fetchHistory backend error: $e');
    }

    await fetchRates();
    final direct = await _fetchDirectHistory(key);
    if (direct.where((p) => p.rate != null).length >= 2) {
      final series = RateHistorySeries(
        points: direct,
        isMarketSourced: true,
      );
      _historyCache[key] = series;
      return series;
    }

    final synthetic = _syntheticHistory(key);
    final series = RateHistorySeries(
      points: synthetic,
      isMarketSourced: false,
    );
    _historyCache[key] = series;
    return series;
  }

  List<ExchangeHouseRate> _localComparison(String currencyCode) {
    final midRate =
        _ratesCache?.rates[currencyCode] ?? kFallbackRates[currencyCode];
    if (midRate == null) return [];

    const spreads = {
      'Al Fardan Exchange': 0.994,
      'Lari Exchange': 0.991,
      'Al Mirqab Exchange': 0.989,
      'Western Union': 0.975,
      'Eastern Exchange': 0.992,
      'CBI Bank': 0.985,
    };

    const websites = {
      'Al Fardan Exchange': 'https://www.alfardanexchange.com.qa',
      'Lari Exchange': 'https://www.lariexchange.com',
      'Western Union': 'https://www.westernunion.com/qa',
      'Al Mirqab Exchange': 'https://almirqabexchange.com',
      'Eastern Exchange': 'https://www.easternexchangeqatar.com',
      'CBI Bank': 'https://www.cbi.com.qa',
    };

    const ratings = {
      'Al Fardan Exchange': 4.7,
      'Lari Exchange': 4.5,
      'Eastern Exchange': 4.3,
      'Al Mirqab Exchange': 4.2,
      'CBI Bank': 4.0,
      'Western Union': 3.8,
    };

    return spreads.entries
        .map(
          (entry) => ExchangeHouseRate(
            name: entry.key,
            rate: double.parse((midRate * entry.value).toStringAsFixed(4)),
            fee: entry.key == 'Western Union' ? '5 QR' : 'Free',
            rating: ratings[entry.key] ?? 4.0,
            hasApp: ['Al Fardan Exchange', 'Lari Exchange', 'Western Union']
                .contains(entry.key),
            website: websites[entry.key],
          ),
        )
        .toList()
      ..sort((a, b) => b.rate.compareTo(a.rate));
  }

  Future<List<ExchangeHouseRate>> fetchComparison(String currencyCode) async {
    final key = currencyCode.toUpperCase();

    if (_compareCache.containsKey(key)) {
      return _compareCache[key]!;
    }

    try {
      final response = await http
          .get(Uri.parse('$_backendBase/compare/$key'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list = (data['comparison'] as List).map((item) {
          final map = item as Map<String, dynamic>;
          return ExchangeHouseRate(
            name: map['name'] as String,
            rate: (map['rate'] as num).toDouble(),
            fee: map['fee'] as String,
            rating: (map['rating'] as num).toDouble(),
            hasApp: map['app'] as bool,
            website: map['website'] as String?,
          );
        }).toList();
        if (list.isNotEmpty) {
          _compareCache[key] = list;
          return list;
        }
      }
    } catch (e) {
      debugPrint('⚠️ fetchComparison backend error: $e');
    }

    await fetchRates();
    final local = _localComparison(key);
    _compareCache[key] = local;
    return local;
  }

  void clearCache() {
    _ratesCache = null;
    _historyCache.clear();
    _compareCache.clear();
  }
}

final exchangeRateServiceProvider = Provider<ExchangeRateService>(
  (ref) => ExchangeRateService(),
);

final liveExchangeRatesProvider = FutureProvider<ExchangeRates>((ref) {
  return ref.read(exchangeRateServiceProvider).fetchRates();
});

final billSplitterRatesProvider = FutureProvider<ExchangeRates>((ref) {
  return ref.read(exchangeRateServiceProvider).fetchBillSplitterRates();
});

/// Alias matching the upgrade spec naming.
final exchangeRatesProvider = liveExchangeRatesProvider;

final rateHistoryProvider =
    FutureProvider.family<List<RateHistoryPoint>, String>((ref, currency) {
  return ref.read(exchangeRateServiceProvider).fetchHistory(currency);
});

final rateHistorySeriesProvider =
    FutureProvider.family<RateHistorySeries, String>((ref, currency) {
  return ref.read(exchangeRateServiceProvider).fetchHistorySeries(currency);
});

final exchangeCompareProvider =
    FutureProvider.family<List<ExchangeHouseRate>, String>((ref, currency) {
  return ref.read(exchangeRateServiceProvider).fetchComparison(currency);
});

final converterAmountProvider = StateProvider<double>((ref) => 500.0);

final exchangeAutoRefreshProvider = Provider<void>((ref) {
  final timer = Timer.periodic(const Duration(minutes: 30), (_) {
    ref.read(exchangeRateServiceProvider).clearCache();
    ref.invalidate(liveExchangeRatesProvider);
    for (final currency in targetCurrencyCodes) {
      ref.invalidate(rateHistoryProvider(currency));
      ref.invalidate(exchangeCompareProvider(currency));
    }
  });
  ref.onDispose(timer.cancel);
});
