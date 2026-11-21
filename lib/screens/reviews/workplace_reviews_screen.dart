import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/reviews/l10n/workplace_review_strings.dart';
import 'package:raabta/screens/reviews/write_review_screen.dart';

class WorkplaceReviewsScreen extends ConsumerStatefulWidget {
  const WorkplaceReviewsScreen({super.key});

  @override
  ConsumerState<WorkplaceReviewsScreen> createState() =>
      _WorkplaceReviewsScreenState();
}

class _WorkplaceReviewsScreenState extends ConsumerState<WorkplaceReviewsScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const _filterKeys = ['all', 'companies', 'accommodation', 'agencies'];

  String _filterLabel(String key, String locale) {
    switch (key) {
      case 'all':
        return WorkplaceReviewStrings.t('filter_all', locale);
      case 'companies':
        return WorkplaceReviewStrings.t('filter_companies', locale);
      case 'accommodation':
        return WorkplaceReviewStrings.t('filter_accommodation', locale);
      case 'agencies':
        return WorkplaceReviewStrings.t('filter_agencies', locale);
      default:
        return key;
    }
  }

  String? _filterTypeForKey(String key) {
    switch (key) {
      case 'companies':
        return 'Companies';
      case 'accommodation':
        return 'Accommodation';
      case 'agencies':
        return 'Agencies';
      default:
        return null;
    }
  }

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
      final filter = _filterTypeForKey(_filterKeys[_selectedFilter]);
      if (filter != null) {
        list = list.where((c) => c.type == filter).toList();
      }
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
    final locale = ref.watch(userLanguageProvider);
    final companies = _filteredCompanies;

    return GlassScreenScaffold(
      leading: GlassIconButton(
        icon: Icons.arrow_back_ios_rounded,
        tooltip: CommonActionStrings.t('action_back', locale),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        GlassCard(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WriteReviewScreen()),
            );
          },
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          borderRadius: AppSpacing.radiusFull,
          glowColor: AppColors.cyanGlow,
          glowIntensity: 0.15,
          margin: const EdgeInsets.only(right: AppSpacing.sm),
          child: Text(
            WorkplaceReviewStrings.t('write_review', locale),
            style: AppTypography.link,
          ),
        ),
      ],
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      body: ListView(
        children: [
          Text(
            WorkplaceReviewStrings.t('screen_title', locale),
            style: AppTypography.headline2,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            WorkplaceReviewStrings.t('screen_subtitle', locale),
            style: AppTypography.body,
          ),
          const SizedBox(height: AppSpacing.md),
          GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.md),
            borderRadius: AppSpacing.radiusSm,
            glowColor: AppColors.cyanGlow,
            glowIntensity: 0.12,
            child: Text(
              WorkplaceReviewStrings.t('anon_banner', locale),
              style: AppTypography.subtitle.copyWith(
                color: AppColors.cyanGlow,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GlassContainer(
            padding: EdgeInsets.zero,
            borderRadius: AppSpacing.radiusSm,
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: AppTypography.body.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: WorkplaceReviewStrings.t('search_hint', locale),
                hintStyle: AppTypography.body.copyWith(
                  color: AppColors.textTertiary,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                  size: AppSpacing.iconMd,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filterKeys.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final isSelected = _selectedFilter == index;
                return GlassCard(
                  onTap: () => setState(() => _selectedFilter = index),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  borderRadius: AppSpacing.radiusFull,
                  glowColor: isSelected ? AppColors.cyanGlow : null,
                  glowIntensity: isSelected ? 0.2 : 0,
                  child: Text(
                    _filterLabel(_filterKeys[index], locale),
                    style: AppTypography.chipLabel.copyWith(
                      color: isSelected
                          ? AppColors.cyanGlow
                          : AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (companies.isEmpty)
            GlassEmptyState(
              icon: Icons.search_off_outlined,
              title: WorkplaceReviewStrings.t('empty_title', locale),
              description: WorkplaceReviewStrings.t('empty_description', locale),
            )
          else
            ...companies.map(
              (company) => _CompanyCard(company: company, locale: locale),
            ),
        ],
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
  const _CompanyCard({required this.company, required this.locale});

  final _CompanyReview company;
  final String locale;

  String _stars(double rating) {
    final full = rating.floor().clamp(0, 5);
    final half = (rating - full) >= 0.5;
    final empty = 5 - full - (half ? 1 : 0);
    return '${'★' * full}${half ? '½' : ''}${'☆' * empty}';
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassContainer(
                padding: const EdgeInsets.all(AppSpacing.sm),
                borderRadius: AppSpacing.radiusFull,
                child: Text(
                  company.initials,
                  style: AppTypography.subtitle.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(company.name, style: AppTypography.title),
                    Text(company.industry, style: AppTypography.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                _stars(company.overallRating),
                style: AppTypography.body.copyWith(
                  color: AppColors.amberGlow,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                company.overallRating.toStringAsFixed(1),
                style: AppTypography.subtitle.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${WorkplaceReviewStrings.t('rating_salary', locale)} ⭐${company.salaryRating.toStringAsFixed(1)}  '
            '${WorkplaceReviewStrings.t('rating_housing', locale)} ⭐${company.housingRating.toStringAsFixed(1)}',
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${WorkplaceReviewStrings.t('rating_management', locale)} ⭐${company.managementRating.toStringAsFixed(1)}  '
            '${WorkplaceReviewStrings.t('rating_work_life', locale)} ⭐${company.workLifeRating.toStringAsFixed(1)}',
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            WorkplaceReviewStrings.format(
              'reviews_count',
              locale,
              params: {'count': '${company.reviewCount}'},
            ),
            style: AppTypography.link.copyWith(fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '"${company.snippet}"',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall.copyWith(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            onTap: () {},
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            borderRadius: AppSpacing.radiusSm,
            glowColor: AppColors.cyanGlow,
            glowIntensity: 0.15,
            child: Text(
              WorkplaceReviewStrings.t('read_reviews', locale),
              style: AppTypography.button.copyWith(color: AppColors.cyanGlow),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
