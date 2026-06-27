import 'package:flutter/material.dart';
import 'package:raabta/core/design/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_text_styles.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  static const List<String> _filters = [
    'All',
    'Visa',
    'Jobs',
    'Traffic',
    'Events',
    'Government',
  ];

  int _selectedFilter = 0;

  static const List<_NewsItem> _newsItems = [
    _NewsItem(
      category: 'Visa',
      badgeColor: AppColors.warning,
      headline: 'New e-visa system launching for GCC visitors',
      source: 'Gulf Times',
      time: '2 hours ago',
      summary:
          'Qatar announces a streamlined e-visa portal for GCC nationals visiting for tourism and business purposes.',
      isBreaking: true,
    ),
    _NewsItem(
      category: 'Jobs',
      badgeColor: AppColors.info,
      headline: 'Qatar hiring 50,000 workers for 2026 projects',
      source: 'Qatar Tribune',
      time: '5 hours ago',
      summary:
          'Major infrastructure and World Cup legacy projects drive demand for skilled expat workers across sectors.',
    ),
    _NewsItem(
      category: 'Traffic',
      badgeColor: AppColors.success,
      headline: 'Doha Expressway lane expansion complete',
      source: 'Ministry of Transport',
      time: '1 day ago',
      summary:
          'New lanes on the Doha Expressway reduce peak-hour congestion between Al Wakrah and central Doha.',
    ),
    _NewsItem(
      category: 'Government',
      badgeColor: AppColors.error,
      headline: 'New labour law amendment on overtime pay',
      source: 'Ministry of Labour',
      time: '2 days ago',
      summary:
          'Updated regulations clarify overtime rates and employer obligations for workers across Qatar.',
      isBreaking: true,
    ),
    _NewsItem(
      category: 'Visa',
      badgeColor: AppColors.warning,
      headline: 'Exit permit rules updated - check details',
      source: 'Metrash2',
      time: '3 days ago',
      summary:
          'Residents should review the latest exit permit requirements before planning travel outside Qatar.',
    ),
  ];

  List<_NewsItem> get _filteredNews {
    if (_selectedFilter == 0) return _newsItems;
    final filter = _filters[_selectedFilter];
    return _newsItems.where((n) => n.category == filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final news = _filteredNews;

    return ColoredBox(
      color: AppColors.background,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          widget.embedded ? AppSpacing.lg : AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xxxl,
        ),
        children: [
          if (!widget.embedded)
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
                ),
                const Expanded(child: _Header()),
              ],
            )
          else
            const _Header(),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final isSelected = _selectedFilter == index;
                return FilterChip(
                  label: Text(_filters[index]),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedFilter = index),
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                  showCheckmark: false,
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (news.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxxl),
                child: Text(
                  'No news in this category',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            )
          else
            ...news.map((item) => _NewsCard(item: item)),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('📰 Qatar Today', style: AppTextStyles.h2),
        Text('News that matters to expats', style: AppTextStyles.bodyMedium),
      ],
    );
  }
}

class _NewsItem {
  const _NewsItem({
    required this.category,
    required this.badgeColor,
    required this.headline,
    required this.source,
    required this.time,
    required this.summary,
    this.isBreaking = false,
  });

  final String category;
  final Color badgeColor;
  final String headline;
  final String source;
  final String time;
  final String summary;
  final bool isBreaking;
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.item});

  final _NewsItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: item.isBreaking
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: item.badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  item.category.toUpperCase(),
                  style: TextStyle(
                    color: item.badgeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (item.isBreaking) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    '🔥 Breaking',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(item.headline, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(Icons.source_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('${item.source} · ${item.time}', style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            item.summary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.4),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Text('Read more →', style: AppTextStyles.labelLarge),
          ),
        ],
      ),
    );
  }
}
