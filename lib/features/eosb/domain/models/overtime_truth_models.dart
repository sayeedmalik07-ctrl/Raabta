// Overtime Truth Engine models — calendar-based monthly records + legacy compat.

import '../rules/overtime_rules.dart';
import '../services/employer_name_normalizer.dart';

enum OvertimeDayCategory {
  regularDay,
  weeklyRestDay,
  publicHoliday,
  nightShift,
  emergencyCallOut,
  standby,
  custom,
}

enum OvertimeShiftType { normal, night }

enum OvertimeEmploymentType { permanent, temporary, contract, dailyWage }

enum OvertimeInputMode { simple, detailed, calendar }

/// Legacy category enum — kept for EOSB breakdown compatibility.
enum OvertimeRateCategory {
  weekdayExtra,
  restDay,
  publicHoliday,
  nightShift,
  emergency,
  standby,
  custom,
}

class OvertimeEmployeeProfile {
  const OvertimeEmployeeProfile({
    this.employeeName = '',
    this.employeeId = '',
    this.companyName = '',
    this.normalizedEmployerKey = '',
    this.jobTitle = '',
    this.project = '',
    this.countryCode = 'QA',
    this.employmentType = OvertimeEmploymentType.permanent,
    this.joiningDate,
    this.basicSalary = 0,
    this.totalSalary = 0,
    this.workingHoursPerDay = 8,
    this.workingDaysPerWeek = 6,
    this.monthlyWorkingDays = 26,
    this.shiftType = OvertimeShiftType.normal,
    this.currency = 'QAR',
    this.isRamadanPeriod = false,
  });

  final String employeeName;
  final String employeeId;
  final String companyName;
  final String normalizedEmployerKey;
  final String jobTitle;
  final String project;
  final String countryCode;
  final OvertimeEmploymentType employmentType;
  final DateTime? joiningDate;
  final double basicSalary;
  final double totalSalary;
  final int workingHoursPerDay;
  final int workingDaysPerWeek;
  final int monthlyWorkingDays;
  final OvertimeShiftType shiftType;
  final String currency;
  final bool isRamadanPeriod;

  String get effectiveNormalizedEmployerKey => normalizedEmployerKey.isNotEmpty
      ? normalizedEmployerKey
      : EmployerNameNormalizer.normalize(companyName);

  OvertimeEmployeeProfile forPersistence() {
    final trimmed = companyName.trim();
    return copyWith(
      companyName: trimmed,
      normalizedEmployerKey: EmployerNameNormalizer.normalize(trimmed),
    );
  }

  OvertimeEmployeeProfile copyWith({
    String? employeeName,
    String? employeeId,
    String? companyName,
    String? normalizedEmployerKey,
    String? jobTitle,
    String? project,
    String? countryCode,
    OvertimeEmploymentType? employmentType,
    DateTime? joiningDate,
    double? basicSalary,
    double? totalSalary,
    int? workingHoursPerDay,
    int? workingDaysPerWeek,
    int? monthlyWorkingDays,
    OvertimeShiftType? shiftType,
    String? currency,
    bool? isRamadanPeriod,
  }) {
    final nextCompany = companyName ?? this.companyName;
    final nextKey = companyName != null
        ? EmployerNameNormalizer.normalize(nextCompany.trim())
        : (normalizedEmployerKey ?? this.normalizedEmployerKey);

    return OvertimeEmployeeProfile(
      employeeName: employeeName ?? this.employeeName,
      employeeId: employeeId ?? this.employeeId,
      companyName: nextCompany,
      normalizedEmployerKey: nextKey,
      jobTitle: jobTitle ?? this.jobTitle,
      project: project ?? this.project,
      countryCode: countryCode ?? this.countryCode,
      employmentType: employmentType ?? this.employmentType,
      joiningDate: joiningDate ?? this.joiningDate,
      basicSalary: basicSalary ?? this.basicSalary,
      totalSalary: totalSalary ?? this.totalSalary,
      workingHoursPerDay: workingHoursPerDay ?? this.workingHoursPerDay,
      workingDaysPerWeek: workingDaysPerWeek ?? this.workingDaysPerWeek,
      monthlyWorkingDays: monthlyWorkingDays ?? this.monthlyWorkingDays,
      shiftType: shiftType ?? this.shiftType,
      currency: currency ?? this.currency,
      isRamadanPeriod: isRamadanPeriod ?? this.isRamadanPeriod,
    );
  }

