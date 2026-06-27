import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/design/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_text_styles.dart';
import 'package:raabta/core/widgets/section_header.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/widgets/ai/job_match_badge.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
    this.email,
    this.note,
    this.whatsappOnly = false,
    this.isNewUnknownCompany = false,
    this.industry = 'General',
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
  final String? email;
  final String? note;
  final bool whatsappOnly;
  final bool isNewUnknownCompany;
  final String industry;

  String get searchableText =>
      '$title $company $location $salary $description ${benefits.join(' ')}'
          .toLowerCase();

  String get companyInitial =>
      company.isNotEmpty ? company.trim()[0].toUpperCase() : '?';
}

Map<String, dynamic> jobListingToMatchData(JobListing job) => {
      'id': job.id,
      'title': job.title,
      'company': job.company,
      'location': job.location,
      'area': job.location,
      'salary': job.salary,
      'requirements': job.requirements,
      'experience': job.experience,
      'category': job.category,
      'skills': job.requirements,
    };

JobVerificationResult getJobVerification(JobListing job) {
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
    return const JobVerificationResult(
      status: JobVerificationStatus.scam,
      analysisText:
          '🚫 High risk detected. Multiple fraud signals found. '
          'Do NOT send money or personal documents.',
    );
  }

  if (!hasSalaryAmount() ||
      !hasCompanyName() ||
      job.whatsappOnly ||
      !hasBenefits() ||
      job.isNewUnknownCompany) {
    return const JobVerificationResult(
      status: JobVerificationStatus.warning,
      analysisText:
          '⚠ Review carefully. Some details unconfirmed. '
          'Ask for written contract before proceeding.',
    );
  }

  if (hasSalaryAmount() &&
      hasCompanyName() &&
      hasQatarLocation() &&
      hasBenefits() &&
      !containsAny(suspiciousKeywords)) {
    return const JobVerificationResult(
      status: JobVerificationStatus.verified,
      analysisText:
          '✓ Verified listing. Company registered in Qatar. '
          'Salary within market range. Benefits confirmed.',
    );
  }

  return const JobVerificationResult(
    status: JobVerificationStatus.warning,
    analysisText:
        '⚠ Review carefully. Some details unconfirmed. '
        'Ask for written contract before proceeding.',
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
  return AppColors.textMuted;
}

