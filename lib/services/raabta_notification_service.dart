import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:raabta/services/notification_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef NotificationTapHandler = void Function(String route, Map<String, dynamic> data);

class RaabtaNotificationService {
  RaabtaNotificationService._();
  static final RaabtaNotificationService instance = RaabtaNotificationService._();

  static const _userIdKey = 'raabta_user_id';
  static const _fcmTokenKey = 'raabta_fcm_token';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  NotificationTapHandler? _onTap;
  String? _userId;

  String? get userId => _userId;

  Future<String> getOrCreateUserId() async {
    if (_userId != null) return _userId!;
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_userIdKey);
    if (id == null) {
      id = 'user_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(_userIdKey, id);
    }
    _userId = id;
    return id;
  }

  Future<void> initialize({NotificationTapHandler? onTap}) async {
    _onTap = onTap;

    await RaabtaLocalNotifications.instance.initialize(
      onTap: (response) {
        final route = RaabtaLocalNotifications.instance
            .parsePayloadRoute(response);
        if (route != null) {
          _onTap?.call(route, {});
        }
      },
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('Notification permission denied');
        return;
      }

      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      final token = await _messaging.getToken();
      if (token != null) {
        await _registerToken(token);
      }

      _messaging.onTokenRefresh.listen(_registerToken);

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedApp);

      final initial = await _messaging.getInitialMessage();
      if (initial != null) {
        _handleOpenedApp(initial);
      }
    }

    await getOrCreateUserId();
  }

  Future<void> _registerToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fcmTokenKey, token);

    final userId = await getOrCreateUserId();
    try {
      await http.post(
        Uri.parse('${AppConfig.backendUrl}/api/notifications/register-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'fcmToken': token,
          'platform': Platform.operatingSystem,
        }),
      );
    } catch (e) {
      debugPrint('FCM token registration failed: $e');
    }

    if (FirebaseService.isReady) {
      await FirebaseFirestore.instance.collection('users').doc(userId).set(
        {
          'fcmToken': token,
          'fcmUpdatedAt': DateTime.now().toIso8601String(),
        },
        SetOptions(merge: true),
      );
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final route = message.data['route'] as String? ?? '/home';
    RaabtaLocalNotifications.instance.show(
      id: message.hashCode,
      title: notification.title ?? 'Raabta',
      body: notification.body ?? '',
      payload: jsonEncode({'route': route, ...message.data}),
    );
  }

  void _handleOpenedApp(RemoteMessage message) {
    final route = message.data['route'] as String? ?? '/home';
    _onTap?.call(route, Map<String, dynamic>.from(message.data));
  }
}
