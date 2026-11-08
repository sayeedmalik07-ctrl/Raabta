import 'package:raabta/features/bill_tracker/friends_family_loans/data/models/loan_entry_model.dart';
import 'package:raabta/services/notifications/notification_engine.dart';

export 'package:raabta/services/notifications/notification_engine.dart'
    show
        SmartNotificationRequest,
        SmartSendGate,
        SmartSendResult,
        NotificationEngine;
export 'package:raabta/services/notifications/notification_priority.dart'
    show NotificationPriority, NotificationPriorityResolver;

/// Backward-compatible facade — all logic lives in [NotificationEngine].
class SmartNotificationEngine {
  SmartNotificationEngine._();
  static final SmartNotificationEngine instance = SmartNotificationEngine._();

  static const defaultDedupWindow = NotificationEngine.defaultDedupWindow;
  static const dailyNonCriticalCap = 10;
  static const jobMatchNotifyThreshold = NotificationEngine.jobMatchNotifyThreshold;
  static const billReminderOffsets = NotificationEngine.billReminderOffsets;

  Future<SmartSendGate> shouldSend(SmartNotificationRequest request) =>
      NotificationEngine.instance.shouldSend(request);

  Future<SmartSendResult> send(SmartNotificationRequest request) =>
      NotificationEngine.instance.send(request);

  Future<void> notifyEventVerificationResult({
    required String eventId,
    required String groupId,
    required String title,
    required bool approved,
    required String reason,
    required String creatorUserId,
  }) =>
      NotificationEngine.instance.notifyEventVerificationResult(
        eventId: eventId,
        groupId: groupId,
        title: title,
        approved: approved,
        reason: reason,
        creatorUserId: creatorUserId,
      );

  Future<void> notifyLostFoundPosted({
    required String itemId,
    required String groupId,
    required String title,
    required String type,
    required String posterUserId,
  }) =>
      NotificationEngine.instance.notifyLostFoundPosted(
        itemId: itemId,
        groupId: groupId,
        title: title,
        type: type,
        posterUserId: posterUserId,
      );

  Future<void> notifyLostFoundResolved({
    required String itemId,
    required String title,
    required String posterUserId,
  }) =>
      NotificationEngine.instance.notifyLostFoundResolved(
        itemId: itemId,
        title: title,
        posterUserId: posterUserId,
      );

  Future<void> notifyAskQatarAnswer({
    required String questionId,
    required String questionTitle,
    required String authorUserId,
    required String replyPreview,
  }) =>
      NotificationEngine.instance.notifyAskQatarAnswer(
        questionId: questionId,
        questionTitle: questionTitle,
        authorUserId: authorUserId,
        replyPreview: replyPreview,
      );

  Future<void> notifyAskQatarAnswerAccepted({
    required String questionId,
    required String questionTitle,
    required String answerAuthorUserId,
    required String answerId,
  }) =>
      NotificationEngine.instance.notifyAskQatarAnswerAccepted(
        questionId: questionId,
        questionTitle: questionTitle,
        answerAuthorUserId: answerAuthorUserId,
        answerId: answerId,
      );

  Future<void> notifyBuddyRequest({
    required String requestId,
    required String helperUserId,
    required String introPreview,
  }) =>
      NotificationEngine.instance.notifyBuddyRequest(
        requestId: requestId,
        helperUserId: helperUserId,
        introPreview: introPreview,
      );

  Future<void> notifyBuddyRequestAccepted({
    required String requestId,
    required String threadId,
    required String newcomerUserId,
  }) =>
      NotificationEngine.instance.notifyBuddyRequestAccepted(
        requestId: requestId,
        threadId: threadId,
        newcomerUserId: newcomerUserId,
      );

  Future<void> maybeNotifyJobMatch({
    required String jobId,
    required String jobTitle,
    required String company,
    required int matchScore,
  }) =>
      NotificationEngine.instance.maybeNotifyJobMatch(
        jobId: jobId,
        jobTitle: jobTitle,
        company: company,
        matchScore: matchScore,
      );

  Future<void> maybeNotifyHousingMatch({
    required String listingId,
    required String summary,
    required int matchScore,
  }) =>
      NotificationEngine.instance.maybeNotifyHousingMatch(
        listingId: listingId,
        summary: summary,
        matchScore: matchScore,
      );

  Future<void> scheduleBillDueReminders({
    required String billId,
    required String provider,
    required DateTime dueDate,
    required double amount,
  }) =>
      NotificationEngine.instance.scheduleBillDueReminders(
        billId: billId,
        provider: provider,
        dueDate: dueDate,
        amount: amount,
      );

  Future<void> cancelBillReminders(String billId) =>
      NotificationEngine.instance.cancelBillReminders(billId);

  Future<void> maybeNotifyBillAmountAnomaly({
    required String billId,
    required String provider,
    required double currentAmount,
    required double averageAmount,
    required int percentAbove,
    required String currency,
    required String dedupKey,
    String? locale,
  }) =>
      NotificationEngine.instance.maybeNotifyBillAmountAnomaly(
        billId: billId,
        provider: provider,
        currentAmount: currentAmount,
        averageAmount: averageAmount,
        percentAbove: percentAbove,
        currency: currency,
        dedupKey: dedupKey,
        locale: locale,
      );

  Future<void> scheduleFriendsFamilyLoanReminders({
    required String loanId,
    required String personName,
    required String personKey,
    required LoanDirection direction,
    required double remainingAmount,
    required DateTime dueDate,
  }) =>
      NotificationEngine.instance.scheduleFriendsFamilyLoanReminders(
        loanId: loanId,
        personName: personName,
        personKey: personKey,
        direction: direction,
        remainingAmount: remainingAmount,
        dueDate: dueDate,
      );

