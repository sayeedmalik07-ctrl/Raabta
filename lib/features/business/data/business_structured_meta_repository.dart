import 'package:cloud_firestore/cloud_firestore.dart';

/// Convenience cache of open structured-request counts (not security-authoritative).
/// Writes are restricted by Firestore rules to structured-action participants only.
class BusinessStructuredMetaRepository {
  BusinessStructuredMetaRepository({FirebaseFirestore? firestore})
      : _db = firestore;

  final FirebaseFirestore? _db;

  DocumentReference<Map<String, dynamic>>? _metaRef(String businessId) {
    if (_db == null) return null;
    return _db!
        .collection('businesses')
        .doc(businessId)
        .collection('internal')
        .doc('structured_meta');
  }

  Future<void> incrementAppointmentCount(
    Transaction tx,
    String businessId,
  ) async {
    final ref = _metaRef(businessId);
    if (ref == null) return;
    final snap = await tx.get(ref);
    if (!snap.exists) {
      tx.set(ref, {
        'openAppointmentCount': 1,
        'openQuoteCount': 0,
      });
      return;
    }
    final current = (snap.data()?['openAppointmentCount'] as num?)?.toInt() ?? 0;
    tx.update(ref, {'openAppointmentCount': current + 1});
  }

  Future<void> decrementAppointmentCount(
    Transaction tx,
    String businessId, {
    required String releasedRequesterId,
  }) async {
    final ref = _metaRef(businessId);
    if (ref == null) return;
    final snap = await tx.get(ref);
    if (!snap.exists) return;
    final current = (snap.data()?['openAppointmentCount'] as num?)?.toInt() ?? 0;
    final next = current > 0 ? current - 1 : 0;
    tx.update(ref, {
      'openAppointmentCount': next,
      'decrementForRequesterId': releasedRequesterId,
    });
  }

  Future<void> incrementQuoteCount(Transaction tx, String businessId) async {
    final ref = _metaRef(businessId);
    if (ref == null) return;
    final snap = await tx.get(ref);
    if (!snap.exists) {
      tx.set(ref, {
        'openAppointmentCount': 0,
        'openQuoteCount': 1,
      });
      return;
    }
    final current = (snap.data()?['openQuoteCount'] as num?)?.toInt() ?? 0;
    tx.update(ref, {'openQuoteCount': current + 1});
  }

  Future<void> decrementQuoteCount(
    Transaction tx,
    String businessId, {
    required String releasedRequesterId,
  }) async {
    final ref = _metaRef(businessId);
    if (ref == null) return;
    final snap = await tx.get(ref);
    if (!snap.exists) return;
    final current = (snap.data()?['openQuoteCount'] as num?)?.toInt() ?? 0;
    final next = current > 0 ? current - 1 : 0;
    tx.update(ref, {
      'openQuoteCount': next,
      'decrementForRequesterId': releasedRequesterId,
    });
  }
}
