import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

class JobMatchResult {
  const JobMatchResult({
    required this.jobId,
    required this.matchScore,
    required this.matchLevel,
    required this.matchColor,
    required this.explanation,
    required this.breakdown,
  });

  final String jobId;
  final int matchScore;
  final String matchLevel;
  final Color matchColor;
  final String explanation;
  final Map<String, int> breakdown;

  Map<String, dynamic> toJson() => {
        'jobId': jobId,
        'matchScore': matchScore,
        'matchLevel': matchLevel,
        'matchColor': matchColor.toARGB32(),
        'explanation': explanation,
        'breakdown': breakdown,
      };
}

class RankedJobMatch {
  const RankedJobMatch({
    required this.job,
    required this.result,
  });

  final Map<String, dynamic> job;
  final JobMatchResult result;
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

class JobMatchService {
  static const Color _excellentColor = Color(0xFF34D399);
  static const Color _strongColor = Color(0xFF22D3EE);
  static const Color _goodColor = Color(0xFF60A5FA);
  static const Color _fairColor = Color(0xFFFBBF24);
  static const Color _lowColor = Color(0xFF6B7280);

  static const List<String> _criticalCertifications = [
    'nebosh',
    'iosh',
    'safety',
  ];

  static const Map<String, List<String>> _cityGroups = {
    'doha': [
      'doha',
      'west bay',
      'the pearl',
      'lusail',
      'al sadd',
      'al waab',
      'industrial area',
    ],
    'al khor': [
      'al khor',
      'ras laffan',
      'al dhakhira',
    ],
    'al wakrah': ['al wakrah', 'wakrah'],
  };

  static const Map<String, List<String>> _relatedIndustries = {
    'hse officer': [
      'hse',
      'safety',
      'health and safety',
      'environmental',
      'risk',
      'nebosh',
    ],
    'engineer': [
      'engineering',
      'construction',
      'mechanical',
      'electrical',
      'civil',
      'project',
    ],
    'nurse': ['healthcare', 'medical', 'hospital', 'clinical'],
    'driver': ['logistics', 'transport', 'delivery', 'fleet'],
    'teacher': ['education', 'school', 'training', 'academic'],
    'accountant': ['finance', 'accounting', 'audit', 'bookkeeping'],
  };

  /// Calculates total match score (0–100) from five weighted dimensions.
  int calculateMatch(Map<String, dynamic> jobData, UserAIProfile profile) {
    final breakdown = _calculateBreakdown(jobData, profile);
    final total = breakdown.values.fold<int>(0, (sum, score) => sum + score);
    return total.clamp(0, 100);
  }

  /// Builds a full [JobMatchResult] including level, color, and explanation.
  JobMatchResult evaluateMatch(
    Map<String, dynamic> jobData,
    UserAIProfile profile,
  ) {
    final jobId = _extractJobId(jobData);
    final breakdown = _calculateBreakdown(jobData, profile);
    final score = breakdown.values.fold<int>(0, (sum, s) => sum + s).clamp(0, 100);
    final levelInfo = _resolveMatchLevel(score);

    final result = JobMatchResult(
      jobId: jobId,
      matchScore: score,
      matchLevel: levelInfo.label,
      matchColor: levelInfo.color,
      explanation: '',
      breakdown: breakdown,
    );

    return JobMatchResult(
      jobId: jobId,
      matchScore: score,
      matchLevel: levelInfo.label,
      matchColor: levelInfo.color,
      explanation: generateExplanation(result, profile, jobData),
      breakdown: breakdown,
    );
  }

  /// Generates a human-readable explanation based on score and profile.
  String generateExplanation(
    JobMatchResult result,
    UserAIProfile profile, [
    Map<String, dynamic>? jobData,
  ]) {
    final score = result.matchScore;
    final profession =
        profile.profession.isNotEmpty ? profile.profession : 'professional';
    final topSkill = _topMatchingSkill(jobData, profile) ??
        (profile.skills.isNotEmpty ? profile.skills.first : 'relevant');
    final topCert = profile.certifications.isNotEmpty
        ? profile.certifications.first
        : topSkill;
    final matchedCount = _countMatchedRequirements(jobData, profile);
    final gapArea = _weakestBreakdownArea(result.breakdown);

    if (score >= 90) {
      return 'Excellent match! Your $profession experience and $topCert '
          'certification strongly align with this role.';
    }
    if (score >= 75) {
      return 'Strong match. Your background in $profession matches '
          '$matchedCount of the key requirements.';
    }
    if (score >= 60) {
      return 'Good match. Your $topSkill experience is relevant, though '
          '$gapArea experience would strengthen your application.';
    }
    if (score >= 45) {
      return 'Moderate match. Consider this role as a career growth opportunity.';
    }
    return 'Lower match based on your current profile. Skills gap in $gapArea.';
  }

