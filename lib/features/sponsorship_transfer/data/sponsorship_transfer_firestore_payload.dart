import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_input.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_models.dart';

/// Firestore document shapes for sponsorship transfer sync — testable without Firebase.
abstract final class SponsorshipTransferFirestorePayload {
  static String recordIdFor(TransferReadinessResult result) =>
      '${result.checkedAt.millisecondsSinceEpoch}';

  static Map<String, dynamic> record({
    required TransferReadinessInput input,
    required TransferReadinessResult result,
    required String legalVersionVerifiedAt,
  }) {
    return {
      'checkedAt': result.checkedAt.toIso8601String(),
      'employmentStartDate': input.employmentStartDate?.toIso8601String(),
      'residencePermitExpiry': input.residencePermitExpiry?.toIso8601String(),
      'contractType': input.contractType.name,
      'formalNoticeStatus': input.formalNoticeStatus?.name,
      'probationPeriodStatus': input.probationPeriodStatus?.name,
      'noticeMonths': result.noticeMonths,
      'probationNoticeApplies': result.probationNoticeApplies,
      'permitWindowStatus': result.permitWindowStatus.name,
      'daysSincePermitExpiry': result.daysSincePermitExpiry,
      'monthsEmployed': result.monthsEmployed,
      'hasCriticalIssue': result.hasCriticalIssue,
      'hasWarning': result.hasWarning,
      'legalVersionVerifiedAt': legalVersionVerifiedAt,
    };
  }

  static Map<String, dynamic> userSummary({
    required String latestRecordId,
    required TransferReadinessInput input,
    required TransferReadinessResult result,
    required String legalVersionVerifiedAt,
    required int checklistCollectedCount,
    required int checklistTotalCount,
  }) {
    return {
      'checkCompleted': true,
      'latestRecordId': latestRecordId,
      'latestCheckedAt': result.checkedAt.toIso8601String(),
      'hasCriticalIssue': result.hasCriticalIssue,
      'hasWarning': result.hasWarning,
      'noticeMonths': result.noticeMonths,
      'permitWindowStatus': result.permitWindowStatus.name,
      'formalNoticeStatus': input.formalNoticeStatus?.name,
      'legalVersionVerifiedAt': legalVersionVerifiedAt,
      'checklistCollectedCount': checklistCollectedCount,
      'checklistTotalCount': checklistTotalCount,
    };
  }
}
