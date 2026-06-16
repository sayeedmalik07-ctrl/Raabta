import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum BusinessVerificationLevel { raabtaVerified, communityVerified, listed }

class TrustScoreBreakdown {
  const TrustScoreBreakdown({
    required this.total,
    required this.reviewsScore,
    required this.ratingScore,
    required this.activityScore,
    required this.level,
  });

  final int total;
  final int reviewsScore;
  final int ratingScore;
  final int activityScore;
  final BusinessVerificationLevel level;
}

class BusinessListing {
  const BusinessListing({
    required this.id,
    required this.name,
    required this.category,
    required this.emoji,
    required this.rating,
    required this.reviewCount,
    required this.location,
    required this.speciality,
    required this.trustScore,
    required this.phone,
    this.cuisine,
    this.openNow = true,
    this.closingTime,
    this.languages = const [],
    this.whatsapp,
    this.yearsActive = 1,
    this.hasReports = false,
    this.description,
  });

  final String id;
  final String name;
  final String category;
  final String emoji;
  final double rating;
  final int reviewCount;
  final String location;
  final String speciality;
  final int trustScore;
  final String phone;
  final String? cuisine;
  final bool openNow;
  final String? closingTime;
  final List<String> languages;
  final String? whatsapp;
  final int yearsActive;
  final bool hasReports;
  final String? description;

  bool get hasWhatsApp => whatsapp != null && whatsapp!.trim().isNotEmpty;

  String get searchableText =>
      '$name $category ${cuisine ?? ''} $location $speciality ${languages.join(' ')}'
          .toLowerCase();
}

TrustScoreBreakdown getTrustScore(BusinessListing business) {
  final reviewsScore = (business.reviewCount / 3).clamp(0, 35).round();
  final ratingScore = ((business.rating / 5) * 35).round();
  final activityScore = (business.yearsActive * 6).clamp(0, 30).round();
  final computedTotal = (reviewsScore + ratingScore + activityScore).clamp(0, 100);

  BusinessVerificationLevel level;
  if (business.reviewCount > 50 &&
      business.rating >= 4.5 &&
      business.yearsActive >= 2 &&
      business.hasWhatsApp &&
      !business.hasReports) {
    level = BusinessVerificationLevel.raabtaVerified;
  } else if (business.reviewCount > 20 &&
      business.rating >= 4.0 &&
      !business.hasReports) {
    level = BusinessVerificationLevel.communityVerified;
  } else {
    level = BusinessVerificationLevel.listed;
  }

  return TrustScoreBreakdown(
    total: business.trustScore > 0 ? business.trustScore : computedTotal,
    reviewsScore: reviewsScore,
    ratingScore: ratingScore,
    activityScore: activityScore,
    level: level,
  );
}

class BusinessesScreen extends StatefulWidget {
  const BusinessesScreen({super.key});

  @override
  State<BusinessesScreen> createState() => _BusinessesScreenState();
}

