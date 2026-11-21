import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/app_locale_storage.dart';
import 'package:raabta/models/notification_models.dart';
import 'package:raabta/services/notification_background.dart';
import 'package:raabta/services/notification_repository.dart';
import 'package:raabta/services/notifications/cap_overflow_digest.dart';
import 'package:raabta/services/notifications/groups_digest_service.dart';
import 'package:raabta/services/notifications/notification_copy_strings.dart';
import 'package:raabta/services/notifications/notification_dedup_service.dart';
import 'package:raabta/services/notifications/notification_preferences_service.dart';
import 'package:raabta/services/notifications/notification_presentation.dart';
import 'package:raabta/services/notifications/notification_priority.dart';
import 'package:raabta/services/notifications/notification_type.dart';
import 'package:raabta/services/notifications/quiet_hours_service.dart';
import 'package:raabta/features/bill_tracker/friends_family_loans/data/models/loan_entry_model.dart';
import 'package:raabta/features/bill_tracker/friends_family_loans/domain/loan_balance_calculator.dart';
import 'package:raabta/features/gold_intelligence/domain/gold_alert_models.dart';
import 'package:raabta/services/legal_deadline_reminder_prefs.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_push_weekly_cap.dart';
import 'package:raabta/services/raabta_notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Central smart notification orchestrator — wraps [RaabtaNotificationService]
/// without duplicating FCM init or token registration.
class NotificationEngine {
  NotificationEngine._();
  static final NotificationEngine instance = NotificationEngine._();

  static const billReminderOffsets = [3, 1, 0];
  static const warrantyReminderOffsets = [30, 7, 1, 0];
  static const documentDeadlineReminderOffsets = [30, 7, 1];
  static const legalDeadlineReminderOffsets = [90, 30, 7];
  static const jobMatchNotifyThreshold = 80;
  static const defaultDedupWindow = Duration(hours: 4);

  static const _freqCapBox = 'notification_freq_cap_v1';
  static const _capQueueBox = 'notification_cap_queue_v1';

  bool _initialized = false;

  Future<String> _resolveLocale([String? locale]) async {
    if (locale != null && locale.isNotEmpty) {
      return AppLocale.normalize(locale);
    }
    return AppLocaleStorage.readNormalized();
  }

  Future<void> init() async {
    if (_initialized) return;
    try {
      await Hive.initFlutter();
    } catch (_) {
      Hive.init('raabta_hive');
    }
    await NotificationDedupService.instance.init();
    await NotificationPreferencesService.ensureHive();
    if (!Hive.isBoxOpen(_freqCapBox)) {
      await Hive.openBox<int>(_freqCapBox);
    }
    if (!Hive.isBoxOpen(_capQueueBox)) {
      await Hive.openBox<String>(_capQueueBox);
    }
    GroupsDigestService.instance.start();
    _initialized = true;
    unawaited(maintainCapOverflowDigests());
  }

  /// Startup + foreground maintenance: purge TTL entries and flush stale digests.
  Future<void> maintainCapOverflowDigests() async {
    await init();
    final currentDate = _qatarDateKey();
    await _purgeExpiredCapQueueEntries(currentDate);
    await _flushEligibleCapOverflowDigests(currentDate);
  }

  Future<SmartSendGate> shouldSend(SmartNotificationRequest request) async {
    await init();
    final settings = await _loadSettings();
    final apiKey = notificationTypeToApi(request.type);
    final meta = NotificationTypeRegistry.metaFor(request.type);

    if (!settings.isTypeEnabled(request.type)) {
      return SmartSendGate.blocked('type_disabled');
    }

    if (request.type == NotificationType.scamAdvisoryAlert ||
        request.type == NotificationType.securityTip) {
      if (!await SecurityPushWeeklyCap.canSend(now: DateTime.now())) {
        return SmartSendGate.blocked('security_weekly_cap');
      }
    }

    final dedupKey = NotificationDedupService.instance.buildKey(
      notificationType: apiKey,
      referenceId: request.dedupKey,
    );
    final window = request.dedupWindow == NotificationEngine.defaultDedupWindow
        ? NotificationDedupService.instance.dedupWindowFor(apiKey)
        : request.dedupWindow;

    if (await NotificationDedupService.instance.isDuplicate(
      dedupKey: dedupKey,
      window: window,
    )) {
      return SmartSendGate.blocked('deduplicated');
    }

    // [NotificationPriority] classification for presentation metadata only.
    // Does not mutate SmartNotificationRequest.urgent/timeCritical or bypass gates.
    // Urgent Android channel may follow ResolvedNotificationPriority.useUrgentPresentation.
    NotificationPresentation.classify(
      type: request.type,
      requestedPriority: request.priority,
      urgent: request.urgent,
      data: request.data,
    );

    final quiet = QuietHoursService.instance;
    final inQuietHours = quiet.isQuietHours(settings);
    if (!request.timeCritical &&
        inQuietHours &&
        !quiet.isExemptDuringQuietHours(request.type, settings)) {
      return SmartSendGate.silent('quiet_hours');
    }

    if (!request.timeCritical && !request.skipDailyCap) {
      if (await _categoryCapReached(apiKey, meta.dailyCap)) {
        if (!CapOverflowDigest.isCapOverflowDigestData(request.data)) {
          await _queueForDigest(request);
          debugPrint(
            'NotificationEngine: category cap hit for $apiKey — queued for digest',
          );
        }
        return SmartSendGate.blocked(
          CapOverflowDigest.isCapOverflowDigestData(request.data)
              ? 'category_cap'
              : 'category_cap_queued',
        );
      }
    }

    return SmartSendGate.allowed();
  }

