import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';

class ExchangeRates {
  const ExchangeRates({
    required this.rates,
    required this.lastUpdated,
    this.isFallback = false,
  });

  final Map<String, double> rates;
  final DateTime lastUpdated;
  final bool isFallback;
}

class RateHistoryPoint {
  const RateHistoryPoint({required this.date, this.rate});

  final String date;
  final double? rate;
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

const List<CurrencyInfo> raabtaCurrencies = [
  CurrencyInfo(
    code: 'INR',
    country: 'India',
    flag: '🇮🇳',
    name: 'Indian Rupee',
    chartColor: Color(0xFFFF6B35),
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
    chartColor: Color(0xFFFFB627),
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

  ExchangeRates? _ratesCache;
  final Map<String, List<RateHistoryPoint>> _historyCache = {};
  final Map<String, List<ExchangeHouseRate>> _compareCache = {};

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
      debugPrint('⚠️ fetchRates error: $e');
    }

    return ExchangeRates(
      rates: const {
        'INR': 22.80,
        'PKR': 76.50,
        'BDT': 30.20,
        'NPR': 36.50,
        'PHP': 16.30,
        'EGP': 13.90,
        'KES': 37.10,
        'LKR': 8.50,
      },
      lastUpdated: DateTime.now(),
      isFallback: true,
    );
  }

  Future<List<RateHistoryPoint>> fetchHistory(String currencyCode) async {
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
        _historyCache[key] = list;
        return list;
      }
    } catch (e) {
      debugPrint('⚠️ fetchHistory error: $e');
    }

    return List.generate(7, (i) {
      final d = DateTime.now().subtract(Duration(days: 6 - i));
      return RateHistoryPoint(
        date: d.toIso8601String().split('T').first,
        rate: null,
      );
    });
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
        _compareCache[key] = list;
        return list;
      }
    } catch (e) {
      debugPrint('⚠️ fetchComparison error: $e');
    }
    return [];
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

final rateHistoryProvider =
    FutureProvider.family<List<RateHistoryPoint>, String>((ref, currency) {
  return ref.read(exchangeRateServiceProvider).fetchHistory(currency);
});

final exchangeCompareProvider =
    FutureProvider.family<List<ExchangeHouseRate>, String>((ref, currency) {
  return ref.read(exchangeRateServiceProvider).fetchComparison(currency);
});

final selectedCurrencyProvider = StateProvider<String>((ref) => 'INR');

final converterAmountProvider = StateProvider<double>((ref) => 500.0);
