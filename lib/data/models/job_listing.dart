import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/screens/jobs/l10n/jobs_strings.dart';
import 'package:raabta/data/models/job_listing_source.dart';
import 'package:raabta/data/models/job_requirements.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum JobVerificationStatus { verified, warning, scam }

class JobVerificationResult {
  const JobVerificationResult({
    required this.status,
    required this.analysisText,
  });

  final JobVerificationStatus status;
  final String analysisText;
}

class JobListing {
  const JobListing({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.benefits,
    required this.posted,
    required this.applicants,
    required this.type,
    required this.experience,
    required this.description,
    required this.contact,
    required this.category,
    this.requirements = const [],
    this.requirementsSpec,
    this.postedAt,
    this.email,
    this.note,
    this.whatsappOnly = false,
    this.isNewUnknownCompany = false,
    this.industry = 'General',
    this.listingSource = JobListingSource.raabtaNative,
    this.postedBy,
    this.businessId,
  });

  final String id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final List<String> benefits;
  final String posted;
  final int applicants;
  final String type;
  final String experience;
  final String description;
  final String contact;
  final String category;
  final List<String> requirements;
  final JobRequirementsSpec? requirementsSpec;
  final DateTime? postedAt;
  final String? email;
  final String? note;
  final bool whatsappOnly;
  final bool isNewUnknownCompany;
  final String industry;
  final JobListingSource listingSource;
  final String? postedBy;
  final String? businessId;

  bool get supportsApplicationTracking =>
      listingSource.supportsApplicationTracking;

  String get searchableText =>
      '$title $company $location $salary $description ${benefits.join(' ')}'
          .toLowerCase();

  String get companyInitial =>
      company.isNotEmpty ? company.trim()[0].toUpperCase() : '?';

  JobRequirementsSpec get effectiveRequirements =>
      requirementsSpec ??
      (requirements.isNotEmpty
          ? JobRequirementsSpec(requiredSkills: requirements)
          : const JobRequirementsSpec());

  bool get isRecentlyPosted {
    if (postedAt == null) {
      return posted.contains('hour') || posted.contains('minute');
    }
    return DateTime.now().difference(postedAt!) <= const Duration(hours: 48);
  }

