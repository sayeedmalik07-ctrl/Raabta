import 'package:flutter/material.dart';
import 'package:raabta/screens/reviews/write_review_screen.dart';

class WorkplaceReviewsScreen extends StatefulWidget {
  const WorkplaceReviewsScreen({super.key});

  @override
  State<WorkplaceReviewsScreen> createState() => _WorkplaceReviewsScreenState();
}

class _WorkplaceReviewsScreenState extends State<WorkplaceReviewsScreen> {
  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);

  final TextEditingController _searchController = TextEditingController();

  static const List<String> _filters = [
    'All',
    'Companies',
    'Accommodation',
    'Agencies',
  ];

  int _selectedFilter = 0;

  static const List<_CompanyReview> _companies = [
    _CompanyReview(
      name: 'QatarEnergy LNG',
      industry: 'Oil & Gas',
      initials: 'QL',
      overallRating: 4.5,
      salaryRating: 4.5,
      housingRating: 4.2,
      managementRating: 4.3,
      workLifeRating: 4.0,
      reviewCount: 234,
      snippet: 'Salary always on time, good benefits package for expats.',
      type: 'Companies',
    ),
    _CompanyReview(
      name: 'Hamad Medical Corporation',
      industry: 'Healthcare',
      initials: 'HM',
      overallRating: 4.2,
      salaryRating: 4.0,
      housingRating: 3.8,
      managementRating: 4.1,
      workLifeRating: 3.9,
      reviewCount: 156,
      snippet: 'Great learning environment but long shifts in some departments.',
      type: 'Companies',
    ),
    _CompanyReview(
      name: 'Qatar Airways',
      industry: 'Aviation',
      initials: 'QA',
      overallRating: 4.1,
      salaryRating: 4.2,
      housingRating: 4.0,
      managementRating: 3.9,
      workLifeRating: 3.5,
      reviewCount: 89,
      snippet: 'Excellent travel benefits, competitive salary structure.',
      type: 'Companies',
    ),
    _CompanyReview(
      name: 'EMCO Qatar',
      industry: 'FM Maintenance',
      initials: 'EQ',
      overallRating: 4.0,
      salaryRating: 4.0,
      housingRating: 3.8,
      managementRating: 4.0,
      workLifeRating: 3.5,
      reviewCount: 88,
      snippet: 'Stable company with regular salary payments.',
      type: 'Companies',
    ),
    _CompanyReview(
      name: 'Ashghal',
      industry: 'Construction',
      initials: 'AG',
      overallRating: 3.5,
      salaryRating: 3.8,
      housingRating: 3.5,
      managementRating: 3.2,
      workLifeRating: 3.0,
      reviewCount: 67,
      snippet: 'Government project work, decent pay but demanding hours.',
      type: 'Companies',
    ),
    _CompanyReview(
      name: 'DOPET Qatar',
      industry: 'Oil & Gas Maintenance',
      initials: 'DQ',
      overallRating: 4.5,
      salaryRating: 4.5,
      housingRating: 4.0,
      managementRating: 4.2,
      workLifeRating: 4.0,
      reviewCount: 52,
      snippet: 'Good overtime pay and accommodation provided.',
      type: 'Companies',
    ),
  ];

  List<_CompanyReview> get _filteredCompanies {
    final query = _searchController.text.trim().toLowerCase();
    var list = _companies;
    if (_selectedFilter > 0) {
      final filter = _filters[_selectedFilter];
      list = list.where((c) => c.type == filter).toList();
    }
    if (query.isNotEmpty) {
      list = list
          .where((c) => c.name.toLowerCase().contains(query))
          .toList();
    }
    return list;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final companies = _filteredCompanies;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WriteReviewScreen()),
              );
            },
            child: const Text(
              'Write Review',
              style: TextStyle(
                color: _cyanColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            const Text(
              '📝 Workplace Reviews',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Anonymous honest reviews from expats',
              style: TextStyle(color: _subtitleColor, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _cyanColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _cyanColor.withValues(alpha: 0.3)),
              ),
              child: const Text(
                '🔒 100% Anonymous · Your identity is never revealed',
                style: TextStyle(
                  color: _cyanColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search company name...',
                hintStyle: const TextStyle(color: _subtitleColor),
                prefixIcon: const Icon(Icons.search, color: _subtitleColor),
                filled: true,
                fillColor: _surfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilter == index;
                  return FilterChip(
                    label: Text(_filters[index]),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedFilter = index),
                    backgroundColor: _surfaceColor,
                    selectedColor: _cyanColor.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? _cyanColor : _subtitleColor,
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? _cyanColor : Colors.transparent,
                    ),
                    showCheckmark: false,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ...companies.map((company) => _CompanyCard(company: company)),
          ],
        ),
      ),
    );
  }
}

class _CompanyReview {
  const _CompanyReview({
    required this.name,
    required this.industry,
    required this.initials,
    required this.overallRating,
    required this.salaryRating,
    required this.housingRating,
    required this.managementRating,
    required this.workLifeRating,
    required this.reviewCount,
    required this.snippet,
    required this.type,
  });

  final String name;
  final String industry;
  final String initials;
  final double overallRating;
  final double salaryRating;
  final double housingRating;
  final double managementRating;
  final double workLifeRating;
  final int reviewCount;
  final String snippet;
  final String type;
}

class _CompanyCard extends StatelessWidget {
  const _CompanyCard({required this.company});

  final _CompanyReview company;

  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);
  static const Color _starColor = Color(0xFFF59E0B);

  String _stars(double rating) {
    final full = rating.floor().clamp(0, 5);
    final half = (rating - full) >= 0.5;
    final empty = 5 - full - (half ? 1 : 0);
    return '${'★' * full}${half ? '½' : ''}${'☆' * empty}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF1A2535),
                child: Text(
                  company.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      company.industry,
                      style: const TextStyle(
                        color: _subtitleColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                _stars(company.overallRating),
                style: const TextStyle(color: _starColor, fontSize: 16),
              ),
              const SizedBox(width: 8),
              Text(
                company.overallRating.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '💰 Salary: ⭐${company.salaryRating.toStringAsFixed(1)}  '
            '🏠 Housing: ⭐${company.housingRating.toStringAsFixed(1)}',
            style: const TextStyle(color: _subtitleColor, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            '👔 Management: ⭐${company.managementRating.toStringAsFixed(1)}  '
            '📅 Work-Life: ⭐${company.workLifeRating.toStringAsFixed(1)}',
            style: const TextStyle(color: _subtitleColor, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Text(
            '${company.reviewCount} reviews',
            style: const TextStyle(
              color: _cyanColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"${company.snippet}"',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _subtitleColor,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: _cyanColor,
                side: const BorderSide(color: _cyanColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Read Reviews',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
