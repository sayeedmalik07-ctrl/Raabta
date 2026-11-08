import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/models/notification_models.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:raabta/services/raabta_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationRepository {
  NotificationRepository(this._userId);

  final String _userId;

  static const _localNotificationsKey = 'local_notifications';
  static const _localSettingsKey = 'notification_settings';

  CollectionReference<Map<String, dynamic>>? get _notificationsRef {
    if (!FirebaseService.isReady || FirebaseAuth.instance.currentUser == null) {
      return null;
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('notifications');
  }

  DocumentReference<Map<String, dynamic>>? get _settingsRef {
    if (!FirebaseService.isReady || FirebaseAuth.instance.currentUser == null) {
      return null;
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('settings')
        .doc('notifications');
  }

  Stream<List<AppNotification>> watchNotifications() {
    final ref = _notificationsRef;
    if (ref != null) {
      return ref
          .orderBy('createdAt', descending: true)
          .limit(100)
          .snapshots()
          .map(
            (snap) => snap.docs
                .map((d) => AppNotification.fromJson({...d.data(), 'id': d.id}))
                .toList(),
          );
    }
    return Stream.fromFuture(_loadLocalNotifications());
  }

  Stream<int> watchUnreadCount() {
    return watchNotifications().map(
      (list) => list.where((n) => !n.read).length,
    );
  }

  Future<List<AppNotification>> _loadLocalNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_localNotificationsKey) ?? [];
    return raw
        .map((s) => AppNotification.fromJson(
              jsonDecode(s) as Map<String, dynamic>,
            ))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _saveLocalNotifications(List<AppNotification> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _localNotificationsKey,
      items.map((n) => jsonEncode(n.toJson())).toList(),
    );
  }

  Future<void> seedDemoNotificationsIfEmpty() async {
    final existing = await _loadLocalNotifications();
    if (existing.isNotEmpty) return;

    final now = DateTime.now();
    final demo = [
      AppNotification(
        id: 'demo-1',
        title: 'Iqama Expiring Soon',
        body: 'آپ کا اقامہ 7 دن میں ختم ہو رہا ہے',
        type: NotificationType.iqamaExpiry,
        route: '/visa',
        read: false,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: 'demo-2',
        title: 'New Housing Match',
        body: 'Room in Qatar — 1,200 QR/month matches your search',
        type: NotificationType.housingMatch,
        route: '/housing',
        read: false,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      AppNotification(
        id: 'demo-3',
        title: 'INR Rate Alert',
        body: 'INR reached 22.95 — your target was 22.90',
        type: NotificationType.rateAlert,
        route: '/money',
        read: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];

    final ref = _notificationsRef;
    if (ref != null) {
      for (final n in demo) {
        await ref.doc(n.id).set(n.toJson());
      }
    } else {
      await _saveLocalNotifications(demo);
    }
  }

  Future<void> markRead(String notificationId) async {
    final ref = _notificationsRef;
    if (ref != null) {
      await ref.doc(notificationId).set({'read': true}, SetOptions(merge: true));
      return;
    }

    final items = await _loadLocalNotifications();
    final updated = items
        .map((n) => n.id == notificationId ? n.copyWith(read: true) : n)
        .toList();
    await _saveLocalNotifications(updated);
  }

  Future<void> markAllRead() async {
    final ref = _notificationsRef;
    if (ref != null) {
      final snap = await ref.where('read', isEqualTo: false).get();
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
      return;
    }

    final items = await _loadLocalNotifications();
    await _saveLocalNotifications(
      items.map((n) => n.copyWith(read: true)).toList(),
    );
  }

  Future<void> deleteNotification(String notificationId) async {
    final ref = _notificationsRef;
    if (ref != null) {
      await ref.doc(notificationId).delete();
      return;
    }

    final items = await _loadLocalNotifications();
    items.removeWhere((n) => n.id == notificationId);
    await _saveLocalNotifications(items);
  }

  Future<NotificationSettings> getSettings() async {
    final ref = _settingsRef;
    if (ref != null) {
      final doc = await ref.get();
      if (doc.exists) {
        return NotificationSettings.fromJson(doc.data()!);
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localSettingsKey);
    if (raw != null) {
      return NotificationSettings.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    }
    return const NotificationSettings();
  }

  Future<void> saveSettings(NotificationSettings settings) async {
    final ref = _settingsRef;
    if (ref != null) {
      await ref.set(settings.toJson(), SetOptions(merge: true));
      await FirebaseFirestore.instance.collection('users').doc(_userId).set(
        {'notificationLanguage': settings.notificationLanguage},
        SetOptions(merge: true),
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localSettingsKey, jsonEncode(settings.toJson()));
  }

  Future<void> addInboxNotification(AppNotification notification) async {
    final ref = _notificationsRef;
    if (ref != null) {
      try {
        await ref.doc(notification.id).set(notification.toJson());
        return;
      } catch (e) {
        // Fall through to local cache.
      }
    }

    final items = await _loadLocalNotifications();
    items.removeWhere((n) => n.id == notification.id);
    items.insert(0, notification);
    if (items.length > 100) {
      items.removeRange(100, items.length);
    }
    await _saveLocalNotifications(items);
  }
}

Future<NotificationRepository> createNotificationRepository() async {
  final userId =
      await RaabtaNotificationService.instance.getOrCreateUserId();
  final repo = NotificationRepository(userId);
  await repo.seedDemoNotificationsIfEmpty();
  return repo;
}