  Map<String, dynamic> toJson() => {
        'employeeName': employeeName,
        'employeeId': employeeId,
        'companyName': companyName,
        'normalizedEmployerKey': normalizedEmployerKey,
        'jobTitle': jobTitle,
        'project': project,
        'countryCode': countryCode,
        'employmentType': employmentType.name,
        'joiningDate': joiningDate?.toIso8601String(),
        'basicSalary': basicSalary,
        'totalSalary': totalSalary,
        'workingHoursPerDay': workingHoursPerDay,
        'workingDaysPerWeek': workingDaysPerWeek,
        'monthlyWorkingDays': monthlyWorkingDays,
        'shiftType': shiftType.name,
        'currency': currency,
        'isRamadanPeriod': isRamadanPeriod,
      };

  factory OvertimeEmployeeProfile.fromJson(Map<String, dynamic> json) {
    return OvertimeEmployeeProfile(
      employeeName: json['employeeName'] as String? ?? '',
      employeeId: json['employeeId'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      normalizedEmployerKey: json['normalizedEmployerKey'] as String? ?? '',
      jobTitle: json['jobTitle'] as String? ?? '',
      project: json['project'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? 'QA',
      employmentType: OvertimeEmploymentType.values.firstWhere(
        (e) => e.name == json['employmentType'],
        orElse: () => OvertimeEmploymentType.permanent,
      ),
      joiningDate: json['joiningDate'] != null
          ? DateTime.tryParse(json['joiningDate'] as String)
          : null,
      basicSalary: (json['basicSalary'] as num?)?.toDouble() ?? 0,
      totalSalary: (json['totalSalary'] as num?)?.toDouble() ?? 0,
      workingHoursPerDay: (json['workingHoursPerDay'] as num?)?.toInt() ?? 8,
      workingDaysPerWeek: (json['workingDaysPerWeek'] as num?)?.toInt() ?? 6,
      monthlyWorkingDays: (json['monthlyWorkingDays'] as num?)?.toInt() ?? 26,
      shiftType: OvertimeShiftType.values.firstWhere(
        (e) => e.name == json['shiftType'],
        orElse: () => OvertimeShiftType.normal,
      ),
      currency: json['currency'] as String? ?? 'QAR',
      isRamadanPeriod: json['isRamadanPeriod'] as bool? ?? false,
    );
  }
}

class OvertimeDayEntry {
  const OvertimeDayEntry({
    required this.date,
    this.dayCategory = OvertimeDayCategory.regularDay,
    this.shiftType = OvertimeShiftType.normal,
    this.overtimeHours = 0,
    this.overtimeMinutes = 0,
    this.notes = '',
    this.holidayName = '',
    this.userLoggedStartTime,
    this.userLoggedEndTime,
    this.employerReportedStartTime,
    this.employerReportedEndTime,
  });

  final DateTime date;
  final OvertimeDayCategory dayCategory;
  final OvertimeShiftType shiftType;
  final int overtimeHours;
  final int overtimeMinutes;
  final String notes;
  final String holidayName;

  /// User shift clock times (`HH:mm`) for rounding analysis — separate from OT hours.
  final String? userLoggedStartTime;
  final String? userLoggedEndTime;

  /// Employer-recorded shift clock times (`HH:mm`) for the same date.
  final String? employerReportedStartTime;
  final String? employerReportedEndTime;

  double get totalHours => overtimeHours + overtimeMinutes / 60.0;

  bool get hasUserShiftTimes =>
      _isValidTime(userLoggedStartTime) && _isValidTime(userLoggedEndTime);

  bool get hasEmployerShiftTimes =>
      _isValidTime(employerReportedStartTime) &&
      _isValidTime(employerReportedEndTime);

  bool get hasDualShiftTimes => hasUserShiftTimes && hasEmployerShiftTimes;

  static bool _isValidTime(String? value) =>
      value != null && value.contains(':') && value.trim().length >= 4;

  String get dayName {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[date.weekday - 1];
  }

  OvertimeDayEntry copyWith({
    DateTime? date,
    OvertimeDayCategory? dayCategory,
    OvertimeShiftType? shiftType,
    int? overtimeHours,
    int? overtimeMinutes,
    String? notes,
    String? holidayName,
    String? userLoggedStartTime,
    String? userLoggedEndTime,
    String? employerReportedStartTime,
    String? employerReportedEndTime,
    bool clearUserShiftTimes = false,
    bool clearEmployerShiftTimes = false,
  }) {
    return OvertimeDayEntry(
      date: date ?? this.date,
      dayCategory: dayCategory ?? this.dayCategory,
      shiftType: shiftType ?? this.shiftType,
      overtimeHours: overtimeHours ?? this.overtimeHours,
      overtimeMinutes: overtimeMinutes ?? this.overtimeMinutes,
      notes: notes ?? this.notes,
      holidayName: holidayName ?? this.holidayName,
      userLoggedStartTime: clearUserShiftTimes
          ? null
          : (userLoggedStartTime ?? this.userLoggedStartTime),
      userLoggedEndTime: clearUserShiftTimes
          ? null
          : (userLoggedEndTime ?? this.userLoggedEndTime),
      employerReportedStartTime: clearEmployerShiftTimes
          ? null
          : (employerReportedStartTime ?? this.employerReportedStartTime),
      employerReportedEndTime: clearEmployerShiftTimes
          ? null
          : (employerReportedEndTime ?? this.employerReportedEndTime),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'dayCategory': dayCategory.name,
        'shiftType': shiftType.name,
        'overtimeHours': overtimeHours,
        'overtimeMinutes': overtimeMinutes,
        'notes': notes,
        'holidayName': holidayName,
        if (userLoggedStartTime != null)
          'userLoggedStartTime': userLoggedStartTime,
        if (userLoggedEndTime != null) 'userLoggedEndTime': userLoggedEndTime,
        if (employerReportedStartTime != null)
          'employerReportedStartTime': employerReportedStartTime,
        if (employerReportedEndTime != null)
          'employerReportedEndTime': employerReportedEndTime,
      };

  factory OvertimeDayEntry.fromJson(Map<String, dynamic> json) {
    return OvertimeDayEntry(
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      dayCategory: OvertimeDayCategory.values.firstWhere(
        (e) => e.name == json['dayCategory'],
        orElse: () => OvertimeDayCategory.regularDay,
      ),
      shiftType: OvertimeShiftType.values.firstWhere(
        (e) => e.name == json['shiftType'],
        orElse: () => OvertimeShiftType.normal,
      ),
      overtimeHours: (json['overtimeHours'] as num?)?.toInt() ?? 0,
      overtimeMinutes: (json['overtimeMinutes'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String? ?? '',
      holidayName: json['holidayName'] as String? ?? '',
      userLoggedStartTime: json['userLoggedStartTime'] as String?,
      userLoggedEndTime: json['userLoggedEndTime'] as String?,
      employerReportedStartTime: json['employerReportedStartTime'] as String?,
      employerReportedEndTime: json['employerReportedEndTime'] as String?,
    );
  }
}

class OvertimeMonthlyRecord {
  const OvertimeMonthlyRecord({
    required this.id,
    required this.year,
    required this.month,
    this.profile = const OvertimeEmployeeProfile(),
    this.days = const [],
    this.employerPaidOvertime = 0,
    this.employerReportedHours = 0,
    this.isFavorite = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final int year;
  final int month;
  final OvertimeEmployeeProfile profile;
  final List<OvertimeDayEntry> days;
  final double employerPaidOvertime;
  final double employerReportedHours;
  final bool isFavorite;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DateTime get periodStart => DateTime(year, month);
  DateTime get periodEnd => DateTime(year, month + 1, 0);

  String get label => '${_monthName(month)} $year';

  static String _monthName(int m) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return names[m - 1];
  }

  OvertimeMonthlyRecord copyWith({
    String? id,
    int? year,
    int? month,
    OvertimeEmployeeProfile? profile,
    List<OvertimeDayEntry>? days,
    double? employerPaidOvertime,
    double? employerReportedHours,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OvertimeMonthlyRecord(
      id: id ?? this.id,
      year: year ?? this.year,
      month: month ?? this.month,
      profile: profile ?? this.profile,
      days: days ?? this.days,
      employerPaidOvertime: employerPaidOvertime ?? this.employerPaidOvertime,
      employerReportedHours:
          employerReportedHours ?? this.employerReportedHours,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'year': year,
        'month': month,
        'profile': profile.toJson(),
        'days': days.map((d) => d.toJson()).toList(),
        'employerPaidOvertime': employerPaidOvertime,
        'employerReportedHours': employerReportedHours,
        'isFavorite': isFavorite,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory OvertimeMonthlyRecord.fromJson(Map<String, dynamic> json) {
    return OvertimeMonthlyRecord(
      id: json['id'] as String? ?? '',
      year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
      month: (json['month'] as num?)?.toInt() ?? DateTime.now().month,
      profile: OvertimeEmployeeProfile.fromJson(
        json['profile'] as Map<String, dynamic>? ?? {},
      ),
      days: (json['days'] as List<dynamic>? ?? [])
          .map((e) => OvertimeDayEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      employerPaidOvertime:
          (json['employerPaidOvertime'] as num?)?.toDouble() ?? 0,
      employerReportedHours:
          (json['employerReportedHours'] as num?)?.toDouble() ?? 0,
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  static OvertimeMonthlyRecord emptyForMonth(int year, int month) {
    final lastDay = DateTime(year, month + 1, 0).day;
    final entries = List.generate(
      lastDay,
      (i) => OvertimeDayEntry(date: DateTime(year, month, i + 1)),
    );
    return OvertimeMonthlyRecord(
      id: '${year}_${month}_${DateTime.now().millisecondsSinceEpoch}',
      year: year,
      month: month,
      days: entries,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Ensures every day of the month exists — merges any saved partial entries.
  OvertimeMonthlyRecord withFullMonthDays() {
    final lastDay = DateTime(year, month + 1, 0).day;
    if (days.length == lastDay) return this;

    final byDay = <int, OvertimeDayEntry>{};
    for (final day in days) {
      byDay[day.date.day] = day;
    }

    final fullDays = List.generate(
      lastDay,
      (i) => byDay[i + 1] ?? OvertimeDayEntry(date: DateTime(year, month, i + 1)),
    );

    return copyWith(days: fullDays);
  }

  OvertimeMonthlyRecord forPersistence() {
    return copyWith(profile: profile.forPersistence());
  }
}

/// Legacy input — preserved for backward compatibility with cached data.
class OvertimeTruthInput {
  const OvertimeTruthInput({
    this.companyName = '',
    this.normalizedEmployerKey = '',
    this.basicSalary = 0,
    this.periodStart,
    this.periodEnd,
    this.workingDaysPerWeek = 6,
    this.standardHoursPerDay = 8,
    this.isRamadanPeriod = false,
    this.inputMode = OvertimeInputMode.simple,
    this.totalHoursWorked = 0,
    this.weekdayOvertimeHours = 0,
    this.restDayHours = 0,
    this.publicHolidayHours = 0,
    this.employerPaidOvertime = 0,
    this.employerReportedOvertimeHours = 0,
    this.notes = '',
    this.record,
  });

  final String companyName;
  final String normalizedEmployerKey;
  final double basicSalary;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final int workingDaysPerWeek;
  final int standardHoursPerDay;
  final bool isRamadanPeriod;
  final OvertimeInputMode inputMode;
  final double totalHoursWorked;
  final double weekdayOvertimeHours;
  final double restDayHours;
  final double publicHolidayHours;
  final double employerPaidOvertime;
  final double employerReportedOvertimeHours;
  final String notes;
  final OvertimeMonthlyRecord? record;

  int get effectiveStandardHoursPerDay =>
      isRamadanPeriod ? 6 : standardHoursPerDay;

  int get periodDays {
    if (periodStart == null || periodEnd == null) return 30;
    return periodEnd!.difference(periodStart!).inDays + 1;
  }

  double get hourlyRate => basicSalary > 0 ? basicSalary / 30 / 8 : 0;

  String get effectiveNormalizedEmployerKey => normalizedEmployerKey.isNotEmpty
      ? normalizedEmployerKey
      : EmployerNameNormalizer.normalize(companyName);

  OvertimeTruthInput forPersistence() {
    final trimmed = companyName.trim();
    final key = EmployerNameNormalizer.normalize(trimmed);
    final persistedRecord = record?.copyWith(
      profile: record!.profile.copyWith(
        companyName: trimmed,
        normalizedEmployerKey: key,
      ),
    );
    return copyWith(
      companyName: trimmed,
      normalizedEmployerKey: key,
      record: persistedRecord ?? record,
    );
  }

  OvertimeTruthInput copyWith({
    String? companyName,
    String? normalizedEmployerKey,
    double? basicSalary,
    DateTime? periodStart,
    DateTime? periodEnd,
    int? workingDaysPerWeek,
    int? standardHoursPerDay,
    bool? isRamadanPeriod,
    OvertimeInputMode? inputMode,
    double? totalHoursWorked,
    double? weekdayOvertimeHours,
    double? restDayHours,
    double? publicHolidayHours,
    double? employerPaidOvertime,
    double? employerReportedOvertimeHours,
    String? notes,
    OvertimeMonthlyRecord? record,
  }) {
    final nextCompany = companyName ?? this.companyName;
    final nextKey = companyName != null
        ? EmployerNameNormalizer.normalize(nextCompany.trim())
        : (normalizedEmployerKey ?? this.normalizedEmployerKey);

    return OvertimeTruthInput(
      companyName: nextCompany,
      normalizedEmployerKey: nextKey,
      basicSalary: basicSalary ?? this.basicSalary,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      workingDaysPerWeek: workingDaysPerWeek ?? this.workingDaysPerWeek,
      standardHoursPerDay: standardHoursPerDay ?? this.standardHoursPerDay,
      isRamadanPeriod: isRamadanPeriod ?? this.isRamadanPeriod,
      inputMode: inputMode ?? this.inputMode,
      totalHoursWorked: totalHoursWorked ?? this.totalHoursWorked,
      weekdayOvertimeHours: weekdayOvertimeHours ?? this.weekdayOvertimeHours,
      restDayHours: restDayHours ?? this.restDayHours,
      publicHolidayHours: publicHolidayHours ?? this.publicHolidayHours,
      employerPaidOvertime: employerPaidOvertime ?? this.employerPaidOvertime,
      employerReportedOvertimeHours:
          employerReportedOvertimeHours ?? this.employerReportedOvertimeHours,
      notes: notes ?? this.notes,
      record: record ?? this.record,
    );
  }

  Map<String, dynamic> toJson() => {
        'companyName': companyName,
        'normalizedEmployerKey': normalizedEmployerKey,
        'basicSalary': basicSalary,
        'periodStart': periodStart?.toIso8601String(),
        'periodEnd': periodEnd?.toIso8601String(),
        'workingDaysPerWeek': workingDaysPerWeek,
        'standardHoursPerDay': standardHoursPerDay,
        'isRamadanPeriod': isRamadanPeriod,
        'inputMode': inputMode.name,
        'totalHoursWorked': totalHoursWorked,
        'weekdayOvertimeHours': weekdayOvertimeHours,
        'restDayHours': restDayHours,
        'publicHolidayHours': publicHolidayHours,
        'employerPaidOvertime': employerPaidOvertime,
        'employerReportedOvertimeHours': employerReportedOvertimeHours,
        'notes': notes,
        if (record != null) 'record': record!.toJson(),
      };

  factory OvertimeTruthInput.fromJson(Map<String, dynamic> json) {
    return OvertimeTruthInput(
      companyName: json['companyName'] as String? ?? '',
      normalizedEmployerKey: json['normalizedEmployerKey'] as String? ?? '',
      basicSalary: (json['basicSalary'] as num?)?.toDouble() ?? 0,
      periodStart: json['periodStart'] != null
          ? DateTime.tryParse(json['periodStart'] as String)
          : null,
      periodEnd: json['periodEnd'] != null
          ? DateTime.tryParse(json['periodEnd'] as String)
          : null,
      workingDaysPerWeek: (json['workingDaysPerWeek'] as num?)?.toInt() ?? 6,
      standardHoursPerDay: (json['standardHoursPerDay'] as num?)?.toInt() ?? 8,
      isRamadanPeriod: json['isRamadanPeriod'] as bool? ?? false,
      inputMode: OvertimeInputMode.values.firstWhere(
        (e) => e.name == json['inputMode'],
        orElse: () => OvertimeInputMode.simple,
      ),
      totalHoursWorked: (json['totalHoursWorked'] as num?)?.toDouble() ?? 0,
      weekdayOvertimeHours:
          (json['weekdayOvertimeHours'] as num?)?.toDouble() ?? 0,
      restDayHours: (json['restDayHours'] as num?)?.toDouble() ?? 0,
      publicHolidayHours:
          (json['publicHolidayHours'] as num?)?.toDouble() ?? 0,
      employerPaidOvertime:
          (json['employerPaidOvertime'] as num?)?.toDouble() ?? 0,
      employerReportedOvertimeHours:
          (json['employerReportedOvertimeHours'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String? ?? '',
      record: json['record'] != null
          ? OvertimeMonthlyRecord.fromJson(
              json['record'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class OvertimeLineItem {
  const OvertimeLineItem({
    required this.category,
    required this.hours,
    required this.rateMultiplier,
    required this.hourlyRate,
    required this.amount,
    required this.ruleKey,
    required this.formulaKey,
    this.dayCategory = OvertimeDayCategory.regularDay,
    this.articleRef = '',
  });

  final OvertimeRateCategory category;
  final OvertimeDayCategory dayCategory;
  final double hours;
  final double rateMultiplier;
  final double hourlyRate;
  final double amount;
  final String ruleKey;
  final String formulaKey;
  final String articleRef;
}

class OvertimeMonthlySummary {
  const OvertimeMonthlySummary({
    required this.regularDayHours,
    required this.restDayHours,
    required this.holidayHours,
    required this.nightHours,
    required this.emergencyHours,
    required this.standbyHours,
    required this.customHours,
    required this.totalHours,
    required this.totalPayment,
    required this.averageDailyOvertime,
    required this.highestDay,
    required this.lowestDay,
    required this.workingDaysRecorded,
    required this.missingDays,
    required this.weeklyTotals,
    required this.dailyTotals,
  });

  final double regularDayHours;
  final double restDayHours;
  final double holidayHours;
  final double nightHours;
  final double emergencyHours;
  final double standbyHours;
  final double customHours;
  final double totalHours;
  final double totalPayment;
  final double averageDailyOvertime;
  final OvertimeDayEntry? highestDay;
  final OvertimeDayEntry? lowestDay;
  final int workingDaysRecorded;
  final int missingDays;
  final List<double> weeklyTotals;
  final List<double> dailyTotals;
}

class OvertimeAlert {
  const OvertimeAlert({
    required this.severity,
    required this.titleKey,
    required this.bodyKey,
  });

  final String severity;
  final String titleKey;
  final String bodyKey;
}

class OvertimeValidationIssue {
  const OvertimeValidationIssue({
    required this.fieldKey,
    required this.messageKey,
  });

  final String fieldKey;
  final String messageKey;
}

class OvertimeEmployerComparison {
  const OvertimeEmployerComparison({
    required this.legalOwed,
    required this.employerPaid,
    required this.unpaidGap,
    required this.isUnderpaid,
    required this.isOverpaid,
    required this.paymentCoveragePercent,
    required this.percentDifference,
    required this.hoursGap,
    required this.confidenceNoteKey,
  });

  final double legalOwed;
  final double employerPaid;
  final double unpaidGap;
  final bool isUnderpaid;
  final bool isOverpaid;
  final double paymentCoveragePercent;
  final double percentDifference;
  final double hoursGap;
  final String confidenceNoteKey;
}

class OvertimeAiReview {
  const OvertimeAiReview({
    required this.summary,
    required this.missingPayments,
    required this.potentialErrors,
    required this.calculationExplanation,
    required this.questionsForEmployer,
    required this.payrollTips,
    required this.nextSteps,
    required this.confidence,
  });

  final String summary;
  final List<String> missingPayments;
  final List<String> potentialErrors;
  final String calculationExplanation;
  final List<String> questionsForEmployer;
  final List<String> payrollTips;
  final List<String> nextSteps;
  final double confidence;

  factory OvertimeAiReview.fromJson(Map<String, dynamic> json) {
    return OvertimeAiReview(
      summary: json['summary'] as String? ?? '',
      missingPayments: List<String>.from(json['missingPayments'] ?? []),
      potentialErrors: List<String>.from(json['potentialErrors'] ?? []),
      calculationExplanation: json['calculationExplanation'] as String? ?? '',
      questionsForEmployer:
          List<String>.from(json['questionsForEmployer'] ?? []),
      payrollTips: List<String>.from(json['payrollTips'] ?? []),
      nextSteps: List<String>.from(json['nextSteps'] ?? []),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.7,
    );
  }

  Map<String, dynamic> toJson() => {
        'summary': summary,
        'missingPayments': missingPayments,
        'potentialErrors': potentialErrors,
        'calculationExplanation': calculationExplanation,
        'questionsForEmployer': questionsForEmployer,
        'payrollTips': payrollTips,
        'nextSteps': nextSteps,
        'confidence': confidence,
      };
}

class OvertimeTruthResult {
  const OvertimeTruthResult({
    required this.record,
    required this.input,
    required this.lineItems,
    required this.summary,
    required this.rateBreakdown,
    required this.totalOvertimeHours,
    required this.totalLegalOwed,
    required this.comparison,
    required this.alerts,
    required this.validationIssues,
    required this.confidenceScore,
    required this.calculatedAt,
    required this.standardHoursInPeriod,
    required this.weeklyAverageHours,
    required this.statusKey,
  });

  final OvertimeMonthlyRecord record;
  final OvertimeTruthInput input;
  final List<OvertimeLineItem> lineItems;
  final OvertimeMonthlySummary summary;
  final OvertimeRateBreakdown rateBreakdown;
  final double totalOvertimeHours;
  final double totalLegalOwed;
  final OvertimeEmployerComparison comparison;
  final List<OvertimeAlert> alerts;
  final List<OvertimeValidationIssue> validationIssues;
  final int confidenceScore;
  final DateTime calculatedAt;
  final double standardHoursInPeriod;
  final double weeklyAverageHours;
  final String statusKey;

  Map<String, dynamic> toJson() => {
        'record': record.toJson(),
        'totalOvertimeHours': totalOvertimeHours,
        'totalLegalOwed': totalLegalOwed,
        'employerPaid': comparison.employerPaid,
        'unpaidGap': comparison.unpaidGap,
        'confidenceScore': confidenceScore,
        'calculatedAt': calculatedAt.toIso8601String(),
      };
}
