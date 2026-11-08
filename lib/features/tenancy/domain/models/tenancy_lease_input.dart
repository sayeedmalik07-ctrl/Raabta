import 'package:raabta/features/tenancy/domain/models/tenancy_enums.dart';

/// Structured lease input — EOSB-style form fields, not free text.
class TenancyLeaseInput {
  const TenancyLeaseInput({
    this.monthlyRent = 0,
    this.securityDeposit = 0,
    this.leaseStartDate,
    this.leaseEndDate,
    this.registrationStatus,
    this.propertyType = TenancyPropertyType.residential,
    this.landlordName = '',
    this.leaseScannedToVault,
    this.committeeDecisionDate,
  });

  final double monthlyRent;
  final double securityDeposit;
  final DateTime? leaseStartDate;
  final DateTime? leaseEndDate;
  final TenancyRegistrationStatus? registrationStatus;
  final TenancyPropertyType propertyType;
  final String landlordName;
  final bool? leaseScannedToVault;
  final DateTime? committeeDecisionDate;

  bool get isResidential => propertyType == TenancyPropertyType.residential;

  double get depositCapMonths =>
      isResidential ? 2 : double.infinity;

  bool get isDepositOverCap =>
      isResidential && monthlyRent > 0 && securityDeposit > monthlyRent * 2;

  bool get isUnregistered =>
      registrationStatus == TenancyRegistrationStatus.no ||
      registrationStatus == TenancyRegistrationStatus.notSure;

  TenancyLeaseInput copyWith({
    double? monthlyRent,
    double? securityDeposit,
    DateTime? leaseStartDate,
    DateTime? leaseEndDate,
    TenancyRegistrationStatus? registrationStatus,
    TenancyPropertyType? propertyType,
    String? landlordName,
    bool? leaseScannedToVault,
    DateTime? committeeDecisionDate,
  }) {
    return TenancyLeaseInput(
      monthlyRent: monthlyRent ?? this.monthlyRent,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      leaseStartDate: leaseStartDate ?? this.leaseStartDate,
      leaseEndDate: leaseEndDate ?? this.leaseEndDate,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      propertyType: propertyType ?? this.propertyType,
      landlordName: landlordName ?? this.landlordName,
      leaseScannedToVault: leaseScannedToVault ?? this.leaseScannedToVault,
      committeeDecisionDate:
          committeeDecisionDate ?? this.committeeDecisionDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'monthlyRent': monthlyRent,
        'securityDeposit': securityDeposit,
        'leaseStartDate': leaseStartDate?.toIso8601String(),
        'leaseEndDate': leaseEndDate?.toIso8601String(),
        'registrationStatus': registrationStatus?.name,
        'propertyType': propertyType.name,
        'landlordName': landlordName,
        'leaseScannedToVault': leaseScannedToVault,
        'committeeDecisionDate': committeeDecisionDate?.toIso8601String(),
      };

  factory TenancyLeaseInput.fromJson(Map<String, dynamic> json) {
    return TenancyLeaseInput(
      monthlyRent: (json['monthlyRent'] as num?)?.toDouble() ?? 0,
      securityDeposit: (json['securityDeposit'] as num?)?.toDouble() ?? 0,
      leaseStartDate: _parseDate(json['leaseStartDate']),
      leaseEndDate: _parseDate(json['leaseEndDate']),
      registrationStatus: _parseRegistration(json['registrationStatus']),
      propertyType: TenancyPropertyType.values.firstWhere(
        (e) => e.name == json['propertyType'],
        orElse: () => TenancyPropertyType.residential,
      ),
      landlordName: json['landlordName'] as String? ?? '',
      leaseScannedToVault: json['leaseScannedToVault'] as bool?,
      committeeDecisionDate: _parseDate(json['committeeDecisionDate']),
    );
  }
}

DateTime? _parseDate(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

TenancyRegistrationStatus? _parseRegistration(Object? value) {
  if (value == null) return null;
  return TenancyRegistrationStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => TenancyRegistrationStatus.notSure,
  );
}
