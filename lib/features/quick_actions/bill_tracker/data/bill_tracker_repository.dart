import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:raabta/features/quick_actions/bill_tracker/domain/bill_entry.dart';

/// Firestore access for Bill Tracker — bounded, user-scoped reads.
class BillTrackerRepository {
  BillTrackerRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Max bills loaded per user (≈4 providers × 24 months).
  static const int billLimit = 100;

  /// One-shot fetch for post-save logic (e.g. anomaly check after add).
  Future<List<BillEntry>> fetchBills(String userId) async {
    try {
      final snap = await _indexedQuery(userId).get();
      return _mapDocs(snap.docs);
    } catch (e) {
      if (_isMissingIndexError(e)) {
        final snap = await _fallbackQuery(userId).get();
        return _sortBills(_mapDocs(snap.docs));
      }
      rethrow;
    }
  }

  Stream<List<BillEntry>> watchBills(String userId) {
    return Stream<List<BillEntry>>.multi((controller) {
      StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? sub;

      void attach(Stream<QuerySnapshot<Map<String, dynamic>>> stream,
          {required bool clientSort}) {
        sub?.cancel();
        sub = stream.listen(
          (snapshot) {
            final bills = _mapDocs(snapshot.docs);
            controller.add(clientSort ? _sortBills(bills) : bills);
          },
          onError: (Object error, StackTrace stack) {
            if (_isMissingIndexError(error)) {
              attach(_fallbackQuery(userId).snapshots(), clientSort: true);
              return;
            }
            controller.addError(error, stack);
          },
        );
      }

      attach(_indexedQuery(userId).snapshots(), clientSort: false);
      controller.onCancel = () => sub?.cancel();
    });
  }

  Query<Map<String, dynamic>> _indexedQuery(String userId) {
    return _db
        .collection('bill_tracker')
        .where('userId', isEqualTo: userId)
        .orderBy('isPaid')
        .orderBy('dueDate')
        .limit(billLimit);
  }

  Query<Map<String, dynamic>> _fallbackQuery(String userId) {
    return _db
        .collection('bill_tracker')
        .where('userId', isEqualTo: userId)
        .limit(billLimit);
  }

  Future<String> addBill({
    required String userId,
    required String provider,
    required String category,
    required String emoji,
    required double amount,
    required DateTime dueDate,
    String accountNumber = '',
    String notes = '',
    DateTime? billingPeriodStart,
    DateTime? billingPeriodEnd,
    String currency = 'QAR',
  }) async {
    final payload = <String, dynamic>{
      'userId': userId,
      'provider': provider,
      'category': category,
      'emoji': emoji,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'isPaid': false,
      'accountNumber': accountNumber,
      'notes': notes,
      'currency': currency,
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (billingPeriodStart != null) {
      payload['billingPeriodStart'] = Timestamp.fromDate(billingPeriodStart);
    }
    if (billingPeriodEnd != null) {
      payload['billingPeriodEnd'] = Timestamp.fromDate(billingPeriodEnd);
    }
    final doc = await _db.collection('bill_tracker').add(payload);
    return doc.id;
  }

  Future<void> markPaid(String id, bool paid) async {
    await _db.collection('bill_tracker').doc(id).update({'isPaid': paid});
  }

  Future<void> deleteBill(String id) async {
    await _db.collection('bill_tracker').doc(id).delete();
  }

  /// Removes all utility bills for a device/account user id (PDPPL deletion).
  Future<void> deleteAllForUser(String userId) async {
    final snap = await _db
        .collection('bill_tracker')
        .where('userId', isEqualTo: userId)
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  static List<BillEntry> _mapDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final bills = <BillEntry>[];
    for (final doc in docs) {
      try {
        bills.add(BillEntry.fromFirestore(doc));
      } catch (_) {}
    }
    return bills;
  }

  static List<BillEntry> _sortBills(List<BillEntry> bills) {
    bills.sort((a, b) {
      if (a.isPaid != b.isPaid) {
        return a.isPaid ? 1 : -1;
      }
      return a.dueDate.compareTo(b.dueDate);
    });
    return bills;
  }

  static bool _isMissingIndexError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('index') ||
        message.contains('failed-precondition');
  }

  @visibleForTesting
  static List<BillEntry> sortBillsForTest(List<BillEntry> bills) {
    return _sortBills(List<BillEntry>.from(bills));
  }
}
