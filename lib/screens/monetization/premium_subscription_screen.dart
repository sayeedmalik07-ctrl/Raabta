import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const kPremiumMonthlyPrice = 15;
const kPremiumYearlyPrice = 129;
const kProMonthlyPrice = 79;
const kProYearlyPrice = 699;

class PremiumSubscriptionScreen extends ConsumerStatefulWidget {
  const PremiumSubscriptionScreen({super.key});

  @override
  ConsumerState<PremiumSubscriptionScreen> createState() =>
      _PremiumSubscriptionScreenState();
}

class _PremiumSubscriptionScreenState
    extends ConsumerState<PremiumSubscriptionScreen> {
  bool _isYearly = false;

  final List<Map<String, dynamic>> _features = [
    {
      'feature': 'AI questions per day',
      'free': '10',
      'premium': 'Unlimited',
      'pro': 'Unlimited',
    },
    {
      'feature': 'Document scans',
      'free': '5/month',
      'premium': 'Unlimited',
      'pro': 'Unlimited',
    },
    {
      'feature': 'Job applications',
      'free': '3/day',
      'premium': 'Unlimited',
      'pro': 'Unlimited',
    },
    {
      'feature': 'Ad-free experience',
      'free': false,
      'premium': true,
      'pro': true,
    },
    {
      'feature': 'Priority listings',
      'free': false,
      'premium': true,
      'pro': true,
    },
    {
      'feature': 'Advanced filters',
      'free': false,
      'premium': true,
      'pro': true,
    },
    {
      'feature': 'Direct employer contact',
      'free': false,
      'premium': true,
      'pro': true,
    },
    {
      'feature': 'Labour law AI advisor',
      'free': 'Basic',
      'premium': 'Full',
      'pro': 'Full',
    },
    {
      'feature': 'Monthly consultation',
      'free': false,
      'premium': false,
      'pro': '30 min',
    },
    {
      'feature': 'Featured listing monthly',
      'free': false,
      'premium': false,
      'pro': true,
    },
    {
      'feature': 'Business listing',
      'free': false,
      'premium': false,
      'pro': '1 free',
    },
    {
      'feature': 'Priority support',
      'free': false,
      'premium': false,
      'pro': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(),
            _buildBillingToggle(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildFreeCard(),
                  const SizedBox(height: 14),
                  _buildPremiumCard(),
                  const SizedBox(height: 14),
                  _buildProCard(),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _buildComparisonTable(),
            const SizedBox(height: 20),
            _buildTrustSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF0F0F0F)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFFB627), Color(0xFF6C3FC5)],
            ).createShader(bounds),
            child: const Text(
              '💎 Raabta Premium',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Unlock the full Qatar expat experience',
            style: TextStyle(color: Colors.white60, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _proofChip('👥', '10,000+ expats'),
              const SizedBox(width: 12),
              _proofChip('⭐', '4.8 rated'),
              const SizedBox(width: 12),
              _proofChip('🔒', 'Cancel anytime'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _proofChip(String icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Monthly',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => setState(() => _isYearly = !_isYearly),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 52,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: _isYearly
                    ? const Color(0xFFFFB627)
                    : const Color(0xFF2A2A3E),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                alignment: _isYearly
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              const Text(
                'Yearly',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                ),
                child: const Text(
                  'Save 35%',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFreeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Free',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Text(
                '0 QR',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Text(
            'Forever free',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 14),
          ...[
            '10 AI questions per day',
            '5 document scans/month',
            '3 job applications/day',
            'Basic listings',
            'Community access',
          ].map((f) => _featureRow(f, true, Colors.white54)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Current Plan',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard() {
    final price = _isYearly ? kPremiumYearlyPrice : kPremiumMonthlyPrice;
    final period = _isYearly ? '/year' : '/month';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFB627), width: 2),
        gradient: const LinearGradient(
          colors: [Color(0x1FFFB627), Color(0x08FFB627)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB627).withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
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
                    const Text(
                      'Premium ⭐',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$price',
                              style: const TextStyle(
                                color: Color(0xFFFFB627),
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                height: 1,
                              ),
                            ),
                            Text(
                              ' QR$period',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        if (_isYearly)
                          Text(
                            '= ${(price / 12).round()} QR/mo',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...[
                  'Unlimited AI questions',
                  'Unlimited document scans',
                  'Unlimited job applications',
                  'Ad-free experience',
                  'Priority listings',
                  'Advanced filters',
                  'Direct employer contact',
                  'Full labour law AI advisor',
                ].map(
                  (f) => _featureRow(f, true, const Color(0xFFFFB627)),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleSubscribe('Premium', price),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB627),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Subscribe Now',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB627),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'MOST POPULAR',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProCard() {
    final price = _isYearly ? kProYearlyPrice : kProMonthlyPrice;
    final period = _isYearly ? '/year' : '/month';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6C3FC5), width: 2),
        gradient: const LinearGradient(
          colors: [Color(0x1A6C3FC5), Color(0x086C3FC5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Pro 💎',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$price',
                          style: const TextStyle(
                            color: Color(0xFF6C3FC5),
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        Text(
                          ' QR$period',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (_isYearly)
                      Text(
                        '= ${(price / 12).round()} QR/mo',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Everything in Premium, plus:',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 12),
            ...[
              '30 min monthly PRO consultation',
              'Featured listing every month',
              '1 free business listing',
              'Priority customer support',
              'Exclusive PRO community badge',
            ].map((f) => _featureRow(f, true, const Color(0xFF6C3FC5))),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleSubscribe('Pro', price),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C3FC5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Get Pro',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureRow(String text, bool included, Color checkColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(
            included ? Icons.check_circle : Icons.remove_circle,
            color: included ? checkColor : Colors.white24,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: included ? Colors.white70 : Colors.white30,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Compare all features',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                _tableHeader(),
                const Divider(color: Colors.white12, height: 1),
                ..._features.asMap().entries.map((entry) {
                  final isLast = entry.key == _features.length - 1;
                  return Column(
                    children: [
                      _tableRow(entry.value),
                      if (!isLast)
                        Divider(
                          color: Colors.white.withValues(alpha: 0.08),
                          height: 1,
                          indent: 12,
                          endIndent: 12,
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          const Expanded(
            flex: 3,
            child: Text(
              'Feature',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _headerCell('Free'),
          _headerCell('Premium', color: const Color(0xFFFFB627)),
          _headerCell('Pro', color: const Color(0xFF6C3FC5)),
        ],
      ),
    );
  }

  Widget _headerCell(String label, {Color? color}) {
    return Expanded(
      flex: 2,
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: color ?? Colors.white38,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _tableRow(Map<String, dynamic> row) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              row['feature'],
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          _tableCell(row['free']),
          _tableCell(row['premium'], color: const Color(0xFFFFB627)),
          _tableCell(row['pro'], color: const Color(0xFF6C3FC5)),
        ],
      ),
    );
  }

  Widget _tableCell(dynamic value, {Color? color}) {
    Widget child;
    if (value is bool) {
      child = Icon(
        value ? Icons.check : Icons.close,
        size: 16,
        color: value ? (color ?? Colors.white54) : Colors.white24,
      );
    } else {
      child = Text(
        value.toString(),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color ?? Colors.white54,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      );
    }
    return Expanded(flex: 2, child: Center(child: child));
  }

  Widget _buildTrustSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _trustItem('🔒', 'Secure\nPayment'),
          _trustItem('↩️', 'Cancel\nAnytime'),
          _trustItem('📞', '24/7\nSupport'),
          _trustItem('🌍', 'Qatar\nBased'),
        ],
      ),
    );
  }

  Widget _trustItem(String icon, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white38, fontSize: 10),
        ),
      ],
    );
  }

  void _handleSubscribe(String plan, int price) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '💎 $plan selected — QR $price. Redirecting to payment…',
        ),
        backgroundColor: const Color(0xFF6C3FC5),
      ),
    );
  }
}