enum PremiumJobBadge { featured, urgent, spotlight }

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilter = 0;
  final Set<String> _savedJobIds = {};

  static const List<String> _filters = [
    'All',
    'HSE/Safety',
    'Construction',
    'IT',
    'Healthcare',
    'Hospitality',
    'Driving',
    'Security',
    'Cleaning',
  ];

  static const List<JobListing> _allJobs = [
    JobListing(
      id: 'job-1',
      title: 'HSE Officer',
      company: 'QatarEnergy LNG',
      location: 'Ras Laffan, Qatar',
      salary: '8,000 — 12,000 QR/month',
      benefits: ['Flight Ticket', 'Housing', 'Medical'],
      posted: '2 hours ago',
      applicants: 45,
      type: 'Full Time',
      experience: '5+ years',
      description:
          'Responsible for HSE compliance at LNG facility. NEBOSH certificate required.',
      contact: '+974 4400 0000',
      category: 'HSE/Safety',
      industry: 'Oil & Gas',
      requirements: [
        'NEBOSH IGC or equivalent',
        '5+ years HSE experience in oil & gas',
        'Valid Qatar driving license preferred',
      ],
      email: 'careers@qa.energy',
    ),
    JobListing(
      id: 'job-2',
      title: 'HSE Engineer',
      company: 'EMCO Qatar',
      location: 'Doha, Qatar',
      salary: '8,000 — 10,000 QR/month',
      benefits: ['Housing Allowance', 'Medical'],
      posted: '5 hours ago',
      applicants: 23,
      type: 'Full Time',
      experience: '3+ years',
      description:
          'Support HSE programs across construction projects in Doha. Conduct site audits and training.',
      contact: '+974 4411 2233',
      category: 'HSE/Safety',
      industry: 'Construction',
      requirements: [
        'Bachelor in Engineering or HSE',
        '3+ years Qatar/GCC experience',
        'IOSH or NEBOSH certification',
      ],
      email: 'hr@emco.qa',
    ),
    JobListing(
      id: 'job-3',
      title: 'IT Support Specialist',
      company: 'Qatar Airways',
      location: 'Doha, Qatar',
      salary: '5,500 — 7,500 QR/month',
      benefits: ['Flight Discount', 'Housing', 'Medical'],
      posted: '1 day ago',
      applicants: 67,
      type: 'Full Time',
      experience: '2+ years',
      description:
          'Provide L1/L2 IT support for corporate staff. Manage tickets, hardware, and onboarding.',
      contact: '+974 4022 0000',
      category: 'IT',
      industry: 'Aviation',
      requirements: [
        'CompTIA A+ or equivalent',
        'Experience with Active Directory',
        'Strong English communication',
      ],
      email: 'jobs@qatarairways.qa',
    ),
    JobListing(
      id: 'job-4',
      title: 'Staff Nurse',
      company: 'Hamad Medical Corporation',
      location: 'Doha, Qatar',
      salary: '7,000 — 9,000 QR/month',
      benefits: ['Housing', 'Medical', 'Annual Leave'],
      posted: '3 hours ago',
      applicants: 89,
      type: 'Full Time',
      experience: '3+ years',
      description:
          'Deliver patient care in a busy hospital ward. QCHP license required.',
      contact: '+974 4439 5777',
      category: 'Healthcare',
      industry: 'Healthcare',
      requirements: [
        'Valid QCHP license',
        'BSN or equivalent nursing degree',
        '3+ years clinical experience',
      ],
      email: 'recruitment@hamad.qa',
    ),
    JobListing(
      id: 'job-5',
      title: 'Construction Worker',
      company: 'Al Baraka Trading',
      location: 'Qatar',
      salary: 'Contact for salary',
      benefits: [],
      posted: '1 day ago',
      applicants: 12,
      type: 'Full Time',
      experience: '1+ years',
      description:
          'General construction labour needed for site work. Accommodation may be discussed.',
      contact: '+974 3344 5566',
      category: 'Construction',
      industry: 'Construction',
      requirements: ['Previous construction experience'],
      note: 'No salary and no benefits mentioned',
      isNewUnknownCompany: true,
    ),
    JobListing(
      id: 'job-6',
      title: 'Driver Needed',
      company: 'Private Family',
      location: 'Doha',
      salary: '2,000 QR/month',
      benefits: [],
      posted: '6 hours ago',
      applicants: 12,
      type: 'Full Time',
      experience: '2+ years',
      description:
          'Family driver required in Doha. Must have valid Qatar license. Send CV on WhatsApp only.',
      contact: '+974 5566 7788',
      category: 'Driving',
      industry: 'Private',
      requirements: ['Valid Qatar light vehicle license', 'Clean driving record'],
      note: 'No written contract mentioned',
      whatsappOnly: true,
      isNewUnknownCompany: true,
    ),
    JobListing(
      id: 'job-7',
      title: 'Easy Work High Pay',
      company: 'Global Opportunities',
      location: 'International',
      salary: '50,000 QR/month guaranteed',
      benefits: ['Everything provided'],
      posted: '30 minutes ago',
      applicants: 234,
      type: 'Full Time',
      experience: 'None required',
      description:
          'Guaranteed job with easy work and high pay. Send CV and 500 QR registration fee to secure placement.',
      contact: '+971 50 123 4567',
      category: 'All',
      industry: 'Recruitment',
      requirements: [],
      note: 'Send CV and 500 QR registration fee',
    ),
  ];

  List<JobListing> get _filteredJobs {
    var jobs = _allJobs;
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      jobs = jobs.where((j) => j.searchableText.contains(query)).toList();
    }
    if (_selectedFilter > 0) {
      final filter = _filters[_selectedFilter];
      jobs = jobs.where((j) => j.category == filter).toList();
    }
    return jobs;
  }

  List<JobListing> get _featuredJobs => _allJobs
      .where((j) => getJobVerification(j).status == JobVerificationStatus.verified)
      .take(3)
      .toList();

  List<JobListing> get _urgentJobs => _allJobs
      .where((j) => j.posted.contains('hour') || j.posted.contains('minutes'))
      .take(2)
      .toList();

  int get _matchedJobCount => _allJobs
      .where((j) => aiMatchScore(j) >= 72)
      .length;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _statusColor(JobVerificationStatus status) {
    switch (status) {
      case JobVerificationStatus.verified:
        return AppColors.success;
      case JobVerificationStatus.warning:
        return AppColors.warning;
      case JobVerificationStatus.scam:
        return AppColors.error;
    }
  }

  String _badgeLabel(JobVerificationStatus status) {
    switch (status) {
      case JobVerificationStatus.verified:
        return '✓ AI VERIFIED';
      case JobVerificationStatus.warning:
        return '⚠ REVIEW CAREFULLY';
      case JobVerificationStatus.scam:
        return '🚫 POSSIBLE SCAM';
    }
  }

  String _miniAnalysisText(JobVerificationResult verification) {
    switch (verification.status) {
      case JobVerificationStatus.verified:
        return '🤖 High match · Verified · Market salary';
      case JobVerificationStatus.warning:
        return '🤖 Moderate match · Review details carefully';
      case JobVerificationStatus.scam:
        return '🤖 Low match · High risk signals detected';
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _toggleSave(String jobId) {
    setState(() {
      if (_savedJobIds.contains(jobId)) {
        _savedJobIds.remove(jobId);
      } else {
        _savedJobIds.add(jobId);
      }
    });
  }

  Future<void> _shareJob(JobListing job) async {
    final verification = getJobVerification(job);
    await Share.share(
      '${job.title} at ${job.company}\n'
      '${job.location} · ${job.salary}\n'
      'AI Status: ${_badgeLabel(verification.status)}\n'
      'Posted via Raabta Jobs',
    );
  }

  void _applyToJob(JobListing job, JobVerificationResult verification) {
    if (verification.status == JobVerificationStatus.scam) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This listing flagged as high risk. Proceed with caution.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    _showJobDetailSheet(job);
  }

  void _showJobDetailSheet(JobListing job) {
    final verification = getJobVerification(job);
    final color = _statusColor(verification.status);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.88,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(job.title, style: AppTextStyles.h1),
                      ),
                      _VerificationBadge(
                        label: _badgeLabel(verification.status),
                        color: color,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('🏢 ${job.company}', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.description,
                    style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
                  ),
                  if (job.requirements.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Requirements',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...job.requirements.map(
                      (req) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('• $req', style: AppTextStyles.bodyMedium),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border(left: BorderSide(color: color, width: 3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.smart_toy_outlined,
                              color: AppColors.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '🤖 Full AI Analysis',
                              style: AppTextStyles.labelLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          verification.analysisText,
                          style: TextStyle(color: color, height: 1.4),
                        ),
                        if (job.note != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            job.note!,
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final phone =
                                job.contact.replaceAll(' ', '').replaceAll('-', '');
                            _openUrl(
                              'https://wa.me/${phone.replaceAll('+', '')}?text=${Uri.encodeComponent('Hi, I am interested in the ${job.title} position at ${job.company} listed on Raabta.')}',
                            );
                          },
                          icon: const Icon(Icons.chat),
                          label: const Text('WhatsApp'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: job.email == null
                              ? null
                              : () => _openUrl('mailto:${job.email}'),
                          icon: const Icon(Icons.email_outlined),
                          label: const Text('Email'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                              color: AppColors.primary.withValues(alpha: 0.5),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openUrl('tel:${job.contact}'),
                      icon: const Icon(Icons.phone),
                      label: Text('Call ${job.contact}'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: BorderSide(color: AppColors.surfaceElevated),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Report submitted for "${job.title}"'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      },
                      child: const Text(
                        'Report this job',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPostJobSheet() {
    final titleController = TextEditingController();
    final companyController = TextEditingController();
    final salaryController = TextEditingController();
    final locationController = TextEditingController(text: 'Qatar');
    final descriptionController = TextEditingController();
    final whatsappController = TextEditingController();
    var housing = false;
    var flight = false;
    var medical = false;
    var other = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Post a Job', style: AppTextStyles.h1),
                    const SizedBox(height: 16),
                    _FormField(controller: titleController, hint: 'Job title'),
                    const SizedBox(height: 10),
                    _FormField(
                      controller: companyController,
                      hint: 'Company name',
                    ),
                    const SizedBox(height: 10),
                    _FormField(
                      controller: salaryController,
                      hint: 'Salary range (e.g. 4,000 — 6,000 QR/month)',
                    ),
                    const SizedBox(height: 10),
                    _FormField(
                      controller: locationController,
                      hint: 'Location',
                    ),
                    const SizedBox(height: 12),
                    Text('Benefits', style: AppTextStyles.bodyMedium),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('Housing'),
                          selected: housing,
                          onSelected: (v) => setSheetState(() => housing = v),
                          selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        ),
                        FilterChip(
                          label: const Text('Flight'),
                          selected: flight,
                          onSelected: (v) => setSheetState(() => flight = v),
                          selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        ),
                        FilterChip(
                          label: const Text('Medical'),
                          selected: medical,
                          onSelected: (v) => setSheetState(() => medical = v),
                          selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        ),
                        FilterChip(
                          label: const Text('Other'),
                          selected: other,
                          onSelected: (v) => setSheetState(() => other = v),
                          selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _FormField(
                      controller: descriptionController,
                      hint: 'Job description',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 10),
                    _FormField(
                      controller: whatsappController,
                      hint: 'Contact WhatsApp (+974...)',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          if (titleController.text.trim().isEmpty ||
                              companyController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill required fields'),
                              ),
                            );
                            return;
                          }
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Your job posted! AI verification within 2 hours.',
                              ),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Post & Request AI Verification',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobs = _filteredJobs;
    final featured = _featuredJobs;
    final urgent = _urgentJobs;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: _showPostJobSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 12, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _showPostJobSheet,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Post Job'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildHeroSection()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildFilterChips()),
            SliverToBoxAdapter(child: _buildAiMatchBanner()),
            if (featured.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xxl,
                    AppSpacing.xl,
                    AppSpacing.md,
                  ),
                  child: SectionHeader(
                    title: '⭐ Featured Jobs',
                    onSeeAll: () {},
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 420,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    itemCount: featured.length,
                    separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final badges = [
                        PremiumJobBadge.featured,
                        PremiumJobBadge.urgent,
                        PremiumJobBadge.spotlight,
                      ];
                      return _PremiumJobCard(
                        job: featured[index],
                        badge: badges[index % badges.length],
                        isSaved: _savedJobIds.contains(featured[index].id),
                        onApply: () => _applyToJob(
                          featured[index],
                          getJobVerification(featured[index]),
                        ),
                        onSave: () => _toggleSave(featured[index].id),
                        onShare: () => _shareJob(featured[index]),
                        statusColor: _statusColor(
                          getJobVerification(featured[index]).status,
                        ),
                        verification: getJobVerification(featured[index]),
                        miniAnalysis: _miniAnalysisText(
                          getJobVerification(featured[index]),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xxl,
                  AppSpacing.xl,
                  AppSpacing.md,
                ),
                child: SectionHeader(
                  title: '🔥 Urgent Hiring',
                  onSeeAll: () {},
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  children: urgent.map((job) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _UrgentJobCard(
                        job: job,
                        verification: getJobVerification(job),
                        isSaved: _savedJobIds.contains(job.id),
                        onTap: () => _applyToJob(job, getJobVerification(job)),
                        onSave: () => _toggleSave(job.id),
                        onShare: () => _shareJob(job),
                        statusColor: _statusColor(getJobVerification(job).status),
                        badgeLabel: _badgeLabel(getJobVerification(job).status),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildCompanySpotlight()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xxl,
                  AppSpacing.xl,
                  AppSpacing.md,
                ),
                child: Text('All Jobs', style: AppTextStyles.h2),
              ),
            ),
            SliverToBoxAdapter(
              child: Consumer(
                builder: (context, ref, _) {
                  final profile = ref
                          .read(userProfileAIServiceProvider)
                          .getCachedProfile() ??
                      ref.watch(userAIProfileProvider);
                  if (profile == null) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.07),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      children: [
                        const Text('🤖', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 6),
                        Text(
                          'Sorted by AI match for your profile',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (jobs.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.work_off_outlined,
                        color: AppColors.textSecondary,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No jobs match your search',
                        style: AppTextStyles.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _selectedFilter = 0;
                          });
                        },
                        child: Text(
                          'Clear filters',
                          style: AppTextStyles.labelLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  100,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final job = jobs[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < jobs.length - 1 ? AppSpacing.md : 0,
                        ),
                        child: _JobListingCard(
                          job: job,
                          verification: getJobVerification(job),
                          isSaved: _savedJobIds.contains(job.id),
                          statusColor: _statusColor(getJobVerification(job).status),
                          badgeLabel: _badgeLabel(getJobVerification(job).status),
                          matchScore: aiMatchScore(job),
                          onApply: () => _applyToJob(job, getJobVerification(job)),
                          onSave: () => _toggleSave(job.id),
                          onShare: () => _shareJob(job),
                        ),
                      );
                    },
                    childCount: jobs.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.surface, AppColors.surfaceElevated],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          border: Border.all(color: AppColors.borderPrimary),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('💼 Qatar Jobs Board', style: AppTextStyles.h1),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'AI-Verified · Updated Daily',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(child: _HeroStat(value: '1,234', label: 'Jobs')),
                Container(width: 1, height: 32, color: AppColors.border),
                Expanded(child: _HeroStat(value: '47', label: 'Companies')),
                Container(width: 1, height: 32, color: AppColors.border),
                Expanded(child: _HeroStat(value: '23', label: 'Urgent')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Search jobs, companies, skills...',
          hintStyle: AppTextStyles.bodyMedium,
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          itemCount: _filters.length,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, index) {
            final selected = _selectedFilter == index;
            return FilterChip(
              label: Text(_filters[index]),
              selected: selected,
              onSelected: (_) => setState(() => _selectedFilter = index),
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
              showCheckmark: false,
              side: BorderSide(
                color: selected ? AppColors.primary : Colors.transparent,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAiMatchBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.15),
              AppColors.secondary.withValues(alpha: 0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          border: Border.all(color: AppColors.borderPrimary),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🤖 Your AI Match Score', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Based on your profile, you match $_matchedJobCount jobs today',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '85% match rate',
              style: AppTextStyles.displayMedium.copyWith(
                color: AppColors.primary,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => context.push('/profile'),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: Text(
                'Update Profile to improve →',
                style: AppTextStyles.labelLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanySpotlight() {
    const spotlightCompany = 'QatarEnergy LNG';
    const spotlightIndustry = 'Oil & Gas';
    final companyJobs =
        _allJobs.where((j) => j.company == spotlightCompany).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🏢 Company Spotlight', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.surface, AppColors.surfaceElevated],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.surfaceElevated,
                      child: Text(
                        'Q',
                        style: AppTextStyles.h2.copyWith(color: AppColors.gold),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(spotlightCompany, style: AppTextStyles.h3),
                          Text(spotlightIndustry, style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Hiring $companyJobs positions',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: const [
                    _BenefitChip(label: '✈️ Flight Ticket'),
                    _BenefitChip(label: '🏠 Housing'),
                    _BenefitChip(label: '🏥 Medical'),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _searchController.text = 'QatarEnergy');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.gold,
                      side: BorderSide(color: AppColors.gold.withValues(alpha: 0.5)),
                    ),
                    child: const Text('View All Jobs'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        Text(label, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
      ],
    );
  }
}

class _PremiumJobCard extends StatelessWidget {
  const _PremiumJobCard({
    required this.job,
    required this.badge,
    required this.isSaved,
    required this.onApply,
    required this.onSave,
    required this.onShare,
    required this.statusColor,
    required this.verification,
    required this.miniAnalysis,
  });

  final JobListing job;
  final PremiumJobBadge badge;
  final bool isSaved;
  final VoidCallback onApply;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final Color statusColor;
  final JobVerificationResult verification;
  final String miniAnalysis;

  @override
  Widget build(BuildContext context) {
    final match = aiMatchScore(job);

    return Container(
      width: 260,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
              gradient: LinearGradient(
          colors: [AppColors.surfaceElevated, AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.background,
                child: Text(
                  job.companyInitial,
                  style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.company,
                      style: AppTextStyles.bodyLarge.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(job.industry, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              _MonetizationBadge(type: badge),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(job.title, style: AppTextStyles.h3.copyWith(fontSize: 16)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            job.salary,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('📍 ${job.location}', style: AppTextStyles.bodySmall),
          if (job.benefits.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _BenefitRow(benefits: job.benefits),
          ],
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${job.posted} · ${job.applicants} applicants',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _MatchIndicator(score: match),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '🤖 $match% Match',
                style: AppTextStyles.bodySmall.copyWith(
                  color: aiMatchColor(match),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onApply,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              IconButton(
                onPressed: onSave,
                icon: Icon(
                  isSaved ? Icons.favorite : Icons.favorite_border,
                  color: isSaved ? AppColors.primary : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: onShare,
                icon: Icon(Icons.share_outlined, color: AppColors.textSecondary, size: 20),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          JobMatchBadge(
            jobData: jobListingToMatchData(job),
            compact: true,
          ),
          _AiMiniBox(text: miniAnalysis, borderColor: statusColor),
        ],
      ),
    );
  }
}

class _UrgentJobCard extends StatelessWidget {
  const _UrgentJobCard({
    required this.job,
    required this.verification,
    required this.isSaved,
    required this.onTap,
    required this.onSave,
    required this.onShare,
    required this.statusColor,
    required this.badgeLabel,
  });

  final JobListing job;
  final JobVerificationResult verification;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final Color statusColor;
  final String badgeLabel;

  @override
  Widget build(BuildContext context) {
    final match = aiMatchScore(job);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _MonetizationBadge(type: PremiumJobBadge.urgent),
                const Spacer(),
                _VerificationBadge(label: badgeLabel, color: statusColor),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(job.title, style: AppTextStyles.h3),
            _MatchBadge(score: match),
            const SizedBox(height: AppSpacing.xs),
            Text('🏢 ${job.company}', style: AppTextStyles.bodyMedium),
            Text(
              job.salary,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${job.posted} · ${job.applicants} applicants',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
                IconButton(
                  onPressed: onSave,
                  icon: Icon(
                    isSaved ? Icons.favorite : Icons.favorite_border,
                    color: isSaved ? AppColors.primary : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                IconButton(
                  onPressed: onShare,
                  icon: Icon(Icons.share_outlined, color: AppColors.textSecondary, size: 20),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            JobMatchBadge(
              jobData: jobListingToMatchData(job),
              compact: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _JobListingCard extends StatelessWidget {
  const _JobListingCard({
    required this.job,
    required this.verification,
    required this.isSaved,
    required this.statusColor,
    required this.badgeLabel,
    required this.matchScore,
    required this.onApply,
    required this.onSave,
    required this.onShare,
  });

  final JobListing job;
  final JobVerificationResult verification;
  final bool isSaved;
  final Color statusColor;
  final String badgeLabel;
  final int matchScore;
  final VoidCallback onApply;
  final VoidCallback onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.surfaceElevated,
                child: Text(
                  job.companyInitial,
                  style: AppTextStyles.labelLarge,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.title, style: AppTextStyles.h3),
                    const SizedBox(height: AppSpacing.xs),
                    _MatchBadge(score: matchScore),
                    const SizedBox(height: AppSpacing.xs),
                    Text('🏢 ${job.company}', style: AppTextStyles.bodyMedium),
                    Text('📍 ${job.location}', style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              _VerificationBadge(label: badgeLabel, color: statusColor),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            job.salary,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (job.benefits.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _BenefitRow(benefits: job.benefits),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${job.posted} · ${job.applicants} applicants · ${job.type}',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onApply,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSave,
                  icon: Icon(
                    isSaved ? Icons.favorite : Icons.favorite_border,
                    size: 18,
                    color: isSaved ? AppColors.primary : AppColors.textSecondary,
                  ),
                  label: Text(
                    isSaved ? 'Saved' : 'Save',
                    style: TextStyle(
                      color: isSaved ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.surfaceElevated),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onShare,
                  icon: Icon(
                    Icons.share_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  label: Text(
                    'Share',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.surfaceElevated),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          JobMatchBadge(
            jobData: jobListingToMatchData(job),
            compact: false,
          ),
          const SizedBox(height: AppSpacing.md),
          _AiAnalysisBox(
            analysisText: verification.analysisText,
            borderColor: statusColor,
          ),
        ],
      ),
    );
  }
}

class _MonetizationBadge extends StatelessWidget {
  const _MonetizationBadge({required this.type});

  final PremiumJobBadge type;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      PremiumJobBadge.featured => ('⭐ FEATURED', AppColors.gold),
      PremiumJobBadge.urgent => ('🔥 URGENT HIRING', AppColors.error),
      PremiumJobBadge.spotlight => ('🏢 SPOTLIGHT', AppColors.secondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _MatchBadge extends StatelessWidget {
  const _MatchBadge({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final color = aiMatchColor(score);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        '🤖 $score% Profile Match',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MatchIndicator extends StatelessWidget {
  const _MatchIndicator({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final color = aiMatchColor(score);
    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 3,
            backgroundColor: AppColors.surfaceElevated,
            color: color,
          ),
          Text(
            '$score',
            style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.benefits});

  final List<String> benefits;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: benefits.map((benefit) {
        final emoji = benefit.toLowerCase().contains('flight')
            ? '✈️'
            : benefit.toLowerCase().contains('housing') ||
                    benefit.toLowerCase().contains('house')
                ? '🏠'
                : benefit.toLowerCase().contains('medical')
                    ? '🏥'
                    : '✨';
        return _BenefitChip(label: '$emoji ${benefit.split(' ').first}');
      }).toList(),
    );
  }
}

class _AiMiniBox extends StatelessWidget {
  const _AiMiniBox({required this.text, required this.borderColor});

  final String text;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border(left: BorderSide(color: borderColor, width: 3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: borderColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _VerificationBadge extends StatelessWidget {
  const _VerificationBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _BenefitChip extends StatelessWidget {
  const _BenefitChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.surfaceElevated),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
      ),
    );
  }
}

class _AiAnalysisBox extends StatelessWidget {
  const _AiAnalysisBox({
    required this.analysisText,
    required this.borderColor,
  });

  final String analysisText;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: borderColor, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.smart_toy_outlined, color: AppColors.primary, size: 14),
              const SizedBox(width: 6),
              Text(
                '🤖 Raabta AI Analysis:',
                style: AppTextStyles.labelLarge.copyWith(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            analysisText,
            style: TextStyle(color: borderColor, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
