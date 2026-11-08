import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:raabta/firebase_options.dart';
import 'package:raabta/models/notification_models.dart';
import 'package:raabta/services/notifications/notification_presentation.dart';
import 'package:raabta/services/notifications/notification_priority.dart';
import 'package:raabta/services/notifications/notification_type.dart';
import 'package:raabta/services/notification_sound_config.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Top-level background FCM handler (must be top-level function).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('Background FCM: ${message.notification?.title}');

  if (message.notification == null && message.data.isNotEmpty) {
    await RaabtaLocalNotifications.instance.initialize();
    final data = message.data;
    final route = data['route'] as String? ?? '/home';
    final type = parseNotificationType(data['type'] as String?);
    final presentation = NotificationPresentation.classify(
      type: type,
      requestedPriority:
          NotificationPriority.tryParse(data['priority'] as String?),
      urgent: data['type'] == 'emergency' || data['timeCritical'] == 'true',
      data: Map<String, dynamic>.from(data),
    );
    await RaabtaLocalNotifications.instance.show(
      id: message.hashCode,
      title: data['title'] as String? ?? 'Raabta',
      body: data['body'] as String? ?? '',
      payload: jsonEncode({'route': route, ...data}),
      presentation: presentation,
    );
  }
}

class RaabtaLocalNotifications {
  RaabtaLocalNotifications._();
  static final RaabtaLocalNotifications instance = RaabtaLocalNotifications._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static AndroidNotificationChannel _buildDefaultChannel() {
    return AndroidNotificationChannel(
      RaabtaNotificationSound.defaultChannelId,
      RaabtaNotificationSound.defaultChannelName,
      description: RaabtaNotificationSound.defaultChannelDescription,
      importance: Importance.high,
      sound: RaabtaNotificationSound.useCustomSound
          ? const RawResourceAndroidNotificationSound(
              RaabtaNotificationSound.androidRawSound,
            )
          : null,
    );
  }

  static final _digestChannel = AndroidNotificationChannel(
    RaabtaNotificationSound.digestChannelId,
    RaabtaNotificationSound.digestChannelName,
    description: RaabtaNotificationSound.digestChannelDescription,
    importance: Importance.defaultImportance,
    sound: RaabtaNotificationSound.useCustomSound
        ? const RawResourceAndroidNotificationSound(
            RaabtaNotificationSound.androidRawSound,
          )
        : null,
  );

  static final _urgentChannel = AndroidNotificationChannel(
    RaabtaNotificationSound.urgentChannelId,
    RaabtaNotificationSound.urgentChannelName,
    description: 'Time-sensitive safety and emergency alerts',
    importance: Importance.max,
    sound: RaabtaNotificationSound.useCustomSound
        ? const RawResourceAndroidNotificationSound(
            RaabtaNotificationSound.urgentAndroidRawSound,
          )
        : null,
  );

  static final _securityChannel = AndroidNotificationChannel(
    RaabtaNotificationSound.securityChannelId,
    RaabtaNotificationSound.securityChannelName,
    description: RaabtaNotificationSound.securityChannelDescription,
    importance: Importance.high,
    enableVibration: true,
    vibrationPattern: Int64List.fromList([0, 200, 80, 200]),
    sound: RaabtaNotificationSound.useCustomSound
        ? const RawResourceAndroidNotificationSound(
            RaabtaNotificationSound.securityAndroidRawSound,
          )
        : null,
  );

  bool _initialized = false;

