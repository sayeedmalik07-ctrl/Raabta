import 'package:flutter/material.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);

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
      badgeColor: Color(0xFFF59E0B),
      headline: 'New e-visa system launching for GCC visitors',
      source: 'Gulf Times',
      time: '2 hours ago',
      summary:
          'Qatar announces a streamlined e-visa portal for GCC nationals visiting for tourism and business purposes.',
    ),
    _NewsItem(
      category: 'Jobs',
      badgeColor: Color(0xFF3B82F6),
      headline: 'Qatar hiring 50,000 workers for 2026 projects',
      source: 'Qatar Tribune',
      time: '5 hours ago',
      summary:
          'Major infrastructure and World Cup legacy projects drive demand for skilled expat workers across sectors.',
    ),
    _NewsItem(
      category: 'Traffic',
      badgeColor: Color(0xFF22C55E),
      headline: 'Doha Expressway lane expansion complete',
      source: 'Ministry of Transport',
      time: '1 day ago',
      summary:
          'New lanes on the Doha Expressway reduce peak-hour congestion between Al Wakrah and central Doha.',
    ),
    _NewsItem(
      category: 'Government',
      badgeColor: Color(0xFFEF4444),
      headline: 'New labour law amendment on overtime pay',
      source: 'Ministry of Labour',
      time: '2 days ago',
      summary:
          'Updated regulations clarify overtime rates and employer obligations for workers across Qatar.',
    ),
    _NewsItem(
      category: 'Visa',
      badgeColor: Color(0xFFF59E0B),
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
      color: _backgroundColor,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, widget.embedded ? 16 : 16, 20, 24),
        children: [
          if (!widget.embedded)
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const Expanded(child: _Header()),
              ],
            )
          else
            const _Header(),
          const SizedBox(height: 16),
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
          if (news.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No news in this category',
                  style: TextStyle(color: _subtitleColor),
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

  static const Color _subtitleColor = Color(0xFF8A9BB0);

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📰 Qatar Today',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'News that matters to expats',
          style: TextStyle(color: _subtitleColor, fontSize: 14),
        ),
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
  });

  final String category;
  final Color badgeColor;
  final String headline;
  final String source;
  final String time;
  final String summary;
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.item});

  final _NewsItem item;

  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: item.badgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
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
          const SizedBox(height: 10),
          Text(
            item.headline,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${item.source} · ${item.time}',
            style: const TextStyle(color: _subtitleColor, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Text(
            item.summary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _subtitleColor,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Read more →',
              style: TextStyle(
                color: _cyanColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
