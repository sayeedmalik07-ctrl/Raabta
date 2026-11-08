import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:raabta/models/notification_models.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:raabta/services/notification_repository.dart';
import 'package:raabta/services/raabta_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Per-category preferences — Firestore `users/{uid}/notification_preferences`
/// with Hive + SharedPreferences local cache for instant UI.
class NotificationPreferencesService {
  NotificationPreferencesService(this._userId);

  final String _userId;

  static const _hiveBox = 'notification_preferences_cache';
  static const _prefsKey = 'notification_preferences_v1';

  DocumentReference<Map<String, dynamic>>? get _firestoreRef {
    if (!FirebaseService.isReady) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('notification_preferences')
        .doc('settings');
  }

  static Future<void> ensureHive() async {
    if (Hive.isBoxOpen(_hiveBox)) return;
    try {
      await Hive.initFlutter();
    } catch (_) {
      Hive.init('raabta_hive');
    }
    if (!Hive.isBoxOpen(_hiveBox)) {
      await Hive.openBox<String>(_hiveBox);
    }
  }

  Future<NotificationSettings> getSettings() async {
    await ensureHive();
    final box = Hive.box<String>(_hiveBox);
    final cached = box.get(_userId);
    if (cached != null) {
      try {
        return NotificationSettings.fromJson(
          jsonDecode(cached) as Map<String, dynamic>,
        );
      } catch (_) {}
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefsKey$_userId');
    if (raw != null) {
      try {
        return NotificationSettings.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } catch (_) {}
    }

    final ref = _firestoreRef;
    if (ref != null) {
      try {
        final doc = await ref.get();
        if (doc.exists && doc.data() != null) {
          final settings = NotificationSettings.fromJson(doc.data()!);
          await _cacheLocally(settings);
          return settings;
        }
      } catch (e) {
        debugPrint('NotificationPreferencesService Firestore read failed: $e');
      }
    }

    // Fallback to legacy settings path.
    return NotificationRepository(_userId).getSettings();
  }

  Future<void> saveSettings(NotificationSettings settings) async {
    await _cacheLocally(settings);

    final ref = _firestoreRef;
    if (ref != null) {
      try {
        await ref.set(settings.toJson(), SetOptions(merge: true));
        // Keep legacy path in sync for existing screens.
        await NotificationRepository(_userId).saveSettings(settings);
      } catch (e) {
        debugPrint(
          'NotificationPreferencesService Firestore write failed (Hive cache kept): $e',
        );
      }
    } else {
      await NotificationRepository(_userId).saveSettings(settings);
    }
  }

  Future<void> _cacheLocally(NotificationSettings settings) async {
    final encoded = jsonEncode(settings.toJson());
    await ensureHive();
    await Hive.box<String>(_hiveBox).put(_userId, encoded);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefsKey$_userId', encoded);
  }
}

Future<NotificationPreferencesService> createNotificationPreferencesService() async {
  final userId =
      await RaabtaNotificationService.instance.getOrCreateUserId();
  return NotificationPreferencesService(userId);
}
