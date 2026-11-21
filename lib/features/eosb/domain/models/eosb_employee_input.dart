import 'package:raabta/features/eosb/domain/services/employer_name_normalizer.dart';

import 'eosb_enums.dart';

/// Employee and contract data collected for EOSB estimation.
class EosbEmployeeInput {
  const EosbEmployeeInput({
    this.country = 'Qatar',
    this.companyName = '',
    this.normalizedEmployerKey = '',
    this.industry = '',
    this.basicSalary = 0,
    this.basicSalaryChanged = false,
    this.basicSalaryChangeDate,
    this.totalSalary = 0,
    this.housingAllowance = 0,
    this.foodAllowance = 0,
    this.transportAllowance = 0,
    this.annualBonus = 0,
    this.commission = 0,
    this.retentionBonus = 0,
    this.joiningDate,
    this.lastWorkingDate,
    this.contractTerminationDate,
    this.dateOfLeavingWork,
    this.art49NoticeGiven,
    this.contractTerminationSameAsLastWorkingDate = false,
    this.dateOfLeavingSameAsLastWorkingDate = false,
    this.contractType = EosbContractType.unlimited,
    this.employmentCategory = EosbEmploymentCategory.fullTime,
    this.terminationType = EosbTerminationType.employerTermination,
    this.summaryDismissalGround = EosbSummaryDismissalGround.none,
    this.summaryDismissalGroundConfirmed = false,
    this.dismissalReviewSkipped = false,
    this.dismissalReviewReasonGiven,
    this.dismissalReviewMatchesArt61Ground,
    this.dismissalReviewProcessFollowed,
    this.showStandardEmployeeReference = false,
    this.noticeServed = true,
    this.noticeBuyoutAmount = 0,
    this.unusedLeaveDays = 0,
    this.unusedSickLeaveDays = 0,
    this.overtimeHours = 0,
    this.pendingSalary = 0,
    this.familySponsored = false,
    this.returnTicketIncluded = false,
    this.dependentsCount = 0,
    this.employerOffer,
    this.otherContractualBenefits = 0,
    this.storeSalaryWithConsent = false,
  });

  final String country;
  final String companyName;

  /// Deterministic aggregation key — stored on save; not a display name.
  final String normalizedEmployerKey;

  final String industry;
  final double basicSalary;

  /// Optional — user reported a mid-employment basic wage change.
  final bool basicSalaryChanged;
  final DateTime? basicSalaryChangeDate;

  final double totalSalary;
  final double housingAllowance;
  final double foodAllowance;
  final double transportAllowance;
  final double annualBonus;
  final double commission;
  final double retentionBonus;
  final DateTime? joiningDate;
  final DateTime? lastWorkingDate;

  /// Art. 67 standard branch — contract termination date (not last working day).
  final DateTime? contractTerminationDate;

  /// Art. 67 exception branch — date worker left Work.
  final DateTime? dateOfLeavingWork;

  /// Art. 49 notice given before leaving — Art. 67 branch selector only.
  final bool? art49NoticeGiven;

  /// User confirmed contract termination date equals [lastWorkingDate].
  final bool contractTerminationSameAsLastWorkingDate;

  /// User confirmed date of leaving equals [lastWorkingDate].
  final bool dateOfLeavingSameAsLastWorkingDate;

  final EosbContractType contractType;
  final EosbEmploymentCategory employmentCategory;
  final EosbTerminationType terminationType;
  final EosbSummaryDismissalGround summaryDismissalGround;
  final bool summaryDismissalGroundConfirmed;

  /// Optional dismissal review self-assessment (employer termination only).
  final bool dismissalReviewSkipped;
  final bool? dismissalReviewReasonGiven;
  final bool? dismissalReviewMatchesArt61Ground;
  final bool? dismissalReviewProcessFollowed;