  factory JobListing.fromFirestore(Map<String, dynamic> data, String id) {
    final spec = JobRequirementsSpec.fromFirestore(data);
    final legacyRequirements = (data['requirements'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .where((s) => s.isNotEmpty)
            .toList() ??
        const [];
    final requirements =
        spec.toMatchList().isNotEmpty ? spec.toMatchList() : legacyRequirements;

    DateTime? created;
    final rawCreated = data['createdAt'];
    if (rawCreated is Timestamp) {
      created = rawCreated.toDate();
    } else if (rawCreated is String) {
      created = DateTime.tryParse(rawCreated);
    }

    final benefits = (data['benefits'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .where((s) => s.isNotEmpty)
            .toList() ??
        const [];

    return JobListing(
      id: id,
      title: data['title'] as String? ?? '',
      company: data['company'] as String? ?? '',
      location: data['location'] as String? ?? 'Qatar',
      salary: data['salary'] as String? ?? 'Contact for salary',
      benefits: benefits,
      posted: formatJobPostedLabel(created) ??
          (data['posted'] as String? ?? 'Recently'),
      applicants: (data['applicantCount'] as num?)?.toInt() ?? 0,
      type: data['type'] as String? ?? 'Full Time',
      experience: data['experience'] as String? ?? '',
      description: data['description'] as String? ?? '',
      contact: data['contact'] as String? ?? '',
      category: data['category'] as String? ?? 'General',
      industry: data['industry'] as String? ?? 'General',
      requirements: requirements,
      requirementsSpec: spec.isSpecified ? spec : null,
      postedAt: created,
      email: data['email'] as String?,
      note: data['note'] as String?,
      whatsappOnly: data['whatsappOnly'] as bool? ?? false,
      isNewUnknownCompany: data['isNewUnknownCompany'] as bool? ?? false,
      listingSource: JobListingSource.fromStored(
        data['listingSource'] as String?,
      ),
      postedBy: data['postedBy'] as String?,
      businessId: _parseOptionalId(data['businessId']),
    );
  }

  static String? _parseOptionalId(Object? raw) {
    if (raw is! String) return null;
    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

String? formatJobPostedLabel(DateTime? createdAt) {
  if (createdAt == null) return null;
  final diff = DateTime.now().difference(createdAt);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
  if (diff.inHours < 24) return '${diff.inHours} hours ago';
  if (diff.inDays == 1) return '1 day ago';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
}

Map<String, dynamic> jobListingToMatchData(JobListing job) {
  final spec = job.effectiveRequirements;
  return {
    'id': job.id,
    'title': job.title,
    'company': job.company,
    'location': job.location,
    'area': job.location,
    'salary': job.salary,
    'requirements': spec.toMatchList().isNotEmpty ? spec.toMatchList() : job.requirements,
    'requiredSkills': spec.requiredSkills,
    'qualifications': spec.qualifications,
    'languageRequirements': spec.languageRequirements,
    'minimumExperience': spec.minimumExperience,
    'experience': job.experience.isNotEmpty ? job.experience : spec.minimumExperience,
    'category': job.category,
    'industry': job.industry,
    'skills': spec.requiredSkills.isNotEmpty ? spec.requiredSkills : job.requirements,
  };
}

JobVerificationResult getJobVerification(JobListing job, [String locale = 'English']) {
  final combined = '${job.title} ${job.company} ${job.location} ${job.salary} '
          '${job.description} ${job.note ?? ''} ${job.contact}'
      .toLowerCase();

  bool containsAny(List<String> phrases) =>
      phrases.any((phrase) => combined.contains(phrase.toLowerCase()));

  bool hasSalaryAmount() {
    if (job.salary.toLowerCase().contains('contact for salary')) return false;
    return RegExp(r'\d').hasMatch(job.salary);
  }

  bool hasCompanyName() => job.company.trim().isNotEmpty;

  bool hasQatarLocation() {
    const qatarMarkers = [
      'qatar',
      'doha',
      'lusail',
      'al khor',
      'ras laffan',
      'al wakrah',
      'al rayyan',
      'mesaieed',
      'west bay',
    ];
    return qatarMarkers.any(
      (marker) => job.location.toLowerCase().contains(marker),
    );
  }

  bool hasBenefits() => job.benefits.isNotEmpty;

  bool hasValidQatarPhone() {
    final normalized = job.contact.replaceAll(' ', '');
    return normalized.startsWith('+974');
  }

  int? maxSalaryValue() {
    final matches = RegExp(r'([\d,]+)').allMatches(job.salary);
    if (matches.isEmpty) return null;
    final values = matches
        .map((m) => int.tryParse(m.group(1)!.replaceAll(',', '')))
        .whereType<int>()
        .toList();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a > b ? a : b);
  }

  const suspiciousKeywords = [
    'send cv on whatsapp only',
    'whatsapp only',
  ];

  const scamKeywords = [
    'pay deposit',
    'send money first',
    'registration fee',
    'send money',
    'processing fee',
  ];

  final maxSalary = maxSalaryValue();

  if (containsAny(scamKeywords) ||
      combined.contains('guaranteed job') ||
      (combined.contains('guaranteed') && combined.contains('50000')) ||
      !hasQatarLocation() ||
      !hasValidQatarPhone() ||
      (maxSalary != null && maxSalary >= 50000)) {
    return JobVerificationResult(
      status: JobVerificationStatus.scam,
      analysisText: JobsStrings.t('jobs_scam_analysis', locale),
    );
  }

  if (!hasSalaryAmount() ||
      !hasCompanyName() ||
      job.whatsappOnly ||
      !hasBenefits() ||
      job.isNewUnknownCompany) {
    return JobVerificationResult(
      status: JobVerificationStatus.warning,
      analysisText: JobsStrings.t('jobs_warning_analysis', locale),
    );
  }

  if (hasSalaryAmount() &&
      hasCompanyName() &&
      hasQatarLocation() &&
      hasBenefits() &&
      !containsAny(suspiciousKeywords)) {
    return JobVerificationResult(
      status: JobVerificationStatus.verified,
      analysisText: JobsStrings.t('jobs_verified_analysis', locale),
    );
  }

  return JobVerificationResult(
    status: JobVerificationStatus.warning,
    analysisText: JobsStrings.t('jobs_warning_analysis', locale),
  );
}

int aiMatchScore(JobListing job) {
  final verification = getJobVerification(job);
  final seed = job.id.hashCode.abs() % 35 + 58;
  switch (verification.status) {
    case JobVerificationStatus.verified:
      return seed.clamp(72, 98);
    case JobVerificationStatus.warning:
      return seed.clamp(50, 71);
    case JobVerificationStatus.scam:
      return seed.clamp(18, 49);
  }
}

Color aiMatchColor(int score) {
  if (score >= 72) return AppColors.success;
  if (score >= 50) return AppColors.warning;
  return AppColors.textTertiary;
}

enum PremiumJobBadge { featured, urgent, spotlight }
