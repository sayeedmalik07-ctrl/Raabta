import 'package:raabta/features/sponsorship_transfer/domain/models/sponsorship_transfer_enums.dart';

/// Structured transfer readiness form — EOSB-style fields, not free text.
class TransferReadinessInput {
  const TransferReadinessInput({
    this.residencePermitExpiry,
    this.employmentStartDate,
    this.contractType = TransferContractType.indefinite,
    this.formalNoticeStatus,
    this.probationPeriodStatus,
  });

  final DateTime? residencePermitExpiry;
  final DateTime? employmentStartDate;
  final TransferContractType contractType;
  final FormalNoticeStatus? formalNoticeStatus;
  final ProbationPeriodStatus? probationPeriodStatus;

  TransferReadinessInput copyWith({
    DateTime? residencePermitExpiry,
    DateTime? employmentStartDate,
    TransferContractType? contractType,
    FormalNoticeStatus? formalNoticeStatus,
    ProbationPeriodStatus? probationPeriodStatus,
  }) {
    return TransferReadinessInput(
      residencePermitExpiry: residencePermitExpiry ?? this.residencePermitExpiry,
      employmentStartDate: employmentStartDate ?? this.employmentStartDate,
      contractType: contractType ?? this.contractType,
      formalNoticeStatus: formalNoticeStatus ?? this.formalNoticeStatus,
      probationPeriodStatus:
          probationPeriodStatus ?? this.probationPeriodStatus,
    );
  }

  Map<String, dynamic> toJson() => {
        'residencePermitExpiry': residencePermitExpiry?.toIso8601String(),
        'employmentStartDate': employmentStartDate?.toIso8601String(),
        'contractType': contractType.name,
        'formalNoticeStatus': formalNoticeStatus?.name,
        'probationPeriodStatus': probationPeriodStatus?.name,
      };

  factory TransferReadinessInput.fromJson(Map<String, dynamic> json) {
    return TransferReadinessInput(
      residencePermitExpiry: _parseDate(json['residencePermitExpiry']),
      employmentStartDate: _parseDate(json['employmentStartDate']),
      contractType: TransferContractType.values.firstWhere(
        (e) => e.name == json['contractType'],
        orElse: () => TransferContractType.indefinite,
      ),
      formalNoticeStatus: _parseNotice(json['formalNoticeStatus']),
      probationPeriodStatus: _parseProbation(json['probationPeriodStatus']),
    );
  }
}

DateTime? _parseDate(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

FormalNoticeStatus? _parseNotice(Object? value) {
  if (value == null) return null;
  return FormalNoticeStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => FormalNoticeStatus.notSure,
  );
}

ProbationPeriodStatus? _parseProbation(Object? value) {
  if (value == null) return null;
  return ProbationPeriodStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => ProbationPeriodStatus.notSure,
  );
}
