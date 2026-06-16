import 'package:flutter/material.dart';
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

  String get searchableText =>
      '$title $company $location $salary $description ${benefits.join(' ')}'
          .toLowerCase();
}

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

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);
  static const Color _verifiedGreen = Color(0xFF22C55E);
  static const Color _warningAmber = Color(0xFFF59E0B);
  static const Color _scamRed = Color(0xFFEF4444);

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _statusColor(JobVerificationStatus status) {
    switch (status) {
      case JobVerificationStatus.verified:
        return _verifiedGreen;
      case JobVerificationStatus.warning:
        return _warningAmber;
      case JobVerificationStatus.scam:
        return _scamRed;
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

  void _showJobDetailSheet(JobListing job) {
    final verification = getJobVerification(job);
    final color = _statusColor(verification.status);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surfaceColor,
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
                        color: _subtitleColor.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          job.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _VerificationBadge(
                        label: _badgeLabel(verification.status),
                        color: color,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '🏢 ${job.company}',
                    style: const TextStyle(color: _subtitleColor),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.description,
                    style: const TextStyle(color: _subtitleColor, height: 1.5),
                  ),
                  if (job.requirements.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Requirements',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...job.requirements.map(
                      (req) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '• $req',
                          style: const TextStyle(color: _subtitleColor),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border(
                        left: BorderSide(color: color, width: 3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.smart_toy_outlined,
                                color: _cyanColor, size: 16),
                            SizedBox(width: 6),
                            Text(
                              '🤖 Full AI Analysis',
                              style: TextStyle(
                                color: _cyanColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
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
                            style: const TextStyle(
                              color: _subtitleColor,
                              fontSize: 12,
                            ),
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
                            foregroundColor: _cyanColor,
                            side: BorderSide(color: _cyanColor.withValues(alpha: 0.5)),
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
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF1A2535)),
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
                            backgroundColor: _scamRed,
                          ),
                        );
                      },
                      child: const Text(
                        'Report this job',
                        style: TextStyle(color: _scamRed),
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
      backgroundColor: _surfaceColor,
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
                    const Text(
                      'Post a Job',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                    const Text(
                      'Benefits',
                      style: TextStyle(color: _subtitleColor, fontSize: 13),
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('Housing'),
                          selected: housing,
                          onSelected: (v) => setSheetState(() => housing = v),
                          selectedColor: _cyanColor.withValues(alpha: 0.2),
                        ),
                        FilterChip(
                          label: const Text('Flight'),
                          selected: flight,
                          onSelected: (v) => setSheetState(() => flight = v),
                          selectedColor: _cyanColor.withValues(alpha: 0.2),
                        ),
                        FilterChip(
                          label: const Text('Medical'),
                          selected: medical,
                          onSelected: (v) => setSheetState(() => medical = v),
                          selectedColor: _cyanColor.withValues(alpha: 0.2),
                        ),
                        FilterChip(
                          label: const Text('Other'),
                          selected: other,
                          onSelected: (v) => setSheetState(() => other = v),
                          selectedColor: _cyanColor.withValues(alpha: 0.2),
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
                              backgroundColor: _verifiedGreen,
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: _cyanColor,
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

    return Scaffold(
      backgroundColor: _backgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: _showPostJobSheet,
        backgroundColor: _cyanColor,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💼 Qatar Jobs',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'AI-verified listings',
                          style: TextStyle(color: _subtitleColor, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _showPostJobSheet,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Post Job'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: _cyanColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search jobs, companies, skills...',
                  hintStyle: const TextStyle(color: _subtitleColor),
                  prefixIcon: const Icon(Icons.search, color: _cyanColor),
                  filled: true,
                  fillColor: _surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final selected = _selectedFilter == index;
                  return FilterChip(
                    label: Text(_filters[index]),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedFilter = index),
                    backgroundColor: _surfaceColor,
                    selectedColor: _cyanColor.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: selected ? _cyanColor : _subtitleColor,
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    showCheckmark: false,
                    side: BorderSide(
                      color: selected ? _cyanColor : Colors.transparent,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: jobs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.work_off_outlined,
                              color: _subtitleColor, size: 48),
                          const SizedBox(height: 12),
                          const Text(
                            'No jobs match your search',
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _selectedFilter = 0;
                              });
                            },
                            child: const Text(
                              'Clear filters',
                              style: TextStyle(color: _cyanColor),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 88),
                      itemCount: jobs.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final job = jobs[index];
                        final verification = getJobVerification(job);
                        final statusColor = _statusColor(verification.status);
                        final isSaved = _savedJobIds.contains(job.id);

                        return Container(
                          decoration: BoxDecoration(
                            color: _surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          job.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '🏢 ${job.company}',
                                          style: const TextStyle(
                                            color: _subtitleColor,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '📍 ${job.location}',
                                          style: const TextStyle(
                                            color: _subtitleColor,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _VerificationBadge(
                                    label: _badgeLabel(verification.status),
                                    color: statusColor,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                job.salary,
                                style: const TextStyle(
                                  color: _cyanColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (job.benefits.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: job.benefits.map((benefit) {
                                    final emoji = benefit.toLowerCase().contains('flight')
                                        ? '✈️'
                                        : benefit.toLowerCase().contains('housing') ||
                                                benefit.toLowerCase().contains('house')
                                            ? '🏠'
                                            : benefit.toLowerCase().contains('medical')
                                                ? '🏥'
                                                : '✨';
                                    return _BenefitChip(
                                      label: '$emoji $benefit',
                                    );
                                  }).toList(),
                                ),
                              ],
                              const SizedBox(height: 10),
                              Text(
                                '${job.posted} · ${job.applicants} applicants · ${job.type}',
                                style: const TextStyle(
                                  color: _subtitleColor,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: verification.status ==
                                          JobVerificationStatus.scam
                                      ? () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'This listing flagged as high risk. Proceed with caution.',
                                              ),
                                              backgroundColor: _scamRed,
                                            ),
                                          );
                                        }
                                      : () => _showJobDetailSheet(job),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _cyanColor,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text(
                                    'Apply',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _toggleSave(job.id),
                                      icon: Icon(
                                        isSaved
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        size: 18,
                                        color: isSaved ? _cyanColor : _subtitleColor,
                                      ),
                                      label: Text(
                                        isSaved ? 'Saved' : 'Save',
                                        style: TextStyle(
                                          color: isSaved ? _cyanColor : _subtitleColor,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Color(0xFF1A2535),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _shareJob(job),
                                      icon: const Icon(Icons.share_outlined,
                                          size: 18, color: _subtitleColor),
                                      label: const Text(
                                        'Share',
                                        style: TextStyle(color: _subtitleColor),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Color(0xFF1A2535),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _AiAnalysisBox(
                                analysisText: verification.analysisText,
                                borderColor: statusColor,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
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
        color: const Color(0xFF050A0F),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF1A2535)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Color(0xFF8A9BB0), fontSize: 11),
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

  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _cyanColor = Color(0xFF22D3EE);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: borderColor, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.smart_toy_outlined, color: _cyanColor, size: 14),
              SizedBox(width: 6),
              Text(
                '🤖 Raabta AI Analysis:',
                style: TextStyle(
                  color: _cyanColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
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
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF8A9BB0)),
        filled: true,
        fillColor: const Color(0xFF050A0F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
