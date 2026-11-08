import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_enums.dart';

/// Local-only guest profile for pre-arrival Qatar planning.
class ProspectiveProfile {
  const ProspectiveProfile({
    this.countryId = '',
    this.roleTitle = '',
    this.keyTerms = '',
    this.contract = const EosbEmployeeInput(),
    this.beforeYouSignChecked = const {},
    this.qvcStepsChecked = const {},
    this.contractIntakeComplete = false,
    this.updatedAt,
  });

  final String countryId;
  final String roleTitle;
  final String keyTerms;
  final EosbEmployeeInput contract;
  final Map<String, bool> beforeYouSignChecked;
  final Map<String, bool> qvcStepsChecked;
  final bool contractIntakeComplete;
  final DateTime? updatedAt;

  bool get hasCountry => countryId.trim().isNotEmpty;

  String get nationalityLabel {
    switch (countryId) {
      case 'india':
        return 'India';
      case 'nepal':
        return 'Nepal';
      case 'philippines':
        return 'Philippines';
      default:
        return countryId;
    }
  }

  ProspectiveProfile copyWith({
    String? countryId,
    String? roleTitle,
    String? keyTerms,
    EosbEmployeeInput? contract,
    Map<String, bool>? beforeYouSignChecked,
    Map<String, bool>? qvcStepsChecked,
    bool? contractIntakeComplete,
    DateTime? updatedAt,
  }) {
    return ProspectiveProfile(
      countryId: countryId ?? this.countryId,
      roleTitle: roleTitle ?? this.roleTitle,
      keyTerms: keyTerms ?? this.keyTerms,
      contract: contract ?? this.contract,
      beforeYouSignChecked: beforeYouSignChecked ?? this.beforeYouSignChecked,
      qvcStepsChecked: qvcStepsChecked ?? this.qvcStepsChecked,
      contractIntakeComplete:
          contractIntakeComplete ?? this.contractIntakeComplete,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'countryId': countryId,
        'roleTitle': roleTitle,
        'keyTerms': keyTerms,
        'contract': contract.toJson(),
        'beforeYouSignChecked': beforeYouSignChecked,
        'qvcStepsChecked': qvcStepsChecked,
        'contractIntakeComplete': contractIntakeComplete,
        'updatedAt': updatedAt?.toIso8601String(),
        'schemaVersion': 1,
      };

  factory ProspectiveProfile.fromJson(Map<String, dynamic> json) {
    final contractRaw = json['contract'];
    return ProspectiveProfile(
      countryId: json['countryId'] as String? ?? '',
      roleTitle: json['roleTitle'] as String? ?? '',
      keyTerms: json['keyTerms'] as String? ?? '',
      contract: contractRaw is Map<String, dynamic>
          ? EosbEmployeeInput.fromJson(contractRaw)
          : const EosbEmployeeInput(),
      beforeYouSignChecked: _boolMap(json['beforeYouSignChecked']),
      qvcStepsChecked: _boolMap(json['qvcStepsChecked']),
      contractIntakeComplete: json['contractIntakeComplete'] as bool? ?? false,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }

  static Map<String, bool> _boolMap(dynamic raw) {
    if (raw is! Map) return {};
    return raw.map((k, v) => MapEntry(k.toString(), v == true));
  }
}

/// Maps guest contract data to EOSB input for preview / post-arrival migration.
class ProspectiveProfileMapper {
  const ProspectiveProfileMapper();

  static const previewServiceYears = 3;

  EosbEmployeeInput toPreviewInput(ProspectiveProfile profile) {
    final contract = profile.contract;
    final start = contract.joiningDate ?? DateTime.now();
    final end = contract.lastWorkingDate ??
        DateTime(start.year + previewServiceYears, start.month, start.day);

    return contract.copyWith(
      country: 'Qatar',
      companyName: contract.companyName,
      industry: profile.roleTitle.isNotEmpty
          ? profile.roleTitle
          : contract.industry,
      joiningDate: start,
      lastWorkingDate: end,
      terminationType: EosbTerminationType.employerTermination,
      contractType: contract.contractType,
      totalSalary: contract.totalSalary > 0
          ? contract.totalSalary
          : contract.basicSalary,
    );
  }

  EosbEmployeeInput toMigrationInput(ProspectiveProfile profile) {
    final preview = toPreviewInput(profile);
    return preview.copyWith(
      storeSalaryWithConsent: true,
    );
  }
}
