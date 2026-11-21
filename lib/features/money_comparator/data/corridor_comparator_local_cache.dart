import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:raabta/features/money_comparator/data/models/corridor_aggregate_model.dart';
import 'package:raabta/features/money_comparator/data/models/remittance_mid_market_model.dart';
import 'package:raabta/features/money_comparator/data/models/remittance_provider_rate_model.dart';

/// Hive cache for corridor aggregate and Remittance Truth Engine reads.
class CorridorComparatorLocalCache {
  CorridorComparatorLocalCache._();
  static final CorridorComparatorLocalCache instance =
      CorridorComparatorLocalCache._();

  static const _boxName = 'corridor_aggregates_cache_v1';
  static const cacheTtl = Duration(minutes: 20);

  static const midMarketDataKey = 'rte_mid_market_v1';
  static const midMarketTsKey = 'rte_mid_market_ts_v1';

  Box<dynamic>? _box;
  Future<void>? _initFuture;

  Future<void> init() {
    if (_box != null && _box!.isOpen) return Future.value();
    return _initFuture ??= _openBox();
  }

  Future<void> _openBox() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        try {
          await Hive.initFlutter();
        } catch (_) {
          Hive.init('raabta_hive');
        }
        _box = await Hive.openBox<dynamic>(_boxName);
      } else {
        _box = Hive.box<dynamic>(_boxName);
      }
    } catch (_) {
      _box = null;
    }
  }

  String _normalizeCountry(String countryCode) => countryCode.toUpperCase();

  String _dataKey(String countryCode) => 'agg_${_normalizeCountry(countryCode)}';
  String _tsKey(String countryCode) => 'agg_ts_${_normalizeCountry(countryCode)}';
  String _rteProvidersDataKey(String countryCode) =>
      'rte_providers_v1_${_normalizeCountry(countryCode)}';
  String _rteProvidersTsKey(String countryCode) =>
      'rte_providers_ts_v1_${_normalizeCountry(countryCode)}';

  Future<bool> isFresh(String countryCode) async {
    await init();
    final raw = _box?.get(_tsKey(countryCode));
    if (raw == null) return false;
    final ts = DateTime.tryParse(raw.toString());
    if (ts == null) return false;
    return DateTime.now().difference(ts) < cacheTtl;
  }

  Future<DateTime?> cachedAt(String countryCode) async {
    await init();
    final raw = _box?.get(_tsKey(countryCode));
    return DateTime.tryParse(raw?.toString() ?? '');
  }

  Future<void> cacheAggregates(
    String countryCode,
    List<CorridorAggregate> aggregates,
  ) async {
    await init();
    final box = _box;
    if (box == null) return;
    try {
      await box.put(
        _dataKey(countryCode),
        aggregates.map((a) => a.toCacheJson()).toList(),
      );
      await box.put(_tsKey(countryCode), DateTime.now().toIso8601String());
    } catch (_) {
      // Non-fatal — network result remains authoritative.
    }
  }

  Future<List<CorridorAggregate>?> loadAggregates(String countryCode) async {
    await init();
    final raw = _box?.get(_dataKey(countryCode));
    if (raw is! List) return null;
    try {
      return raw
          .map(
            (e) => CorridorAggregate.fromCacheJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    } catch (_) {
      await _deleteKeys(_dataKey(countryCode), _tsKey(countryCode));
      return null;
    }
  }

  Future<void> cacheMidMarket(RemittanceMidMarketSnapshot snapshot) async {
    await init();
    final box = _box;
    if (box == null) return;
    try {
      await box.put(midMarketDataKey, snapshot.toCacheJson());
      await box.put(midMarketTsKey, DateTime.now().toIso8601String());
    } catch (_) {
      // Non-fatal.
    }
  }

  Future<RemittanceMidMarketSnapshot?> loadMidMarket() async {
    await init();
    final raw = _box?.get(midMarketDataKey);
    if (raw is! Map) return null;
    try {
      return RemittanceMidMarketSnapshot.fromCacheJson(
        Map<String, dynamic>.from(raw),
      );
    } catch (_) {
      await _deleteKeys(midMarketDataKey, midMarketTsKey);
      return null;
    }
  }

  Future<DateTime?> midMarketCachedAt() async {
    await init();
    final raw = _box?.get(midMarketTsKey);
    return DateTime.tryParse(raw?.toString() ?? '');
  }

  Future<void> cacheProviderRates(
    String countryCode,
    List<RemittanceProviderRate> providers,
  ) async {
    await init();
    final box = _box;
    if (box == null) return;
    final code = _normalizeCountry(countryCode);
    try {
      await box.put(
        _rteProvidersDataKey(code),
        providers.map((p) => p.toCacheJson()).toList(),
      );
      await box.put(
        _rteProvidersTsKey(code),
        DateTime.now().toIso8601String(),
      );
    } catch (_) {
      // Non-fatal.
    }
  }

  Future<List<RemittanceProviderRate>?> loadProviderRates(
    String countryCode,
  ) async {
    await init();
    final code = _normalizeCountry(countryCode);
    final raw = _box?.get(_rteProvidersDataKey(code));
    if (raw is! List) return null;
    try {
      return raw
          .map(
            (e) => RemittanceProviderRate.fromCacheJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    } catch (_) {
      await _deleteKeys(_rteProvidersDataKey(code), _rteProvidersTsKey(code));
      return null;
    }
  }

  Future<DateTime?> providerRatesCachedAt(String countryCode) async {
    await init();
    final raw = _box?.get(_rteProvidersTsKey(_normalizeCountry(countryCode)));
    return DateTime.tryParse(raw?.toString() ?? '');
  }

  /// Known provider names seen in past reports (for autocomplete).
  Future<void> appendProviderName(String name) async {
    await init();
    final box = _box;
    if (box == null) return;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final existing = List<String>.from(await loadProviderNames());
    if (existing.contains(trimmed)) return;
    existing.insert(0, trimmed);
    try {
      await box.put(
        'provider_names',
        jsonEncode(existing.take(50).toList()),
      );
    } catch (_) {
      // Non-fatal.
    }
  }

  Future<List<String>> loadProviderNames() async {
    await init();
    final raw = _box?.get('provider_names');
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw.toString()) as List<dynamic>;
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> invalidateCountry(String countryCode) async {
    await init();
    final box = _box;
    if (box == null) return;
    final code = _normalizeCountry(countryCode);
    await _deleteKeys(_dataKey(code), _tsKey(code));
  }

  Future<void> _deleteKeys(String dataKey, String tsKey) async {
    final box = _box;
    if (box == null) return;
    try {
      await box.delete(dataKey);
      await box.delete(tsKey);
    } catch (_) {
      // Non-fatal.
    }
  }
}
