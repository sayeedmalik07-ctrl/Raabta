import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_check_history_entry.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_compliance_models.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_enums.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_lease_input.dart';
import 'package:raabta/features/tenancy/domain/services/tenancy_compliance_checker.dart';

/// Reads append-only tenancy compliance history from Firestore (`tenancy_records`).
abstract final class TenancyHistoryLoader {
  static const defaultLimit = 50;

  static Future<List<TenancyCheckHistoryEntry>> load({
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
          .collection('tenancy_records')
          .orderBy('checkedAt', descending: true)
          .limit(limit)
          .get();

      return snap.docs
          .map(parseDocument)
          .whereType<TenancyCheckHistoryEntry>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  static TenancyCheckHistoryEntry? parseDocument(DocumentSnapshot doc) {
    final data = doc.data();
    if (data is! Map<String, dynamic>) return null;
    return parseRecord(id: doc.id, data: data);
  }

  static TenancyCheckHistoryEntry? parseRecord({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final checkedAt = _parseDate(data['checkedAt']);
    if (checkedAt == null) return null;

    final input = TenancyLeaseInput(
      monthlyRent: (data['monthlyRent'] as num?)?.toDouble() ?? 0,
      securityDeposit: (data['securityDeposit'] as num?)?.toDouble() ?? 0,
      leaseStartDate: _parseDate(data['leaseStartDate']),
      leaseEndDate: _parseDate(data['leaseEndDate']),
      registrationStatus: _parseRegistration(data['registrationStatus']),
      propertyType: TenancyPropertyType.values.firstWhere(
        (e) => e.name == data['propertyType'],
        orElse: () => TenancyPropertyType.residential,
      ),
      committeeDecisionDate: _parseDate(data['committeeDecisionDate']),
      leaseScannedToVault: data['leaseScannedToVault'] as bool?,
    );

    const checker = TenancyComplianceChecker();
    final computed = checker.check(input);
    final result = TenancyComplianceResult(
      items: computed.items,
      checkedAt: checkedAt,
      lateFeeEstimate: computed.lateFeeEstimate,
    );

    return TenancyCheckHistoryEntry(
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

  static TenancyRegistrationStatus? _parseRegistration(Object? value) {
    if (value == null) return null;
    return TenancyRegistrationStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TenancyRegistrationStatus.notSure,
    );
  }
}