class _BusinessesScreenState extends State<BusinessesScreen> {
  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);
  static const Color _goldColor = Color(0xFFF59E0B);
  static const Color _greenColor = Color(0xFF22C55E);
  static const Color _blueColor = Color(0xFF3B82F6);

  final TextEditingController _searchController = TextEditingController();
  int _selectedCategory = 0;

  static const List<({String label, String emoji, String? filter})> _categories =
      [
    (label: 'All', emoji: '🔍', filter: null),
    (label: 'Restaurants', emoji: '🍛', filter: 'Restaurant'),
    (label: 'Salons', emoji: '✂️', filter: 'Salon'),
    (label: 'Gyms', emoji: '🏋️', filter: 'Gym'),
    (label: 'Clinics', emoji: '🏥', filter: 'Clinic'),
    (label: 'AC & Repair', emoji: '🔧', filter: 'AC & Repair'),
    (label: 'Grocery', emoji: '🛒', filter: 'Grocery'),
    (label: 'Travel', emoji: '✈️', filter: 'Travel'),
    (label: 'PRO Services', emoji: '📋', filter: 'PRO Services'),
  ];

  static const List<BusinessListing> _allBusinesses = [
    BusinessListing(
      id: 'biz-1',
      name: 'Karachi Darbar Restaurant',
      category: 'Restaurant',
      emoji: '🍛',
      cuisine: 'Indian & Pakistani',
      rating: 4.8,
      reviewCount: 234,
      location: 'Al Khor, Qatar',
      openNow: true,
      closingTime: '11:00 PM',
      languages: ['Urdu', 'Hindi', 'Arabic'],
      phone: '+974 4470 0000',
      whatsapp: '+974 5500 0000',
      yearsActive: 5,
      speciality: 'Best Biryani in Al Khor',
      trustScore: 96,
      description:
          'Family-friendly Indian & Pakistani restaurant serving authentic biryani, karahi, and BBQ.',
    ),
    BusinessListing(
      id: 'biz-2',
      name: 'Malabar Kitchen',
      category: 'Restaurant',
      emoji: '🍲',
      cuisine: 'South Indian & Kerala',
      rating: 4.6,
      reviewCount: 156,
      location: 'Doha, Qatar',
      openNow: true,
      closingTime: '10:30 PM',
      languages: ['Malayalam', 'English', 'Hindi'],
      phone: '+974 4488 1122',
      whatsapp: '+974 5511 2233',
      yearsActive: 4,
      speciality: 'Authentic Kerala meals & seafood',
      trustScore: 91,
    ),
    BusinessListing(
      id: 'biz-3',
      name: 'Al Noor Gents Salon',
      category: 'Salon',
      emoji: '✂️',
      rating: 4.5,
      reviewCount: 89,
      location: 'Al Khor, Qatar',
      openNow: true,
      closingTime: '9:00 PM',
      languages: ['Urdu', 'Hindi', 'Arabic'],
      phone: '+974 4471 3344',
      whatsapp: '+974 5522 3344',
      yearsActive: 3,
      speciality: 'Indian & Arabic styles',
      trustScore: 88,
    ),
    BusinessListing(
      id: 'biz-4',
      name: 'Qatar AC Repair Services',
      category: 'AC & Repair',
      emoji: '❄️',
      rating: 4.7,
      reviewCount: 67,
      location: 'Al Khor & Doha',
      openNow: true,
      closingTime: '8:00 PM',
      languages: ['Urdu', 'English', 'Arabic'],
      phone: '+974 4472 5566',
      whatsapp: '+974 5533 4455',
      yearsActive: 6,
      speciality: 'Fast AC repair, 50 QR call',
      trustScore: 92,
    ),
    BusinessListing(
      id: 'biz-5',
      name: 'Indian PRO Services Qatar',
      category: 'PRO Services',
      emoji: '📋',
      rating: 4.9,
      reviewCount: 312,
      location: 'Doha, Qatar',
      openNow: true,
      closingTime: '6:00 PM',
      languages: ['Hindi', 'Urdu', 'English'],
      phone: '+974 4499 8877',
      whatsapp: '+974 5544 6677',
      yearsActive: 7,
      speciality: 'Visa, QID, document assistance',
      trustScore: 97,
    ),
    BusinessListing(
      id: 'biz-6',
      name: 'Al Meera Indian Groceries',
      category: 'Grocery',
      emoji: '🛒',
      rating: 4.4,
      reviewCount: 45,
      location: 'Al Khor, Qatar',
      openNow: true,
      closingTime: '11:30 PM',
      languages: ['Hindi', 'Urdu', 'English'],
      phone: '+974 4473 7788',
      whatsapp: '+974 5555 7788',
      yearsActive: 2,
      speciality: 'Indian spices & vegetables',
      trustScore: 78,
    ),
    BusinessListing(
      id: 'biz-7',
      name: 'Aster Medical Center Al Khor',
      category: 'Clinic',
      emoji: '🏥',
      rating: 4.8,
      reviewCount: 178,
      location: 'Al Khor, Qatar',
      openNow: true,
      closingTime: '9:00 PM',
      languages: ['Hindi', 'Urdu', 'Malayalam', 'English'],
      phone: '+974 4444 9999',
      yearsActive: 8,
      speciality: 'Doctors who speak your language',
      trustScore: 94,
    ),
    BusinessListing(
      id: 'biz-8',
      name: 'Qatar Travel House',
      category: 'Travel',
      emoji: '✈️',
      rating: 4.2,
      reviewCount: 18,
      location: 'Doha, Qatar',
      openNow: false,
      closingTime: '7:00 PM',
      languages: ['English', 'Urdu', 'Hindi'],
      phone: '+974 4488 3344',
      yearsActive: 1,
      speciality: 'India & Pakistan flight bookings',
      trustScore: 62,
    ),
  ];

  List<BusinessListing> get _filteredBusinesses {
    var list = _allBusinesses;
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((b) => b.searchableText.contains(query)).toList();
    }
    final filter = _categories[_selectedCategory].filter;
    if (filter != null) {
      list = list.where((b) => b.category == filter).toList();
    }
    return list;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _levelColor(BusinessVerificationLevel level) {
    switch (level) {
      case BusinessVerificationLevel.raabtaVerified:
        return _goldColor;
      case BusinessVerificationLevel.communityVerified:
        return _greenColor;
      case BusinessVerificationLevel.listed:
        return _blueColor;
    }
  }

  String _badgeLabel(BusinessVerificationLevel level) {
    switch (level) {
      case BusinessVerificationLevel.raabtaVerified:
        return '🥇 RAABTA VERIFIED';
      case BusinessVerificationLevel.communityVerified:
        return '✓ COMMUNITY VERIFIED';
      case BusinessVerificationLevel.listed:
        return '📋 LISTED';
    }
  }

  String _levelSubtitle(BusinessVerificationLevel level) {
    switch (level) {
      case BusinessVerificationLevel.raabtaVerified:
        return 'Raabta Verified Business';
      case BusinessVerificationLevel.communityVerified:
        return 'Community Verified Business';
      case BusinessVerificationLevel.listed:
        return 'New Listing — Verification Pending';
    }
  }

  String _languageFlag(String language) {
    switch (language.toLowerCase()) {
      case 'urdu':
        return '🇵🇰';
      case 'hindi':
        return '🇮🇳';
      case 'arabic':
        return '🇶🇦';
      case 'malayalam':
        return '🇮🇳';
      case 'english':
        return '🇬🇧';
      case 'filipino':
        return '🇵🇭';
      default:
        return '🌐';
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openDirections(BusinessListing business) {
    _openUrl(
      'https://maps.google.com/?q=${Uri.encodeComponent('${business.name} ${business.location}')}',
    );
  }

  List<String> _sampleReviews(BusinessListing business) {
    return [
      '"Great service and very friendly staff. Highly recommended!" — Community member',
      '"Been using ${business.name} for over a year. Always reliable." — Verified user',
      '"Speaks ${business.languages.isNotEmpty ? business.languages.first : 'English'} — very helpful for expats." — Raabta user',
    ];
  }

  List<String> _trustAnalysisLines(BusinessListing business, TrustScoreBreakdown trust) {
    return [
      '✓ Registered business in Qatar',
      '✓ ${business.reviewCount} community reviews verified',
      if (!business.hasReports) '✓ No fraud reports in 12 months',
      if (business.yearsActive >= 2) '✓ Active ${business.yearsActive}+ years',
      if (business.languages.isNotEmpty)
        '✓ Languages verified by community: ${business.languages.join(', ')}',
      'Overall Trust: ${trust.total}/100 — ${_recommendation(trust.total)}',
    ];
  }

  String _recommendation(int score) {
    if (score >= 90) return 'Highly Recommended';
    if (score >= 75) return 'Recommended';
    if (score >= 60) return 'Use with Caution';
    return 'Needs More Reviews';
  }

  void _showBusinessDetail(BusinessListing business) {
    final trust = getTrustScore(business);
    final color = _levelColor(trust.level);

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
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: color.withValues(alpha: 0.15),
                        child: Text(business.emoji, style: const TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              business.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              business.category,
                              style: const TextStyle(color: _subtitleColor),
                            ),
                          ],
                        ),
                      ),
                      _VerificationBadge(
                        label: _badgeLabel(trust.level),
                        color: color,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (business.description != null)
                    Text(
                      business.description!,
                      style: const TextStyle(color: _subtitleColor, height: 1.5),
                    ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border(left: BorderSide(color: color, width: 3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🤖 Raabta AI Trust Analysis',
                          style: TextStyle(
                            color: _cyanColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ..._trustAnalysisLines(business, trust).map(
                          (line) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(line, style: TextStyle(color: color, height: 1.4)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _TrustScoreBar(score: trust.total, color: color),
                        const SizedBox(height: 6),
                        Text(
                          'Reviews ${trust.reviewsScore} + Rating ${trust.ratingScore} + Activity ${trust.activityScore}',
                          style: const TextStyle(color: _subtitleColor, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Community Reviews',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._sampleReviews(business).map(
                    (review) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        review,
                        style: const TextStyle(color: _subtitleColor, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openUrl('tel:${business.phone}'),
                          icon: const Icon(Icons.phone, size: 18),
                          label: const Text('Call'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _cyanColor,
                            side: BorderSide(color: _cyanColor.withValues(alpha: 0.5)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: business.hasWhatsApp
                              ? () => _openUrl(
                                    'https://wa.me/${business.whatsapp!.replaceAll(RegExp(r'[^0-9]'), '')}',
                                  )
                              : null,
                          icon: const Icon(Icons.chat, size: 18),
                          label: const Text('WhatsApp'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _cyanColor,
                            side: BorderSide(color: _cyanColor.withValues(alpha: 0.5)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddBusinessSheet() {
    final nameController = TextEditingController();
    final locationController = TextEditingController(text: 'Qatar');
    final phoneController = TextEditingController();
    final whatsappController = TextEditingController();
    final descriptionController = TextEditingController();
    var selectedCategory = _categories[1].filter ?? 'Restaurant';
    final languageOptions = ['English', 'Urdu', 'Hindi', 'Arabic', 'Malayalam'];
    final selectedLanguages = <String>{'English'};

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
                      'Add Business',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FormField(controller: nameController, hint: 'Business name'),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      dropdownColor: _backgroundColor,
                      style: const TextStyle(color: Colors.white),
                      decoration: _fieldDecoration('Category'),
                      items: _categories
                          .where((c) => c.filter != null)
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.filter,
                              child: Text('${c.emoji} ${c.label}'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setSheetState(() => selectedCategory = v);
                      },
                    ),
                    const SizedBox(height: 10),
                    _FormField(controller: locationController, hint: 'Location'),
                    const SizedBox(height: 10),
                    _FormField(
                      controller: phoneController,
                      hint: 'Phone (+974...)',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    _FormField(
                      controller: whatsappController,
                      hint: 'WhatsApp (+974...)',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Languages spoken',
                      style: TextStyle(color: _subtitleColor, fontSize: 13),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: languageOptions.map((lang) {
                        final selected = selectedLanguages.contains(lang);
                        return FilterChip(
                          label: Text('${_languageFlag(lang)} $lang'),
                          selected: selected,
                          onSelected: (v) {
                            setSheetState(() {
                              if (v) {
                                selectedLanguages.add(lang);
                              } else {
                                selectedLanguages.remove(lang);
                              }
                            });
                          },
                          selectedColor: _cyanColor.withValues(alpha: 0.2),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    _FormField(
                      controller: descriptionController,
                      hint: 'Brief description',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          if (nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Enter business name')),
                            );
                            return;
                          }
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Submitted for Raabta AI Verification. '
                                'Verification takes 2-3 business days.',
                              ),
                              backgroundColor: _greenColor,
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: _cyanColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Submit for Raabta AI Verification',
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

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _subtitleColor),
      filled: true,
      fillColor: _backgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final businesses = _filteredBusinesses;

    return Scaffold(
      backgroundColor: _backgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBusinessSheet,
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
                          '🏪 Qatar Businesses',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Verified expat-friendly services',
                          style: TextStyle(color: _subtitleColor, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _showAddBusinessSheet,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Business'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: _cyanColor,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  hintText: 'Search restaurants, salons, shops...',
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
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final selected = _selectedCategory == index;
                  return FilterChip(
                    label: Text('${cat.emoji} ${cat.label}'),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedCategory = index),
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
              child: businesses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.store_outlined,
                              color: _subtitleColor, size: 48),
                          const SizedBox(height: 12),
                          const Text(
                            'No businesses found',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _selectedCategory = 0;
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
                      itemCount: businesses.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final business = businesses[index];
                        final trust = getTrustScore(business);
                        final color = _levelColor(trust.level);

                        return GestureDetector(
                          onTap: () => _showBusinessDetail(business),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.07),
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: color.withValues(alpha: 0.15),
                                      child: Text(
                                        business.emoji,
                                        style: const TextStyle(fontSize: 22),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            business.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            business.category,
                                            style: const TextStyle(
                                              color: _subtitleColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _VerificationBadge(
                                      label: _badgeLabel(trust.level),
                                      color: color,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      '⭐ ${business.rating.toStringAsFixed(1)}',
                                      style: const TextStyle(
                                        color: _goldColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '(${business.reviewCount} reviews)',
                                      style: const TextStyle(
                                        color: _subtitleColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: business.openNow
                                            ? _greenColor.withValues(alpha: 0.15)
                                            : _scamChipColor()
                                                .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        business.openNow
                                            ? 'Open · Closes ${business.closingTime ?? 'late'}'
                                            : 'Closed',
                                        style: TextStyle(
                                          color: business.openNow
                                              ? _greenColor
                                              : _subtitleColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '📍 ${business.location}',
                                  style: const TextStyle(
                                    color: _subtitleColor,
                                    fontSize: 12,
                                  ),
                                ),
                                if (business.languages.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: business.languages.map((lang) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _backgroundColor,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: const Color(0xFF1A2535),
                                          ),
                                        ),
                                        child: Text(
                                          '${_languageFlag(lang)} $lang',
                                          style: const TextStyle(
                                            color: _subtitleColor,
                                            fontSize: 10,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Text(
                                  business.speciality,
                                  style: const TextStyle(
                                    color: _subtitleColor,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _backgroundColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '🤖 Trust Score: ${trust.total}/100',
                                        style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _TrustScoreBar(score: trust.total, color: color),
                                      const SizedBox(height: 6),
                                      Text(
                                        _levelSubtitle(trust.level),
                                        style: TextStyle(color: color, fontSize: 11),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Reviews ${trust.reviewsScore} + Rating ${trust.ratingScore} + Activity ${trust.activityScore}',
                                        style: const TextStyle(
                                          color: _subtitleColor,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () =>
                                            _openUrl('tel:${business.phone}'),
                                        icon: const Icon(Icons.phone, size: 16),
                                        label: const Text('Call'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: _cyanColor,
                                          side: BorderSide(
                                            color: _cyanColor.withValues(alpha: 0.5),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: business.hasWhatsApp
                                            ? () => _openUrl(
                                                  'https://wa.me/${business.whatsapp!.replaceAll(RegExp(r'[^0-9]'), '')}',
                                                )
                                            : null,
                                        icon: const Icon(Icons.chat, size: 16),
                                        label: const Text('WhatsApp'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: _cyanColor,
                                          side: BorderSide(
                                            color: _cyanColor.withValues(alpha: 0.5),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _openDirections(business),
                                        icon: const Icon(Icons.directions, size: 16),
                                        label: const Text('Directions'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: _cyanColor,
                                          side: BorderSide(
                                            color: _cyanColor.withValues(alpha: 0.5),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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

  Color _scamChipColor() => const Color(0xFFEF4444);
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
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TrustScoreBar extends StatelessWidget {
  const _TrustScoreBar({required this.score, required this.color});

  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: score / 100,
        minHeight: 6,
        backgroundColor: Colors.white.withValues(alpha: 0.08),
        color: color,
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
