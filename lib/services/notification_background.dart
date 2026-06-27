import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:raabta/firebase_options.dart';

/// Top-level background FCM handler (must be top-level function).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('Background FCM: ${message.notification?.title}');

  // Data-only payloads: show a local notification (notification payloads are
  // displayed by the OS when the app is backgrounded).
  if (message.notification == null && message.data.isNotEmpty) {
    await RaabtaLocalNotifications.instance.initialize();
    final data = message.data;
    final route = data['route'] as String? ?? '/home';
    await RaabtaLocalNotifications.instance.show(
      id: message.hashCode,
      title: data['title'] as String? ?? 'Raabta',
      body: data['body'] as String? ?? '',
      payload: jsonEncode({'route': route, ...data}),
    );
  }
}

class RaabtaLocalNotifications {
  RaabtaLocalNotifications._();
  static final RaabtaLocalNotifications instance = RaabtaLocalNotifications._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'raabta_push',
    'Raabta Notifications',
    description: 'Push notifications from Raabta',
    importance: Importance.high,
  );

  bool _initialized = false;

  Future<void> initialize({
    void Function(NotificationResponse)? onTap,
  }) async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: darwin, macOS: darwin),
      onDidReceiveNotificationResponse: onTap,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    _initialized = true;
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) return;

    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
        macOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  String? parsePayloadRoute(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return null;
    try {
      final map = jsonDecode(payload) as Map<String, dynamic>;
      return map['route'] as String?;
    } catch (_) {
      return payload.startsWith('/') ? payload : null;
    }
  }
}