  Future<SmartSendResult> send(SmartNotificationRequest request) async {
    await init();
    final classified = NotificationPresentation.classify(
      type: request.type,
      requestedPriority: request.priority,
      urgent: request.urgent,
      data: request.data,
    );
    final gate = await shouldSend(request);
    if (!gate.allowed) {
      if (gate.silent) {
        if (CapOverflowDigest.isCapOverflowDigestData(request.data)) {
          return SmartSendResult(skipped: true, reason: gate.reason);
        }
        await _deliverToInboxOnly(request);
        return SmartSendResult(skipped: true, reason: gate.reason, inboxOnly: true);
      }
      debugPrint('NotificationEngine skipped (${gate.reason}): ${request.type}');
      return SmartSendResult(skipped: true, reason: gate.reason);
    }

    final apiKey = notificationTypeToApi(request.type);
    final dedupKey = NotificationDedupService.instance.buildKey(
      notificationType: apiKey,
      referenceId: request.dedupKey,
    );
    await NotificationDedupService.instance.record(dedupKey);

    if (!request.timeCritical && !request.skipDailyCap) {
      await _incrementCategoryCount(apiKey);
    }

    if (request.type == NotificationType.scamAdvisoryAlert ||
        request.type == NotificationType.securityTip) {
      await SecurityPushWeeklyCap.recordSend(now: DateTime.now());
    }

    if (request.remoteUserIds != null && request.remoteUserIds!.isNotEmpty) {
      return _sendRemote(request, classified);
    }
    if (request.groupId != null) {
      return _sendRemote(request, classified);
    }
    return _sendLocalNow(request, classified);
  }

  // ─── Feature triggers ─────────────────────────────────────

  Future<void> notifyEventVerificationResult({
    required String eventId,
    required String groupId,
    required String title,
    required bool approved,
    required String reason,
    required String creatorUserId,
  }) async {
    final locale = await _resolveLocale();
    final status = approved ? 'approved' : 'rejected';
    await send(
      SmartNotificationRequest(
        type: approved
            ? NotificationType.eventApproved
            : NotificationType.eventRejected,
        title: approved
            ? NotificationCopyStrings.t('event_approved_title', locale)
            : NotificationCopyStrings.t('event_not_approved_title', locale),
        body: approved
            ? NotificationCopyStrings.format(
                'event_approved_body',
                locale,
                params: {'title': title},
              )
            : NotificationCopyStrings.format(
                'event_rejected_body',
                locale,
                params: {'title': title, 'reason': reason},
              ),
        route: '/community/events',
        dedupKey: 'event_${eventId}_$status',
        data: {'eventId': eventId, 'groupId': groupId},
      ),
    );

    if (approved) {
      GroupsDigestService.instance.recordActivity(
        groupId: groupId,
        activityKind: 'event',
      );
      await send(
        SmartNotificationRequest(
          type: NotificationType.eventLive,
          title: NotificationCopyStrings.t('event_live_title', locale),
          body: NotificationCopyStrings.format(
            'event_live_body',
            locale,
            params: {'title': title},
          ),
          route: '/community/events',
          dedupKey: 'event_live_$eventId',
          groupId: groupId,
          excludeUserId: creatorUserId,
          data: {'eventId': eventId, 'groupId': groupId},
        ),
      );
    }
  }

  Future<void> notifyLostFoundPosted({
    required String itemId,
    required String groupId,
    required String title,
    required String type,
    required String posterUserId,
  }) async {
    final locale = await _resolveLocale();
    GroupsDigestService.instance.recordActivity(
      groupId: groupId,
      activityKind: 'lost_found',
    );
    await send(
      SmartNotificationRequest(
        type: NotificationType.lostFoundPosted,
        title: NotificationCopyStrings.lostFoundPostedTitle(type, locale),
        body: NotificationCopyStrings.format(
          'lost_found_posted_body',
          locale,
          params: {'title': title},
        ),
        route: '/community',
        dedupKey: 'lostfound_post_$itemId',
        groupId: groupId,
        excludeUserId: posterUserId,
        data: {'itemId': itemId, 'groupId': groupId},
      ),
    );
  }

  Future<void> notifyLostFoundResolved({
    required String itemId,
    required String title,
    required String posterUserId,
  }) async {
    final locale = await _resolveLocale();
    await send(
      SmartNotificationRequest(
        type: NotificationType.lostFoundResolved,
        title: NotificationCopyStrings.t('lost_found_resolved_title', locale),
        body: NotificationCopyStrings.format(
          'lost_found_resolved_body',
          locale,
          params: {'title': title},
        ),
        route: '/community',
        dedupKey: 'lostfound_resolved_$itemId',
        remoteUserIds: [posterUserId],
        data: {'itemId': itemId},
      ),
    );
  }

  Future<void> notifyAskQatarAnswer({
    required String questionId,
    required String questionTitle,
    required String authorUserId,
    required String replyPreview,
  }) async {
    final locale = await _resolveLocale();
    await send(
      SmartNotificationRequest(
        type: NotificationType.communityReply,
        title: NotificationCopyStrings.t('community_reply_title', locale),
        body: NotificationCopyStrings.format(
          'community_reply_body',
          locale,
          params: {
            'questionTitle': questionTitle,
            'replyPreview': replyPreview,
          },
        ),
        route: '/community',
        dedupKey: 'ask_qatar_$questionId',
        remoteUserIds: [authorUserId],
        data: {'questionId': questionId},
      ),
    );
  }

  Future<void> notifyAskQatarAnswerAccepted({
    required String questionId,
    required String questionTitle,
    required String answerAuthorUserId,
    required String answerId,
  }) async {
    final locale = await _resolveLocale();
    await send(
      SmartNotificationRequest(
        type: NotificationType.communityReply,
        title: NotificationCopyStrings.t(
          'ask_qatar_answer_accepted_title',
          locale,
        ),
        body: NotificationCopyStrings.format(
          'ask_qatar_answer_accepted_body',
          locale,
          params: {'questionTitle': questionTitle},
        ),
        route: '/community',
        dedupKey: 'ask_qatar_accepted_${questionId}_$answerId',
        remoteUserIds: [answerAuthorUserId],
        data: {'questionId': questionId, 'answerId': answerId},
      ),
    );
  }

