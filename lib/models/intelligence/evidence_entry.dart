import 'package:raabta/models/intelligence/evidence_attachment_metadata.dart';

/// Labour dispute evidence log entry — append-only by convention.
class EvidenceEntry {
  const EvidenceEntry({
    required this.id,
    required this.userId,
    required this.entryDate,
    required this.note,
    required this.claimType,
    required this.createdAt,
    this.attachmentDocumentId,
    this.attachmentCaptureSource,
    this.attachmentCapturedAt,
    this.attachmentCapturedLatitude,
    this.attachmentCapturedLongitude,
    this.attachmentUploadedAt,
    this.supersedesEntryId,
  });

  final String id;
  final String userId;

  /// When the documented event happened (user-entered).
  final DateTime entryDate;

  /// Required human-written note — no AI generation.
  final String note;

  /// Optional reference into Document Vault (`scanned_documents`).
  final String? attachmentDocumentId;

  /// `in_app_camera` or `gallery` — see [EvidenceAttachmentCaptureSource].
  final String? attachmentCaptureSource;

  /// Device timestamp when photo was taken through in-app camera flow.
  final DateTime? attachmentCapturedAt;

  /// One-shot location at in-app capture moment only — never background tracked.
  final double? attachmentCapturedLatitude;
  final double? attachmentCapturedLongitude;

  /// When a gallery photo was attached (capture time not verified).
  final DateTime? attachmentUploadedAt;

  /// Reuses EOSB [ViolationItem.ruleKey] values where they overlap — see [EvidenceClaimTypes].
  final String claimType;

  /// Immutable timestamp set once at creation.
  final DateTime createdAt;

  /// When the user supplements an earlier entry, points to the prior row (append-only amend).
  final String? supersedesEntryId;

  EvidenceAttachmentMetadata get attachmentMetadata => EvidenceAttachmentMetadata(
        captureSource:
            EvidenceAttachmentCaptureSourceJson.fromStorage(attachmentCaptureSource),
        capturedAt: attachmentCapturedAt,
        capturedLatitude: attachmentCapturedLatitude,
        capturedLongitude: attachmentCapturedLongitude,
        uploadedAt: attachmentUploadedAt,
      );

  EvidenceEntry copyWith({
    String? id,
    String? userId,
    DateTime? entryDate,
    String? note,
    String? claimType,
    DateTime? createdAt,
    String? attachmentDocumentId,
    String? attachmentCaptureSource,
    DateTime? attachmentCapturedAt,
    double? attachmentCapturedLatitude,
    double? attachmentCapturedLongitude,
    DateTime? attachmentUploadedAt,
    String? supersedesEntryId,
  }) {
    return EvidenceEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      entryDate: entryDate ?? this.entryDate,
      note: note ?? this.note,
      claimType: claimType ?? this.claimType,
      createdAt: createdAt ?? this.createdAt,
      attachmentDocumentId: attachmentDocumentId ?? this.attachmentDocumentId,
      attachmentCaptureSource:
          attachmentCaptureSource ?? this.attachmentCaptureSource,
      attachmentCapturedAt: attachmentCapturedAt ?? this.attachmentCapturedAt,
      attachmentCapturedLatitude:
          attachmentCapturedLatitude ?? this.attachmentCapturedLatitude,
      attachmentCapturedLongitude:
          attachmentCapturedLongitude ?? this.attachmentCapturedLongitude,
      attachmentUploadedAt: attachmentUploadedAt ?? this.attachmentUploadedAt,
      supersedesEntryId: supersedesEntryId ?? this.supersedesEntryId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'entryDate': entryDate.toIso8601String(),
        'note': note,
        if (attachmentDocumentId != null)
          'attachmentDocumentId': attachmentDocumentId,
        if (attachmentCaptureSource != null)
          'attachmentCaptureSource': attachmentCaptureSource,
        if (attachmentCapturedAt != null)
          'attachmentCapturedAt': attachmentCapturedAt!.toIso8601String(),
        if (attachmentCapturedLatitude != null)
          'attachmentCapturedLatitude': attachmentCapturedLatitude,
        if (attachmentCapturedLongitude != null)
          'attachmentCapturedLongitude': attachmentCapturedLongitude,
        if (attachmentUploadedAt != null)
          'attachmentUploadedAt': attachmentUploadedAt!.toIso8601String(),
        'claimType': claimType,
        'createdAt': createdAt.toIso8601String(),
        if (supersedesEntryId != null) 'supersedesEntryId': supersedesEntryId,
      };

