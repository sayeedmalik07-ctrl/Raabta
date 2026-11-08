enum NotificationType {
  iqamaExpiry,
  housingMatch,
  rateAlert,
  communityReply,
  jobMatch,
  weeklyDigest,
  adminAnnouncement,
  billDue,
  warrantyExpiring,
  eventApproved,
  eventRejected,
  eventLive,
  eventReminder,
  lostFoundPosted,
  lostFoundResolved,
  breakingNews,
  groupActivity,
  groupNewMember,
  emergency,
  eosbReengagement,
  goldPriceThresholdQatar,
  jewelryValueGainQatar,
  documentDeadlineApproaching,
  zakatAnnualReminder,
  friendsFamilyLoanReminder,
  healthInsuranceReminder,
  concierge90Day,
  intelligenceDailyReview,
  scamShieldIncident,
  scamShieldShareAlert,
  scamAdvisoryAlert,
  securityTip,
  legalSourceUpdate,
  lifeEventCorrelation,
  lifeIntelligence,
  buddyRequest,
  buddyRequestAccepted,
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
    case 'bill_due':
      return NotificationType.billDue;
    case 'warranty_expiring':
      return NotificationType.warrantyExpiring;
    case 'event_approved':
      return NotificationType.eventApproved;
    case 'event_rejected':
      return NotificationType.eventRejected;
    case 'event_live':
      return NotificationType.eventLive;
    case 'event_reminder':
      return NotificationType.eventReminder;
    case 'lost_found_posted':
      return NotificationType.lostFoundPosted;
    case 'lost_found_resolved':
      return NotificationType.lostFoundResolved;
    case 'breaking_news':
      return NotificationType.breakingNews;
    case 'group_activity':
      return NotificationType.groupActivity;
    case 'group_new_member':
      return NotificationType.groupNewMember;
    case 'emergency':
      return NotificationType.emergency;
    case 'eosb_reengagement':
      return NotificationType.eosbReengagement;
    case 'gold_price_threshold_qatar':
      return NotificationType.goldPriceThresholdQatar;
    case 'jewelry_value_gain_qatar':
      return NotificationType.jewelryValueGainQatar;
    case 'document_deadline_approaching':
      return NotificationType.documentDeadlineApproaching;
    case 'zakat_annual_reminder':
      return NotificationType.zakatAnnualReminder;
    case 'friends_family_loan_reminder':
      return NotificationType.friendsFamilyLoanReminder;
    case 'health_insurance_reminder':
      return NotificationType.healthInsuranceReminder;
    case 'medicine_reminder':
      return NotificationType.general;
    case 'concierge_90_day':
      return NotificationType.concierge90Day;
    case 'intelligence_daily_review':
      return NotificationType.intelligenceDailyReview;
    case 'scam_shield_incident':
      return NotificationType.scamShieldIncident;
    case 'scam_shield_share_alert':
      return NotificationType.scamShieldShareAlert;
    case 'scam_advisory_alert':
      return NotificationType.scamAdvisoryAlert;
    case 'security_tip':
      return NotificationType.securityTip;
    case 'legal_source_update':
      return NotificationType.legalSourceUpdate;
    case 'life_event_correlation':
      return NotificationType.lifeEventCorrelation;
    case 'life_intelligence':
      return NotificationType.lifeIntelligence;
    case 'buddy_request':
      return NotificationType.buddyRequest;
    case 'buddy_request_accepted':
      return NotificationType.buddyRequestAccepted;
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
    case NotificationType.billDue:
      return 'bill_due';
    case NotificationType.warrantyExpiring:
      return 'warranty_expiring';
    case NotificationType.eventApproved:
      return 'event_approved';
    case NotificationType.eventRejected:
      return 'event_rejected';
    case NotificationType.eventLive:
      return 'event_live';
    case NotificationType.eventReminder:
      return 'event_reminder';
    case NotificationType.lostFoundPosted:
      return 'lost_found_posted';
    case NotificationType.lostFoundResolved:
      return 'lost_found_resolved';
    case NotificationType.breakingNews:
      return 'breaking_news';
    case NotificationType.groupActivity:
      return 'group_activity';
    case NotificationType.groupNewMember:
      return 'group_new_member';
    case NotificationType.emergency:
      return 'emergency';
    case NotificationType.eosbReengagement:
      return 'eosb_reengagement';
    case NotificationType.goldPriceThresholdQatar:
      return 'gold_price_threshold_qatar';
    case NotificationType.jewelryValueGainQatar:
      return 'jewelry_value_gain_qatar';
    case NotificationType.documentDeadlineApproaching:
      return 'document_deadline_approaching';
    case NotificationType.zakatAnnualReminder:
      return 'zakat_annual_reminder';
    case NotificationType.friendsFamilyLoanReminder:
      return 'friends_family_loan_reminder';
    case NotificationType.healthInsuranceReminder:
      return 'health_insurance_reminder';
    case NotificationType.concierge90Day:
      return 'concierge_90_day';
    case NotificationType.intelligenceDailyReview:
      return 'intelligence_daily_review';
    case NotificationType.scamShieldIncident:
      return 'scam_shield_incident';
    case NotificationType.scamShieldShareAlert:
      return 'scam_shield_share_alert';
    case NotificationType.scamAdvisoryAlert:
      return 'scam_advisory_alert';
    case NotificationType.securityTip:
      return 'security_tip';
    case NotificationType.legalSourceUpdate:
      return 'legal_source_update';
    case NotificationType.lifeEventCorrelation:
      return 'life_event_correlation';
    case NotificationType.lifeIntelligence:
      return 'life_intelligence';
    case NotificationType.buddyRequest:
      return 'buddy_request';
    case NotificationType.buddyRequestAccepted:
      return 'buddy_request_accepted';
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
    this.billDue = true,
    this.warrantyExpiring = true,
    this.communityEvents = true,
    this.communityLostFound = true,
    this.breakingNews = true,
    this.groupActivity = true,
    this.emergency = true,
    this.eosbReengagement = true,
    this.goldPriceThresholdQatar = true,
    this.jewelryValueGainQatar = true,
    this.documentDeadlineApproaching = true,
    this.zakatAnnualReminder = true,
    this.friendsFamilyLoanReminder = true,
    this.healthInsuranceReminder = true,
    this.concierge90Day = true,
    this.intelligenceDailyReview = true,
    this.scamShieldIncident = true,
    this.scamShieldShareAlert = true,
    this.scamAdvisoryAlert = true,
    this.securityTip = true,
    this.securityTodayCards = true,
    this.legalSourceUpdate = true,
    this.lifeIntelligence = true,
    this.quietHoursEnabled = true,
    this.quietHoursStart = 22,
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
  final bool billDue;
  final bool warrantyExpiring;
  final bool communityEvents;
  final bool communityLostFound;
  final bool breakingNews;
  final bool groupActivity;
  final bool emergency;
  final bool eosbReengagement;
  final bool goldPriceThresholdQatar;
  final bool jewelryValueGainQatar;
  final bool documentDeadlineApproaching;
  final bool zakatAnnualReminder;
  final bool friendsFamilyLoanReminder;
  final bool healthInsuranceReminder;
  final bool concierge90Day;
  final bool intelligenceDailyReview;
  final bool scamShieldIncident;
  final bool scamShieldShareAlert;
  final bool scamAdvisoryAlert;
  final bool securityTip;
  final bool securityTodayCards;
  final bool legalSourceUpdate;
  final bool lifeIntelligence;
  final bool quietHoursEnabled;
  final int quietHoursStart;
  final int quietHoursEnd;
  final String notificationLanguage;

  bool isTypeEnabled(NotificationType type) {
    switch (type) {
      case NotificationType.iqamaExpiry:
        return iqamaExpiry;
      case NotificationType.housingMatch:
        return housingMatch;
      case NotificationType.rateAlert:
        return rateAlert;
      case NotificationType.communityReply:
      case NotificationType.buddyRequest:
      case NotificationType.buddyRequestAccepted:
        return communityReply;
      case NotificationType.jobMatch:
        return jobMatch;
      case NotificationType.weeklyDigest:
        return weeklyDigest;
      case NotificationType.adminAnnouncement:
        return adminAnnouncement;
      case NotificationType.billDue:
        return billDue;
      case NotificationType.warrantyExpiring:
        return warrantyExpiring;
      case NotificationType.eventApproved:
      case NotificationType.eventRejected:
      case NotificationType.eventLive:
      case NotificationType.eventReminder:
        return communityEvents;
      case NotificationType.lostFoundPosted:
      case NotificationType.lostFoundResolved:
        return communityLostFound;
      case NotificationType.breakingNews:
        return breakingNews;
      case NotificationType.groupActivity:
      case NotificationType.groupNewMember:
        return groupActivity;
      case NotificationType.emergency:
        return emergency;
      case NotificationType.eosbReengagement:
        return eosbReengagement;
      case NotificationType.goldPriceThresholdQatar:
        return goldPriceThresholdQatar;
      case NotificationType.jewelryValueGainQatar:
        return jewelryValueGainQatar;
      case NotificationType.documentDeadlineApproaching:
        return documentDeadlineApproaching;
      case NotificationType.zakatAnnualReminder:
        return zakatAnnualReminder;
      case NotificationType.friendsFamilyLoanReminder:
        return friendsFamilyLoanReminder;
      case NotificationType.healthInsuranceReminder:
        return healthInsuranceReminder;
      case NotificationType.concierge90Day:
        return concierge90Day;
      case NotificationType.intelligenceDailyReview:
        return intelligenceDailyReview;
      case NotificationType.scamShieldIncident:
        return scamShieldIncident;
      case NotificationType.scamShieldShareAlert:
        return scamShieldShareAlert;
      case NotificationType.scamAdvisoryAlert:
        return scamAdvisoryAlert;
      case NotificationType.securityTip:
        return securityTip;
      case NotificationType.legalSourceUpdate:
        return legalSourceUpdate;
      case NotificationType.lifeEventCorrelation:
        return healthInsuranceReminder;
      case NotificationType.lifeIntelligence:
        return lifeIntelligence;
      case NotificationType.general:
        return true;
    }
  }

  NotificationSettings copyWith({
    bool? iqamaExpiry,
    bool? housingMatch,
    bool? rateAlert,
    bool? communityReply,
    bool? jobMatch,
    bool? weeklyDigest,
    bool? adminAnnouncement,
    bool? billDue,
    bool? warrantyExpiring,
    bool? communityEvents,
    bool? communityLostFound,
    bool? breakingNews,
    bool? groupActivity,
    bool? emergency,
    bool? eosbReengagement,
    bool? goldPriceThresholdQatar,
    bool? jewelryValueGainQatar,
    bool? documentDeadlineApproaching,
    bool? zakatAnnualReminder,
    bool? friendsFamilyLoanReminder,
    bool? healthInsuranceReminder,
    bool? concierge90Day,
    bool? intelligenceDailyReview,
    bool? scamShieldIncident,
    bool? scamShieldShareAlert,
    bool? scamAdvisoryAlert,
    bool? securityTip,
    bool? securityTodayCards,
    bool? legalSourceUpdate,
    bool? lifeIntelligence,
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
      billDue: billDue ?? this.billDue,
      warrantyExpiring: warrantyExpiring ?? this.warrantyExpiring,
      communityEvents: communityEvents ?? this.communityEvents,
      communityLostFound: communityLostFound ?? this.communityLostFound,
      breakingNews: breakingNews ?? this.breakingNews,
      groupActivity: groupActivity ?? this.groupActivity,
      emergency: emergency ?? this.emergency,
      eosbReengagement: eosbReengagement ?? this.eosbReengagement,
      goldPriceThresholdQatar:
          goldPriceThresholdQatar ?? this.goldPriceThresholdQatar,
      jewelryValueGainQatar:
          jewelryValueGainQatar ?? this.jewelryValueGainQatar,
      documentDeadlineApproaching:
          documentDeadlineApproaching ?? this.documentDeadlineApproaching,
      zakatAnnualReminder: zakatAnnualReminder ?? this.zakatAnnualReminder,
      friendsFamilyLoanReminder:
          friendsFamilyLoanReminder ?? this.friendsFamilyLoanReminder,
      healthInsuranceReminder:
          healthInsuranceReminder ?? this.healthInsuranceReminder,
      concierge90Day: concierge90Day ?? this.concierge90Day,
      intelligenceDailyReview:
          intelligenceDailyReview ?? this.intelligenceDailyReview,
      scamShieldIncident: scamShieldIncident ?? this.scamShieldIncident,
      scamShieldShareAlert:
          scamShieldShareAlert ?? this.scamShieldShareAlert,
      scamAdvisoryAlert: scamAdvisoryAlert ?? this.scamAdvisoryAlert,
      securityTip: securityTip ?? this.securityTip,
      securityTodayCards: securityTodayCards ?? this.securityTodayCards,
      legalSourceUpdate: legalSourceUpdate ?? this.legalSourceUpdate,
      lifeIntelligence: lifeIntelligence ?? this.lifeIntelligence,
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
      billDue: json['billDue'] as bool? ?? true,
      warrantyExpiring: json['warrantyExpiring'] as bool? ?? true,
      communityEvents: json['communityEvents'] as bool? ?? true,
      communityLostFound: json['communityLostFound'] as bool? ?? true,
      breakingNews: json['breakingNews'] as bool? ?? true,
      groupActivity: json['groupActivity'] as bool? ?? true,
      emergency: json['emergency'] as bool? ?? true,
      eosbReengagement: json['eosbReengagement'] as bool? ?? true,
      goldPriceThresholdQatar: json['goldPriceThresholdQatar'] as bool? ?? true,
      jewelryValueGainQatar: json['jewelryValueGainQatar'] as bool? ?? true,
      documentDeadlineApproaching:
          json['documentDeadlineApproaching'] as bool? ?? true,
      zakatAnnualReminder: json['zakatAnnualReminder'] as bool? ?? true,
      friendsFamilyLoanReminder:
          json['friendsFamilyLoanReminder'] as bool? ?? true,
      healthInsuranceReminder:
          json['healthInsuranceReminder'] as bool? ?? true,
      concierge90Day: json['concierge90Day'] as bool? ?? true,
      intelligenceDailyReview: json['intelligenceDailyReview'] as bool? ?? true,
      scamShieldIncident: json['scamShieldIncident'] as bool? ?? true,
      scamShieldShareAlert: json['scamShieldShareAlert'] as bool? ?? true,
      scamAdvisoryAlert: json['scamAdvisoryAlert'] as bool? ?? true,
      securityTip: json['securityTip'] as bool? ?? true,
      securityTodayCards: json['securityTodayCards'] as bool? ?? true,
      legalSourceUpdate: json['legalSourceUpdate'] as bool? ?? true,
      lifeIntelligence: json['lifeIntelligence'] as bool? ?? true,
      quietHoursEnabled: json['quietHoursEnabled'] as bool? ?? true,
      quietHoursStart: (json['quietHoursStart'] as num?)?.toInt() ?? 22,
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
        'billDue': billDue,
        'warrantyExpiring': warrantyExpiring,
        'communityEvents': communityEvents,
        'communityLostFound': communityLostFound,
        'breakingNews': breakingNews,
        'groupActivity': groupActivity,
        'emergency': emergency,
        'eosbReengagement': eosbReengagement,
        'goldPriceThresholdQatar': goldPriceThresholdQatar,
        'jewelryValueGainQatar': jewelryValueGainQatar,
        'documentDeadlineApproaching': documentDeadlineApproaching,
        'zakatAnnualReminder': zakatAnnualReminder,
        'friendsFamilyLoanReminder': friendsFamilyLoanReminder,
        'healthInsuranceReminder': healthInsuranceReminder,
        'concierge90Day': concierge90Day,
        'intelligenceDailyReview': intelligenceDailyReview,
        'scamShieldIncident': scamShieldIncident,
        'scamShieldShareAlert': scamShieldShareAlert,
        'scamAdvisoryAlert': scamAdvisoryAlert,
        'securityTip': securityTip,
        'securityTodayCards': securityTodayCards,
        'legalSourceUpdate': legalSourceUpdate,
        'lifeIntelligence': lifeIntelligence,
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
    case NotificationType.buddyRequest:
    case NotificationType.buddyRequestAccepted:
      return '💬';
    case NotificationType.jobMatch:
      return '💼';
    case NotificationType.weeklyDigest:
      return '📰';
    case NotificationType.adminAnnouncement:
      return '📢';
    case NotificationType.billDue:
      return '💳';
    case NotificationType.warrantyExpiring:
      return '🛡️';
    case NotificationType.eventApproved:
    case NotificationType.eventRejected:
    case NotificationType.eventLive:
    case NotificationType.eventReminder:
      return '📅';
    case NotificationType.lostFoundPosted:
    case NotificationType.lostFoundResolved:
      return '🔍';
    case NotificationType.breakingNews:
      return '🚨';
    case NotificationType.groupActivity:
    case NotificationType.groupNewMember:
      return '👥';
    case NotificationType.emergency:
      return '🆘';
    case NotificationType.eosbReengagement:
      return '📊';
    case NotificationType.goldPriceThresholdQatar:
    case NotificationType.jewelryValueGainQatar:
      return '🥇';
    case NotificationType.documentDeadlineApproaching:
      return '📋';
    case NotificationType.zakatAnnualReminder:
      return '🤲';
    case NotificationType.friendsFamilyLoanReminder:
      return '🤝';
    case NotificationType.healthInsuranceReminder:
      return '🏥';
    case NotificationType.concierge90Day:
      return '🧭';
    case NotificationType.intelligenceDailyReview:
      return '🎯';
    case NotificationType.scamShieldIncident:
    case NotificationType.scamShieldShareAlert:
    case NotificationType.scamAdvisoryAlert:
    case NotificationType.securityTip:
      return '🛡️';
    case NotificationType.legalSourceUpdate:
      return '⚖️';
    case NotificationType.lifeEventCorrelation:
      return '🏥';
    case NotificationType.lifeIntelligence:
      return '🧭';
    case NotificationType.general:
      return '🔔';
  }
}
