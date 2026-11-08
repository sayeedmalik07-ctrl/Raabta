/// Optional, consent-gated advanced profile — personalization signals only.
///
/// Not required for any app feature. Excluded: marital status, dependents,
/// exact salary, employer name, family/health free text (PDPPL scope).
class AdvancedProfile {
  const AdvancedProfile({
    this.jobTitle,
    this.industry,
    this.educationLevel,
    this.salaryComparisonRange,
  });

  final String? jobTitle;
  final String? industry;
  final String? educationLevel;
  final String? salaryComparisonRange;

  bool get hasAnyField =>
      isSet(jobTitle) ||
      isSet(industry) ||
      isSet(educationLevel) ||
      isSet(salaryComparisonRange);

  int get filledFieldCount {
    var count = 0;
    if (isSet(jobTitle)) count++;
    if (isSet(industry)) count++;
    if (isSet(educationLevel)) count++;
    if (isSet(salaryComparisonRange)) count++;
    return count;
  }

  AdvancedProfile copyWith({
    String? jobTitle,
    String? industry,
    String? educationLevel,
    String? salaryComparisonRange,
    bool clearJobTitle = false,
    bool clearIndustry = false,
    bool clearEducationLevel = false,
    bool clearSalaryComparisonRange = false,
  }) {
    return AdvancedProfile(
      jobTitle: clearJobTitle ? null : (jobTitle ?? this.jobTitle),
      industry: clearIndustry ? null : (industry ?? this.industry),
      educationLevel:
          clearEducationLevel ? null : (educationLevel ?? this.educationLevel),
      salaryComparisonRange: clearSalaryComparisonRange
          ? null
          : (salaryComparisonRange ?? this.salaryComparisonRange),
    );
  }

  Map<String, dynamic> toJson() => {
        if (isSet(jobTitle)) 'jobTitle': jobTitle!.trim(),
        if (isSet(industry)) 'industry': industry!.trim(),
        if (isSet(educationLevel)) 'educationLevel': educationLevel!.trim(),
        if (isSet(salaryComparisonRange))
          'salaryComparisonRange': salaryComparisonRange!.trim(),
      };

  factory AdvancedProfile.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return const AdvancedProfile();
    return AdvancedProfile(
      jobTitle: json['jobTitle'] as String?,
      industry: json['industry'] as String?,
      educationLevel: json['educationLevel'] as String?,
      salaryComparisonRange: json['salaryComparisonRange'] as String?,
    );
  }

  static bool isSet(String? value) =>
      value != null && value.trim().isNotEmpty;
}

/// Stable keys for education dropdown — not display labels.
abstract final class AdvancedEducationLevel {
  static const highSchool = 'high_school';
  static const diploma = 'diploma';
  static const bachelors = 'bachelors';
  static const masters = 'masters';
  static const doctorate = 'doctorate';
  static const other = 'other';

  static const values = [
    highSchool,
    diploma,
    bachelors,
    masters,
    doctorate,
    other,
  ];
}

/// Salary comparison range buckets (QAR/month) — preference input, not exact salary.
abstract final class AdvancedSalaryRange {
  static const under3000 = 'under_3000';
  static const r3000_5999 = '3000_5999';
  static const r6000_8999 = '6000_8999';
  static const r10000_14999 = '10000_14999';
  static const r15000_24999 = '15000_24999';
  static const r25000Plus = '25000_plus';

  static const values = [
    under3000,
    r3000_5999,
    r6000_8999,
    r10000_14999,
    r15000_24999,
    r25000Plus,
  ];

  /// Representative midpoint for job-salary comparison scoring only.
  static double? midpointQar(String? rangeKey) {
    return switch (rangeKey) {
      under3000 => 2500,
      r3000_5999 => 4500,
      r6000_8999 => 7500,
      r10000_14999 => 12500,
      r15000_24999 => 20000,
      r25000Plus => 30000,
      _ => null,
    };
  }

  /// Bucket label for AI signals — never echo raw range to user-facing AI text.
  static String? bucketLabel(String? rangeKey) {
    return switch (rangeKey) {
      under3000 => 'low',
      r3000_5999 => 'lower_mid',
      r6000_8999 => 'mid',
      r10000_14999 => 'upper_mid',
      r15000_24999 => 'high',
      r25000Plus => 'very_high',
      _ => null,
    };
  }
}

/// Derived, bucketed signals for AI consumers — no raw sensitive echo.
abstract final class AdvancedProfileSignals {
  static Map<String, String> bucketedMap({
    required AdvancedProfile? profile,
    required bool consentGiven,
  }) {
    if (!consentGiven || profile == null || !profile.hasAnyField) {
      return const {};
    }

    final out = <String, String>{};
    if (AdvancedProfile.isSet(profile.industry)) {
      out['industry'] = profile.industry!.trim().toLowerCase();
    }
    if (AdvancedProfile.isSet(profile.educationLevel)) {
      out['education'] = profile.educationLevel!.trim();
    }
    final salaryBucket =
        AdvancedSalaryRange.bucketLabel(profile.salaryComparisonRange);
    if (salaryBucket != null) {
      out['salaryComparisonBucket'] = salaryBucket;
    }
    if (AdvancedProfile.isSet(profile.jobTitle)) {
      out['hasJobTitle'] = 'true';
    }
    return out;
  }

  /// Generic hint for Central Brain — no raw values.
  static String? personalizationHint({
    required AdvancedProfile? profile,
    required bool consentGiven,
  }) {
    if (!consentGiven || profile == null || !profile.hasAnyField) return null;
    return 'The user has optionally shared career/comparison preferences for '
        'personalization. Use this only to improve relevance and tone — never '
        'state their salary range, education, or job title back to them verbatim.';
  }
}