  Future<void> notifyBuddyRequest({
    required String requestId,
    required String helperUserId,
    required String introPreview,
  }) async {
    final locale = await _resolveLocale();
    await send(
      SmartNotificationRequest(
        type: NotificationType.buddyRequest,
        title: NotificationCopyStrings.t('buddy_request_title', locale),
        body: NotificationCopyStrings.format(
          'buddy_request_body',
          locale,
          params: {'introPreview': introPreview},
        ),
        route: '/community/buddy',
        dedupKey: 'buddy_request_$requestId',
        remoteUserIds: [helperUserId],
        data: {'requestId': requestId},
      ),
    );
  }

  Future<void> notifyBuddyRequestAccepted({
    required String requestId,
    required String threadId,
    required String newcomerUserId,
  }) async {
    final locale = await _resolveLocale();
    await send(
      SmartNotificationRequest(
        type: NotificationType.buddyRequestAccepted,
        title: NotificationCopyStrings.t('buddy_request_accepted_title', locale),
        body: NotificationCopyStrings.t('buddy_request_accepted_body', locale),
        route: '/community/buddy/chat/$threadId',
        dedupKey: 'buddy_accept_$requestId',
        remoteUserIds: [newcomerUserId],
        data: {'requestId': requestId, 'threadId': threadId},
      ),
    );
  }

  /// Jobs saved-search matching — stub until matching feature ships.
  Future<void> maybeNotifyJobMatch({
    required String jobId,
    required String jobTitle,
    required String company,
    required int matchScore,
  }) async {
    // Dependency: saved-search / profile matching must exist in Jobs feature.
    if (matchScore < jobMatchNotifyThreshold) return;

    final locale = await _resolveLocale();
    await send(
      SmartNotificationRequest(
        type: NotificationType.jobMatch,
        title: NotificationCopyStrings.t('job_match_title', locale),
        body: NotificationCopyStrings.format(
          'job_match_body',
          locale,
          params: {
            'jobTitle': jobTitle,
            'company': company,
            'matchScore': '$matchScore',
          },
        ),
        route: '/jobs',
        dedupKey: 'job_match_$jobId',
        dedupWindow: const Duration(hours: 24),
        data: {'jobId': jobId, 'matchScore': '$matchScore'},
      ),
    );
  }

  /// Housing saved-search matching — stub until matching feature ships.
  Future<void> maybeNotifyHousingMatch({
    required String listingId,
    required String summary,
    required int matchScore,
  }) async {
    if (matchScore < 75) return;

    final locale = await _resolveLocale();
    await send(
      SmartNotificationRequest(
        type: NotificationType.housingMatch,
        title: NotificationCopyStrings.t('housing_match_title', locale),
        body: summary,
        route: '/housing',
        dedupKey: 'housing_match_$listingId',
        dedupWindow: const Duration(hours: 24),
        data: {'listingId': listingId},
      ),
    );
  }

  Future<void> notifyScamShieldIncident({
    required String dedupKey,
    required String title,
    required String body,
    required String route,
    bool timeCritical = false,
  }) async {
    await send(
      SmartNotificationRequest(
        type: NotificationType.scamShieldIncident,
        title: title,
        body: body,
        route: route,
        dedupKey: dedupKey,
        dedupWindow: const Duration(hours: 24),
        timeCritical: timeCritical,
      ),
    );
  }

  Future<void> notifyScamShieldShareAlert({
    required String dedupKey,
    required String title,
    required String body,
    required String route,
    bool timeCritical = false,
  }) async {
    await send(
      SmartNotificationRequest(
        type: NotificationType.scamShieldShareAlert,
        title: title,
        body: body,
        route: route,
        dedupKey: dedupKey,
        dedupWindow: const Duration(hours: 4),
        timeCritical: timeCritical,
      ),
    );
  }

  Future<void> notifyScamAdvisoryAlert({
    required String dedupKey,
    required String title,
    required String body,
    required String route,
    required String advisoryId,
  }) async {
    await send(
      SmartNotificationRequest(
        type: NotificationType.scamAdvisoryAlert,
        title: title,
        body: body,
        route: route,
        dedupKey: dedupKey,
        dedupWindow: const Duration(hours: 168),
        data: {'advisoryId': advisoryId},
      ),
    );
  }

  Future<void> notifySecurityTip({
    required String dedupKey,
    required String title,
    required String body,
    required String route,
    required String topicId,
  }) async {
    await send(
      SmartNotificationRequest(
        type: NotificationType.securityTip,
        title: title,
        body: body,
        route: route,
        dedupKey: dedupKey,
        dedupWindow: const Duration(hours: 720),
        data: {'topicId': topicId},
      ),
    );
  }

  Future<void> notifyLegalSourceUpdate({
    required String dedupKey,
    required String title,
    required String body,
    required String route,
    required String domain,
  }) async {
    await send(
      SmartNotificationRequest(
        type: NotificationType.legalSourceUpdate,
        title: title,
        body: body,
        route: route,
        dedupKey: dedupKey,
        dedupWindow: const Duration(days: 3650),
        data: {'legalUpdateDomain': domain},
      ),
    );
  }

  Future<void> notifyHealthInsuranceComplianceIssue({
    required String issueId,
    required String title,
    required String body,
    required String route,
  }) async {
    await send(
      SmartNotificationRequest(
        type: NotificationType.healthInsuranceReminder,
        title: title,
        body: body,
        route: route,
        dedupKey: 'hi_issue_$issueId',
        dedupWindow: const Duration(hours: 168),
      ),
    );
  }

  /// Bill amount unusually high vs rolling provider average (Bill Tracker Part C).
  Future<void> maybeNotifyBillAmountAnomaly({
    required String billId,
    required String provider,
    required double currentAmount,
    required double averageAmount,
    required int percentAbove,
    required String currency,
    required String dedupKey,
    String? locale,
  }) async {
    final resolvedLocale = locale ?? await _resolveLocale();
    await send(
      SmartNotificationRequest(
        type: NotificationType.billDue,
        title: NotificationCopyStrings.t(
          'bill_anomaly_alert_title',
          resolvedLocale,
        ),
        body: NotificationCopyStrings.format(
          'bill_anomaly_alert_body',
          resolvedLocale,
          params: {
            'provider': provider,
            'amount': currentAmount.toStringAsFixed(0),
            'average': averageAmount.toStringAsFixed(0),
            'percent': '$percentAbove',
            'currency': currency,
          },
        ),
        route: '/bill-tracker',
        dedupKey: dedupKey,
        dedupWindow: const Duration(days: 30),
        data: {
          'billId': billId,
          'type': 'bill_amount_anomaly',
          'provider': provider,
        },
      ),
    );
  }

