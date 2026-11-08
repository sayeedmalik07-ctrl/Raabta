import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Recurrence frequency ────────────────────────────────

enum SplitRecurrence {
  weekly,
  biweekly,
  monthly,
}

extension SplitRecurrenceLabel on SplitRecurrence {
  String get label {
    switch (this) {
      case SplitRecurrence.weekly:    return 'Every week';
      case SplitRecurrence.biweekly:  return 'Every 2 weeks';
      case SplitRecurrence.monthly:   return 'Every month';
    }
  }

  String get shortLabel {
    switch (this) {
      case SplitRecurrence.weekly:    return 'Weekly';
      case SplitRecurrence.biweekly:  return 'Bi-weekly';
      case SplitRecurrence.monthly:   return 'Monthly';
    }
  }
}

// ─── Bill type labels ────────────────────────────────────

enum SplitBillType {
  rent,
  utilities,
  groceries,
  internet,
  dining,
  other,
}

extension SplitBillTypeLabel on SplitBillType {
  String get label {
    switch (this) {
      case SplitBillType.rent:        return '🏠  Rent';
      case SplitBillType.utilities:   return '⚡  Utilities';
      case SplitBillType.groceries:   return '🛒  Groceries';
      case SplitBillType.internet:    return '📡  Internet';
      case SplitBillType.dining:      return '🍽️  Dining';
      case SplitBillType.other:       return '📄  Other';
    }
  }

  String get emoji {
    switch (this) {
      case SplitBillType.rent:        return '🏠';
      case SplitBillType.utilities:   return '⚡';
      case SplitBillType.groceries:   return '🛒';
      case SplitBillType.internet:    return '📡';
      case SplitBillType.dining:      return '🍽️';
      case SplitBillType.other:       return '📄';
    }
  }
}

// ─── Member inside a group ───────────────────────────────

class SplitMember {
  final String id;
  final String name;
  final String flag;
  final String currency;
  final double shareQar;

  const SplitMember({
    required this.id,
    required this.name,
    required this.flag,
    required this.currency,
    required this.shareQar,
  });

  Map<String, dynamic> toMap() => {
    'id':        id,
    'name':      name,
    'flag':      flag,
    'currency':  currency,
    'shareQar':  shareQar,
  };

  factory SplitMember.fromMap(Map<String, dynamic> m) =>
      SplitMember(
        id:        m['id']       as String? ?? '',
        name:      m['name']     as String? ?? '',
        flag:      m['flag']     as String? ?? '🌍',
        currency:  m['currency'] as String? ?? 'QAR',
        shareQar:  (m['shareQar'] as num?)?.toDouble() ?? 0,
      );
}

// ─── Recurring group ─────────────────────────────────────

class RecurringSplitGroup {
  final String id;
  final String groupName;
  final SplitBillType billType;
  final SplitRecurrence recurrence;
  final List<SplitMember> members;
  final double totalQar;
  final double taxPercent;
  final DateTime createdAt;
  final DateTime nextCycleDate;
  final bool isActive;

  static const String firestoreCollection =
      'recurring_split_groups';

  static const String paymentsSubcollection =
      'split_payments';

  const RecurringSplitGroup({
    required this.id,
    required this.groupName,
    required this.billType,
    required this.recurrence,
    required this.members,
    required this.totalQar,
    required this.taxPercent,
    required this.createdAt,
    required this.nextCycleDate,
    required this.isActive,
  });

  factory RecurringSplitGroup.fromFirestore(
    DocumentSnapshot doc,
  ) {
    final d = doc.data() as Map<String, dynamic>? ?? {};

    SplitBillType parseBillType(String? raw) =>
        SplitBillType.values.firstWhere(
          (e) => e.name == raw,
          orElse: () => SplitBillType.other,
        );

    SplitRecurrence parseRecurrence(String? raw) =>
        SplitRecurrence.values.firstWhere(
          (e) => e.name == raw,
          orElse: () => SplitRecurrence.monthly,
        );

    final membersRaw =
        (d['members'] as List<dynamic>? ?? []);
    final members = membersRaw
        .map((m) => SplitMember.fromMap(
              m as Map<String, dynamic>,
            ))
        .toList();

    return RecurringSplitGroup(
      id:           doc.id,
      groupName:    d['groupName']  as String? ?? 'Group',
      billType:     parseBillType(d['billType']  as String?),
      recurrence:   parseRecurrence(d['recurrence'] as String?),
      members:      members,
      totalQar:     (d['totalQar']  as num?)?.toDouble() ?? 0,
      taxPercent:   (d['taxPercent'] as num?)?.toDouble() ?? 0,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      nextCycleDate:
          (d['nextCycleDate'] as Timestamp?)?.toDate() ??
              DateTime.now(),
      isActive:     d['isActive']   as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'groupName':    groupName,
    'billType':     billType.name,
    'recurrence':   recurrence.name,
    'members':      members.map((m) => m.toMap()).toList(),
    'totalQar':     totalQar,
    'taxPercent':   taxPercent,
    'createdAt':    Timestamp.fromDate(createdAt),
    'nextCycleDate':Timestamp.fromDate(nextCycleDate),
    'isActive':     isActive,
  };

  // Compute next cycle date from recurrence
  static DateTime computeNextCycleDate(
    SplitRecurrence recurrence, [
    DateTime? from,
  ]) {
    final base = from ?? DateTime.now();
    switch (recurrence) {
      case SplitRecurrence.weekly:
        return base.add(const Duration(days: 7));
      case SplitRecurrence.biweekly:
        return base.add(const Duration(days: 14));
      case SplitRecurrence.monthly:
        return DateTime(base.year, base.month + 1, base.day);
    }
  }
}

// ─── Payment status per member per cycle ─────────────────

class SplitPayment {
  final String id;
  final String memberId;
  final String memberName;
  final bool paid;
  final DateTime? paidAt;
  final DateTime cycleDate;
  final double amountQar;

  const SplitPayment({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.paid,
    this.paidAt,
    required this.cycleDate,
    required this.amountQar,
  });

  factory SplitPayment.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return SplitPayment(
      id:         doc.id,
      memberId:   d['memberId']   as String? ?? '',
      memberName: d['memberName'] as String? ?? '',
      paid:       d['paid']       as bool?   ?? false,
      paidAt: (d['paidAt'] as Timestamp?)?.toDate(),
      cycleDate:
          (d['cycleDate'] as Timestamp?)?.toDate() ??
              DateTime.now(),
      amountQar: (d['amountQar'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'memberId':   memberId,
    'memberName': memberName,
    'paid':       paid,
    'paidAt':     paidAt != null
        ? Timestamp.fromDate(paidAt!)
        : null,
    'cycleDate':  Timestamp.fromDate(cycleDate),
    'amountQar':  amountQar,
  };
}
