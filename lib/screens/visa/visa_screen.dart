import 'package:flutter/material.dart';

class VisaScreen extends StatelessWidget {
  const VisaScreen({super.key});

  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _subtitleColor = Color(0xFF8A9BB0);

  static const List<_VisaCategory> _categories = [
    _VisaCategory(
      emoji: '📄',
      title: 'Iqama Renewal',
      subtitle: 'Renew your residence permit',
      steps: 5,
    ),
    _VisaCategory(
      emoji: '✈️',
      title: 'Exit Permit',
      subtitle: 'Travel outside Qatar',
      steps: 4,
    ),
    _VisaCategory(
      emoji: '👨‍👩‍👧',
      title: 'Family Visa',
      subtitle: 'Bring family to Qatar',
      steps: 7,
    ),
    _VisaCategory(
      emoji: '🔄',
      title: 'Sponsor Transfer',
      subtitle: 'Change your sponsor',
      steps: 6,
    ),
    _VisaCategory(
      emoji: '🏥',
      title: 'Medical Card',
      subtitle: 'Health check requirements',
      steps: 3,
    ),
    _VisaCategory(
      emoji: '🆔',
      title: 'Qatar ID',
      subtitle: 'Apply or renew QID',
      steps: 4,
    ),
  ];

  static const List<_DeadlineItem> _deadlines = [
    _DeadlineItem(
      document: 'Iqama',
      expiryText: 'Expires in 47 days',
      urgency: _Urgency.amber,
    ),
    _DeadlineItem(
      document: 'Passport',
      expiryText: 'Expires in 180 days',
      urgency: _Urgency.green,
    ),
    _DeadlineItem(
      document: 'Work Permit',
      expiryText: 'Expires in 12 days',
      urgency: _Urgency.red,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              sliver: SliverToBoxAdapter(
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
                            'Visa & Documents',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Step-by-step guides for Qatar residents',
                            style: TextStyle(
                              color: _subtitleColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 160,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _CategoryCard(category: _categories[index]);
                  },
                  childCount: _categories.length,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⏰ My Document Deadlines',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._deadlines.map(
                      (deadline) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _DeadlineCard(deadline: deadline),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _Urgency { amber, green, red }

class _VisaCategory {
  const _VisaCategory({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.steps,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final int steps;
}

class _DeadlineItem {
  const _DeadlineItem({
    required this.document,
    required this.expiryText,
    required this.urgency,
  });

  final String document;
  final String expiryText;
  final _Urgency urgency;
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final _VisaCategory category;

  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(category.emoji, style: const TextStyle(fontSize: 32)),
          const Spacer(),
          Text(
            category.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            category.subtitle,
            style: const TextStyle(color: _subtitleColor, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _cyanColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${category.steps} steps',
              style: const TextStyle(
                color: _cyanColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeadlineCard extends StatelessWidget {
  const _DeadlineCard({required this.deadline});

  final _DeadlineItem deadline;

  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _cyanColor = Color(0xFF22D3EE);

  Color get _urgencyColor {
    switch (deadline.urgency) {
      case _Urgency.amber:
        return const Color(0xFFF59E0B);
      case _Urgency.green:
        return const Color(0xFF22C55E);
      case _Urgency.red:
        return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _urgencyColor.withValues(alpha: 0.4),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: _urgencyColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deadline.document,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  deadline.expiryText,
                  style: TextStyle(
                    color: _urgencyColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: _cyanColor,
              side: const BorderSide(color: _cyanColor),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'How to renew',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