  /// Gold price threshold — client fallback only (server uses sendPushNotification).
  Future<void> maybeNotifyGoldPriceThreshold({
    required String alertId,
    required int purity,
    required double currentPriceQar,
    required double thresholdQar,
    required String direction,
  }) async {
    final locale = await _resolveLocale();
    final directionLabel = NotificationCopyStrings.t(
      direction == 'above' ? 'gold_direction_above' : 'gold_direction_below',
      locale,
    );
    await send(
      SmartNotificationRequest(
        type: NotificationType.goldPriceThresholdQatar,
        title: NotificationCopyStrings.t('gold_price_alert_title', locale),
        body: NotificationCopyStrings.format(
          'gold_price_alert_body',
          locale,
          params: {
            'purity': '$purity',
            'currentPrice': currentPriceQar.toStringAsFixed(2),
            'direction': directionLabel,
            'threshold': thresholdQar.toStringAsFixed(2),
          },
        ),
        route: '/money-services/gold',
        dedupKey: GoldAlertDedupKeys.priceThreshold(alertId, thresholdQar),
        dedupWindow: const Duration(hours: 24),
        data: {
          'alertId': alertId,
          'purity': '$purity',
          'thresholdQar': '$thresholdQar',
        },
      ),
    );
  }

  /// Jewelry locker portfolio gain target hit.
  Future<void> maybeNotifyJewelryLockerGain({
    required String alertId,
    required double gainQar,
    required double targetQar,
  }) async {
    final locale = await _resolveLocale();
    await send(
      SmartNotificationRequest(
        type: NotificationType.jewelryValueGainQatar,
        title: NotificationCopyStrings.t('jewelry_gain_title', locale),
        body: NotificationCopyStrings.format(
          'jewelry_gain_body',
          locale,
          params: {
            'gain': gainQar.toStringAsFixed(0),
            'target': targetQar.toStringAsFixed(0),
          },
        ),
        route: '/money-services/gold?tab=locker',
        dedupKey: GoldAlertDedupKeys.lockerGain(alertId, targetQar),
        dedupWindow: const Duration(hours: 48),
        data: {'alertId': alertId, 'gainQar': '$gainQar'},
      ),
    );
  }

  /// Registers annual Zakat reminder preference (deduped per Hijri year).
  Future<void> maybeNotifyZakatAnnualReminder({
    required int hijriYear,
    required double zakatDueQar,
  }) async {
    final locale = await _resolveLocale();
    await send(
      SmartNotificationRequest(
        type: NotificationType.zakatAnnualReminder,
        title: NotificationCopyStrings.t('zakat_reminder_title', locale),
        body: NotificationCopyStrings.format(
          'zakat_reminder_body',
          locale,
          params: {
            'hijriYear': '$hijriYear',
            'amount': zakatDueQar.toStringAsFixed(2),
          },
        ),
        route: '/ramadan/zakat',
        dedupKey: 'zakat_reminder_$hijriYear',
        dedupWindow: const Duration(days: 365),
        data: {
          'hijriYear': '$hijriYear',
          'zakatDueQar': '$zakatDueQar',
        },
      ),
    );
  }

  static const _healthInsuranceComplianceNudgeId = 884201;
  static const _healthInsuranceViolationRecheckId = 884202;

  /// One-time nudge to complete the employer compliance check.
  Future<void> scheduleHealthInsuranceComplianceNudge() async {
    try {
      await init();
      final settings = await _loadSettings();
      if (!settings.isTypeEnabled(NotificationType.healthInsuranceReminder)) {
        return;
      }
      await RaabtaLocalNotifications.instance.initialize();
      var notifyAt = DateTime.now().add(const Duration(days: 3));
      notifyAt = _adjustScheduledTimeForQuietHours(notifyAt, settings);
      if (notifyAt.isBefore(DateTime.now())) return;

      final locale = await _resolveLocale();
      await RaabtaLocalNotifications.instance.schedule(
        id: _healthInsuranceComplianceNudgeId,
        title: NotificationCopyStrings.t('hi_compliance_nudge_title', locale),
        body: NotificationCopyStrings.t('hi_compliance_nudge_body', locale),
        scheduledDate: notifyAt,
        payload: jsonEncode({
          'route': '/health-insurance/compliance',
          'type': notificationTypeToApi(NotificationType.healthInsuranceReminder),
          'dedupKey': 'hi_compliance_nudge',
        }),
      );
    } catch (e, stack) {
      debugPrint(
        'NotificationEngine.scheduleHealthInsuranceComplianceNudge failed: $e\n$stack',
      );
    }
  }

  /// Periodic reminder when unresolved violations were previously flagged.
  Future<void> scheduleHealthInsuranceViolationRecheck() async {
    try {
      await init();
      final settings = await _loadSettings();
      if (!settings.isTypeEnabled(NotificationType.healthInsuranceReminder)) {
        return;
      }
      await RaabtaLocalNotifications.instance.initialize();
      var notifyAt = DateTime.now().add(const Duration(days: 14));
      notifyAt = _adjustScheduledTimeForQuietHours(notifyAt, settings);
      if (notifyAt.isBefore(DateTime.now())) return;

      final locale = await _resolveLocale();
      await RaabtaLocalNotifications.instance.schedule(
        id: _healthInsuranceViolationRecheckId,
        title: NotificationCopyStrings.t('hi_violation_recheck_title', locale),
        body: NotificationCopyStrings.t('hi_violation_recheck_body', locale),
        scheduledDate: notifyAt,
        payload: jsonEncode({
          'route': '/health-insurance/compliance/results',
          'type': notificationTypeToApi(NotificationType.healthInsuranceReminder),
          'dedupKey': 'hi_violation_recheck',
        }),
      );
    } catch (e, stack) {
      debugPrint(
        'NotificationEngine.scheduleHealthInsuranceViolationRecheck failed: $e\n$stack',
      );
    }
  }

