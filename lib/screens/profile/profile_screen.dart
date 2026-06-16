import 'package:flutter/material.dart';
import 'package:raabta/screens/reviews/workplace_reviews_screen.dart';
import 'package:raabta/screens/reviews/write_review_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);
  static const Color _whatsappGreen = Color(0xFF25D366);

  static const List<_QuickAction> _quickActions = [
    _QuickAction(emoji: '⭐', title: 'My Points & Rewards'),
    _QuickAction(emoji: '📋', title: 'My Listings'),
    _QuickAction(emoji: '❤️', title: 'Saved Items'),
    _QuickAction(emoji: '🔔', title: 'Notifications Settings'),
    _QuickAction(emoji: '🌐', title: 'Language: English'),
    _QuickAction(emoji: '📞', title: 'Help & Support'),
    _QuickAction(emoji: '⚖️', title: 'Legal & Privacy'),
    _QuickAction(emoji: '🚪', title: 'Sign Out', isDestructive: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            const Text(
              '👤 Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildHeaderCard(context),
            const SizedBox(height: 20),
            _buildRewardsCard(context),
            const SizedBox(height: 20),
            _buildStatsRow(),
            const SizedBox(height: 20),
            _buildReferralCard(context),
            const SizedBox(height: 24),
            const Text(
              'Quick Actions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._quickActions.map((action) => _QuickActionTile(action: action)),
            const SizedBox(height: 24),
            _buildReviewCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: _cyanColor.withValues(alpha: 0.2),
            child: const Text(
              'MS',
              style: TextStyle(
                color: _cyanColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Mohammad Sayeed',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '🇮🇳 Indian',
            style: TextStyle(color: _subtitleColor, fontSize: 15),
          ),
          const SizedBox(height: 4),
          const Text(
            'Member since June 2025',
            style: TextStyle(color: _subtitleColor, fontSize: 14),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: _cyanColor,
              side: const BorderSide(color: _cyanColor),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Edit Profile',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0D1520),
            _cyanColor.withValues(alpha: 0.15),
            const Color(0xFF0A1825),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cyanColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⭐ Raabta Rewards',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '250 Points',
            style: TextStyle(
              color: _cyanColor,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _cyanColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Explorer 🗺️',
                  style: TextStyle(
                    color: _cyanColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 250 / 500,
              minHeight: 8,
              backgroundColor: _backgroundColor,
              color: _cyanColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '250 / 500 to next level "Connector"',
            style: TextStyle(color: _subtitleColor, fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'How to earn more →',
              style: TextStyle(
                color: _cyanColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _StatBox(label: 'Listings Posted', value: '3')),
        const SizedBox(width: 10),
        Expanded(child: _StatBox(label: 'Questions Asked', value: '7')),
        const SizedBox(width: 10),
        Expanded(child: _StatBox(label: 'Community Posts', value: '12')),
      ],
    );
  }

  Widget _buildReferralCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '👥 Invite Friends, Earn Points',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Share your unique link and earn 50 points per friend',
            style: TextStyle(color: _subtitleColor, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _cyanColor.withValues(alpha: 0.3),
                style: BorderStyle.solid,
              ),
            ),
            child: const Text(
              'SAYEED2025',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _cyanColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share, size: 20),
              label: const Text(
                'Share Invite Link',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _whatsappGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              '3 friends joined · 150 points earned',
              style: TextStyle(color: _subtitleColor, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: _cyanColor, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📝 Review an Employer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Share your experience anonymously',
            style: TextStyle(color: _subtitleColor, fontSize: 14),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const WorkplaceReviewsScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const Text(
              'Browse all reviews →',
              style: TextStyle(
                color: _cyanColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const WriteReviewScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _cyanColor,
                side: const BorderSide(color: _cyanColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Write a Review',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.emoji,
    required this.title,
    this.isDestructive = false,
  });

  final String emoji;
  final String title;
  final bool isDestructive;
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action});

  final _QuickAction action;

  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);

  @override
  Widget build(BuildContext context) {
    final textColor = action.isDestructive ? Colors.redAccent : Colors.white;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () {},
        leading: Text(action.emoji, style: const TextStyle(fontSize: 22)),
        title: Text(
          action.title,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: action.isDestructive ? Colors.redAccent : _subtitleColor,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});

  final String label;
  final String value;

  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: _cyanColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _subtitleColor,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
