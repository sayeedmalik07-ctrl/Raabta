enum NotificationType {
  iqamaExpiry,
  housingMatch,
  rateAlert,
  communityReply,
  jobMatch,
  weeklyDigest,
  adminAnnouncement,
  general,
}

NotificationType parseNotificationType(String? value) {
  switch (value) {
    case 'iqama_expiry':
      return NotificationType.iqamaExpiry;
    case 'housing_match':
      return NotificationType.housingMatch;
    case 'rate_alert':
      return NotificationType.rateAlert;
    case 'community_reply':
      return NotificationType.communityReply;
    case 'job_match':
      return NotificationType.jobMatch;
    case 'weekly_digest':
      return NotificationType.weeklyDigest;
    case 'admin_announcement':
      return NotificationType.adminAnnouncement;
    default:
      return NotificationType.general;
  }
}

String notificationTypeToApi(NotificationType type) {
  switch (type) {
    case NotificationType.iqamaExpiry:
      return 'iqama_expiry';
    case NotificationType.housingMatch:
      return 'housing_match';
    case NotificationType.rateAlert:
      return 'rate_alert';
    case NotificationType.communityReply:
      return 'community_reply';
    case NotificationType.jobMatch:
      return 'job_match';
    case NotificationType.weeklyDigest:
      return 'weekly_digest';
    case NotificationType.adminAnnouncement:
      return 'admin_announcement';
    case NotificationType.general:
      return 'general';
  }
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.route,
    required this.read,
    required this.createdAt,
    this.data = const {},
  });

  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final String route;
  final bool read;
  final DateTime createdAt;
  final Map<String, dynamic> data;

  AppNotification copyWith({bool? read}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      type: type,
      route: route,
      read: read ?? this.read,
      createdAt: createdAt,
      data: data,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: parseNotificationType(json['type'] as String?),
      route: json['route'] as String? ?? '/home',
      read: json['read'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      data: Map<String, dynamic>.from(json['data'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'type': notificationTypeToApi(type),
        'route': route,
        'read': read,
        'createdAt': createdAt.toIso8601String(),
        'data': data,
      };
}

class NotificationSettings {
  const NotificationSettings({
    this.iqamaExpiry = true,
    this.housingMatch = true,
    this.rateAlert = true,
    this.communityReply = true,
    this.jobMatch = true,
    this.weeklyDigest = true,
    this.adminAnnouncement = true,
    this.quietHoursEnabled = true,
    this.quietHoursStart = 23,
    this.quietHoursEnd = 7,
    this.notificationLanguage = 'English',
  });

  final bool iqamaExpiry;
  final bool housingMatch;
  final bool rateAlert;
  final bool communityReply;
  final bool jobMatch;
  final bool weeklyDigest;
  final bool adminAnnouncement;
  final bool quietHoursEnabled;
  final int quietHoursStart;
  final int quietHoursEnd;
  final String notificationLanguage;

  NotificationSettings copyWith({
    bool? iqamaExpiry,
    bool? housingMatch,
    bool? rateAlert,
    bool? communityReply,
    bool? jobMatch,
    bool? weeklyDigest,
    bool? adminAnnouncement,
    bool? quietHoursEnabled,
    int? quietHoursStart,
    int? quietHoursEnd,
    String? notificationLanguage,
  }) {
    return NotificationSettings(
      iqamaExpiry: iqamaExpiry ?? this.iqamaExpiry,
      housingMatch: housingMatch ?? this.housingMatch,
      rateAlert: rateAlert ?? this.rateAlert,
      communityReply: communityReply ?? this.communityReply,
      jobMatch: jobMatch ?? this.jobMatch,
      weeklyDigest: weeklyDigest ?? this.weeklyDigest,
      adminAnnouncement: adminAnnouncement ?? this.adminAnnouncement,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      notificationLanguage:
          notificationLanguage ?? this.notificationLanguage,
    );
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      iqamaExpiry: json['iqamaExpiry'] as bool? ?? true,
      housingMatch: json['housingMatch'] as bool? ?? true,
      rateAlert: json['rateAlert'] as bool? ?? true,
      communityReply: json['communityReply'] as bool? ?? true,
      jobMatch: json['jobMatch'] as bool? ?? true,
      weeklyDigest: json['weeklyDigest'] as bool? ?? true,
      adminAnnouncement: json['adminAnnouncement'] as bool? ?? true,
      quietHoursEnabled: json['quietHoursEnabled'] as bool? ?? true,
      quietHoursStart: (json['quietHoursStart'] as num?)?.toInt() ?? 23,
      quietHoursEnd: (json['quietHoursEnd'] as num?)?.toInt() ?? 7,
      notificationLanguage:
          json['notificationLanguage'] as String? ?? 'English',
    );
  }

  Map<String, dynamic> toJson() => {
        'iqamaExpiry': iqamaExpiry,
        'housingMatch': housingMatch,
        'rateAlert': rateAlert,
        'communityReply': communityReply,
        'jobMatch': jobMatch,
        'weeklyDigest': weeklyDigest,
        'adminAnnouncement': adminAnnouncement,
        'quietHoursEnabled': quietHoursEnabled,
        'quietHoursStart': quietHoursStart,
        'quietHoursEnd': quietHoursEnd,
        'notificationLanguage': notificationLanguage,
      };
}

String notificationTypeEmoji(NotificationType type) {
  switch (type) {
    case NotificationType.iqamaExpiry:
      return '📋';
    case NotificationType.housingMatch:
      return '🏠';
    case NotificationType.rateAlert:
      return '💰';
    case NotificationType.communityReply:
      return '💬';
    case NotificationType.jobMatch:
      return '💼';
    case NotificationType.weeklyDigest:
      return '📰';
    case NotificationType.adminAnnouncement:
      return '📢';
    case NotificationType.general:
      return '🔔';
  }
}