  Future<void> cancelHealthInsuranceReminders() async {
    await RaabtaLocalNotifications.instance.cancel(
      _healthInsuranceComplianceNudgeId,
    );
    await RaabtaLocalNotifications.instance.cancel(
      _healthInsuranceViolationRecheckId,
    );
  }

  static const _concierge90DayNotificationId = 884301;

  Future<void> scheduleConciergeMilestoneReminder({
    required String milestoneId,
    required String route,
    String locale = 'English',
  }) async {
    try {
      await init();
      final settings = await _loadSettings();
      if (!settings.isTypeEnabled(NotificationType.concierge90Day)) return;

      await RaabtaLocalNotifications.instance.initialize();
      var notifyAt = DateTime.now().add(const Duration(hours: 2));
      notifyAt = _adjustScheduledTimeForQuietHours(notifyAt, settings);
      if (notifyAt.isBefore(DateTime.now())) return;

      final lang = await _resolveLocale(locale);
      await RaabtaLocalNotifications.instance.schedule(
        id: _concierge90DayNotificationId,
        title: NotificationCopyStrings.t('concierge_milestone_title', lang),
        body: NotificationCopyStrings.t('concierge_milestone_body', lang),
        scheduledDate: notifyAt,
        payload: jsonEncode({
          'route': route,
          'milestoneId': milestoneId,
          'type': notificationTypeToApi(NotificationType.concierge90Day),
          'dedupKey': 'concierge_$milestoneId',
        }),
      );
    } catch (e, stack) {
      debugPrint(
        'NotificationEngine.scheduleConciergeMilestoneReminder failed: $e\n$stack',
      );
    }
  }

  Future<void> cancelConcierge90DayReminders() async {
    await RaabtaLocalNotifications.instance.cancel(_concierge90DayNotificationId);
  }

  /// Admin broadcast — Firestore path for Admin Dashboard integration.
  Future<void> sendAdminBroadcast({
    required String broadcastId,
    required String title,
    required String body,
    String route = '/notifications',
    List<String>? targetUserIds,
  }) async {
    await send(
      SmartNotificationRequest(
        type: NotificationType.adminAnnouncement,
        title: title,
        body: body,
        route: route,
        dedupKey: 'admin_$broadcastId',
        remoteUserIds: targetUserIds,
        timeCritical: false,
        data: {'broadcastId': broadcastId},
      ),
    );
  }

