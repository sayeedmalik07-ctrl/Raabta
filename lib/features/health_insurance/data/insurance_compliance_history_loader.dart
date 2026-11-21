import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/features/health_insurance/domain/models/insurance_compliance_history_entry.dart';

/// Reads Part A compliance check summaries from Firestore.
abstract final class InsuranceComplianceHistoryLoader {
  static const defaultLimit = 50;

  static Future<List<InsuranceComplianceHistoryEntry>> load({
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
          .collection('health_insurance_compliance_checks')
          .orderBy('calculatedAt', descending: true)
          .limit(limit)
          .get();

      return snap.docs
          .map(parseDocument)
          .whereType<InsuranceComplianceHistoryEntry>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  static InsuranceComplianceHistoryEntry? parseDocument(DocumentSnapshot doc) {
    final data = doc.data();
    if (data is! Map<String, dynamic>) return null;
    return parseRecord(id: doc.id, data: data);
  }

  static InsuranceComplianceHistoryEntry? parseRecord({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final checkedAt = _parseDate(data['calculatedAt']);
    if (checkedAt == null) return null;

    return InsuranceComplianceHistoryEntry(
      id: id,
      checkedAt: checkedAt,
      companyName: data['companyName'] as String? ?? '',
      hasUnresolvedViolation:
          data['hasUnresolvedViolation'] as bool? ??
              data['violationFlagged'] as bool? ??
              false,
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