  factory EvidenceEntry.fromJson(Map<String, dynamic> json) {
    return EvidenceEntry(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      entryDate: DateTime.tryParse(json['entryDate'] as String? ?? '') ??
          DateTime.now(),
      note: json['note'] as String? ?? '',
      attachmentDocumentId: json['attachmentDocumentId'] as String?,
      attachmentCaptureSource: json['attachmentCaptureSource'] as String?,
      attachmentCapturedAt: DateTime.tryParse(
        json['attachmentCapturedAt'] as String? ?? '',
      ),
      attachmentCapturedLatitude:
          (json['attachmentCapturedLatitude'] as num?)?.toDouble(),
      attachmentCapturedLongitude:
          (json['attachmentCapturedLongitude'] as num?)?.toDouble(),
      attachmentUploadedAt: DateTime.tryParse(
        json['attachmentUploadedAt'] as String? ?? '',
      ),
      claimType: json['claimType'] as String? ?? EvidenceClaimTypes.other,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      supersedesEntryId: json['supersedesEntryId'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvidenceEntry &&
          id == other.id &&
          userId == other.userId &&
          entryDate == other.entryDate &&
          note == other.note &&
          attachmentDocumentId == other.attachmentDocumentId &&
          attachmentCaptureSource == other.attachmentCaptureSource &&
          attachmentCapturedAt == other.attachmentCapturedAt &&
          attachmentCapturedLatitude == other.attachmentCapturedLatitude &&
          attachmentCapturedLongitude == other.attachmentCapturedLongitude &&
          attachmentUploadedAt == other.attachmentUploadedAt &&
          claimType == other.claimType &&
          createdAt == other.createdAt &&
          supersedesEntryId == other.supersedesEntryId;

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        entryDate,
        note,
        attachmentDocumentId,
        attachmentCaptureSource,
        attachmentCapturedAt,
        attachmentCapturedLatitude,
        attachmentCapturedLongitude,
        attachmentUploadedAt,
        claimType,
        createdAt,
        supersedesEntryId,
      );
}

/// Claim types for evidence entries — EOSB violation rule keys reused verbatim.
abstract final class EvidenceClaimTypes {
  // ── EOSB ViolationDetector.ruleKey values (exact reuse) ─────────────────
  static const eosbViolationSalaryBasis = 'eosb_violation_salary_basis_rule';
  static const eosbGratuityMinService = 'eosb_gratuity_rule_min_service';
  static const eosbGratuityMissing = 'eosb_gratuity_rule';

  // ── Additional labour dispute categories (no parallel EOSB taxonomy) ──────
  static const unpaidWages = 'unpaid_wages';
  static const unpaidOvertime = 'unpaid_overtime';
  static const passportWithholding = 'passport_withholding';
  static const contractBreach = 'contract_breach';
  static const wrongfulTermination = 'wrongful_termination';
  static const other = 'other';

  static const all = [
    eosbViolationSalaryBasis,
    eosbGratuityMinService,
    eosbGratuityMissing,
    unpaidWages,
    unpaidOvertime,
    passportWithholding,
    contractBreach,
    wrongfulTermination,
    other,
  ];

  static const labels = {
    eosbViolationSalaryBasis: 'Salary basis mismatch (EOSB)',
    eosbGratuityMinService: 'Minimum service / gratuity (EOSB)',
    eosbGratuityMissing: 'Missing end-of-service gratuity (EOSB)',
    unpaidWages: 'Unpaid wages',
    unpaidOvertime: 'Unpaid overtime',
    passportWithholding: 'Passport or document withholding',
    contractBreach: 'Contract breach',
    wrongfulTermination: 'Wrongful termination',
    other: 'Other labour dispute',
  };

  static String labelFor(String claimType) =>
      labels[claimType] ?? labels[other]!;

  static bool isValid(String claimType) => all.contains(claimType);
}

/// Lightweight evidence row for other intelligence paths (e.g. daily review parity).
class EvidenceDeadlineRecord {
  const EvidenceDeadlineRecord({
    required this.id,
    required this.entryDate,
    this.claimType = EvidenceClaimTypes.other,
  });

  final String id;
  final DateTime entryDate;
  final String claimType;

  factory EvidenceDeadlineRecord.fromEntry(EvidenceEntry entry) {
    return EvidenceDeadlineRecord(
      id: entry.id,
      entryDate: entry.entryDate,
      claimType: entry.claimType,
    );
  }
}