  Future<void> scheduleBillDueReminders({
    required String billId,
    required String provider,
    required DateTime dueDate,
    required double amount,
  }) async {
    await RaabtaLocalNotifications.instance.initialize();

    for (final daysBefore in billReminderOffsets) {
      final notifyAt = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
      ).subtract(Duration(days: daysBefore));

      if (notifyAt.isBefore(DateTime.now())) continue;

      final dedupKey = 'bill_${billId}_$daysBefore';
      final isDueToday = daysBefore == 0;

      final title = isDueToday
          ? '$provider bill due today'
          : '$provider bill due in $daysBefore day${daysBefore == 1 ? '' : 's'}';
      final body = isDueToday
          ? 'Pay ${amount.toStringAsFixed(0)} QR before end of day.'
          : 'Due ${dueDate.day}/${dueDate.month} — ${amount.toStringAsFixed(0)} QR';

      await RaabtaLocalNotifications.instance.schedule(
        id: _billNotificationId(billId, daysBefore),
        title: title,
        body: body,
        scheduledDate: notifyAt,
        notificationType: NotificationType.billDue,
        payload: jsonEncode({
          'route': '/bill-tracker',
          'billId': billId,
          'type': notificationTypeToApi(NotificationType.billDue),
          'dedupKey': dedupKey,
          'timeCritical': isDueToday,
        }),
        urgent: isDueToday,
      );
    }
  }

  Future<void> cancelBillReminders(String billId) async {
    for (final days in billReminderOffsets) {
      await RaabtaLocalNotifications.instance.cancel(
        _billNotificationId(billId, days),
      );
    }
  }

  static const loanReminderHorizonMonths = 12;

  Future<void> scheduleFriendsFamilyLoanReminders({
    required String loanId,
    required String personName,
    required String personKey,
    required LoanDirection direction,
    required double remainingAmount,
    required DateTime dueDate,
  }) async {
    try {
      await init();
      final settings = await _loadSettings();
      if (!settings.isTypeEnabled(NotificationType.friendsFamilyLoanReminder)) {
        return;
      }

      await RaabtaLocalNotifications.instance.initialize();

      final anchors = upcomingMonthlyReminders(dueDate: dueDate);
      for (var i = 0; i < anchors.length; i++) {
        var notifyAt = _adjustScheduledTimeForQuietHours(anchors[i], settings);
        if (notifyAt.isBefore(DateTime.now())) continue;

        final dedupKey = 'loan_${loanId}_month_$i';
        final title = buildLoanReminderTitle(direction);
        final body = buildLoanReminderBody(
          direction: direction,
          personName: personName,
          remainingAmount: remainingAmount,
          dueDate: dueDate,
        );

        await RaabtaLocalNotifications.instance.schedule(
          id: _loanNotificationId(loanId, i),
          title: title,
          body: body,
          scheduledDate: notifyAt,
          payload: jsonEncode({
            'route': '/bill-tracker/loans/person',
            'personKey': personKey,
            'loanId': loanId,
            'type': notificationTypeToApi(
              NotificationType.friendsFamilyLoanReminder,
            ),
            'dedupKey': dedupKey,
          }),
        );
      }
    } catch (e, stack) {
      debugPrint(
        'NotificationEngine.scheduleFriendsFamilyLoanReminders failed: $e\n$stack',
      );
    }
  }

  Future<void> cancelFriendsFamilyLoanReminders(String loanId) async {
    for (var i = 0; i < loanReminderHorizonMonths; i++) {
      await RaabtaLocalNotifications.instance.cancel(
        _loanNotificationId(loanId, i),
      );
    }
  }

  int _loanNotificationId(String loanId, int monthIndex) {
    return 'loan_${loanId}_$monthIndex'.hashCode.abs() % 2147483647;
  }

  DateTime _adjustScheduledTimeForQuietHours(
    DateTime scheduled,
    NotificationSettings settings,
  ) {
    if (!settings.quietHoursEnabled) return scheduled;
    final hour = scheduled.hour;
    final start = settings.quietHoursStart;
    final end = settings.quietHoursEnd;
    final inQuiet = start > end
        ? hour >= start || hour < end
        : hour >= start && hour < end;
    if (!inQuiet) return scheduled;
    return DateTime(scheduled.year, scheduled.month, scheduled.day, end);
  }

  Future<void> scheduleWarrantyReminders({
    required String warrantyId,
    required String productName,
    required String brand,
    required DateTime expiryDate,
  }) async {
    await RaabtaLocalNotifications.instance.initialize();

    for (final daysBefore in warrantyReminderOffsets) {
      final notifyAt =
          expiryDate.subtract(Duration(days: daysBefore));
      if (notifyAt.isBefore(DateTime.now())) continue;

      final title = daysBefore == 0
          ? '$productName warranty expired'
          : '$productName warranty expiring soon';
      final body = daysBefore == 0
          ? 'Your $brand warranty has expired. Check if you need service or renewal.'
          : 'Warranty expires in $daysBefore days (${expiryDate.toLocal().toString().split(' ').first}).';

      await RaabtaLocalNotifications.instance.schedule(
        id: _warrantyNotificationId(warrantyId, daysBefore),
        title: title,
        body: body,
        scheduledDate: notifyAt,
        notificationType: NotificationType.warrantyExpiring,
        payload: jsonEncode({
          'route': '/warranty-shield',
          'warrantyId': warrantyId,
          'type': notificationTypeToApi(NotificationType.warrantyExpiring),
          'dedupKey': 'warranty_${warrantyId}_$daysBefore',
        }),
        urgent: daysBefore <= 1,
      );
    }
  }

  Future<void> cancelWarrantyReminders(String warrantyId) async {
    for (final days in warrantyReminderOffsets) {
      await RaabtaLocalNotifications.instance.cancel(
        _warrantyNotificationId(warrantyId, days),
      );
    }
  }

  /// Housing viewing — day-before (09:00 Qatar) and hour-before the slot.
  Future<void> scheduleViewingReminders({
    required String viewingId,
    required String listingId,
    required String listingTitle,
    required DateTime viewingAt,
    String locale = 'English',
  }) async {
    await RaabtaLocalNotifications.instance.initialize();
    await cancelViewingReminders(viewingId);

    final dayBefore = DateTime(
      viewingAt.year,
      viewingAt.month,
      viewingAt.day,
    ).subtract(const Duration(days: 1)).add(const Duration(hours: 9));
    if (dayBefore.isAfter(DateTime.now())) {
      await RaabtaLocalNotifications.instance.schedule(
        id: _viewingNotificationId(viewingId, 'day'),
        title: 'Viewing tomorrow — $listingTitle',
        body: 'Your property viewing is scheduled for tomorrow.',
        scheduledDate: dayBefore,
        notificationType: NotificationType.general,
        payload: jsonEncode({
          'route': '/housing/chat/$listingId',
          'listingId': listingId,
          'viewingId': viewingId,
          'type': notificationTypeToApi(NotificationType.general),
          'dedupKey': 'viewing_${viewingId}_day',
        }),
      );
    }

    final hourBefore = viewingAt.subtract(const Duration(hours: 1));
    if (hourBefore.isAfter(DateTime.now())) {
      await RaabtaLocalNotifications.instance.schedule(
        id: _viewingNotificationId(viewingId, 'hour'),
        title: 'Viewing in 1 hour — $listingTitle',
        body: 'Head to the property or message the landlord if plans change.',
        scheduledDate: hourBefore,
        notificationType: NotificationType.general,
        payload: jsonEncode({
          'route': '/housing/chat/$listingId',
          'listingId': listingId,
          'viewingId': viewingId,
          'type': notificationTypeToApi(NotificationType.general),
          'dedupKey': 'viewing_${viewingId}_hour',
        }),
        urgent: true,
      );
    }
  }

  Future<void> cancelViewingReminders(String viewingId) async {
    for (final offset in ['day', 'hour']) {
      await RaabtaLocalNotifications.instance.cancel(
        _viewingNotificationId(viewingId, offset),
      );
    }
  }

  Future<void> scheduleDocumentDeadlineReminders({
    required String deadlineId,
    required String documentType,
    required DateTime expiryDate,
    required bool remind30Days,
    required bool remind7Days,
    required bool remind1Day,
  }) async {
    await RaabtaLocalNotifications.instance.initialize();

    final toggles = {
      30: remind30Days,
      7: remind7Days,
      1: remind1Day,
    };

    for (final daysBefore in documentDeadlineReminderOffsets) {
      if (toggles[daysBefore] != true) continue;

      final notifyAt = DateTime(
        expiryDate.year,
        expiryDate.month,
        expiryDate.day,
      ).subtract(Duration(days: daysBefore));

      if (notifyAt.isBefore(DateTime.now())) continue;

      final title = daysBefore == 1
          ? '$documentType expires tomorrow'
          : '$documentType expiring in $daysBefore days';
      final body = daysBefore == 1
          ? 'Renew your $documentType before it expires.'
          : 'Your $documentType expires on ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}.';

      await RaabtaLocalNotifications.instance.schedule(
        id: _documentDeadlineNotificationId(deadlineId, daysBefore),
        title: title,
        body: body,
        scheduledDate: notifyAt,
        notificationType: NotificationType.documentDeadlineApproaching,
        payload: jsonEncode({
          'route': '/visa?deadlineId=$deadlineId',
          'deadlineId': deadlineId,
          'type': notificationTypeToApi(
            NotificationType.documentDeadlineApproaching,
          ),
          'dedupKey': 'deadline_${deadlineId}_$daysBefore',
          'timeCritical': daysBefore <= 1,
        }),
        urgent: daysBefore <= 1,
      );
    }
  }

  Future<void> cancelDocumentDeadlineReminders(String deadlineId) async {
    for (final days in documentDeadlineReminderOffsets) {
      await RaabtaLocalNotifications.instance.cancel(
        _documentDeadlineNotificationId(deadlineId, days),
      );
    }
  }

  /// Opt-in local reminders for Truth Engine legal filing deadlines.
  Future<void> scheduleLegalDeadlineReminders({
    required LegalDeadlineReminderScope scope,
    required DateTime deadlineDate,
    required String titlePrefix,
  }) async {
    await RaabtaLocalNotifications.instance.initialize();

    for (final daysBefore in legalDeadlineReminderOffsets) {
      final notifyAt = DateTime(
        deadlineDate.year,
        deadlineDate.month,
        deadlineDate.day,
      ).subtract(Duration(days: daysBefore));

      if (notifyAt.isBefore(DateTime.now())) continue;

      final title = daysBefore <= 7
          ? 'Legal deadline in $daysBefore day(s)'
          : titlePrefix;

      await RaabtaLocalNotifications.instance.schedule(
        id: _legalDeadlineNotificationId(scope, daysBefore),
        title: title,
        body:
            'Review your case — the standard filing window may be closing. This is general information, not legal advice.',
        scheduledDate: notifyAt,
        payload: jsonEncode({
          'route': _legalDeadlineRoute(scope),
          'type': notificationTypeToApi(NotificationType.general),
          'dedupKey': 'legal_deadline_${scope.storageKey}_$daysBefore',
          'timeCritical': daysBefore <= 7,
        }),
        urgent: daysBefore <= 7,
      );
    }
  }

  Future<void> cancelLegalDeadlineReminders(
    LegalDeadlineReminderScope scope,
  ) async {
    for (final days in legalDeadlineReminderOffsets) {
      await RaabtaLocalNotifications.instance.cancel(
        _legalDeadlineNotificationId(scope, days),
      );
    }
  }

  String _legalDeadlineRoute(LegalDeadlineReminderScope scope) =>
      switch (scope) {
        LegalDeadlineReminderScope.eosb => '/eosb/result',
        LegalDeadlineReminderScope.eosbFinalSettlement => '/eosb/result',
        LegalDeadlineReminderScope.tenancy => '/tenancy/result',
        LegalDeadlineReminderScope.tenancyDepositReturn => '/tenancy/result',
        LegalDeadlineReminderScope.sponsorshipTransfer =>
          '/sponsorship-transfer/result',
      };

  int _legalDeadlineNotificationId(
    LegalDeadlineReminderScope scope,
    int daysBefore,
  ) =>
      16000 + scope.storageKey.hashCode.abs() % 2000 + daysBefore;

  int _documentDeadlineNotificationId(String deadlineId, int daysBefore) =>
      12000 + deadlineId.hashCode.abs() % 4000 + daysBefore;

  int _billNotificationId(String billId, int daysBefore) =>
      5000 + billId.hashCode.abs() % 4000 + daysBefore;

  int _warrantyNotificationId(String warrantyId, int daysBefore) =>
      9000 + warrantyId.hashCode.abs() % 4000 + daysBefore;

  int _viewingNotificationId(String viewingId, String offsetKey) =>
      17000 +
      viewingId.hashCode.abs() % 4000 +
      (offsetKey == 'hour' ? 1 : 0);

  // ─── Delivery ─────────────────────────────────────────────

  Future<SmartSendResult> _sendRemote(
    SmartNotificationRequest request,
    ResolvedNotificationPriority classified,
  ) async {
    try {
      final userId =
          await RaabtaNotificationService.instance.getOrCreateUserId();
      final presentation =
          NotificationPresentation.payloadMetadata(classified);
      final response = await http.post(
        Uri.parse('${AppConfig.backendUrl}/api/notifications/smart-send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'type': notificationTypeToApi(request.type),
          'title': request.title,
          'body': request.body,
          'data': {
            'route': request.route,
            ...request.data,
            ...presentation,
          },
          'dedupKey': request.dedupKey,
          'timeCritical': request.timeCritical,
          'skipDailyCap': request.skipDailyCap,
          'userIds': request.remoteUserIds,
          'groupId': request.groupId,
          'excludeUserId': request.excludeUserId ?? userId,
          'senderUserId': userId,
          'priority': classified.priority.apiValue,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await _persistInbox(request);
        return const SmartSendResult(sent: true);
      }
      debugPrint(
        'NotificationEngine remote send failed: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('NotificationEngine remote send error: $e');
    }

    if (request.remoteUserIds == null && request.groupId == null) {
      return _sendLocalNow(request, classified);
    }
    return const SmartSendResult(skipped: true, reason: 'backend_unavailable');
  }

  Future<SmartSendResult> _sendLocalNow(
    SmartNotificationRequest request,
    ResolvedNotificationPriority classified,
  ) async {
    await RaabtaLocalNotifications.instance.initialize();
    final presentation =
        NotificationPresentation.payloadMetadata(classified);
    await RaabtaLocalNotifications.instance.show(
      id: request.dedupKey.hashCode,
      title: request.title,
      body: request.body,
      payload: jsonEncode({
        'route': request.route,
        'type': notificationTypeToApi(request.type),
        ...request.data,
        ...presentation,
      }),
      presentation: classified,
    );
    await _persistInbox(
      request,
      priority: classified.priority,
      presentation: presentation,
    );
    return const SmartSendResult(sent: true, local: true);
  }

  Future<void> _deliverToInboxOnly(SmartNotificationRequest request) async {
    await _persistInbox(request, silent: true);
  }

  Future<void> _persistInbox(
    SmartNotificationRequest request, {
    bool silent = false,
    NotificationPriority? priority,
    Map<String, String>? presentation,
  }) async {
    try {
      final userId =
          await RaabtaNotificationService.instance.getOrCreateUserId();
      final repo = NotificationRepository(userId);
      await repo.addInboxNotification(
        AppNotification(
          id: request.dedupKey.hashCode.toString(),
          title: request.title,
          body: request.body,
          type: request.type,
          route: request.route,
          read: false,
          createdAt: DateTime.now(),
          data: {
            ...request.data,
            if (priority != null) 'priority': priority.apiValue,
            if (presentation != null) ...presentation,
            if (silent) 'silent': true,
          },
        ),
      );
    } catch (e) {
      debugPrint('NotificationEngine inbox persist failed: $e');
    }
  }

  // ─── Frequency cap ──────────────────────────────────────

  String _qatarDateKey() {
    tz_data.initializeTimeZones();
    final qatar = tz.getLocation('Asia/Qatar');
    final now = tz.TZDateTime.now(qatar);
    return '${now.year}-${now.month}-${now.day}';
  }

  Future<bool> _categoryCapReached(String apiKey, int cap) async {
    final box = Hive.box<int>(_freqCapBox);
    final key = '${_qatarDateKey()}|$apiKey';
    return (box.get(key) ?? 0) >= cap;
  }

  Future<void> _incrementCategoryCount(String apiKey) async {
    final box = Hive.box<int>(_freqCapBox);
    final key = '${_qatarDateKey()}|$apiKey';
    await box.put(key, (box.get(key) ?? 0) + 1);
  }

  Future<void> _queueForDigest(SmartNotificationRequest request) async {
    final box = Hive.box<String>(_capQueueBox);
    final key = '${_qatarDateKey()}|${notificationTypeToApi(request.type)}';
    final existing = box.get(key);
    final count = existing != null ? (jsonDecode(existing)['count'] as int? ?? 0) + 1 : 1;
    await box.put(
      key,
      jsonEncode({
        'count': count,
        'lastTitle': request.title,
        'type': notificationTypeToApi(request.type),
        'queuedAt': DateTime.now().toIso8601String(),
      }),
    );
  }

  Future<void> _purgeExpiredCapQueueEntries(String currentQatarDate) async {
    final box = Hive.box<String>(_capQueueBox);
    final keys = box.keys.cast<String>().toList();
    for (final hiveKey in keys) {
      final parsed = CapOverflowDigest.parseQueueHiveKey(hiveKey);
      if (parsed == null ||
          CapOverflowDigest.isExpiredByTtl(
            parsed.queueDate,
            currentQatarDate,
          )) {
        await box.delete(hiveKey);
      }
    }
  }

  Future<void> _flushEligibleCapOverflowDigests(String currentQatarDate) async {
    final box = Hive.box<String>(_capQueueBox);
    final keys = box.keys.cast<String>().toList()..sort();

    for (final hiveKey in keys) {
      final parsed = CapOverflowDigest.parseQueueHiveKey(hiveKey);
      if (parsed == null) {
        await box.delete(hiveKey);
        continue;
      }
      if (!CapOverflowDigest.isEligibleForFlush(
        parsed.queueDate,
        currentQatarDate,
      )) {
        continue;
      }

      final entry = CapOverflowDigest.parseQueueValue(box.get(hiveKey));
      if (entry == null) {
        await box.delete(hiveKey);
        continue;
      }

      final type = parseNotificationType(parsed.apiKey);
      final locale = await _resolveLocale();
      final copy = CapOverflowDigest.buildDigestCopy(
        type: type,
        heldCount: entry.count,
        locale: locale,
      );

      final request = SmartNotificationRequest(
        type: type,
        title: copy.title,
        body: copy.body,
        route: '/notifications',
        dedupKey: CapOverflowDigest.buildDedupReference(
          parsed.apiKey,
          parsed.queueDate,
        ),
        dedupWindow: const Duration(days: 8),
        data: {
          CapOverflowDigest.dataFlag: true,
          'heldCount': entry.count,
          'queueDate': parsed.queueDate,
        },
        timeCritical: false,
        skipDailyCap: false,
        urgent: false,
      );

      final result = await send(request);
      final shouldDelete = (result.sent && result.local) ||
          result.reason == 'deduplicated';
      if (shouldDelete) {
        await box.delete(hiveKey);
      }
    }
  }

  Future<NotificationSettings> _loadSettings() async {
    final userId =
        await RaabtaNotificationService.instance.getOrCreateUserId();
    return NotificationPreferencesService(userId).getSettings();
  }
}

/// Request / result types shared with [SmartNotificationEngine] facade.
class SmartNotificationRequest {
  const SmartNotificationRequest({
    required this.type,
    required this.title,
    required this.body,
    required this.route,
    required this.dedupKey,
    this.data = const {},
    this.dedupWindow = NotificationEngine.defaultDedupWindow,
    this.timeCritical = false,
    this.skipDailyCap = false,
    this.urgent = false,
    this.priority,
    this.remoteUserIds,
    this.groupId,
    this.excludeUserId,
  });

  final NotificationType type;
  final String title;
  final String body;
  final String route;
  final String dedupKey;
  final Map<String, dynamic> data;
  final Duration dedupWindow;
  final bool timeCritical;
  final bool skipDailyCap;
  final bool urgent;
  /// Optional urgency override — clamped via [NotificationTypeRegistry].
  final NotificationPriority? priority;
  final List<String>? remoteUserIds;
  final String? groupId;
  final String? excludeUserId;
}

class SmartSendGate {
  const SmartSendGate._({
    required this.allowed,
    this.reason,
    this.silent = false,
  });

  factory SmartSendGate.allowed() => const SmartSendGate._(allowed: true);
  factory SmartSendGate.blocked(String reason) =>
      SmartSendGate._(allowed: false, reason: reason);
  factory SmartSendGate.silent(String reason) =>
      SmartSendGate._(allowed: false, reason: reason, silent: true);

  final bool allowed;
  final String? reason;
  final bool silent;
}

class SmartSendResult {
  const SmartSendResult({
    this.sent = false,
    this.skipped = false,
    this.local = false,
    this.inboxOnly = false,
    this.reason,
  });

  final bool sent;
  final bool skipped;
  final bool local;
  final bool inboxOnly;
  final String? reason;
}
