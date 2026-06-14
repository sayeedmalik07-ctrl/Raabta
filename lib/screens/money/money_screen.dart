import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MoneyScreen extends StatefulWidget {
  const MoneyScreen({super.key});

  @override
  State<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends State<MoneyScreen> {
  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);

  final TextEditingController _amountController =
      TextEditingController(text: '500');

  int _selectedCountryIndex = 0;

  static const List<_Country> _countries = [
    _Country(flag: '🇮🇳', name: 'India', currency: 'INR'),
    _Country(flag: '🇵🇰', name: 'Pakistan', currency: 'PKR'),
    _Country(flag: '🇧🇩', name: 'Bangladesh', currency: 'BDT'),
    _Country(flag: '🇳🇵', name: 'Nepal', currency: 'NPR'),
    _Country(flag: '🇵🇭', name: 'Philippines', currency: 'PHP'),
  ];

  static const Map<String, List<_ExchangeHouse>> _housesByCurrency = {
    'INR': [
      _ExchangeHouse(name: 'Al Zaman Exchange', rate: 22.80, fee: 5),
      _ExchangeHouse(name: 'Western Union', rate: 22.65, fee: 8),
      _ExchangeHouse(name: 'Al Dar Exchange', rate: 22.70, fee: 5),
      _ExchangeHouse(name: 'MoneyGram', rate: 22.60, fee: 10),
      _ExchangeHouse(name: 'Al Amanah Exchange', rate: 22.75, fee: 5),
    ],
    'PKR': [
      _ExchangeHouse(name: 'Al Zaman Exchange', rate: 78.40, fee: 5),
      _ExchangeHouse(name: 'Western Union', rate: 78.10, fee: 8),
      _ExchangeHouse(name: 'Al Dar Exchange', rate: 78.25, fee: 5),
      _ExchangeHouse(name: 'MoneyGram', rate: 77.95, fee: 10),
      _ExchangeHouse(name: 'Al Amanah Exchange', rate: 78.35, fee: 5),
    ],
    'BDT': [
      _ExchangeHouse(name: 'Al Zaman Exchange', rate: 32.15, fee: 5),
      _ExchangeHouse(name: 'Western Union', rate: 31.90, fee: 8),
      _ExchangeHouse(name: 'Al Dar Exchange', rate: 32.05, fee: 5),
      _ExchangeHouse(name: 'MoneyGram', rate: 31.80, fee: 10),
      _ExchangeHouse(name: 'Al Amanah Exchange', rate: 32.10, fee: 5),
    ],
    'NPR': [
      _ExchangeHouse(name: 'Al Zaman Exchange', rate: 36.50, fee: 5),
      _ExchangeHouse(name: 'Western Union', rate: 36.20, fee: 8),
      _ExchangeHouse(name: 'Al Dar Exchange', rate: 36.40, fee: 5),
      _ExchangeHouse(name: 'MoneyGram', rate: 36.10, fee: 10),
      _ExchangeHouse(name: 'Al Amanah Exchange', rate: 36.45, fee: 5),
    ],
    'PHP': [
      _ExchangeHouse(name: 'Al Zaman Exchange', rate: 15.35, fee: 5),
      _ExchangeHouse(name: 'Western Union', rate: 15.20, fee: 8),
      _ExchangeHouse(name: 'Al Dar Exchange', rate: 15.30, fee: 5),
      _ExchangeHouse(name: 'MoneyGram', rate: 15.10, fee: 10),
      _ExchangeHouse(name: 'Al Amanah Exchange', rate: 15.32, fee: 5),
    ],
  };

  double get _amount {
    return double.tryParse(_amountController.text.trim()) ?? 0;
  }

  _Country get _selectedCountry => _countries[_selectedCountryIndex];

  List<_ExchangeHouse> get _houses {
    return _housesByCurrency[_selectedCountry.currency] ?? [];
  }

  double get _bestRate {
    if (_houses.isEmpty) return 0;
    return _houses.map((h) => h.rate).reduce((a, b) => a > b ? a : b);
  }

  String _formatAmount(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          );
    }
    return value.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = _selectedCountry.currency;
    final amount = _amount;
    final bestRate = _bestRate;

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
                            'Send Money',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Compare Qatar exchange rates',
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
              sliver: SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: _surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'I want to send',
                        style: TextStyle(
                          color: _subtitleColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          suffixText: 'QR',
                          suffixStyle: TextStyle(
                            color: _cyanColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'To',
                        style: TextStyle(
                          color: _subtitleColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(_countries.length, (index) {
                          final country = _countries[index];
                          final isSelected = _selectedCountryIndex == index;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCountryIndex = index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _cyanColor.withValues(alpha: 0.15)
                                    : _backgroundColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? _cyanColor
                                      : const Color(0xFF1A2535),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    country.flag,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    country.name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? _cyanColor
                                          : Colors.white,
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final house = _houses[index];
                    final isBestRate = house.rate == bestRate;
                    final recipientGets = amount * house.rate;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ExchangeCard(
                        house: house,
                        currency: currency,
                        amount: amount,
                        recipientGets: recipientGets,
                        isBestRate: isBestRate,
                        formatAmount: _formatAmount,
                      ),
                    );
                  },
                  childCount: _houses.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Country {
  const _Country({
    required this.flag,
    required this.name,
    required this.currency,
  });

  final String flag;
  final String name;
  final String currency;
}

class _ExchangeHouse {
  const _ExchangeHouse({
    required this.name,
    required this.rate,
    required this.fee,
  });

  final String name;
  final double rate;
  final int fee;
}

class _ExchangeCard extends StatelessWidget {
  const _ExchangeCard({
    required this.house,
    required this.currency,
    required this.amount,
    required this.recipientGets,
    required this.isBestRate,
    required this.formatAmount,
  });

  final _ExchangeHouse house;
  final String currency;
  final double amount;
  final double recipientGets;
  final bool isBestRate;
  final String Function(double) formatAmount;

  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);
  static const Color _bestRateGreen = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: isBestRate
            ? Border.all(color: _bestRateGreen.withValues(alpha: 0.5))
            : null,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  house.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isBestRate)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _bestRateGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'BEST RATE 🏆',
                    style: TextStyle(
                      color: _bestRateGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '1 QR = ${house.rate.toStringAsFixed(2)} $currency',
            style: const TextStyle(color: _subtitleColor, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            'Recipient gets: ${formatAmount(recipientGets)} $currency',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${house.fee} QR fee',
            style: const TextStyle(color: _subtitleColor, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _cyanColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Instant',
                  style: TextStyle(
                    color: _cyanColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Go to Exchange →',
                  style: TextStyle(
                    color: _cyanColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