  /// Ranks jobs by match score descending.
  List<RankedJobMatch> rankJobs(
    List<Map<String, dynamic>> jobs,
    UserAIProfile profile,
  ) {
    final ranked = jobs
        .map(
          (job) => RankedJobMatch(
            job: job,
            result: evaluateMatch(job, profile),
          ),
        )
        .toList()
      ..sort((a, b) => b.result.matchScore.compareTo(a.result.matchScore));

    return ranked;
  }

  // -------------------------------------------------------------------------
  // Breakdown calculation
  // -------------------------------------------------------------------------

  Map<String, int> _calculateBreakdown(
    Map<String, dynamic> jobData,
    UserAIProfile profile,
  ) {
    return {
      'skill': _scoreSkillMatch(jobData, profile),
      'experience': _scoreExperienceMatch(jobData, profile),
      'location': _scoreLocationMatch(jobData, profile),
      'salary': _scoreSalaryMatch(jobData, profile),
      'industry': _scoreIndustryMatch(jobData, profile),
    };
  }

  int _scoreSkillMatch(Map<String, dynamic> jobData, UserAIProfile profile) {
    final required = _extractRequiredSkills(jobData);
    if (required.isEmpty) return 0;

    var points = 0;
    final profileSkills =
        profile.skills.map((s) => s.toLowerCase().trim()).toSet();
    final profileCerts =
        profile.certifications.map((c) => c.toLowerCase().trim()).toSet();
    final allProfileTokens = {...profileSkills, ...profileCerts};

    for (final skill in required) {
      final normalized = skill.toLowerCase().trim();
      final matched = allProfileTokens.any(
        (token) =>
            token.contains(normalized) ||
            normalized.contains(token) ||
            _fuzzySkillMatch(token, normalized),
      );
      if (matched) {
        points += 5;
      }
    }

    for (final cert in _criticalCertifications) {
      final jobNeedsCert = required.any((s) => s.toLowerCase().contains(cert));
      final profileHasCert = profileCerts.any((c) => c.contains(cert)) ||
          profileSkills.any((s) => s.contains(cert));
      if (jobNeedsCert && profileHasCert) {
        points += 10;
      }
    }

    return points.clamp(0, 40);
  }

  int _scoreExperienceMatch(
    Map<String, dynamic> jobData,
    UserAIProfile profile,
  ) {
    final requiredYears = _extractRequiredYears(jobData);
    if (requiredYears == null) return 10;

    final gap = (profile.yearsExperience - requiredYears).abs();
    if (gap == 0) return 25;
    if (gap == 1) return 20;
    if (gap == 2) return 15;
    if (gap == 3) return 10;
    return 5;
  }

  int _scoreLocationMatch(
    Map<String, dynamic> jobData,
    UserAIProfile profile,
  ) {
    final jobArea = _extractJobArea(jobData).toLowerCase().trim();
    final preferred = profile.preferredArea.toLowerCase().trim();

    if (preferred.isEmpty) return 8;

    if (jobArea.isEmpty) return 8;

    if (jobArea == preferred) return 15;

    if (_sameCityGroup(jobArea, preferred)) return 10;

    return 5;
  }

  int _scoreSalaryMatch(
    Map<String, dynamic> jobData,
    UserAIProfile profile,
  ) {
    final salary = _extractSalary(jobData);
    if (salary == null) return 5;

    final minBudget = (profile.budgetRange['min'] ?? 0).toDouble();
    final maxBudget = (profile.budgetRange['max'] ?? 5000).toDouble();

    if (salary >= minBudget && salary <= maxBudget) return 10;

    if (salary > maxBudget && salary <= maxBudget * 1.1) return 8;

    if (salary < minBudget) return 5;

    return 5;
  }

  int _scoreIndustryMatch(
    Map<String, dynamic> jobData,
    UserAIProfile profile,
  ) {
    final jobCategory = _extractJobCategory(jobData).toLowerCase().trim();
    final profession = profile.profession.toLowerCase().trim();

    if (jobCategory.isEmpty || profession.isEmpty) return 2;

    if (jobCategory.contains(profession) || profession.contains(jobCategory)) {
      return 10;
    }

    for (final entry in _relatedIndustries.entries) {
      if (profession.contains(entry.key) ||
          entry.key.contains(profession.split(' ').first)) {
        final related = entry.value;
        if (related.any((term) => jobCategory.contains(term))) {
          return 6;
        }
      }
    }

    if (_professionKeywords(profession)
        .any((kw) => jobCategory.contains(kw))) {
      return 6;
    }

    return 2;
  }

  // -------------------------------------------------------------------------
  // Match level
  // -------------------------------------------------------------------------

  ({String label, Color color}) _resolveMatchLevel(int score) {
    if (score >= 90) {
      return (label: 'Excellent Match', color: _excellentColor);
    }
    if (score >= 75) {
      return (label: 'Strong Match', color: _strongColor);
    }
    if (score >= 60) {
      return (label: 'Good Match', color: _goodColor);
    }
    if (score >= 45) {
      return (label: 'Fair Match', color: _fairColor);
    }
    return (label: 'Low Match', color: _lowColor);
  }

