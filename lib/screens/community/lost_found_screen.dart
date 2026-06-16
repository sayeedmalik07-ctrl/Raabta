import 'package:flutter/material.dart';

class LostFoundScreen extends StatefulWidget {
  const LostFoundScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<LostFoundScreen> createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends State<LostFoundScreen> {
  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _surfaceColor = Color(0xFF0D1520);

  bool _showLost = true;

  static const List<_LostFoundPost> _lostPosts = [
    _LostFoundPost(
      isLost: true,
      title: 'Black wallet near Industrial Area',
      description:
          'Lost my wallet on 13 June near Gate 3. Contains QID and cards. Please contact if found. Reward offered.',
      location: 'Industrial Area, Gate 3',
      date: '13 June 2025',
    ),
  ];

  static const List<_LostFoundPost> _foundPosts = [
    _LostFoundPost(
      isLost: false,
      title: 'Samsung phone found in Lulu Al Khor',
      description:
          'Found a Samsung Galaxy near Lulu hypermarket. Screen is locked. Owner please contact.',
      location: 'Lulu Hypermarket, Al Khor',
      date: '14 June 2025',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final posts = _showLost ? _lostPosts : _foundPosts;

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
          Container(
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ToggleButton(
                    label: 'Lost Items',
                    isSelected: _showLost,
                    onTap: () => setState(() => _showLost = true),
                  ),
                ),
                Expanded(
                  child: _ToggleButton(
                    label: 'Found Items',
                    isSelected: !_showLost,
                    onTap: () => setState(() => _showLost = false),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...posts.map((post) => _PostCard(post: post)),
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
          '🔍 Lost & Found',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Help each other in Qatar',
          style: TextStyle(color: _subtitleColor, fontSize: 14),
        ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const Color _cyanColor = Color(0xFF22D3EE);
  static const Color _subtitleColor = Color(0xFF8A9BB0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _cyanColor.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: _cyanColor)
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? _cyanColor : _subtitleColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _LostFoundPost {
  const _LostFoundPost({
    required this.isLost,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
  });

  final bool isLost;
  final String title;
  final String description;
  final String location;
  final String date;
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});

  final _LostFoundPost post;

  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _lostRed = Color(0xFFEF4444);
  static const Color _foundGreen = Color(0xFF22C55E);
  static const Color _whatsappGreen = Color(0xFF25D366);

  @override
  Widget build(BuildContext context) {
    final badgeColor = post.isLost ? _lostRed : _foundGreen;
    final badgeLabel = post.isLost ? 'LOST' : 'FOUND';
    final locationLabel = post.isLost ? 'Last seen' : 'Found at';
    final dateLabel = post.isLost ? 'Date lost' : 'Date found';
    final buttonLabel =
        post.isLost ? 'Contact WhatsApp' : 'Contact to Claim';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badgeLabel,
              style: TextStyle(
                color: badgeColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2535),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  post.isLost ? Icons.search_off : Icons.phone_android,
                  color: _subtitleColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post.description,
                      style: const TextStyle(
                        color: _subtitleColor,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$locationLabel: ${post.location}',
            style: const TextStyle(color: _subtitleColor, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            '$dateLabel: ${post.date}',
            style: const TextStyle(color: _subtitleColor, fontSize: 12),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.chat, size: 18),
              label: Text(buttonLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: _whatsappGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