  /// Part-time/freelance: user opted in to see standard-employee reference figures.
  final bool showStandardEmployeeReference;
  final bool noticeServed;
  final double noticeBuyoutAmount;
  final int unusedLeaveDays;
  final int unusedSickLeaveDays;
  final double overtimeHours;
  final double pendingSalary;
  final bool familySponsored;
  final bool returnTicketIncluded;
  final int dependentsCount;
  final double? employerOffer;
  final double otherContractualBenefits;
  final bool storeSalaryWithConsent;

  double get dailyBasicRate => basicSalary > 0 ? basicSalary / 30 : 0;

  double get dailyTotalRate =>
      totalSalary > 0 ? totalSalary / 30 : dailyBasicRate;

  double get serviceYears {
    if (joiningDate == null || lastWorkingDate == null) return 0;
    final days = lastWorkingDate!.difference(joiningDate!).inDays;
    return days / 365.25;
  }

  int get serviceDays {
    if (joiningDate == null || lastWorkingDate == null) return 0;
    return lastWorkingDate!.difference(joiningDate!).inDays;
  }

  bool get hasMinimumService => serviceYears >= 1;

  bool get isTotalSalaryInvalid =>
      totalSalary > 0 && basicSalary > 0 && totalSalary < basicSalary;

  /// Resolved key for reads — recomputes when legacy records lack stored key.
  String get effectiveNormalizedEmployerKey => normalizedEmployerKey.isNotEmpty
      ? normalizedEmployerKey
      : EmployerNameNormalizer.normalize(companyName);

  /// Call before persisting so [normalizedEmployerKey] is stored going forward.
  EosbEmployeeInput forPersistence() {
    final trimmed = companyName.trim();
    return copyWith(
      companyName: trimmed,
      normalizedEmployerKey: EmployerNameNormalizer.normalize(trimmed),
    );
  }

