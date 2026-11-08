import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';
import 'package:raabta/features/gold_intelligence/data/gold_local_store.dart';
import 'package:raabta/features/gold_intelligence/data/gold_spot_client.dart';
import 'package:raabta/features/gold_intelligence/domain/gold_alert_models.dart';
import 'package:raabta/features/gold_intelligence/domain/gold_qatar_models.dart';
import 'package:raabta/features/gold_intelligence/services/gold_alert_service.dart';
import 'package:raabta/services/auth/auth_session_service.dart';

class GoldFetchException implements Exception {
  GoldFetchException(this.message);
  final String message;

  @override
  String toString() => message;
}

class GoldQatarService {
  GoldQatarService({GoldLocalStore? localStore, GoldAlertService? alertService})
      : _localStore = localStore ?? GoldLocalStore(),
        _alertService = alertService ?? GoldAlertService();

  static const _base = '${AppConfig.backendUrl}/api/gold-qatar';
  static const _lockerCollection = 'jewelry_locker_qatar';

  final GoldLocalStore _localStore;
  final GoldAlertService _alertService;
  GoldQatarSnapshot? _latestCache;
  DateTime? _latestFetchedAt;

  Future<Map<String, String>> _jsonAuthHeaders() async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final token = await AuthSessionService.instance.getIdToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<GoldQatarSnapshot> fetchLatest({bool force = false}) async {
    if (!force &&
        _latestCache != null &&
        _latestFetchedAt != null &&
        DateTime.now().difference(_latestFetchedAt!).inMinutes < 5) {
      return _latestCache!.copyWith(isFromCache: true);
    }

    // 1) Raabta backend (snapshots + AI insight when deployed).
    try {
      final res = await http
          .get(Uri.parse('$_base/latest'))
          .timeout(const Duration(seconds: 12));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final snap = GoldQatarSnapshot.fromJson(
          data['snapshot'] as Map<String, dynamic>,
        );
        if (snap.gold24kQarPerGram > 0) {
          await _localStore.recordLivePrice(snap.gold24kQarPerGram);
          _latestCache = snap;
          _latestFetchedAt = DateTime.now();
          // Server runGoldAlertChecks + sendPushNotification handles delivery.
          return snap;
        }
      } else {
        debugPrint('Gold backend HTTP ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Gold backend fetch error: $e');
    }

    // 2) Direct live spot + on-device day stats (works when backend is 404/down).
    try {
      final spot = await GoldSpotClient.fetchUsdPerOz();
      if (spot != null) {
        final qarPerGram = GoldSpotClient.usdOzToQarPerGram24k(spot.usdPerOz);
        final dayStats = await _localStore.recordLivePrice(qarPerGram);
        final snap = GoldQatarSnapshot(
          gold24kQarPerGram: qarPerGram,
          gold30dPercentile: 50,
          gold90dPercentile: 50,
          pctVsYesterday: dayStats.pctVsYesterday ?? 0,
          pctVs7dAvg: 0,
          updatedAt: DateTime.now(),
          qarDeltaVsYesterday: dayStats.qarDeltaVsYesterday,
          yesterdayClose: dayStats.yesterdayClose,
          dayHigh: dayStats.dayHigh,
          dayLow: dayStats.dayLow,
          dayOpen: dayStats.dayOpen,
          spotSource: spot.source,
          isDirectApi: true,
        );
        _latestCache = snap;
        _latestFetchedAt = DateTime.now();
        // Backend unavailable — client-side smart engine fallback only.
        await _alertService.evaluateAlertsClientFallback(
          price24k: snap.gold24kQarPerGram,
        );
        return snap;
      }
    } catch (e) {
      debugPrint('Gold direct spot error: $e');
    }

    // 3) Stale in-memory cache.
    if (_latestCache != null) {
      return _latestCache!.copyWith(isFromCache: true);
    }

    // Should be unreachable if Swissquote is reachable; avoid crashing Riverpod.
    throw GoldFetchException('Could not load live gold rate');
  }

  Future<void> requestRefresh() async {
    try {
      final res = await http
          .post(Uri.parse('$_base/refresh'))
          .timeout(const Duration(seconds: 20));
      if (res.statusCode == 200) return;
    } catch (e) {
      debugPrint('Gold backend refresh skipped: $e');
    }
    // Force a direct spot re-fetch when backend unavailable.
    await fetchLatest(force: true);
  }

  Future<List<GoldHistoryPoint>> fetchHistory({
    int days = 7,
    bool todayOnly = false,
  }) async {
    try {
      final uri = todayOnly
          ? Uri.parse('$_base/history?mode=today')
          : Uri.parse('$_base/history?days=$days');
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final points = (data['history'] as List)
            .map((e) => GoldHistoryPoint.fromJson(e as Map<String, dynamic>))
            .toList();
        if (points.isNotEmpty) return points;
      }
    } catch (e) {
      debugPrint('Gold history backend error: $e');
    }

