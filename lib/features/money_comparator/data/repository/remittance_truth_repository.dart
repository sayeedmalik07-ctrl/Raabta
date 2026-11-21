import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:raabta/features/money_comparator/data/corridor_comparator_local_cache.dart';
import 'package:raabta/features/money_comparator/data/models/remittance_mid_market_model.dart';
import 'package:raabta/features/money_comparator/data/models/remittance_provider_rate_model.dart';

/// Firestore reads with Hive fallback for Remittance Truth Engine.
class RemittanceTruthRepository {
  RemittanceTruthRepository({
    FirebaseFirestore? firestore,
    CorridorComparatorLocalCache? cache,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _cache = cache ?? CorridorComparatorLocalCache.instance;

  final FirebaseFirestore _firestore;
  final CorridorComparatorLocalCache _cache;

  static const midMarketCollection = 'remittance_mid_market';
  static const providerRatesCollection = 'remittance_provider_rates';
  static const midMarketDocId = 'latest';

  Future<RemittanceMidMarketResult> fetchMidMarketWithCache() async {
    await _cache.init();

    try {
      final snap = await _firestore
          .collection(midMarketCollection)
          .doc(midMarketDocId)
          .get();

      if (!snap.exists || snap.data() == null) {
        return _midMarketFromCacheOrEmpty();
      }

      final snapshot = RemittanceMidMarketSnapshot.fromFirestore(snap.data()!);
      if (!_isCacheableMidMarket(snapshot)) {
        return _midMarketFromCacheOrEmpty();
      }

      await _cache.cacheMidMarket(snapshot);
      return RemittanceMidMarketResult(
        snapshot: snapshot,
        fromCache: false,
        cachedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('RemittanceTruthRepository mid-market fetch failed: $e');
      final cached = await _cache.loadMidMarket();
      if (cached != null && _isCacheableMidMarket(cached)) {
        return RemittanceMidMarketResult(
          snapshot: cached,
          fromCache: true,
          isStale: true,
          cachedAt: await _cache.midMarketCachedAt(),
        );
      }
      rethrow;
    }
  }

  Future<RemittanceProviderRatesResult> fetchProviderRatesWithCache(
    String countryCode,
  ) async {
    final code = countryCode.toUpperCase();
    await _cache.init();

    try {
      final snap = await _firestore
          .collection(providerRatesCollection)
          .where('destinationCountryCode', isEqualTo: code)
          .get();

      final providers = snap.docs
          .map((d) => RemittanceProviderRate.fromFirestore(d.id, d.data()))
          .where(_isValidProvider)
          .toList();

      if (!_isCacheableProviderList(providers)) {
        return _providerRatesFromCacheOrEmpty(code);
      }

      await _cache.cacheProviderRates(code, providers);
      return RemittanceProviderRatesResult(
        providers: providers,
        fromCache: false,
        cachedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('RemittanceTruthRepository provider rates fetch failed: $e');
      final cached = await _cache.loadProviderRates(code);
      if (cached != null && _isCacheableProviderList(cached)) {
        return RemittanceProviderRatesResult(
          providers: cached,
          fromCache: true,
          isStale: true,
          cachedAt: await _cache.providerRatesCachedAt(code),
        );
      }
      rethrow;
    }
  }

  /// Corridor-specific usability check for UI gating.
  static bool hasUsableCorridorRate(
    RemittanceMidMarketSnapshot? snapshot,
    String countryCode,
  ) {
    if (snapshot == null) return false;
    final rate = snapshot.rateFor(countryCode);
    return rate != null && rate.rate.isFinite && rate.rate > 0;
  }

  Future<RemittanceMidMarketResult> _midMarketFromCacheOrEmpty() async {
    final cached = await _cache.loadMidMarket();
    if (cached != null && _isCacheableMidMarket(cached)) {
      return RemittanceMidMarketResult(
        snapshot: cached,
        fromCache: true,
        isStale: true,
        cachedAt: await _cache.midMarketCachedAt(),
      );
    }
    return const RemittanceMidMarketResult(snapshot: null);
  }

  Future<RemittanceProviderRatesResult> _providerRatesFromCacheOrEmpty(
    String countryCode,
  ) async {
    final cached = await _cache.loadProviderRates(countryCode);
    if (cached != null && _isCacheableProviderList(cached)) {
      return RemittanceProviderRatesResult(
        providers: cached,
        fromCache: true,
        isStale: true,
        cachedAt: await _cache.providerRatesCachedAt(countryCode),
      );
    }
    return const RemittanceProviderRatesResult(providers: []);
  }

  static bool _isCacheableMidMarket(RemittanceMidMarketSnapshot snapshot) {
    if (snapshot.corridors.isEmpty) return false;
    return snapshot.corridors.values.any(
      (rate) => rate.rate.isFinite && rate.rate > 0,
    );
  }

  static bool _isCacheableProviderList(List<RemittanceProviderRate> providers) {
    if (providers.isEmpty) return false;
    return providers.every(_isValidProvider);
  }

  static bool _isValidProvider(RemittanceProviderRate provider) {
    return provider.id.isNotEmpty &&
        provider.providerName.isNotEmpty &&
        provider.fxMarginPercent.isFinite &&
        provider.flatFeeQar.isFinite;
  }
}

class RemittanceMidMarketResult {
  const RemittanceMidMarketResult({
    required this.snapshot,
    this.fromCache = false,
    this.isStale = false,
    this.cachedAt,
  });

  final RemittanceMidMarketSnapshot? snapshot;
  final bool fromCache;
  final bool isStale;
  final DateTime? cachedAt;
}

class RemittanceProviderRatesResult {
  const RemittanceProviderRatesResult({
    required this.providers,
    this.fromCache = false,
    this.isStale = false,
    this.cachedAt,
  });

  final List<RemittanceProviderRate> providers;
  final bool fromCache;
  final bool isStale;
  final DateTime? cachedAt;
}
