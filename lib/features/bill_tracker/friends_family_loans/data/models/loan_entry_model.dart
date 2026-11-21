import 'package:cloud_firestore/cloud_firestore.dart';

enum LoanDirection { lent, borrowed }

enum LoanStatus { active, overdue, settled }

class LoanRepayment {
  const LoanRepayment({
    required this.amount,
    required this.date,
  });

  final double amount;
  final DateTime date;

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'date': date.toIso8601String(),
      };

  factory LoanRepayment.fromJson(Map<String, dynamic> json) {
    return LoanRepayment(
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    );
  }

  factory LoanRepayment.fromFirestore(Map<String, dynamic> json) {
    final rawDate = json['date'];
    DateTime date;
    if (rawDate is Timestamp) {
      date = rawDate.toDate();
    } else if (rawDate is String) {
      date = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      date = DateTime.now();
    }
    return LoanRepayment(
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      date: date,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'amount': amount,
        'date': Timestamp.fromDate(date),
      };
}

class LoanEntryModel {
  const LoanEntryModel({
    required this.id,
    required this.userId,
    required this.personName,
    required this.direction,
    required this.amount,
    required this.loanDate,
    required this.dueDate,
    this.notes = '',
    this.repayments = const [],
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
    this.pendingSync = false,
  });

  final String id;
  final String userId;
  final String personName;
  final LoanDirection direction;
  final double amount;
  final DateTime loanDate;
  final DateTime dueDate;
  final String notes;
  final List<LoanRepayment> repayments;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool pendingSync;

  LoanEntryModel copyWith({
    String? id,
    String? userId,
    String? personName,
    LoanDirection? direction,
    double? amount,
    DateTime? loanDate,
    DateTime? dueDate,
    String? notes,
    List<LoanRepayment>? repayments,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? pendingSync,
  }) {
    return LoanEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      personName: personName ?? this.personName,
      direction: direction ?? this.direction,
      amount: amount ?? this.amount,
      loanDate: loanDate ?? this.loanDate,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      repayments: repayments ?? this.repayments,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'personName': personName,
        'direction': direction.name,
        'amount': amount,
        'loanDate': loanDate.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'notes': notes,
        'repayments': repayments.map((r) => r.toJson()).toList(),
        'isArchived': isArchived,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'pendingSync': pendingSync,
      };

  factory LoanEntryModel.fromJson(Map<String, dynamic> json) {
    return LoanEntryModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      personName: json['personName'] as String? ?? '',
      direction: _parseDirection(json['direction'] as String?),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      loanDate: DateTime.tryParse(json['loanDate'] as String? ?? '') ??
          DateTime.now(),
      dueDate: DateTime.tryParse(json['dueDate'] as String? ?? '') ??
          DateTime.now(),
      notes: json['notes'] as String? ?? '',
      repayments: (json['repayments'] as List<dynamic>? ?? [])
          .map((e) => LoanRepayment.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      isArchived: json['isArchived'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      pendingSync: json['pendingSync'] as bool? ?? false,
    );
  }

  factory LoanEntryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return LoanEntryModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      personName: data['personName'] as String? ?? '',
      direction: _parseDirection(data['direction'] as String?),
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      loanDate: _parseTimestamp(data['loanDate']),
      dueDate: _parseTimestamp(data['dueDate']),
      notes: data['notes'] as String? ?? '',
      repayments: (data['repayments'] as List<dynamic>? ?? [])
          .map(
            (e) => LoanRepayment.fromFirestore(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
      isArchived: data['isArchived'] as bool? ?? false,
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      pendingSync: false,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'personName': personName.trim(),
        'direction': direction.name,
        'amount': amount,
        'loanDate': Timestamp.fromDate(loanDate),
        'dueDate': Timestamp.fromDate(dueDate),
        'notes': notes,
        'repayments': repayments.map((r) => r.toFirestore()).toList(),
        'isArchived': isArchived,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  static LoanDirection _parseDirection(String? raw) {
    return raw == LoanDirection.borrowed.name
        ? LoanDirection.borrowed
        : LoanDirection.lent;
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
