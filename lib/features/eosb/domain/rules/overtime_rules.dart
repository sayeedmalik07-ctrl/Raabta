import '../models/overtime_truth_models.dart';

/// Configurable overtime rate rule — UI reads labels, engine reads multipliers.
class OvertimeRateRule {
  const OvertimeRateRule({
    required this.id,
    required this.multiplier,
    required this.labelKey,
    required this.ruleKey,
    required this.formulaKey,
    this.articleRef = '',
  });

  final String id;
  final double multiplier;
  final String labelKey;
  final String ruleKey;
  final String formulaKey;
  final String articleRef;
}

/// Country-level overtime configuration. Rates live here, not in UI.
class OvertimeCountryRules {
  const OvertimeCountryRules({
    required this.countryCode,
    required this.countryName,
    required this.currency,
    required this.hourlyDivisorDays,
    required this.hourlyDivisorHours,
    required this.maxWeeklyHours,
    required this.standardHoursPerDay,
    required this.ramadanHoursPerDay,
    required this.categories,
    this.isPreview = false,
  });

  final String countryCode;
  final String countryName;
  final String currency;
  final int hourlyDivisorDays;
  final int hourlyDivisorHours;
  final int maxWeeklyHours;
  final int standardHoursPerDay;
  final int ramadanHoursPerDay;
  final Map<OvertimeDayCategory, OvertimeRateRule> categories;
  final bool isPreview;

  OvertimeRateRule ruleFor(OvertimeDayCategory category) =>
      categories[category] ?? categories[OvertimeDayCategory.regularDay]!;

  double hourlyRateFromBasic(double basicSalary) {
    if (basicSalary <= 0) return 0;
    return basicSalary / hourlyDivisorDays / hourlyDivisorHours;
  }

  double hourlyRateFromProfile(OvertimeEmployeeProfile profile) {
    if (profile.basicSalary <= 0) return 0;
    final days = profile.monthlyWorkingDays > 0
        ? profile.monthlyWorkingDays
        : hourlyDivisorDays;
    final hours = profile.workingHoursPerDay > 0
        ? profile.workingHoursPerDay
        : hourlyDivisorHours;
    return profile.basicSalary / days / hours;
  }

  int effectiveWorkingHoursPerDay(OvertimeEmployeeProfile profile) =>
      profile.isRamadanPeriod ? ramadanHoursPerDay : profile.workingHoursPerDay;

  double dailyRateFromBasic(double basicSalary) =>
      hourlyRateFromBasic(basicSalary) * standardHoursPerDay;

  double minuteRateFromBasic(double basicSalary) =>
      hourlyRateFromBasic(basicSalary) / 60;
}

/// Registry of country rules — add GCC countries without UI changes.
abstract final class OvertimeRulesRegistry {
  static const qatar = OvertimeCountryRules(
    countryCode: 'QA',
    countryName: 'Qatar',
    currency: 'QAR',
    hourlyDivisorDays: 30,
    hourlyDivisorHours: 8,
    maxWeeklyHours: 48,
    standardHoursPerDay: 8,
    ramadanHoursPerDay: 6,
    categories: {
      OvertimeDayCategory.regularDay: OvertimeRateRule(
        id: 'weekday_extra',
        multiplier: 1.25,
        labelKey: 'ot_cat_weekday',
        ruleKey: 'ot_rule_weekday',
        formulaKey: 'ot_formula_weekday',
        articleRef: 'Law 14/2004 Art. 74',
      ),
      OvertimeDayCategory.weeklyRestDay: OvertimeRateRule(
        id: 'rest_day',
        multiplier: 1.50,
        labelKey: 'ot_cat_restday',
        ruleKey: 'ot_rule_restday',
        formulaKey: 'ot_formula_restday',
        articleRef: 'Law 14/2004 Art. 78',
      ),
      OvertimeDayCategory.publicHoliday: OvertimeRateRule(
        id: 'public_holiday',
        multiplier: 1.50,
        labelKey: 'ot_cat_holiday',
        ruleKey: 'ot_rule_holiday',
        formulaKey: 'ot_formula_holiday',
        articleRef: 'Law 14/2004',
      ),
      OvertimeDayCategory.nightShift: OvertimeRateRule(
        id: 'night_shift',
        multiplier: 1.25,
        labelKey: 'ot_cat_night',
        ruleKey: 'ot_rule_night',
        formulaKey: 'ot_formula_night',
        articleRef: 'Contract / MoL',
      ),
      OvertimeDayCategory.emergencyCallOut: OvertimeRateRule(
        id: 'emergency',
        multiplier: 1.50,
        labelKey: 'ot_cat_emergency',
        ruleKey: 'ot_rule_emergency',
        formulaKey: 'ot_formula_emergency',
        articleRef: 'Contract',
      ),
      OvertimeDayCategory.standby: OvertimeRateRule(
        id: 'standby',
        multiplier: 1.00,
        labelKey: 'ot_cat_standby',
        ruleKey: 'ot_rule_standby',
        formulaKey: 'ot_formula_standby',
        articleRef: 'Contract',
      ),
      OvertimeDayCategory.custom: OvertimeRateRule(
        id: 'custom',
        multiplier: 1.25,
        labelKey: 'ot_cat_custom',
        ruleKey: 'ot_rule_custom',
        formulaKey: 'ot_formula_custom',
        articleRef: 'Company policy',
      ),
    },
  );

