import 'package:flutter/material.dart';

class AskQatarScreen extends StatefulWidget {
  const AskQatarScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<AskQatarScreen> createState() => _AskQatarScreenState();
}

class _AskQatarScreenState extends State<AskQatarScreen> {
  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);

  final TextEditingController _searchController = TextEditingController();
  int _sortIndex = 0;

  static const List<String> _sortOptions = [
    'Recent',
    'Popular',
    'Unanswered',
  ];

  static const List<_Question> _questions = [
    _Question(
      title: 'Best driving school in Doha under 2000 QR?',
      category: 'Transport',
      answers: 23,
      votes: 18,
      views: 340,
      asked: '2 days ago',
    ),
    _Question(
      title: 'What is salary range for HSE Officer Qatar?',
      category: 'Jobs',
      answers: 45,
      votes: 67,
      views: 1200,
      asked: '1 week ago',
    ),
    _Question(
      title: 'Can I change sponsor without NOC in 2025?',
      category: 'Visa',
      answers: 67,
      votes: 112,
      views: 3400,
      asked: '3 days ago',
    ),
    _Question(
      title: 'Best Indian school in Al Khor?',
      category: 'Education',
      answers: 12,
      votes: 24,
      views: 890,
      asked: '5 hours ago',
    ),
  ];

  List<_Question> get _sortedQuestions {
    final list = List<_Question>.from(_questions);
    if (_sortIndex == 1) {
      list.sort((a, b) => b.votes.compareTo(a.votes));
    } else if (_sortIndex == 2) {
      list.sort((a, b) => a.answers.compareTo(b.answers));
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
    final questions = _sortedQuestions;

    return ColoredBox(
      color: _backgroundColor,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, widget.embedded ? 16 : 16, 20, 24),
        children: [
          if (!widget.embedded) ...[
            Row(
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
                        'Ask Qatar 🤔',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Get answers from the community',
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
            const SizedBox(height: 16),
          ] else ...[
            const Text(
              'Ask Qatar 🤔',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Get answers from the community',
              style: TextStyle(color: _subtitleColor, fontSize: 14),
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search questions...',
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
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Ask a Question',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _cyanColor,
                foregroundColor: _backgroundColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _sortOptions.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = _sortIndex == index;
                return FilterChip(
                  label: Text(_sortOptions[index]),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _sortIndex = index),
                  backgroundColor: _surfaceColor,
                  selectedColor: _cyanColor.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? _cyanColor : _subtitleColor,
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
          ...questions.map((q) => _QuestionCard(question: q)),
        ],
      ),
    );
  }
}

class _Question {
  const _Question({
    required this.title,
    required this.category,
    required this.answers,
    required this.votes,
    required this.views,
    required this.asked,
  });

  final String title;
  final String category;
  final int answers;
  final int votes;
  final int views;
  final String asked;
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question});

  final _Question question;

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _cyanColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  question.category,
                  style: const TextStyle(
                    color: _cyanColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                question.asked,
                style: const TextStyle(color: _subtitleColor, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            question.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Stat(icon: Icons.arrow_upward, label: '${question.votes} votes'),
              const SizedBox(width: 16),
              _Stat(
                icon: Icons.chat_bubble_outline,
                label: '${question.answers} answers',
              ),
              const SizedBox(width: 16),
              _Stat(icon: Icons.visibility_outlined, label: '${question.views} views'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  static const Color _subtitleColor = Color(0xFF8A9BB0);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _subtitleColor, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: _subtitleColor, fontSize: 12),
        ),
      ],
    );
  }
}
