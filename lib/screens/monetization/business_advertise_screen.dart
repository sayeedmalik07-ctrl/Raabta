import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const kFeaturedBusinessPrice = 99;
const kSpotlightPrice = 249;
const kBannerPrice = 499;

class BusinessAdvertiseScreen extends ConsumerStatefulWidget {
  const BusinessAdvertiseScreen({super.key});

  @override
  ConsumerState<BusinessAdvertiseScreen> createState() =>
      _BusinessAdvertiseScreenState();
}

class _BusinessAdvertiseScreenState
    extends ConsumerState<BusinessAdvertiseScreen> {
  int? _selectedPackage;

  final List<Map<String, dynamic>> _adPackages = [
    {
      'index': 0,
      'tier': 'Basic Listing',
      'price': 0,
      'period': 'Forever Free',
      'icon': '📋',
      'borderColor': Colors.white24,
      'accentColor': Colors.white54,
      'badge': null,
      'features': [
        'Basic business profile',
        'Community reviews',
        'Map location pin',
        'Contact info display',
      ],
      'buttonLabel': 'Already Included',
      'buttonEnabled': false,
    },
    {
      'index': 1,
      'tier': 'Featured Business',
      'price': kFeaturedBusinessPrice,
      'period': '/month',
      'icon': '⭐',
      'borderColor': const Color(0xFFFFB627),
      'accentColor': const Color(0xFFFFB627),
      'badge': 'POPULAR',
      'features': [
        '"Featured" gold badge on profile',
        'Top placement in your category',
        'Homepage featured businesses section',
        'WhatsApp priority contact button',
        'Business analytics (views + clicks)',
      ],
      'buttonLabel': 'Get Featured — $kFeaturedBusinessPrice QR/mo',
      'buttonEnabled': true,
    },
    {
      'index': 2,
      'tier': 'Business Spotlight',
      'price': kSpotlightPrice,
      'period': '/month',
      'icon': '🔦',
      'borderColor': const Color(0xFF00D4FF),
      'accentColor': const Color(0xFF00D4FF),
      'badge': 'BEST VALUE',
      'features': [
        'Everything in Featured, plus:',
        'Banner in Community feed',
        'AI feed sponsored post (weekly)',
        '"Company Spotlight" on Jobs screen',
        'Full analytics dashboard',
        'Monthly performance report',
      ],
      'buttonLabel': 'Get Spotlight — $kSpotlightPrice QR/mo',
      'buttonEnabled': true,
    },
    {
      'index': 3,
      'tier': 'Banner Advertising',
      'price': kBannerPrice,
      'period': '/month',
      'icon': '📢',
      'borderColor': const Color(0xFF6C3FC5),
      'accentColor': const Color(0xFF6C3FC5),
      'badge': 'MAX REACH',
      'features': [
        'Everything in Spotlight, plus:',
        'Home screen banner placement',
        'Push notification to 10,000 users',
        'Targeted by nationality & interest',
        'Monthly performance report',
        'Dedicated account manager',
      ],
      'buttonLabel': 'Get Max Reach — $kBannerPrice QR/mo',
      'buttonEnabled': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '📢 Advertise on Raabta',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReachBanner(),
            const SizedBox(height: 20),
            const Text(
              'Choose your advertising plan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Reach Qatar expats where they live, work, and shop',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ..._adPackages.map(_buildAdCard),
            const SizedBox(height: 20),
            _buildWhySection(),
            const SizedBox(height: 20),
            _buildContactCTA(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildReachBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF252540)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your audience in Qatar',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _reachStat('50K+', 'Monthly\nUsers', const Color(0xFFFFB627)),
              _dividerV(),
              _reachStat('8', 'Languages\nSupported', const Color(0xFF00D4FF)),
              _dividerV(),
              _reachStat('12+', 'Expat\nNationalities', const Color(0xFF6C3FC5)),
              _dividerV(),
              _reachStat('4.8★', 'App\nRating', const Color(0xFFFFB627)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reachStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }

  Widget _dividerV() {
    return Container(width: 1, height: 36, color: Colors.white12);
  }

  Widget _buildAdCard(Map<String, dynamic> pkg) {
    final isSelected = _selectedPackage == pkg['index'];
    final accent = pkg['accentColor'] as Color;
    final border = pkg['borderColor'] as Color;
    final enabled = pkg['buttonEnabled'] as bool;

    return GestureDetector(
      onTap: enabled
          ? () => setState(() => _selectedPackage = pkg['index'])
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? border
                : border.withValues(alpha: enabled ? 0.5 : 0.2),
            width: isSelected ? 2 : 1,
          ),
          color: const Color(0xFF1A1A2E),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.2),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        pkg['icon'] as String,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pkg['tier'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              pkg['price'] == 0
                                  ? pkg['period'] as String
                                  : '${pkg['price']} QR${pkg['period']}',
                              style: TextStyle(
                                color: pkg['price'] == 0
                                    ? Colors.white38
                                    : accent,
                                fontSize: pkg['price'] == 0 ? 12 : 18,
                                fontWeight: pkg['price'] == 0
                                    ? FontWeight.normal
                                    : FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...(pkg['features'] as List<String>).map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            f.endsWith(':')
                                ? Icons.arrow_forward
                                : Icons.check_circle,
                            color: f.endsWith(':')
                                ? Colors.white38
                                : (enabled ? accent : Colors.white24),
                            size: 15,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              f,
                              style: TextStyle(
                                color: f.endsWith(':')
                                    ? Colors.white54
                                    : Colors.white70,
                                fontSize: 12,
                                fontStyle: f.endsWith(':')
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (enabled) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _selectedPackage = pkg['index']);
                          _handleAdSubscribe(pkg);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? accent
                              : accent.withValues(alpha: 0.15),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(color: accent, width: 1),
                        ),
                        child: Text(
                          pkg['buttonLabel'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? (accent == const Color(0xFFFFB627)
                                    ? Colors.black
                                    : Colors.white)
                                : accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (pkg['badge'] != null)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    pkg['badge'] as String,
                    style: TextStyle(
                      color: accent == const Color(0xFFFFB627)
                          ? Colors.black
                          : Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Why advertise on Raabta?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...[
            [
              '🎯',
              'Hyper-targeted',
              'Reach by nationality, job type, and neighbourhood',
            ],
            [
              '📱',
              'Mobile-first',
              'Users spend avg. 18 min/session in the app',
            ],
            [
              '🌍',
              'Multilingual',
              "Your ad shown in user's own language automatically",
            ],
            [
              '📊',
              'Measurable',
              'Real-time dashboard — clicks, views, contacts',
            ],
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item[0], style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item[1],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          item[2],
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCTA() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C3FC5).withValues(alpha: 0.2),
            const Color(0xFFFFB627).withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF6C3FC5).withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Need a custom package?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Contact our business team for bulk deals,\ncampaigns, or sponsorships',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('📲 Opening business enquiry…'),
                    backgroundColor: Color(0xFF6C3FC5),
                  ),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline, size: 16),
              label: const Text('Contact Business Team'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFFB627),
                side: const BorderSide(color: Color(0xFFFFB627), width: 1),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAdSubscribe(Map<String, dynamic> pkg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '📢 ${pkg['tier']} selected — ${pkg['price']} QR/mo. Redirecting…',
        ),
        backgroundColor: const Color(0xFF6C3FC5),
      ),
    );
  }
}
