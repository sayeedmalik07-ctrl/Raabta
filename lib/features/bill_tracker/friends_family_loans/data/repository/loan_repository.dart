import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:raabta/features/bill_tracker/friends_family_loans/data/models/loan_entry_model.dart';
import 'package:raabta/features/bill_tracker/friends_family_loans/domain/loan_balance_calculator.dart';

/// Firestore + Hive cache for Friends & Family loans.
///
/// Collection: `friends_family_loans` (sibling to `bill_tracker` — separate schema,
/// no changes to utility bill documents).
class LoanRepository {
  LoanRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const collection = 'friends_family_loans';
  static const hiveBoxName = 'friends_family_loans_v1';
  static const loanLimit = 200;

  Future<void> _ensureHive() async {
    try {
      if (!Hive.isBoxOpen(hiveBoxName)) {
        await Hive.openBox<String>(hiveBoxName);
      }
    } catch (_) {
      Hive.init('raabta_hive');
      if (!Hive.isBoxOpen(hiveBoxName)) {
        await Hive.openBox<String>(hiveBoxName);
      }
    }
  }

  String _cacheKey(String userId) => 'loans_$userId';

  Future<List<LoanEntryModel>> _loadCached(String userId) async {
    await _ensureHive();
    final raw = Hive.box<String>(hiveBoxName).get(_cacheKey(userId));
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => LoanEntryModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveCache(String userId, List<LoanEntryModel> entries) async {
    await _ensureHive();
    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await Hive.box<String>(hiveBoxName).put(_cacheKey(userId), encoded);
  }

  Stream<List<LoanEntryModel>> watchLoans(String userId) {
    return Stream<List<LoanEntryModel>>.multi((controller) {
      StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? sub;

      _loadCached(userId).then((cached) {
        if (cached.isNotEmpty) controller.add(cached);
      });

      void attach(Stream<QuerySnapshot<Map<String, dynamic>>> stream,
          {required bool clientSort}) {
        sub?.cancel();
        sub = stream.listen(
          (snapshot) async {
            final loans = _mapDocs(snapshot.docs);
            final merged = clientSort ? _sortLoans(loans) : loans;
            await _saveCache(userId, merged);
            controller.add(merged);
          },
          onError: (Object error, StackTrace stack) {
            if (_isMissingIndexError(error)) {
              attach(_fallbackQuery(userId).snapshots(), clientSort: true);
              return;
            }
            _loadCached(userId).then((cached) {
              if (cached.isNotEmpty) {
                controller.add(cached);
              } else {
                controller.addError(error, stack);
              }
            });
          },
        );
      }

      attach(_indexedQuery(userId).snapshots(), clientSort: false);
      controller.onCancel = () => sub?.cancel();
    });
  }

  Query<Map<String, dynamic>> _indexedQuery(String userId) {
    return _db
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .limit(loanLimit);
  }

  Query<Map<String, dynamic>> _fallbackQuery(String userId) {
    return _db
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .limit(loanLimit);
  }

  Future<String> addLoan({
    required String userId,
    required String personName,
    required LoanDirection direction,
    required double amount,
    required DateTime loanDate,
    required DateTime dueDate,
    String notes = '',
  }) async {
    final now = DateTime.now();
    final tempId = 'local_${now.millisecondsSinceEpoch}';
    final localEntry = LoanEntryModel(
      id: tempId,
      userId: userId,
      personName: personName.trim(),
      direction: direction,
      amount: amount,
      loanDate: loanDate,
      dueDate: dueDate,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      pendingSync: true,
    );

    final cached = await _loadCached(userId);
    await _saveCache(userId, [localEntry, ...cached]);

    try {
      final doc = await _db.collection(collection).add({
        'userId': userId,
        'personName': personName.trim(),
        'direction': direction.name,
        'amount': amount,
        'loanDate': Timestamp.fromDate(loanDate),
        'dueDate': Timestamp.fromDate(dueDate),
        'notes': notes,
        'repayments': <Map<String, dynamic>>[],
        'isArchived': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (e) {
      debugPrint('LoanRepository.addLoan offline/failed sync: $e');
      return tempId;
    }
  }

  Future<void> addRepayment({
    required String loanId,
    required String userId,
    required double amount,
    required DateTime date,
  }) async {
    if (loanId.startsWith('local_')) {
      await _addRepaymentLocally(
        userId: userId,
        loanId: loanId,
        amount: amount,
        date: date,
      );
      return;
    }

    final docRef = _db.collection(collection).doc(loanId);
    final snap = await docRef.get();
    if (!snap.exists) return;

    final entry = LoanEntryModel.fromFirestore(snap);
    final updatedRepayments = [
      ...entry.repayments,
      LoanRepayment(amount: amount, date: date),
    ];

    await docRef.update({
      'repayments': updatedRepayments.map((r) => r.toFirestore()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isArchived': _shouldArchive(entry.amount, updatedRepayments),
    });
  }

  Future<void> archiveLoan(String loanId, {required String userId}) async {
    if (loanId.startsWith('local_')) {
      final cached = await _loadCached(userId);
      final updated = cached
          .map(
            (e) => e.id == loanId
                ? e.copyWith(isArchived: true, updatedAt: DateTime.now())
                : e,
          )
          .toList();
      await _saveCache(userId, updated);
      return;
    }

    await _db.collection(collection).doc(loanId).update({
      'isArchived': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteLoan(String loanId, {required String userId}) async {
    final cached = await _loadCached(userId);
    await _saveCache(
      userId,
      cached.where((e) => e.id != loanId).toList(),
    );

    if (!loanId.startsWith('local_')) {
      await _db.collection(collection).doc(loanId).delete();
    }
  }

  /// Removes all loan entries for a user (PDPPL account deletion).
  Future<void> deleteAllForUser(String userId) async {
    final snap = await _db
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
    await _ensureHive();
    await Hive.box<String>(hiveBoxName).delete(_cacheKey(userId));
  }

  Future<void> deleteAllForPerson({
    required String userId,
    required String personKey,
  }) async {
    final cached = await _loadCached(userId);
    final toDelete = cached
        .where((e) => personKeyFromName(e.personName) == personKey)
        .map((e) => e.id)
        .toList();

    for (final id in toDelete) {
      await deleteLoan(id, userId: userId);
    }
  }

  Future<void> _addRepaymentLocally({
    required String userId,
    required String loanId,
    required double amount,
    required DateTime date,
  }) async {
    final cached = await _loadCached(userId);
    final updated = cached.map((entry) {
      if (entry.id != loanId) return entry;
      final repayments = [
        ...entry.repayments,
        LoanRepayment(amount: amount, date: date),
      ];
      return entry.copyWith(
        repayments: repayments,
        isArchived: _shouldArchive(entry.amount, repayments),
        updatedAt: DateTime.now(),
      );
    }).toList();
    await _saveCache(userId, updated);
  }

  static bool _shouldArchive(double total, List<LoanRepayment> repayments) {
    final repaid = repayments.fold(0.0, (s, r) => s + r.amount);
    return repaid >= total;
  }

  static List<LoanEntryModel> _mapDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final loans = <LoanEntryModel>[];
    for (final doc in docs) {
      try {
        loans.add(LoanEntryModel.fromFirestore(doc));
      } catch (_) {}
    }
    return loans;
  }

  static List<LoanEntryModel> _sortLoans(List<LoanEntryModel> loans) {
    loans.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return loans;
  }

  static bool _isMissingIndexError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('index') ||
        message.contains('failed-precondition');
  }

  @visibleForTesting
  static List<LoanEntryModel> sortLoansForTest(List<LoanEntryModel> loans) {
    return _sortLoans(List<LoanEntryModel>.from(loans));
  }
}