  EosbEmployeeInput copyWith({
    String? country,
    String? companyName,
    String? normalizedEmployerKey,
    String? industry,
    double? basicSalary,
    bool? basicSalaryChanged,
    DateTime? basicSalaryChangeDate,
    bool clearBasicSalaryChangeDate = false,
    double? totalSalary,
    double? housingAllowance,
    double? foodAllowance,
    double? transportAllowance,
    double? annualBonus,
    double? commission,
    double? retentionBonus,
    DateTime? joiningDate,
    DateTime? lastWorkingDate,
    DateTime? contractTerminationDate,
    DateTime? dateOfLeavingWork,
    bool? art49NoticeGiven,
    bool clearArt49NoticeGiven = false,
    bool? contractTerminationSameAsLastWorkingDate,
    bool? dateOfLeavingSameAsLastWorkingDate,
    bool clearContractTerminationDate = false,
    bool clearDateOfLeavingWork = false,
    EosbContractType? contractType,
    EosbEmploymentCategory? employmentCategory,
    EosbTerminationType? terminationType,
    EosbSummaryDismissalGround? summaryDismissalGround,
    bool? summaryDismissalGroundConfirmed,
    bool? dismissalReviewSkipped,
    bool? dismissalReviewReasonGiven,
    bool clearDismissalReviewReasonGiven = false,
    bool? dismissalReviewMatchesArt61Ground,
    bool clearDismissalReviewMatchesArt61Ground = false,
    bool? dismissalReviewProcessFollowed,
    bool clearDismissalReviewProcessFollowed = false,
    bool? showStandardEmployeeReference,
    bool? noticeServed,
    double? noticeBuyoutAmount,
    int? unusedLeaveDays,
    int? unusedSickLeaveDays,
    double? overtimeHours,
    double? pendingSalary,
    bool? familySponsored,
    bool? returnTicketIncluded,
    int? dependentsCount,
    double? employerOffer,
    double? otherContractualBenefits,
    bool? storeSalaryWithConsent,
    bool clearEmployerOffer = false,
  }) {
    final nextCompany = companyName ?? this.companyName;
    final nextKey = companyName != null
        ? EmployerNameNormalizer.normalize(nextCompany.trim())
        : (normalizedEmployerKey ?? this.normalizedEmployerKey);

    return EosbEmployeeInput(
      country: country ?? this.country,
      companyName: nextCompany,
      normalizedEmployerKey: nextKey,
      industry: industry ?? this.industry,
      basicSalary: basicSalary ?? this.basicSalary,
      basicSalaryChanged: basicSalaryChanged ?? this.basicSalaryChanged,
      basicSalaryChangeDate: clearBasicSalaryChangeDate
          ? null
          : (basicSalaryChangeDate ?? this.basicSalaryChangeDate),
      totalSalary: totalSalary ?? this.totalSalary,
      housingAllowance: housingAllowance ?? this.housingAllowance,
      foodAllowance: foodAllowance ?? this.foodAllowance,
      transportAllowance: transportAllowance ?? this.transportAllowance,
      annualBonus: annualBonus ?? this.annualBonus,
      commission: commission ?? this.commission,
      retentionBonus: retentionBonus ?? this.retentionBonus,
      joiningDate: joiningDate ?? this.joiningDate,
      lastWorkingDate: lastWorkingDate ?? this.lastWorkingDate,
      contractTerminationDate: clearContractTerminationDate
          ? null
          : (contractTerminationDate ?? this.contractTerminationDate),
      dateOfLeavingWork: clearDateOfLeavingWork
          ? null
          : (dateOfLeavingWork ?? this.dateOfLeavingWork),
      art49NoticeGiven: clearArt49NoticeGiven
          ? null
          : (art49NoticeGiven ?? this.art49NoticeGiven),
      contractTerminationSameAsLastWorkingDate:
          contractTerminationSameAsLastWorkingDate ??
              this.contractTerminationSameAsLastWorkingDate,
      dateOfLeavingSameAsLastWorkingDate: dateOfLeavingSameAsLastWorkingDate ??
          this.dateOfLeavingSameAsLastWorkingDate,
      contractType: contractType ?? this.contractType,
      employmentCategory: employmentCategory ?? this.employmentCategory,
      terminationType: terminationType ?? this.terminationType,
      summaryDismissalGround:
          summaryDismissalGround ?? this.summaryDismissalGround,
      summaryDismissalGroundConfirmed: summaryDismissalGroundConfirmed ??
          this.summaryDismissalGroundConfirmed,
      dismissalReviewSkipped:
          dismissalReviewSkipped ?? this.dismissalReviewSkipped,
      dismissalReviewReasonGiven: clearDismissalReviewReasonGiven
          ? null
          : (dismissalReviewReasonGiven ?? this.dismissalReviewReasonGiven),
      dismissalReviewMatchesArt61Ground: clearDismissalReviewMatchesArt61Ground
          ? null
          : (dismissalReviewMatchesArt61Ground ??
              this.dismissalReviewMatchesArt61Ground),
      dismissalReviewProcessFollowed: clearDismissalReviewProcessFollowed
          ? null
          : (dismissalReviewProcessFollowed ??
              this.dismissalReviewProcessFollowed),
      showStandardEmployeeReference: showStandardEmployeeReference ??
          this.showStandardEmployeeReference,
      noticeServed: noticeServed ?? this.noticeServed,
      noticeBuyoutAmount: noticeBuyoutAmount ?? this.noticeBuyoutAmount,
      unusedLeaveDays: unusedLeaveDays ?? this.unusedLeaveDays,
      unusedSickLeaveDays: unusedSickLeaveDays ?? this.unusedSickLeaveDays,
      overtimeHours: overtimeHours ?? this.overtimeHours,
      pendingSalary: pendingSalary ?? this.pendingSalary,
      familySponsored: familySponsored ?? this.familySponsored,
      returnTicketIncluded: returnTicketIncluded ?? this.returnTicketIncluded,
      dependentsCount: dependentsCount ?? this.dependentsCount,
      employerOffer:
          clearEmployerOffer ? null : (employerOffer ?? this.employerOffer),
      otherContractualBenefits:
          otherContractualBenefits ?? this.otherContractualBenefits,
      storeSalaryWithConsent:
          storeSalaryWithConsent ?? this.storeSalaryWithConsent,
    );
  }

