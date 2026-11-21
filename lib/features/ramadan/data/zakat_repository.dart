import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/features/ramadan/domain/zakat_calculator.dart';
import 'package:raabta/features/ramadan/hijri_calendar.dart';

class ZakatCalculationRecord {
  const ZakatCalculationRecord({
    required this.id,
    required this.hijriYear,
    required this.zakatDue,
    required this.zakatableWealth,
    required this.nisabThreshold,
    required this.meetsNisab,
    required this.nisabStandard,
    required this.calculatedAt,
    this.reminderEnabled = false,
  });

  final String id;
  final int hijriYear;
  final double zakatDue;
  final double zakatableWealth;
  final double nisabThreshold;
  final bool meetsNisab;
  final NisabStandard nisabStandard;
  final DateTime calculatedAt;
  final bool reminderEnabled;

  Map<String, dynamic> toJson() => {
        'hijriYear': hijriYear,
        'zakatDue': zakatDue,
        'zakatableWealth': zakatableWealth,
        'nisabThreshold': nisabThreshold,
        'meetsNisab': meetsNisab,
        'nisabStandard': nisabStandard.name,
        'calculatedAt': calculatedAt.toIso8601String(),
        'reminderEnabled': reminderEnabled,
      };
}

class ZakatRepository {
  ZakatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> saveCalculation({
    required ZakatResult result,
    required ZakatInputs inputs,
    required double goldRatePerGram,
    bool reminderEnabled = false,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final hijri = gregorianToHijri(DateTime.now());
    final id = '${hijri.year}_${DateTime.now().millisecondsSinceEpoch}';
    final record = ZakatCalculationRecord(
      id: id,
      hijriYear: hijri.year,
      zakatDue: result.zakatDue,
      zakatableWealth: result.zakatableWealth,
      nisabThreshold: result.nisabThreshold,
      meetsNisab: result.meetsNisab,
      nisabStandard: result.nisabStandard,
      calculatedAt: DateTime.now(),
      reminderEnabled: reminderEnabled,
    );

    final userRef = _firestore.collection('users').doc(user.uid);
    await userRef.collection('zakat_calculations').doc(id).set({
      ...record.toJson(),
      'inputs': {
        'cashQar': inputs.cashQar,
        'goldWeightGrams': inputs.goldWeightGrams,
        'goldPurity': inputs.goldPurity,
        'useLockerGold': inputs.useLockerGold,
        'lockerGoldValueQar': inputs.lockerGoldValueQar,
        'silverWeightGrams': inputs.silverWeightGrams,
        'investmentsQar': inputs.investmentsQar,
        'businessInventoryQar': inputs.businessInventoryQar,
        'debtsReceivableQar': inputs.debtsReceivableQar,
        'debtsPayableQar': inputs.debtsPayableQar,
        'goldRatePerGram': goldRatePerGram,
      },
    });

    await userRef.set({
      'zakatSummary': {
        'latestHijriYear': hijri.year,
        'latestZakatDue': result.zakatDue,
        'latestCalculatedAt': record.calculatedAt.toIso8601String(),
        'reminderEnabled': reminderEnabled,
      },
    }, SetOptions(merge: true));
  }
}
