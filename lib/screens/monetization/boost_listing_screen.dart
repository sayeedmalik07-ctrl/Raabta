import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const kBoostStarterPrice = 5;
const kBoostPopularPrice = 15;
const kBoostPremiumPrice = 45;

const kBoostStarterDays = 3;
const kBoostPopularDays = 7;
const kBoostPremiumDays = 30;

class BoostListingScreen extends ConsumerStatefulWidget {
  const BoostListingScreen({
    super.key,
    required this.listingTitle,
    required this.currentViews,
    required this.currentContacts,
    required this.listingId,
  });

  final String listingTitle;
  final int currentViews;
  final int currentContacts;
  final String listingId;

  @override
  ConsumerState<BoostListingScreen> createState() =>
      _BoostListingScreenState();
}

class _BoostListingScreenState extends ConsumerState<BoostListingScreen> {
  int? _selectedPackage;
  bool _showPayment = false;

  final List<Map<String, dynamic>> _packages = [
    {
      'index': 0,
      'label': 'Starter',
      'days': kBoostStarterDays,
      'price': kBoostStarterPrice,
      'oldPrice': null,
      'popular': false,
      'borderColor': const Color(0xFF00D4FF),
      'borderWidth': 1.0,
      'gradientColors': null,
      'priceColor': const Color(0xFF00D4FF),
      'buttonStyle': 'outline',
      'buttonColor': const Color(0xFF00D4FF),
      'badge': null,
      'benefits': [
        '3× more visibility',
        'Highlighted in search results',
        'Priority placement for 3 days',
      ],
    },
    {
      'index': 1,
      'label': 'Popular',
      'days': kBoostPopularDays,
      'price': kBoostPopularPrice,
      'oldPrice': 25,
      'popular': true,
      'borderColor': const Color(0xFF00D4FF),
      'borderWidth': 2.0,
      'gradientColors': [const Color(0xFF00D4FF), const Color(0xFF6C3FC5)],
      'priceColor': const Color(0xFF00D4FF),
      'buttonStyle': 'filled',
      'buttonColor': const Color(0xFF00D4FF),
      'badge': 'MOST POPULAR',
      'benefits': [
        '7× more visibility',
        '"FEATURED" badge on your listing',
        'Top search results for 7 days',
        'Push alert to 500 nearby users',
      ],
    },
    {
      'index': 2,
      'label': 'Premium',
      'days': kBoostPremiumDays,
      'price': kBoostPremiumPrice,
      'oldPrice': null,
      'popular': false,
      'borderColor': const Color(0xFFFFB627),
      'borderWidth': 2.0,
      'gradientColors': [const Color(0xFFFFB627), const Color(0xFFFF6B00)],
      'priceColor': const Color(0xFFFFB627),
      'buttonStyle': 'gold',
      'buttonColor': const Color(0xFFFFB627),
      'badge': null,
      'benefits': [
        '15× more visibility',
        '"PREMIUM" gold badge on listing',
        'Homepage featured section',
        'AI-recommended to matched users',
        'Monthly analytics report',
      ],
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
          '🚀 Boost Your Listing',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _showPayment
            ? _buildPaymentSection()
            : _buildPackagesSection(),
      ),
    );
  }

  Widget _buildPackagesSection() {
    return SingleChildScrollView(
      key: const ValueKey('packages'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildListingPreview(),
          const SizedBox(height: 20),
          const Text(
            'Choose a boost package',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Prices in Qatari Riyal — no hidden fees',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ..._packages.map(_buildPackageCard),
          const SizedBox(height: 16),
          if (_selectedPackage != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => setState(() => _showPayment = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C3FC5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Continue with '
                  '${_packages[_selectedPackage!]['label']} — '
                  '${_packages[_selectedPackage!]['price']} QR',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildListingPreview() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF6C3FC5).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFF6C3FC5),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.listingTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _statChip(
                      Icons.visibility_outlined,
                      '${widget.currentViews} views',
                      Colors.white54,
                    ),
                    const SizedBox(width: 10),
                    _statChip(
                      Icons.phone_outlined,
                      '${widget.currentContacts} contacts',
                      Colors.white54,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'ACTIVE',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> pkg) {
    final isSelected = _selectedPackage == pkg['index'];
    final hasGradient = pkg['gradientColors'] != null;
    final borderColor = pkg['borderColor'] as Color;
    final priceColor = pkg['priceColor'] as Color;

    return GestureDetector(
      onTap: () => setState(() => _selectedPackage = pkg['index']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? borderColor
                : borderColor.withValues(alpha: 0.4),
            width: isSelected
                ? (pkg['borderWidth'] as double) + 0.5
                : pkg['borderWidth'] as double,
          ),
          gradient: hasGradient
              ? LinearGradient(
                  colors: (pkg['gradientColors'] as List<Color>)
                      .map((c) => c.withValues(alpha: 0.12))
                      .toList(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: hasGradient ? null : const Color(0xFF1A1A2E),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: borderColor.withValues(alpha: 0.25),
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
                        '${pkg['days']} Days Boost',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (pkg['oldPrice'] != null)
                            Text(
                              '${pkg['oldPrice']} QR',
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            '${pkg['price']} QR',
                            style: TextStyle(
                              color: priceColor,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...(pkg['benefits'] as List<String>).map(
                    (b) => Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: priceColor, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              b,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: _buildPackageButton(pkg, isSelected, priceColor),
                  ),
                ],
              ),
            ),
            if (pkg['badge'] != null)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB627),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    pkg['badge'] as String,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            if (isSelected)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: borderColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageButton(
    Map<String, dynamic> pkg,
    bool isSelected,
    Color color,
  ) {
    final style = pkg['buttonStyle'] as String;
    if (style == 'outline') {
      return OutlinedButton(
        onPressed: () => setState(() => _selectedPackage = pkg['index']),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(
          'Select',
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      );
    }
    return ElevatedButton(
      onPressed: () => setState(() => _selectedPackage = pkg['index']),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : color.withValues(alpha: 0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      child: Text(
        isSelected ? '✓ Selected' : 'Select',
        style: TextStyle(
          color: style == 'gold' ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    if (_selectedPackage == null) return const SizedBox();
    final pkg = _packages[_selectedPackage!];

    return SingleChildScrollView(
      key: const ValueKey('payment'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _showPayment = false),
            child: const Row(
              children: [
                Icon(Icons.arrow_back_ios, color: Color(0xFF00D4FF), size: 16),
                Text(
                  'Change package',
                  style: TextStyle(color: Color(0xFF00D4FF), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Complete Payment',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                _summaryRow('Package', '${pkg['label']} — ${pkg['days']} Days'),
                const Divider(color: Colors.white12, height: 20),
                _summaryRow('Listing', widget.listingTitle, valueMaxLines: 1),
                const Divider(color: Colors.white12, height: 20),
                _summaryRow(
                  'Total',
                  '${pkg['price']} QR',
                  valueColor: const Color(0xFFFFB627),
                  valueBold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Payment method',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF00D4FF), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D4FF).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.credit_card,
                    color: Color(0xFF00D4FF),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pay with Card',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Tap Payments — Visa / Mastercard',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.check_circle, color: Color(0xFF00D4FF), size: 20),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '🚀 Boost activated! Redirecting to payment…',
                    ),
                    backgroundColor: Color(0xFF6C3FC5),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C3FC5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Pay ${pkg['price']} QR — Activate Boost',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, color: Colors.white24, size: 12),
                SizedBox(width: 4),
                Text(
                  'Secured by Tap Payments',
                  style: TextStyle(color: Colors.white24, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    Color? valueColor,
    bool valueBold = false,
    int valueMaxLines = 2,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: valueMaxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 13,
              fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
