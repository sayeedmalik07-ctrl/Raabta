import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:raabta/models/notification_models.dart';
import 'package:raabta/services/notification_background.dart';
import 'package:raabta/services/notifications/notification_presentation.dart';
import 'package:raabta/services/notifications/notification_priority.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_alert_delivery.dart';
import 'package:raabta/core/l10n/app_locale_storage.dart';
import 'package:raabta/services/notifications/notification_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef NotificationTapHandler = void Function(String route, Map<String, dynamic> data);

class RaabtaNotificationService with WidgetsBindingObserver {
  RaabtaNotificationService._();
  static final RaabtaNotificationService instance = RaabtaNotificationService._();

  static const _userIdKey = 'raabta_user_id';
  static const _fcmTokenKey = 'raabta_fcm_token';

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;
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
        final map = RaabtaLocalNotifications.instance.parsePayloadMap(response);
        final route = map?['route'] as String?;
        if (route != null) {
          _onTap?.call(route, map ?? {});
        }
      },
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      try {
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

        final token = await _resolveFcmToken();
        if (token != null) {
          await _registerToken(token);
        }

        _messaging.onTokenRefresh.listen((token) {
          _registerToken(token).catchError((Object e) {
            debugPrint('FCM token refresh registration failed: $e');
          });
        });

        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedApp);

        final initial = await _messaging.getInitialMessage();
        if (initial != null) {
          _handleOpenedApp(initial);
        }
      } catch (e, stack) {
        // iOS can throw apns-token-not-set on cold start — app must still launch.
        debugPrint('Firebase Messaging setup deferred: $e\n$stack');
      }
    }

    await getOrCreateUserId();
    WidgetsBinding.instance.addObserver(this);
    try {
      await NotificationEngine.instance.init();
      await NotificationEngine.instance.maintainCapOverflowDigests();
    } catch (e, stack) {
      debugPrint('NotificationEngine init failed: $e\n$stack');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      NotificationEngine.instance.maintainCapOverflowDigests().catchError(
        (Object e, StackTrace stack) {
          debugPrint('Cap overflow digest maintenance failed: $e\n$stack');
        },
      );
      AppLocaleStorage.readNormalized().then((locale) {
        SecurityAlertDelivery.onAppOpen(locale: locale);
      });
    }
  }

  /// Resolves FCM token without blocking app startup on iOS.
  Future<String?> _resolveFcmToken() async {
    if (Platform.isIOS) {
      for (var attempt = 0; attempt < 6; attempt++) {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken != null) break;
        await Future<void>.delayed(
          Duration(milliseconds: 400 * (attempt + 1)),
        );
      }
    }

    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('FCM getToken unavailable yet: $e');
      return null;
    }
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
    final type = parseNotificationType(message.data['type'] as String?);
    final presentation = NotificationPresentation.classify(
      type: type,
      requestedPriority:
          NotificationPriority.tryParse(message.data['priority'] as String?),
      urgent: message.data['type'] == 'emergency' ||
          message.data['timeCritical'] == 'true',
      data: Map<String, dynamic>.from(message.data),
    );
    RaabtaLocalNotifications.instance.show(
      id: message.hashCode,
      title: notification.title ?? 'Raabta',
      body: notification.body ?? '',
      payload: jsonEncode({'route': route, ...message.data}),
      presentation: presentation,
    );
  }

  /// Smart send — dedup, quiet hours, preferences, then local or remote delivery.
  Future<SmartSendResult> sendSmartNotification(
    SmartNotificationRequest request,
  ) {
    return NotificationEngine.instance.send(request);
  }

  void _handleOpenedApp(RemoteMessage message) {
    final route = message.data['route'] as String? ?? '/home';
    _onTap?.call(route, Map<String, dynamic>.from(message.data));
  }
}