  Map<String, dynamic> toJson() => {
        'country': country,
        'companyName': companyName,
        'normalizedEmployerKey': normalizedEmployerKey,
        'industry': industry,
        'basicSalary': basicSalary,
        'basicSalaryChanged': basicSalaryChanged,
        'basicSalaryChangeDate': basicSalaryChangeDate?.toIso8601String(),
        'totalSalary': totalSalary,
        'housingAllowance': housingAllowance,
        'foodAllowance': foodAllowance,
        'transportAllowance': transportAllowance,
        'annualBonus': annualBonus,
        'commission': commission,
        'retentionBonus': retentionBonus,
        'joiningDate': joiningDate?.toIso8601String(),
        'lastWorkingDate': lastWorkingDate?.toIso8601String(),
        'contractTerminationDate':
            contractTerminationDate?.toIso8601String(),
        'dateOfLeavingWork': dateOfLeavingWork?.toIso8601String(),
        'art49NoticeGiven': art49NoticeGiven,
        'contractTerminationSameAsLastWorkingDate':
            contractTerminationSameAsLastWorkingDate,
        'dateOfLeavingSameAsLastWorkingDate':
            dateOfLeavingSameAsLastWorkingDate,
        'contractType': contractType.name,
        'employmentCategory': employmentCategory.name,
        'terminationType': terminationType.name,
        'summaryDismissalGround': summaryDismissalGround.name,
        'summaryDismissalGroundConfirmed': summaryDismissalGroundConfirmed,
        'dismissalReviewSkipped': dismissalReviewSkipped,
        'dismissalReviewReasonGiven': dismissalReviewReasonGiven,
        'dismissalReviewMatchesArt61Ground': dismissalReviewMatchesArt61Ground,
        'dismissalReviewProcessFollowed': dismissalReviewProcessFollowed,
        'showStandardEmployeeReference': showStandardEmployeeReference,
        'noticeServed': noticeServed,
        'noticeBuyoutAmount': noticeBuyoutAmount,
        'unusedLeaveDays': unusedLeaveDays,
        'unusedSickLeaveDays': unusedSickLeaveDays,
        'overtimeHours': overtimeHours,
        'pendingSalary': pendingSalary,
        'familySponsored': familySponsored,
        'returnTicketIncluded': returnTicketIncluded,
        'dependentsCount': dependentsCount,
        'employerOffer': employerOffer,
        'otherContractualBenefits': otherContractualBenefits,
        'storeSalaryWithConsent': storeSalaryWithConsent,
      };