  Future<void> initialize({
    void Function(NotificationResponse)? onTap,
  }) async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Qatar'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: darwin, macOS: darwin),
      onDidReceiveNotificationResponse: onTap,
    );

    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(_buildDefaultChannel());
      await androidPlugin?.createNotificationChannel(_digestChannel);
      await androidPlugin?.createNotificationChannel(_urgentChannel);
      await androidPlugin?.createNotificationChannel(_securityChannel);
    }

    _initialized = true;
  }

  NotificationDetails _details({
    required ResolvedNotificationPriority presentation,
  }) {
    final urgent = NotificationPresentation.useUrgentAndroidChannel(
      presentation,
    );
    final digest = NotificationPresentation.useDigestAndroidChannel(
      presentation,
    );
    final threadIdentifier = NotificationPresentation.threadIdentifierFor(
      presentation.type,
    );
    final interruptionLevel = NotificationPresentation.interruptionLevelFor(
      priority: presentation.priority,
      timeSensitiveEntitlementAvailable:
          NotificationPlatformConfig.iosTimeSensitiveEntitlementAvailable,
    );
    final darwin = DarwinNotificationDetails(
      sound: RaabtaNotificationSound.useCustomSound
          ? (urgent
              ? RaabtaNotificationSound.urgentIosSoundFile
              : RaabtaNotificationSound.iosSoundFile)
          : null,
      threadIdentifier: threadIdentifier,
      interruptionLevel: interruptionLevel,
    );

    if (urgent) {
      return NotificationDetails(
        android: AndroidNotificationDetails(
          _urgentChannel.id,
          _urgentChannel.name,
          channelDescription: _urgentChannel.description,
          importance: Importance.max,
          priority: Priority.max,
          sound: RaabtaNotificationSound.useCustomSound
              ? const RawResourceAndroidNotificationSound(
                  RaabtaNotificationSound.urgentAndroidRawSound,
                )
              : null,
        ),
        iOS: darwin,
        macOS: darwin,
      );
    }

    if (presentation.type == NotificationType.scamAdvisoryAlert ||
        presentation.type == NotificationType.securityTip) {
      return NotificationDetails(
        android: AndroidNotificationDetails(
          _securityChannel.id,
          _securityChannel.name,
          channelDescription: _securityChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
          vibrationPattern: _securityChannel.vibrationPattern,
          sound: RaabtaNotificationSound.useCustomSound
              ? const RawResourceAndroidNotificationSound(
                  RaabtaNotificationSound.securityAndroidRawSound,
                )
              : null,
        ),
        iOS: darwin,
        macOS: darwin,
      );
    }

    if (digest) {
      return NotificationDetails(
        android: AndroidNotificationDetails(
          _digestChannel.id,
          _digestChannel.name,
          channelDescription: _digestChannel.description,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          sound: RaabtaNotificationSound.useCustomSound
              ? const RawResourceAndroidNotificationSound(
                  RaabtaNotificationSound.androidRawSound,
                )
              : null,
        ),
        iOS: darwin,
        macOS: darwin,
      );
    }

    return NotificationDetails(
      android: AndroidNotificationDetails(
        RaabtaNotificationSound.defaultChannelId,
        RaabtaNotificationSound.defaultChannelName,
        channelDescription: RaabtaNotificationSound.defaultChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        sound: RaabtaNotificationSound.useCustomSound
            ? const RawResourceAndroidNotificationSound(
                RaabtaNotificationSound.androidRawSound,
              )
            : null,
      ),
      iOS: darwin,
      macOS: darwin,
    );
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
    ResolvedNotificationPriority? presentation,
    bool urgent = false,
    bool digest = false,
  }) async {
    if (!_initialized) return;

    final resolved = presentation ??
        ResolvedNotificationPriority(
          type: NotificationType.general,
          priority: NotificationPriority.p3UsefulRecommendation,
          meta: NotificationTypeRegistry.metaFor(NotificationType.general),
          urgent: urgent,
          digest: digest,
        );

    await _plugin.show(
      id,
      title,
      body,
      _details(presentation: resolved),
      payload: payload,
    );
  }

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationType? notificationType,
    NotificationPriority? priority,
    bool urgent = false,
  }) async {
    if (!_initialized) return;

    final when = tz.TZDateTime.from(scheduledDate, tz.local);
    if (when.isBefore(tz.TZDateTime.now(tz.local))) return;

    final presentation = NotificationPresentation.classifyScheduled(
      notificationType: notificationType,
      payload: payload,
      priority: priority,
      urgent: urgent,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      _details(presentation: presentation),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);

  /// Pending local notifications (IDs + payloads when provided by the OS).
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() {
    return _plugin.pendingNotificationRequests();
  }

  String? parsePayloadRoute(NotificationResponse response) {
    final map = parsePayloadMap(response);
    if (map == null) return null;
    return map['route'] as String?;
  }

  Map<String, dynamic>? parsePayloadMap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return null;
    try {
      return Map<String, dynamic>.from(
        jsonDecode(payload) as Map<String, dynamic>,
      );
    } catch (_) {
      return payload.startsWith('/') ? {'route': payload} : null;
    }
  }
}
