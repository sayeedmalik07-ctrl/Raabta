/// A deterministic, evidence-linked risk surfaced by [RiskDetector].
class Risk {
  const Risk({
    required this.id,
    required this.userId,
    required this.type,
    required this.severity,
    required this.evidenceReference,
    required this.evidenceCollection,
    required this.recommendedAction,
    required this.createdAt,
  });

  static const typeDocumentExpiry = 'document_expiry';
  static const typeBillDue = 'bill_due';
  static const typeVehicleExpiry = 'vehicle_expiry';
  static const typeEosbViolation = 'eosb_violation';
  static const typeLabourComplaintDeadline = 'labour_complaint_deadline';

  static const severityCritical = 'critical';
  static const severityHigh = 'high';
  static const severityMedium = 'medium';
  static const severityLow = 'low';

  final String id;
  final String userId;
  final String type;
  final String severity;
  final String evidenceReference;
  final String evidenceCollection;
  final String recommendedAction;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'type': type,
        'severity': severity,
        'evidenceReference': evidenceReference,
        'evidenceCollection': evidenceCollection,
        'recommendedAction': recommendedAction,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Risk.fromJson(Map<String, dynamic> json) {
    return Risk(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      type: json['type'] as String? ?? '',
      severity: json['severity'] as String? ?? severityLow,
      evidenceReference: json['evidenceReference'] as String? ?? '',
      evidenceCollection: json['evidenceCollection'] as String? ?? '',
      recommendedAction: json['recommendedAction'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Risk &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          type == other.type &&
          severity == other.severity &&
          evidenceReference == other.evidenceReference &&
          evidenceCollection == other.evidenceCollection &&
          recommendedAction == other.recommendedAction &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        type,
        severity,
        evidenceReference,
        evidenceCollection,
        recommendedAction,
        createdAt,
      );
}

/// Document Vault row used by [RiskDetector.checkDocumentExpiry].
class DocumentVaultRecord {
  const DocumentVaultRecord({
    required this.id,
    this.displayName,
    this.docType,
    this.expiryDate,
  });

  final String id;
  final String? displayName;
  final String? docType;
  final DateTime? expiryDate;
}

/// Bill Tracker row used by [RiskDetector.checkBillDue].
class BillDueRecord {
  const BillDueRecord({
    required this.id,
    required this.provider,
    required this.dueDate,
    required this.isPaid,
    this.amount = 0,
  });

  final String id;
  final String provider;
  final DateTime dueDate;
  final bool isPaid;
  final double amount;
}
