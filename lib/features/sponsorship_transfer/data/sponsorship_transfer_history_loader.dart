import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/sponsorship_transfer_enums.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_check_history_entry.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_input.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_models.dart';
import 'package:raabta/features/sponsorship_transfer/domain/services/transfer_readiness_checker.dart';

/// Reads append-only transfer readiness history from Firestore.
abstract final class SponsorshipTransferHistoryLoader {
  static const defaultLimit = 50;

  static Future<List<TransferCheckHistoryEntry>> load({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    int limit = defaultLimit,
  }) async {
    final user = (auth ?? FirebaseAuth.instance).currentUser;
    if (user == null) return [];

    try {
      final snap = await (firestore ?? FirebaseFirestore.instance)
          .collection('users')
          .doc(user.uid)
          .collection('transfer_readiness_checks')
          .orderBy('checkedAt', descending: true)
          .limit(limit)
          .get();

      return snap.docs
          .map(parseDocument)
          .whereType<TransferCheckHistoryEntry>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  static TransferCheckHistoryEntry? parseDocument(DocumentSnapshot doc) {
    final data = doc.data();
    if (data is! Map<String, dynamic>) return null;
    return parseRecord(id: doc.id, data: data);
  }

  static TransferCheckHistoryEntry? parseRecord({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final checkedAt = _parseDate(data['checkedAt']);
    if (checkedAt == null) return null;

    final input = TransferReadinessInput(
      employmentStartDate: _parseDate(data['employmentStartDate']),
      residencePermitExpiry: _parseDate(data['residencePermitExpiry']),
      contractType: TransferContractType.values.firstWhere(
        (e) => e.name == data['contractType'],
        orElse: () => TransferContractType.indefinite,
      ),
      formalNoticeStatus: _parseNotice(data['formalNoticeStatus']),
      probationPeriodStatus: _parseProbation(data['probationPeriodStatus']),
    );

    final computed = TransferReadinessChecker(referenceDate: checkedAt).check(input);
    final result = TransferReadinessResult(
      items: computed.items,
      checkedAt: checkedAt,
      noticeMonths: computed.noticeMonths,
      permitWindowStatus: computed.permitWindowStatus,
      daysSincePermitExpiry: computed.daysSincePermitExpiry,
      monthsEmployed: computed.monthsEmployed,
      probationNoticeApplies: computed.probationNoticeApplies,
    );

    return TransferCheckHistoryEntry(
      id: id,
      checkedAt: checkedAt,
      input: input,
      result: result,
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static FormalNoticeStatus? _parseNotice(Object? value) {
    if (value == null) return null;
    return FormalNoticeStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FormalNoticeStatus.notSure,
    );
  }

  static ProbationPeriodStatus? _parseProbation(Object? value) {
    if (value == null) return null;
    return ProbationPeriodStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ProbationPeriodStatus.notSure,
    );
  }
}
