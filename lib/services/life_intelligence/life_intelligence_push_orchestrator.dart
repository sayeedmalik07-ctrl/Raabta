import 'package:raabta/core/l10n/app_locale_storage.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/models/notification_models.dart';
import 'package:raabta/services/life_intelligence/life_intelligence_push_ack_repository.dart';
import 'package:raabta/services/life_intelligence/life_intelligence_weekly_cap.dart';
import 'package:raabta/services/life_intelligence_signals_service.dart';
import 'package:raabta/services/notifications/notification_copy_strings.dart';
import 'package:raabta/services/notifications/notification_engine.dart';
import 'package:raabta/services/notifications/notification_priority.dart';
import 'package:raabta/services/notifications/notification_type.dart';
import 'package:raabta/services/raabta_notification_service.dart';

/// V2 push eligibility and delivery — separate from V1 Home Today evaluation.
abstract final class LifeIntelligencePushOrchestrator {
  static const transferDedupKey = 'life_intelligence_employer_transfer';
  static const mismatchDedupKey = 'life_intelligence_employer_mismatch';

  /// Ordered push candidates (transfer before mismatch) without delivery gates.
  static List<LifeIntelligenceSignalType> evaluatePushCandidateTypes({
    required bool sponsorshipTransferCompleted,
    required List<CalculationHistoryEntry> eosbHistory,
    required String? healthInsuranceEmployerKey,
    required bool lifeEventHealthCoverageActive,
  }) {
    final candidates = <LifeIntelligenceSignalType>[];

    if (LifeIntelligenceSignalsService.evaluateEmployerTransferStarted(
      sponsorshipTransferCompleted: sponsorshipTransferCompleted,
      hasEosbHistory: eosbHistory.isNotEmpty,
    )) {
      candidates.add(LifeIntelligenceSignalType.employerTransferStarted);
    }

    if (!lifeEventHealthCoverageActive) {
      final eosbKey = eosbHistory.isNotEmpty
          ? eosbHistory.first.input.effectiveNormalizedEmployerKey
          : '';
      if (LifeIntelligenceSignalsService.evaluateEmployerNameMismatch(
        eosbEmployerKey: eosbKey,
        healthInsuranceEmployerKey: healthInsuranceEmployerKey,
      )) {
        candidates.add(LifeIntelligenceSignalType.employerNameMismatch);
      }
    }

    return candidates;
  }

  static String dedupKeyFor(LifeIntelligenceSignalType type) =>
      switch (type) {
        LifeIntelligenceSignalType.employerTransferStarted =>
          transferDedupKey,
        LifeIntelligenceSignalType.employerNameMismatch => mismatchDedupKey,
      };

  static String routeFor(LifeIntelligenceSignalType type) =>
      switch (type) {
        LifeIntelligenceSignalType.employerTransferStarted =>
          LifeIntelligenceSignalsService.eosbRoute,
        LifeIntelligenceSignalType.employerNameMismatch =>
          LifeIntelligenceSignalsService.healthInsuranceRoute,
      };

  static String ackTokenFor({
    required LifeIntelligenceSignalType type,
    required List<CalculationHistoryEntry> eosbHistory,
    required String? healthInsuranceEmployerKey,
  }) {
    final eosbKey = eosbHistory.isNotEmpty
        ? eosbHistory.first.input.effectiveNormalizedEmployerKey
        : null;
    return LifeIntelligencePushAckRepository.ackTokenFor(
      type: type,
      eosbEmployerKey: eosbKey,
      healthInsuranceEmployerKey: healthInsuranceEmployerKey,
    );
  }

  static ({String title, String body}) copyFor(
    LifeIntelligenceSignalType type,
    String locale,
  ) {
    return switch (type) {
      LifeIntelligenceSignalType.employerTransferStarted => (
          title: NotificationCopyStrings.t(
            'life_intelligence_push_transfer_title',
            locale,
          ),
          body: NotificationCopyStrings.t(
            'life_intelligence_push_transfer_body',
            locale,
          ),
        ),
      LifeIntelligenceSignalType.employerNameMismatch => (
          title: NotificationCopyStrings.t(
            'life_intelligence_push_mismatch_title',
            locale,
          ),
          body: NotificationCopyStrings.t(
            'life_intelligence_push_mismatch_body',
            locale,
          ),
        ),
    };
  }

  /// Returns the first eligible candidate after V2 gates, or null.
  static Future<LifeIntelligenceSignalType?> selectEligiblePushType({
    required bool sponsorshipTransferCompleted,
    required List<CalculationHistoryEntry> eosbHistory,
    required String? healthInsuranceEmployerKey,
    required bool lifeEventHealthCoverageActive,
    required LifeIntelligencePushAckRepository ackRepo,
    required DateTime now,
  }) async {
    if (await LifeIntelligenceWeeklyCap.isCapReached(at: now)) {
      return null;
    }

    final candidates = evaluatePushCandidateTypes(
      sponsorshipTransferCompleted: sponsorshipTransferCompleted,
      eosbHistory: eosbHistory,
      healthInsuranceEmployerKey: healthInsuranceEmployerKey,
      lifeEventHealthCoverageActive: lifeEventHealthCoverageActive,
    );

    for (final type in candidates) {
      final token = ackTokenFor(
        type: type,
        eosbHistory: eosbHistory,
        healthInsuranceEmployerKey: healthInsuranceEmployerKey,
      );
      if (await ackRepo.isAcknowledged(token)) continue;
      return type;
    }
    return null;
  }

  /// Attempts delivery for the selected type. Weekly cap increments only when
  /// [SmartSendResult.sent] is true.
  static Future<SmartSendResult?> trySendPush({
    required LifeIntelligenceSignalType type,
    required List<CalculationHistoryEntry> eosbHistory,
    required String? healthInsuranceEmployerKey,
    required String locale,
    required DateTime now,
  }) async {
    final meta = NotificationTypeRegistry.metaFor(
      NotificationType.lifeIntelligence,
    );
    final copy = copyFor(type, locale);
    final ackToken = ackTokenFor(
      type: type,
      eosbHistory: eosbHistory,
      healthInsuranceEmployerKey: healthInsuranceEmployerKey,
    );

    final result = await RaabtaNotificationService.instance.sendSmartNotification(
      SmartNotificationRequest(
        type: NotificationType.lifeIntelligence,
        title: copy.title,
        body: copy.body,
        route: routeFor(type),
        dedupKey: dedupKeyFor(type),
        dedupWindow: Duration(hours: meta.dedupTtlHours),
        priority: NotificationPriority.p2ImportantPersonal,
        data: {
          'lifeIntelligenceAckToken': ackToken,
          'lifeIntelligenceSignalType': type.name,
        },
      ),
    );

    if (result.sent) {
      await LifeIntelligenceWeeklyCap.recordDelivery(at: now);
    }

    return result;
  }

  static Future<String> resolveLocale() async {
    return AppLocaleStorage.readNormalized();
  }
}