    if (todayOnly) {
      return _localStore.todayPoints();
    }
    return _localStore.rangePoints(days);
  }

  Future<List<JewelryLockerItem>> fetchLocker(String userId) async {
    try {
      final headers = await _jsonAuthHeaders();
      final res = await http.get(
        Uri.parse('$_base/locker/$userId'),
        headers: headers,
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final items = (data['items'] as List)
            .map((e) => JewelryLockerItem.fromJson(e as Map<String, dynamic>))
            .toList();
        if (items.isNotEmpty) return items;
      }
    } catch (e) {
      debugPrint('Locker API error: $e');
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection(_lockerCollection)
          .where('userId', isEqualTo: userId)
          .get();
      return snap.docs
          .map((d) => JewelryLockerItem.fromJson({'id': d.id, ...d.data()}))
          .toList()
        ..sort((a, b) => b.purchasePriceQar.compareTo(a.purchasePriceQar));
    } catch (e) {
      debugPrint('Locker Firestore error: $e');
    }
    return [];
  }

  Future<bool> addLockerItem({
    required String userId,
    required String itemName,
    required double purchasePriceQar,
    required double weightGrams,
    required int purity,
    String? invoicePhotoUrl,
  }) async {
    final payload = {
      'userId': userId,
      'itemName': itemName,
      'purchasePriceQar': purchasePriceQar,
      'weightGrams': weightGrams,
      'purity': purity,
      'invoicePhotoUrl': invoicePhotoUrl ?? '',
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      final headers = await _jsonAuthHeaders();
      final res = await http.post(
        Uri.parse('$_base/locker'),
        headers: headers,
        body: jsonEncode(payload),
      );
      if (res.statusCode == 200) return true;
    } catch (_) {}

    try {
      await FirebaseFirestore.instance.collection(_lockerCollection).add(payload);
      return true;
    } catch (e) {
      debugPrint('Locker add error: $e');
      return false;
    }
  }

  Future<bool> deleteLockerItem(String itemId) async {
    try {
      final headers = await _jsonAuthHeaders();
      final res = await http.delete(
        Uri.parse('$_base/locker/$itemId'),
        headers: headers,
      );
      if (res.statusCode == 200) return true;
    } catch (_) {}

    try {
      await FirebaseFirestore.instance
          .collection(_lockerCollection)
          .doc(itemId)
          .delete();
      return true;
    } catch (e) {
      debugPrint('Locker delete error: $e');
      return false;
    }
  }

  GoldAlertService get alertService => _alertService;

  Future<bool> saveAlert({
    required String userId,
    required Map<String, dynamic> alert,
  }) async {
    return _alertService.saveAlert(
      userId: userId,
      alert: GoldAlert.fromJson(alert),
    );
  }
}

extension _GoldSnapshotCopy on GoldQatarSnapshot {
  GoldQatarSnapshot copyWith({bool? isFromCache}) {
    return GoldQatarSnapshot(
      gold24kQarPerGram: gold24kQarPerGram,
      gold30dPercentile: gold30dPercentile,
      gold90dPercentile: gold90dPercentile,
      pctVsYesterday: pctVsYesterday,
      pctVs7dAvg: pctVs7dAvg,
      aiInsight: aiInsight,
      aiInsightDisclaimer: aiInsightDisclaimer,
      updatedAt: updatedAt,
      qarDeltaVsYesterday: qarDeltaVsYesterday,
      yesterdayClose: yesterdayClose,
      dayHigh: dayHigh,
      dayLow: dayLow,
      dayOpen: dayOpen,
      spotSource: spotSource,
      isFromCache: isFromCache ?? this.isFromCache,
      isDirectApi: isDirectApi,
    );
  }
}

final goldQatarServiceProvider = Provider((ref) => GoldQatarService());

final goldLatestProvider = FutureProvider<GoldQatarSnapshot>((ref) async {
  try {
    return await ref.read(goldQatarServiceProvider).fetchLatest();
  } on GoldFetchException catch (e) {
    debugPrint('goldLatestProvider: $e');
    rethrow;
  }
});

final goldHistoryProvider =
    FutureProvider.family<List<GoldHistoryPoint>, GoldChartRange>(
  (ref, range) {
    if (range == GoldChartRange.today) {
      return ref.read(goldQatarServiceProvider).fetchHistory(todayOnly: true);
    }
    return ref
        .read(goldQatarServiceProvider)
        .fetchHistory(days: range.historyDays ?? 7);
  },
);

final goldLockerProvider = FutureProvider.family<List<JewelryLockerItem>, String>(
  (ref, userId) => ref.read(goldQatarServiceProvider).fetchLocker(userId),
);

final goldAlertsProvider = FutureProvider.family<List<GoldAlert>, String>(
  (ref, userId) => ref.read(goldQatarServiceProvider).alertService.fetchAlerts(userId),
);
