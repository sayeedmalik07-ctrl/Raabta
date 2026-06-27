import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class BillSplitterScreen extends StatefulWidget {
  const BillSplitterScreen({super.key});

  @override
  State<BillSplitterScreen> createState() => _BillSplitterScreenState();
}

class _BillSplitterScreenState extends State<BillSplitterScreen> {
  final _billController = TextEditingController(text: '');
  final _nameController = TextEditingController();
  double _taxPercent = 0;
  bool _loadingRates = false;
  bool _ratesLoaded = false;

  Map<String, double> _rates = {
    'INR': 22.6,
    'PHP': 14.7,
    'GBP': 0.21,
    'USD': 0.274,
    'EUR': 0.25,
    'BDT': 30.1,
    'PKR': 76.0,
    'EGP': 13.3,
    'LKR': 82.5,
    'NPR': 36.2,
    'KES': 35.4,
    'MYR': 1.27,
    'SGD': 0.37,
    'AED': 1.00,
    'SAR': 1.03,
  };

  final _symbols = {
    'INR': '₹',
    'PHP': '₱',
    'GBP': '£',
    'USD': '\$',
    'EUR': '€',
    'BDT': '৳',
    'PKR': '₨',
    'EGP': 'E£',
    'LKR': 'Rs',
    'NPR': 'रू',
    'KES': 'KSh',
    'MYR': 'RM',
    'SGD': 'S\$',
    'AED': 'د.إ',
    'SAR': '﷼',
  };

  final _flags = {
    'INR': '🇮🇳',
    'PHP': '🇵🇭',
    'GBP': '🇬🇧',
    'USD': '🇺🇸',
    'EUR': '🇪🇺',
    'BDT': '🇧🇩',
    'PKR': '🇵🇰',
    'EGP': '🇪🇬',
    'LKR': '🇱🇰',
    'NPR': '🇳🇵',
    'KES': '🇰🇪',
    'MYR': '🇲🇾',
    'SGD': '🇸🇬',
    'AED': '🇦🇪',
    'SAR': '🇸🇦',
  };

  final List<_Person> _people = [];
  final String _selectedCurrency = 'INR';

  double get _billAmount =>
      double.tryParse(_billController.text.replaceAll(',', '')) ?? 0;

  double get _taxAmount => _billAmount * (_taxPercent / 100);

  double get _totalWithTax => _billAmount + _taxAmount;

  double get _perPerson =>
      _people.isEmpty ? 0 : _totalWithTax / _people.length;

  String _toHomeCurrency(String currency, double qar) {
    final rate = _rates[currency] ?? 1.0;
    final symbol = _symbols[currency] ?? currency;
    final converted = qar * rate;
    if (converted >= 1000) {
      return '$symbol${(converted / 1000).toStringAsFixed(1)}k';
    }
    return '$symbol${converted.toStringAsFixed(0)}';
  }

  @override
  void initState() {
    super.initState();
    _fetchLiveRates();
  }

  @override
  void dispose() {
    _billController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _fetchLiveRates() async {
    setState(() {
      _loadingRates = true;
    });
    try {
      final res = await http
          .get(
            Uri.parse('https://open.er-api.com/v6/latest/QAR'),
          )
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final fetched = data['rates'] as Map<String, dynamic>;
        final updated = <String, double>{};
        for (final key in _rates.keys) {
          if (fetched.containsKey(key)) {
            updated[key] = (fetched[key] as num).toDouble();
          } else {
            updated[key] = _rates[key]!;
          }
        }
        setState(() {
          _rates = updated;
          _ratesLoaded = true;
        });
      }
    } catch (_) {
      // Fall back to hardcoded rates.
    } finally {
      setState(() {
        _loadingRates = false;
      });
    }
  }

