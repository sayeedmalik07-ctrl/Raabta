import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';
import 'package:raabta/features/gold_intelligence/domain/gold_alert_models.dart';
import 'package:raabta/features/gold_intelligence/domain/gold_qatar_constants.dart';
import 'package:raabta/features/gold_intelligence/domain/gold_qatar_models.dart';
import 'package:raabta/services/auth/auth_session_service.dart';
import 'package:raabta/services/smart_notification_engine.dart';

/// Persists gold alerts and evaluates them via [SmartNotificationEngine].
class GoldAlertService {
  static const _base = '${AppConfig.backendUrl}/api/gold-qatar';
  static const _lockerCollection = 'jewelry_locker_qatar';

  Future<Map<String, String>> _jsonAuthHeaders() async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final token = await AuthSessionService.instance.getIdToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<GoldAlert>> fetchAlerts(String userId) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final raw = doc.data()?['goldAlerts'];
      if (raw is List) {
        return raw
            .map((e) => GoldAlert.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (e) {
      debugPrint('Gold alerts fetch error: $e');
    }
    return [];
  }

  Future<bool> saveAlert({
    required String userId,
    required GoldAlert alert,
  }) async {
    final withId = alert.id.isNotEmpty
        ? alert
        : GoldAlert(
            id: 'ga_${DateTime.now().millisecondsSinceEpoch}',
            type: alert.type,
            purity: alert.purity,
            thresholdQar: alert.thresholdQar,
            direction: alert.direction,
            gainQar: alert.gainQar,
          );

    try {
      final headers = await _jsonAuthHeaders();
      final res = await http.post(
        Uri.parse('$_base/alerts'),
        headers: headers,
        body: jsonEncode({'userId': userId, 'alert': withId.toJson()}),
      );
      if (res.statusCode == 200) return true;
    } catch (e) {
      debugPrint('Gold alert API error: $e');
    }

    try {
      final ref = FirebaseFirestore.instance.collection('users').doc(userId);
      final doc = await ref.get();
      final existing = doc.data()?['goldAlerts'];
      final list = existing is List
          ? existing
              .map((e) => Map<String, dynamic>.from(e as Map))
              .where((e) => e['id'] != withId.id)
              .toList()
          : <Map<String, dynamic>>[];
      list.add(withId.toJson());
      await ref.set({'goldAlerts': list}, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('Gold alert Firestore error: $e');
      return false;
    }
  }

  Future<bool> deleteAlert({
    required String userId,
    required String alertId,
  }) async {
    try {
      final ref = FirebaseFirestore.instance.collection('users').doc(userId);
      final doc = await ref.get();
      final existing = doc.data()?['goldAlerts'];
      if (existing is! List) return false;
      final list = existing
          .map((e) => Map<String, dynamic>.from(e as Map))
          .where((e) => e['id'] != alertId)
          .toList();
      await ref.set({'goldAlerts': list}, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('Gold alert delete error: $e');
      return false;
    }
  }

  /// Client-only fallback when the gold backend is down (direct spot path).
  /// When `/api/gold-qatar` is live, [runGoldAlertChecks] on the server delivers
  /// via [sendPushNotification] — do not evaluate here to avoid double push.
  Future<void> evaluateAlertsClientFallback({
    required double price24k,
    List<GoldAlert>? alerts,
    List<JewelryLockerItem>? lockerItems,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final activeAlerts = alerts ?? await fetchAlerts(uid);
    if (activeAlerts.isEmpty) return;

    final locker = lockerItems ?? await _fetchLocker(uid);

    for (final alert in activeAlerts) {
      if (alert.type == 'price_threshold' && alert.thresholdQar != null) {
        final purity = alert.purity;
        final price = GoldQatarConstants.priceForPurity(price24k, purity);
        final threshold = alert.thresholdQar!;
        final triggered = alert.direction == 'above'
            ? price >= threshold
            : price <= threshold;
        if (!triggered) continue;

        await SmartNotificationEngine.instance.maybeNotifyGoldPriceThreshold(
          alertId: alert.id,
          purity: purity,
          currentPriceQar: price,
          thresholdQar: threshold,
          direction: alert.direction,
        );
      }

      if (alert.type == 'locker_gain' && alert.gainQar != null && locker.isNotEmpty) {
        var totalPurchase = 0.0;
        var totalCurrent = 0.0;
        for (final item in locker) {
          totalPurchase += item.purchasePriceQar;
          totalCurrent += item.estimatedValueQar(price24k);
        }
        final gain = totalCurrent - totalPurchase;
        if (gain < alert.gainQar!) continue;

        await SmartNotificationEngine.instance.maybeNotifyJewelryLockerGain(
          alertId: alert.id,
          gainQar: gain,
          targetQar: alert.gainQar!,
        );
      }
    }
  }

  Future<List<JewelryLockerItem>> _fetchLocker(String userId) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection(_lockerCollection)
          .where('userId', isEqualTo: userId)
          .get();
      return snap.docs
          .map((d) => JewelryLockerItem.fromJson({'id': d.id, ...d.data()}))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