  factory EosbEmployeeInput.fromJson(Map<String, dynamic> json) {
    return EosbEmployeeInput(
      country: json['country'] as String? ?? 'Qatar',
      companyName: json['companyName'] as String? ?? '',
      normalizedEmployerKey: json['normalizedEmployerKey'] as String? ?? '',
      industry: json['industry'] as String? ?? '',
      basicSalary: (json['basicSalary'] as num?)?.toDouble() ?? 0,
      basicSalaryChanged: json['basicSalaryChanged'] as bool? ?? false,
      basicSalaryChangeDate: json['basicSalaryChangeDate'] != null
          ? DateTime.tryParse(json['basicSalaryChangeDate'] as String)
          : null,
      totalSalary: (json['totalSalary'] as num?)?.toDouble() ?? 0,
      housingAllowance: (json['housingAllowance'] as num?)?.toDouble() ?? 0,
      foodAllowance: (json['foodAllowance'] as num?)?.toDouble() ?? 0,
      transportAllowance: (json['transportAllowance'] as num?)?.toDouble() ?? 0,
      annualBonus: (json['annualBonus'] as num?)?.toDouble() ?? 0,
      commission: (json['commission'] as num?)?.toDouble() ?? 0,
      retentionBonus: (json['retentionBonus'] as num?)?.toDouble() ?? 0,
      joiningDate: json['joiningDate'] != null
          ? DateTime.tryParse(json['joiningDate'] as String)
          : null,
      lastWorkingDate: json['lastWorkingDate'] != null
          ? DateTime.tryParse(json['lastWorkingDate'] as String)
          : null,
      contractTerminationDate: json['contractTerminationDate'] != null
          ? DateTime.tryParse(json['contractTerminationDate'] as String)
          : null,
      dateOfLeavingWork: json['dateOfLeavingWork'] != null
          ? DateTime.tryParse(json['dateOfLeavingWork'] as String)
          : null,
      art49NoticeGiven: json.containsKey('art49NoticeGiven')
          ? json['art49NoticeGiven'] as bool?
          : null,
      contractTerminationSameAsLastWorkingDate:
          json['contractTerminationSameAsLastWorkingDate'] as bool? ?? false,
      dateOfLeavingSameAsLastWorkingDate:
          json['dateOfLeavingSameAsLastWorkingDate'] as bool? ?? false,
      contractType: EosbContractType.values.firstWhere(
        (e) => e.name == json['contractType'],
        orElse: () => EosbContractType.unlimited,
      ),
      employmentCategory: EosbEmploymentCategory.values.firstWhere(
        (e) => e.name == json['employmentCategory'],
        orElse: () => EosbEmploymentCategory.fullTime,
      ),
      terminationType: EosbTerminationType.values.firstWhere(
        (e) => e.name == json['terminationType'],
        orElse: () => EosbTerminationType.employerTermination,
      ),
      summaryDismissalGround: EosbSummaryDismissalGround.values.firstWhere(
        (e) => e.name == json['summaryDismissalGround'],
        orElse: () => EosbSummaryDismissalGround.none,
      ),
      summaryDismissalGroundConfirmed:
          json['summaryDismissalGroundConfirmed'] as bool? ?? false,
      dismissalReviewSkipped: json['dismissalReviewSkipped'] as bool? ??
          json['art62AssessmentSkipped'] as bool? ??
          false,
      dismissalReviewReasonGiven: _readNullableBool(
        json,
        'dismissalReviewReasonGiven',
        'art62ReasonGiven',
      ),
      dismissalReviewMatchesArt61Ground: _readNullableBool(
        json,
        'dismissalReviewMatchesArt61Ground',
        'art62MatchesArt61Ground',
      ),
      dismissalReviewProcessFollowed: _readNullableBool(
        json,
        'dismissalReviewProcessFollowed',
        'art62ProcessFollowed',
      ),
      showStandardEmployeeReference:
          json['showStandardEmployeeReference'] as bool? ?? false,
      noticeServed: json['noticeServed'] as bool? ?? true,
      noticeBuyoutAmount: (json['noticeBuyoutAmount'] as num?)?.toDouble() ?? 0,
      unusedLeaveDays: (json['unusedLeaveDays'] as num?)?.toInt() ?? 0,
      unusedSickLeaveDays: (json['unusedSickLeaveDays'] as num?)?.toInt() ?? 0,
      overtimeHours: (json['overtimeHours'] as num?)?.toDouble() ?? 0,
      pendingSalary: (json['pendingSalary'] as num?)?.toDouble() ?? 0,
      familySponsored: json['familySponsored'] as bool? ?? false,
      returnTicketIncluded: json['returnTicketIncluded'] as bool? ?? false,
      dependentsCount: (json['dependentsCount'] as num?)?.toInt() ?? 0,
      employerOffer: (json['employerOffer'] as num?)?.toDouble(),
      otherContractualBenefits:
          (json['otherContractualBenefits'] as num?)?.toDouble() ?? 0,
      storeSalaryWithConsent: json['storeSalaryWithConsent'] as bool? ?? false,
    );
  }

  static bool? _readNullableBool(
    Map<String, dynamic> json,
    String primaryKey,
    String legacyKey,
  ) {
    if (json.containsKey(primaryKey)) {
      return json[primaryKey] as bool?;
    }
    if (json.containsKey(legacyKey)) {
      return json[legacyKey] as bool?;
    }
    return null;
  }
}