  void _showAddPersonSheet() {
    _nameController.clear();
    String pickedCurrency = _selectedCurrency;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A1035),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Add Person',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Name (e.g. Raj, Marco, James)',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 14,
                  ),
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFFFB627),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Home Currency',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: pickedCurrency,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1A1035),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    items: _rates.keys
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(
                              '${_flags[c] ?? ''} $c  —  ${_symbols[c] ?? c}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setSheet(() => pickedCurrency = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final name = _nameController.text.trim();
                    if (name.isEmpty) return;
                    setState(() {
                      _people.add(
                        _Person(
                          name: name,
                          currency: pickedCurrency,
                          flag: _flags[pickedCurrency] ?? '🌍',
                        ),
                      );
                    });
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB627),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add to Bill',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareToGroup() {
    if (_people.isEmpty || _billAmount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a bill amount and at least one person first.'),
          backgroundColor: Color(0xFF1A1035),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final lines = _people.map((p) {
      final home = _toHomeCurrency(p.currency, _perPerson);
      final qar = _perPerson.toStringAsFixed(2);
      return '${p.flag} ${p.name}: $home  (QAR $qar)';
    }).join('\n');

    final taxLine = _taxPercent > 0
        ? '\nTax (${_taxPercent.toStringAsFixed(0)}%): QAR ${_taxAmount.toStringAsFixed(2)}'
        : '';

    Share.share(
      '💳 RAABTA Bill Split\n'
      '────────────────────\n'
      'Bill: QAR ${_billAmount.toStringAsFixed(2)}$taxLine\n'
      'Total: QAR ${_totalWithTax.toStringAsFixed(2)}\n'
      'Each pays: QAR ${_perPerson.toStringAsFixed(2)}\n'
      '────────────────────\n'
      '$lines\n'
      '────────────────────\n'
      'Split with RAABTA app 🚀  raabta.app',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0826),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0826),
        elevation: 0,
        title: const Text(
          'Bill Splitter',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _ratesLoaded
                        ? const Color(0xFF2DC653)
                        : _loadingRates
                            ? const Color(0xFFFFB627)
                            : Colors.white24,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  _loadingRates
                      ? 'Loading rates...'
                      : _ratesLoaded
                          ? 'Live rates'
                          : 'Offline rates',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Bill',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'QAR',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _billController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[\d.]'),
                                  ),
                                ],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                ),
                                decoration: InputDecoration(
                                  hintText: '0.00',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white10),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              'Service / Tax',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${_taxPercent.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Color(0xFFFFB627),
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: const Color(0xFFFFB627),
                            inactiveTrackColor:
                                Colors.white.withValues(alpha: 0.08),
                            thumbColor: const Color(0xFFFFB627),
                            overlayColor:
                                const Color(0xFFFFB627).withValues(alpha: 0.15),
                            trackHeight: 3,
                          ),
                          child: Slider(
                            value: _taxPercent,
                            min: 0,
                            max: 20,
                            divisions: 20,
                            onChanged: (v) => setState(() => _taxPercent = v),
                          ),
                        ),
                        if (_billAmount > 0) ...[
                          const Divider(color: Colors.white10),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _TotalChip(
                                label: 'Total',
                                value:
                                    'QAR ${_totalWithTax.toStringAsFixed(2)}',
                                color: Colors.white70,
                              ),
                              _TotalChip(
                                label: 'Per Person',
                                value:
                                    'QAR ${_perPerson.toStringAsFixed(2)}',
                                color: const Color(0xFFFFB627),
                                bold: true,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _people.isEmpty
                            ? 'Add People'
                            : 'People  (${_people.length})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showAddPersonSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB627).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  const Color(0xFFFFB627).withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.add,
                                color: Color(0xFFFFB627),
                                size: 15,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Add Person',
                                style: TextStyle(
                                  color: Color(0xFFFFB627),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (_people.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '👥',
                            style: TextStyle(fontSize: 36),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No people added yet',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.35),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap "Add Person" to start splitting',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.2),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ..._people.asMap().entries.map((entry) {
                    final i = entry.key;
                    final p = entry.value;
                    final homeAmount = _toHomeCurrency(p.currency, _perPerson);
                    final qar = _perPerson.toStringAsFixed(2);
                    final flagColor = _getFlagColor(p.currency);

                    return Dismissible(
                      key: Key('person_$i'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE63946).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFE63946),
                        ),
                      ),
                      onDismissed: (_) => setState(() => _people.removeAt(i)),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: flagColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  p.flag,
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    p.currency,
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.35),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  homeAmount,
                                  style: TextStyle(
                                    color: flagColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  'QAR $qar',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (_people.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: Text(
                        '← Swipe left on a person to remove',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.2),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0826),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _shareToGroup,
                icon: const Icon(
                  Icons.share_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text(
                  'Send to Group Chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getFlagColor(String currency) {
    const colorMap = {
      'INR': Color(0xFFFF9933),
      'PHP': Color(0xFF0038A8),
      'GBP': Color(0xFF012169),
      'USD': Color(0xFF3C3B6E),
      'EUR': Color(0xFF003399),
      'BDT': Color(0xFF006A4E),
      'PKR': Color(0xFF01411C),
      'EGP': Color(0xFFCE1126),
      'LKR': Color(0xFF8D153A),
      'NPR': Color(0xFF003893),
      'KES': Color(0xFF006600),
      'MYR': Color(0xFFCC0001),
      'SGD': Color(0xFFEF3340),
      'AED': Color(0xFF00732F),
      'SAR': Color(0xFF006C35),
    };
    return colorMap[currency] ?? const Color(0xFF6C3FC5);
  }
}

class _Person {
  const _Person({
    required this.name,
    required this.currency,
    required this.flag,
  });

  final String name;
  final String currency;
  final String flag;
}

class _TotalChip extends StatelessWidget {
  const _TotalChip({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
            fontSize: bold ? 18 : 14,
          ),
        ),
      ],
    );
  }
}
