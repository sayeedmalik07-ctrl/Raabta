import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';
import 'package:raabta/features/cost_of_living/data/cost_of_living_api_client.dart';
import 'package:raabta/features/cost_of_living/data/cost_of_living_firestore_repository.dart';
import 'package:raabta/features/cost_of_living/data/cost_of_living_local_cache.dart';
import 'package:raabta/features/cost_of_living/domain/cost_of_living_models.dart';

class CostOfLivingFetchException implements Exception {
  CostOfLivingFetchException(this.message);
  final String message;

  @override
  String toString() => message;
}

class CostOfLivingService {
  CostOfLivingService({
    CostOfLivingLocalCache? cache,
    CostOfLivingFirestoreRepository? firestore,
  })  : _cache = cache ?? CostOfLivingLocalCache.instance,
        _firestore = firestore ?? CostOfLivingFirestoreRepository();

  static const _base = '${AppConfig.backendUrl}/api/cost-of-living';

  final CostOfLivingLocalCache _cache;
  final CostOfLivingFirestoreRepository _firestore;
  CostOfLivingSnapshot? _memoryCache;

  Future<CostOfLivingSnapshot> fetchLatest({bool force = false}) async {
    if (!force && _memoryCache != null && _cache.isFresh) {
      return _memoryCache!.copyWith(isFromCache: true);
    }

    if (!force && _cache.isFresh) {
      final cached = _cache.load();
      if (cached != null) {
        _memoryCache = cached;
        return cached;
      }
    }

    try {
      final res = await http
          .get(Uri.parse('$_base/latest'))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final snapRaw = data['snapshot'] as Map<String, dynamic>?;
        if (snapRaw != null) {
          final snap = CostOfLivingSnapshot.fromJson(snapRaw);
          _memoryCache = snap;
          await _cache.save(snap);
          return snap;
        }
      } else {
        debugPrint('Cost of Living backend HTTP ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Cost of Living backend fetch error: $e');
    }

    try {
      final fs = await _firestore.fetchLatest();
      if (fs != null) {
        _memoryCache = fs;
        await _cache.save(fs);
        return fs;
      }
    } catch (e) {
      debugPrint('Cost of Living Firestore fallback error: $e');
    }

    // Backend not deployed / empty Firestore — fetch official open data directly.
    try {
      final direct = await CostOfLivingApiClient.fetchSnapshot();
      if (direct != null && direct.categories.isNotEmpty) {
        _memoryCache = direct;
        await _cache.save(direct);
        return direct;
      }
    } catch (e) {
      debugPrint('Cost of Living direct API fallback error: $e');
    }

    final hive = _cache.load();
    if (hive != null) return hive;

    if (_memoryCache != null) return _memoryCache!.copyWith(isFromCache: true);

    throw CostOfLivingFetchException('Could not load cost of living data');
  }
}

final costOfLivingServiceProvider = Provider<CostOfLivingService>(
  (ref) => CostOfLivingService(),
);

final costOfLivingSnapshotProvider =
    FutureProvider<CostOfLivingSnapshot>((ref) async {
  return ref.read(costOfLivingServiceProvider).fetchLatest();
});
