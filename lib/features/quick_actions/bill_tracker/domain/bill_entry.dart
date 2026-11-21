import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/quick_actions/bill_tracker/data/qatar_bill_providers.dart';

class BillEntry {
  final String id;
  final String provider;
  final String category;
  final String emoji;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final String accountNumber;
  final String notes;
  final DateTime createdAt;
  final DateTime? billingPeriodStart;
  final DateTime? billingPeriodEnd;
  final String currency;

  const BillEntry({
    required this.id,
    required this.provider,
    required this.category,
    required this.emoji,
    required this.amount,
    required this.dueDate,
    required this.isPaid,
    required this.accountNumber,
    required this.notes,
    required this.createdAt,
    this.billingPeriodStart,
    this.billingPeriodEnd,
    this.currency = 'QAR',
  });

  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;
  bool get isOverdue => daysUntilDue < 0 && !isPaid;
  bool get isDueSoon => daysUntilDue >= 0 && daysUntilDue <= 5 && !isPaid;

  String get displayProvider =>
      QatarBillProviders.normalizeStoredProviderName(provider);

  String get displayEmoji =>
      QatarBillProviders.byName(provider)?.emoji ?? emoji;

  bool get isLegacyProvider =>
      QatarBillProviders.deprecatedProviderNames.contains(provider);

  factory BillEntry.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};

    DateTime parseDt(dynamic value, DateTime fallback) {
      if (value == null) return fallback;
      if (value is Timestamp) return value.toDate();
      return fallback;
    }

    return BillEntry(
      id: doc.id,
      provider: d['provider'] as String? ?? 'Unknown',
      category: d['category'] as String? ?? 'Other',
      emoji: d['emoji'] as String? ?? '📄',
      amount: (d['amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: parseDt(
        d['dueDate'],
        DateTime.now().add(const Duration(days: 7)),
      ),
      isPaid: d['isPaid'] as bool? ?? false,
      accountNumber: d['accountNumber'] as String? ?? '',
      notes: d['notes'] as String? ?? '',
      createdAt: parseDt(d['createdAt'], DateTime.now()),
      billingPeriodStart: d['billingPeriodStart'] != null
          ? parseDt(d['billingPeriodStart'], DateTime.now())
          : null,
      billingPeriodEnd: d['billingPeriodEnd'] != null
          ? parseDt(d['billingPeriodEnd'], DateTime.now())
          : null,
      currency: d['currency'] as String? ?? 'QAR',
    );
  }
}