  /// Placeholder rules — same structure, rates TBD per country labour law.
  static const uae = OvertimeCountryRules(
    countryCode: 'AE',
    countryName: 'United Arab Emirates',
    currency: 'AED',
    hourlyDivisorDays: 30,
    hourlyDivisorHours: 8,
    maxWeeklyHours: 48,
    standardHoursPerDay: 8,
    ramadanHoursPerDay: 6,
    isPreview: true,
    categories: {
      OvertimeDayCategory.regularDay: OvertimeRateRule(
        id: 'weekday_extra',
        multiplier: 1.25,
        labelKey: 'ot_cat_weekday',
        ruleKey: 'ot_rule_weekday',
        formulaKey: 'ot_formula_weekday',
      ),
      OvertimeDayCategory.weeklyRestDay: OvertimeRateRule(
        id: 'rest_day',
        multiplier: 1.50,
        labelKey: 'ot_cat_restday',
        ruleKey: 'ot_rule_restday',
        formulaKey: 'ot_formula_restday',
      ),
      OvertimeDayCategory.publicHoliday: OvertimeRateRule(
        id: 'public_holiday',
        multiplier: 1.50,
        labelKey: 'ot_cat_holiday',
        ruleKey: 'ot_rule_holiday',
        formulaKey: 'ot_formula_holiday',
      ),
      OvertimeDayCategory.nightShift: OvertimeRateRule(
        id: 'night_shift',
        multiplier: 1.25,
        labelKey: 'ot_cat_night',
        ruleKey: 'ot_rule_night',
        formulaKey: 'ot_formula_night',
      ),
      OvertimeDayCategory.emergencyCallOut: OvertimeRateRule(
        id: 'emergency',
        multiplier: 1.50,
        labelKey: 'ot_cat_emergency',
        ruleKey: 'ot_rule_emergency',
        formulaKey: 'ot_formula_emergency',
      ),
      OvertimeDayCategory.standby: OvertimeRateRule(
        id: 'standby',
        multiplier: 1.00,
        labelKey: 'ot_cat_standby',
        ruleKey: 'ot_rule_standby',
        formulaKey: 'ot_formula_standby',
      ),
      OvertimeDayCategory.custom: OvertimeRateRule(
        id: 'custom',
        multiplier: 1.25,
        labelKey: 'ot_cat_custom',
        ruleKey: 'ot_rule_custom',
        formulaKey: 'ot_formula_custom',
      ),
    },
  );

  static const saudiArabia = uae;
  static const kuwait = uae;
  static const bahrain = uae;
  static const oman = uae;

  static OvertimeCountryRules forCountry(String code) {
    switch (code.toUpperCase()) {
      case 'QA':
      case 'QATAR':
        return qatar;
      case 'AE':
      case 'UAE':
        return uae;
      case 'SA':
      case 'KSA':
        return saudiArabia;
      case 'KW':
        return kuwait;
      case 'BH':
        return bahrain;
      case 'OM':
        return oman;
      default:
        return qatar;
    }
  }

  static List<OvertimeCountryRules> get all => [
        qatar,
        uae,
        saudiArabia,
        kuwait,
        bahrain,
        oman,
      ];
}

/// Step-by-step rate derivation for transparency.
class OvertimeRateBreakdown {
  const OvertimeRateBreakdown({
    required this.basicSalary,
    required this.hourlyRate,
    required this.dailyRate,
    required this.minuteRate,
    required this.steps,
  });

  final double basicSalary;
  final double hourlyRate;
  final double dailyRate;
  final double minuteRate;
  final List<String> steps;

  factory OvertimeRateBreakdown.fromRules({
    required OvertimeCountryRules rules,
    required double basicSalary,
    OvertimeEmployeeProfile? profile,
  }) {
    final hourly = profile != null
        ? rules.hourlyRateFromProfile(profile)
        : rules.hourlyRateFromBasic(basicSalary);
    final effectiveHours = profile != null
        ? rules.effectiveWorkingHoursPerDay(profile)
        : rules.standardHoursPerDay;
    final divisorDays = profile != null && profile.monthlyWorkingDays > 0
        ? profile.monthlyWorkingDays
        : rules.hourlyDivisorDays;
    final divisorHours = profile != null && profile.workingHoursPerDay > 0
        ? profile.workingHoursPerDay
        : rules.hourlyDivisorHours;
    final daily = hourly * effectiveHours;
    final minute = hourly / 60;
    return OvertimeRateBreakdown(
      basicSalary: basicSalary,
      hourlyRate: hourly,
      dailyRate: daily,
      minuteRate: minute,
      steps: [
        'Basic salary: ${rules.currency} ${basicSalary.toStringAsFixed(0)}',
        'Hourly = basic ÷ $divisorDays ÷ $divisorHours '
            '= ${hourly.toStringAsFixed(2)}',
        'Daily = hourly × $effectiveHours = ${daily.toStringAsFixed(2)}',
        'Minute = hourly ÷ 60 = ${minute.toStringAsFixed(4)}',
      ],
    );
  }
}