  // -------------------------------------------------------------------------
  // Extraction helpers
  // -------------------------------------------------------------------------

  String _extractJobId(Map<String, dynamic> jobData) {
    for (final key in ['id', 'jobId', '_id']) {
      final value = jobData[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }

  List<String> _extractRequiredSkills(Map<String, dynamic> jobData) {
    final requirements = jobData['requirements'];
    if (requirements is List) {
      return requirements.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    if (requirements is String && requirements.isNotEmpty) {
      return requirements
          .split(RegExp(r'[,;\n•|]+'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    final skills = jobData['skills'] ?? jobData['requiredSkills'];
    if (skills is List) {
      return skills.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  int? _extractRequiredYears(Map<String, dynamic> jobData) {
    final experience = jobData['experience'] ?? jobData['yearsExperience'];
    if (experience is num) return experience.round();
    if (experience is String) {
      final match = RegExp(r'(\d+)').firstMatch(experience);
      if (match != null) return int.tryParse(match.group(1)!);
    }
    return null;
  }

  String _extractJobArea(Map<String, dynamic> jobData) {
    for (final key in ['area', 'location', 'city', 'jobLocation']) {
      final value = jobData[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }

  double? _extractSalary(Map<String, dynamic> jobData) {
    for (final key in ['salary', 'salaryMax', 'salaryMin', 'monthlySalary']) {
      final value = jobData[key];
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), ''));
        if (parsed != null) return parsed;
      }
    }

    final range = jobData['salaryRange'];
    if (range is Map) {
      final max = range['max'];
      final min = range['min'];
      if (max is num) return max.toDouble();
      if (min is num) return min.toDouble();
    }

    return null;
  }

  String _extractJobCategory(Map<String, dynamic> jobData) {
    for (final key in ['category', 'industry', 'sector', 'profession', 'title']) {
      final value = jobData[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }

  bool _sameCityGroup(String areaA, String areaB) {
    for (final group in _cityGroups.values) {
      final aInGroup = group.any((g) => areaA.contains(g) || g.contains(areaA));
      final bInGroup = group.any((g) => areaB.contains(g) || g.contains(areaB));
      if (aInGroup && bInGroup) return true;
    }
    return false;
  }

  bool _fuzzySkillMatch(String profileSkill, String requiredSkill) {
    final profileTokens = profileSkill.split(RegExp(r'\s+'));
    final requiredTokens = requiredSkill.split(RegExp(r'\s+'));
    return profileTokens.any(
      (pt) => requiredTokens.any(
        (rt) => pt.length > 3 && rt.length > 3 && pt.startsWith(rt.substring(0, 3)),
      ),
    );
  }

  List<String> _professionKeywords(String profession) {
    return profession
        .split(RegExp(r'[\s,/]+'))
        .where((w) => w.length > 2)
        .toList();
  }

  String? _topMatchingSkill(
    Map<String, dynamic>? jobData,
    UserAIProfile profile,
  ) {
    if (jobData == null) return null;
    final required = _extractRequiredSkills(jobData);
    for (final req in required) {
      final normalized = req.toLowerCase();
      for (final skill in profile.skills) {
        if (normalized.contains(skill.toLowerCase()) ||
            skill.toLowerCase().contains(normalized)) {
          return skill;
        }
      }
    }
    return profile.certifications.isNotEmpty
        ? profile.certifications.first
        : null;
  }

  int _countMatchedRequirements(
    Map<String, dynamic>? jobData,
    UserAIProfile profile,
  ) {
    if (jobData == null) return 0;
    final required = _extractRequiredSkills(jobData);
    if (required.isEmpty) return 0;

    var count = 0;
    final tokens = {
      ...profile.skills.map((s) => s.toLowerCase()),
      ...profile.certifications.map((c) => c.toLowerCase()),
    };

    for (final req in required) {
      final normalized = req.toLowerCase();
      if (tokens.any(
        (t) => t.contains(normalized) || normalized.contains(t),
      )) {
        count++;
      }
    }
    return count;
  }

  String _weakestBreakdownArea(Map<String, int> breakdown) {
    const labels = {
      'skill': 'technical skills',
      'experience': 'years of experience',
      'location': 'location',
      'salary': 'salary expectations',
      'industry': 'industry',
    };

    const maxScores = {
      'skill': 40,
      'experience': 25,
      'location': 15,
      'salary': 10,
      'industry': 10,
    };

    var weakestKey = 'skill';
    var lowestRatio = double.infinity;

    for (final entry in breakdown.entries) {
      final max = maxScores[entry.key] ?? 10;
      final ratio = entry.value / max;
      if (ratio < lowestRatio) {
        lowestRatio = ratio;
        weakestKey = entry.key;
      }
    }

    return labels[weakestKey] ?? weakestKey;
  }
}

// ---------------------------------------------------------------------------
// Riverpod
// ---------------------------------------------------------------------------

final jobMatchServiceProvider = Provider<JobMatchService>((ref) {
  return JobMatchService();
});