  Future<void> cancelFriendsFamilyLoanReminders(String loanId) =>
      NotificationEngine.instance.cancelFriendsFamilyLoanReminders(loanId);

  Future<void> scheduleWarrantyReminders({
    required String warrantyId,
    required String productName,
    required String brand,
    required DateTime expiryDate,
  }) =>
      NotificationEngine.instance.scheduleWarrantyReminders(
        warrantyId: warrantyId,
        productName: productName,
        brand: brand,
        expiryDate: expiryDate,
      );

  Future<void> cancelWarrantyReminders(String warrantyId) =>
      NotificationEngine.instance.cancelWarrantyReminders(warrantyId);

  Future<void> scheduleDocumentDeadlineReminders({
    required String deadlineId,
    required String documentType,
    required DateTime expiryDate,
    required bool remind30Days,
    required bool remind7Days,
    required bool remind1Day,
  }) =>
      NotificationEngine.instance.scheduleDocumentDeadlineReminders(
        deadlineId: deadlineId,
        documentType: documentType,
        expiryDate: expiryDate,
        remind30Days: remind30Days,
        remind7Days: remind7Days,
        remind1Day: remind1Day,
      );

  Future<void> cancelDocumentDeadlineReminders(String deadlineId) =>
      NotificationEngine.instance.cancelDocumentDeadlineReminders(deadlineId);

  Future<void> maybeNotifyGoldPriceThreshold({
    required String alertId,
    required int purity,
    required double currentPriceQar,
    required double thresholdQar,
    required String direction,
  }) =>
      NotificationEngine.instance.maybeNotifyGoldPriceThreshold(
        alertId: alertId,
        purity: purity,
        currentPriceQar: currentPriceQar,
        thresholdQar: thresholdQar,
        direction: direction,
      );

  Future<void> maybeNotifyJewelryLockerGain({
    required String alertId,
    required double gainQar,
    required double targetQar,
  }) =>
      NotificationEngine.instance.maybeNotifyJewelryLockerGain(
        alertId: alertId,
        gainQar: gainQar,
        targetQar: targetQar,
      );

  Future<void> maybeNotifyZakatAnnualReminder({
    required int hijriYear,
    required double zakatDueQar,
  }) =>
      NotificationEngine.instance.maybeNotifyZakatAnnualReminder(
        hijriYear: hijriYear,
        zakatDueQar: zakatDueQar,
      );

  Future<void> scheduleHealthInsuranceComplianceNudge() =>
      NotificationEngine.instance.scheduleHealthInsuranceComplianceNudge();

  Future<void> scheduleHealthInsuranceViolationRecheck() =>
      NotificationEngine.instance.scheduleHealthInsuranceViolationRecheck();

  Future<void> cancelHealthInsuranceReminders() =>
      NotificationEngine.instance.cancelHealthInsuranceReminders();

  Future<void> scheduleConciergeMilestoneReminder({
    required String milestoneId,
    required String route,
    String locale = 'English',
  }) =>
      NotificationEngine.instance.scheduleConciergeMilestoneReminder(
        milestoneId: milestoneId,
        route: route,
        locale: locale,
      );

  Future<void> cancelConcierge90DayReminders() =>
      NotificationEngine.instance.cancelConcierge90DayReminders();

  Future<void> sendAdminBroadcast({
    required String broadcastId,
    required String title,
    required String body,
    String route = '/notifications',
    List<String>? targetUserIds,
  }) =>
      NotificationEngine.instance.sendAdminBroadcast(
        broadcastId: broadcastId,
        title: title,
        body: body,
        route: route,
        targetUserIds: targetUserIds,
      );

  Future<void> notifyScamShieldIncident({
    required String dedupKey,
    required String title,
    required String body,
    required String route,
    bool timeCritical = false,
  }) =>
      NotificationEngine.instance.notifyScamShieldIncident(
        dedupKey: dedupKey,
        title: title,
        body: body,
        route: route,
        timeCritical: timeCritical,
      );

  Future<void> notifyScamShieldShareAlert({
    required String dedupKey,
    required String title,
    required String body,
    required String route,
    bool timeCritical = false,
  }) =>
      NotificationEngine.instance.notifyScamShieldShareAlert(
        dedupKey: dedupKey,
        title: title,
        body: body,
        route: route,
        timeCritical: timeCritical,
      );

  Future<void> notifyScamAdvisoryAlert({
    required String dedupKey,
    required String title,
    required String body,
    required String route,
    required String advisoryId,
  }) =>
      NotificationEngine.instance.notifyScamAdvisoryAlert(
        dedupKey: dedupKey,
        title: title,
        body: body,
        route: route,
        advisoryId: advisoryId,
      );

  Future<void> notifySecurityTip({
    required String dedupKey,
    required String title,
    required String body,
    required String route,
    required String topicId,
  }) =>
      NotificationEngine.instance.notifySecurityTip(
        dedupKey: dedupKey,
        title: title,
        body: body,
        route: route,
        topicId: topicId,
      );

  Future<void> notifyLegalSourceUpdate({
    required String dedupKey,
    required String title,
    required String body,
    required String route,
    required String domain,
  }) =>
      NotificationEngine.instance.notifyLegalSourceUpdate(
        dedupKey: dedupKey,
        title: title,
        body: body,
        route: route,
        domain: domain,
      );

  Future<void> notifyHealthInsuranceComplianceIssue({
    required String issueId,
    required String title,
    required String body,
    required String route,
  }) =>
      NotificationEngine.instance.notifyHealthInsuranceComplianceIssue(
        issueId: issueId,
        title: title,
        body: body,
        route: route,
      );
}
