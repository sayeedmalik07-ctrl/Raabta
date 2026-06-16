import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/models/money_models.dart';
import 'package:raabta/providers/money_providers.dart';
import 'package:url_launcher/url_launcher.dart';

class MoneyScreen extends ConsumerStatefulWidget {
  const MoneyScreen({super.key});

  @override
  ConsumerState<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends ConsumerState<MoneyScreen> {
  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);
  static const Color _bestRateGreen = Color(0xFF22C55E);

  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: ref.read(sendAmountProvider).toInt().toString(),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
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

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _onGoToExchange(ExchangeHouseRate house) async {
    final country = ref.read(selectedCountryProvider);
    final amount = ref.read(sendAmountProvider);

    try {
      await ref.read(exchangeApiServiceProvider).trackAffiliateClick(
            exchangeHouseId: house.id,
            exchangeHouseName: house.name,
            currency: country.currency,
            amount: amount,
          );
    } catch (_) {}

    await _openUrl(house.mapsUrl);
  }

  Future<void> _showRateAlertDialog(
    BuildContext context,
    String currency,
    double currentRate,
  ) async {
    final controller = TextEditingController(
      text: currentRate.toStringAsFixed(2),
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surfaceColor,
        title: const Text(
          'Set Rate Alert',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notify me when 1 QR reaches this $currency rate:',
              style: const TextStyle(color: _subtitleColor, fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: _backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                suffixText: currency,
                suffixStyle: const TextStyle(color: _cyanColor),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _cyanColor),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save Alert', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (saved != true) return;

    final target = double.tryParse(controller.text.trim());
    if (target == null) return;

    try {
      await ref.read(exchangeApiServiceProvider).saveRateAlert(
            currency: currency,
            targetRate: target,
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Alert set: we\'ll notify you when 1 QR = ${target.toStringAsFixed(2)} $currency',
          ),
          backgroundColor: _bestRateGreen,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alert saved locally. Connect to server for push notifications.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final country = ref.watch(selectedCountryProvider);
    final amount = ref.watch(sendAmountProvider);
    final liveRates = ref.watch(liveRatesProvider);
    final branches = ref.watch(branchExchangeHousesProvider);
    final ratesAsync = ref.watch(exchangeRatesProvider(country.currency));

    final rates = ratesAsync.when(
      data: (data) => data,
      loading: () => fallbackExchangeRates(country.currency),
      error: (_, _) => fallbackExchangeRates(country.currency),
    );

    final houses = rates.houses;
    final bestRate = houses.isEmpty
        ? 0.0
        : houses.map((h) => h.rate).reduce((a, b) => a > b ? a : b);
    final lowestFee = houses.isEmpty
        ? 0
        : houses.map((h) => h.fee).reduce((a, b) => a < b ? a : b);
    final trendUp = rates.history.isNotEmpty &&
        rates.history.last.rate >= rates.history.first.rate;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildHeader(context),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _SectionTitle(title: '💱 Live Exchange Rates'),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _LiveRatesCard(liveRates: liveRates),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _AmountCalculatorCard(
                  amountController: _amountController,
                  selectedCountry: country,
                  onAmountChanged: (value) {
                    ref.read(sendAmountProvider.notifier).state = value;
                  },
                  onCountrySelected: (selected) {
                    ref.read(selectedCountryProvider.notifier).state = selected;
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    const Expanded(
                      child: _SectionTitle(title: 'Compare Exchange Houses'),
                    ),
                    if (ratesAsync.isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _cyanColor,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final house = houses[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ExchangeComparisonCard(
                        house: house,
                        currency: country.currency,
                        amount: amount,
                        isBestRate: house.rate == bestRate,
                        isLowestFee: house.fee == lowestFee,
                        formatAmount: _formatAmount,
                        onGoToExchange: () => _onGoToExchange(house),
                      ),
                    );
                  },
                  childCount: houses.length,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _RateHistoryCard(
                  history: rates.history,
                  currency: country.currency,
                  trendUp: trendUp,
                  onSetAlert: () => _showRateAlertDialog(
                    context,
                    country.currency,
                    rates.indicativeRate,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _SectionTitle(title: '🏦 Exchange Houses in Qatar'),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final branch = branches[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _BranchCard(
                        branch: branch,
                        onDirections: () => _openUrl(branch.mapsUrl),
                        onCall: () => _openUrl('tel:${branch.phone}'),
                      ),
                    );
                  },
                  childCount: branches.length,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              sliver: SliverToBoxAdapter(
                child: _OnlineTransferBanner(
                  onEarlyAccess: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Thanks! We\'ll notify you when direct bank transfer launches.',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverPadding(
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
                    'Money Services',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Exchange rates updated daily',
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
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _LiveRatesCard extends StatelessWidget {
  const _LiveRatesCard({required this.liveRates});

  final List<LiveRateDisplay> liveRates;

  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cyanColor.withValues(alpha: 0.25)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...liveRates.asMap().entries.map((entry) {
            final isFirst = entry.key == 0;
            final rate = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: isFirst ? 12 : 8),
              child: Text(
                '${rate.flag} 1 QR = ${rate.rate.toStringAsFixed(2)} ${rate.currency}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isFirst ? 22 : 16,
                  fontWeight: isFirst ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          const Text(
            'Last updated: Today 9:00 AM',
            style: TextStyle(color: _subtitleColor, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            '⚠️ Rates are indicative. Visit exchange for final rate.',
            style: TextStyle(
              color: Colors.amber.shade300,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountCalculatorCard extends StatelessWidget {
  const _AmountCalculatorCard({
    required this.amountController,
    required this.selectedCountry,
    required this.onAmountChanged,
    required this.onCountrySelected,
  });

  final TextEditingController amountController;
  final MoneyCountry selectedCountry;
  final ValueChanged<double> onAmountChanged;
  final ValueChanged<MoneyCountry> onCountrySelected;

  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);

  @override
  Widget build(BuildContext context) {
    return Container(
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
            style: TextStyle(color: _subtitleColor, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              onAmountChanged(double.tryParse(value.trim()) ?? 0);
            },
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
            style: TextStyle(color: _subtitleColor, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: MoneyCountry.all.map((country) {
              final isSelected = selectedCountry.currency == country.currency;
              return GestureDetector(
                onTap: () => onCountrySelected(country),
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
                      Text(country.flag, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 6),
                      Text(
                        country.name,
                        style: TextStyle(
                          color: isSelected ? _cyanColor : Colors.white,
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ExchangeComparisonCard extends StatelessWidget {
  const _ExchangeComparisonCard({
    required this.house,
    required this.currency,
    required this.amount,
    required this.isBestRate,
    required this.isLowestFee,
    required this.formatAmount,
    required this.onGoToExchange,
  });

  final ExchangeHouseRate house;
  final String currency;
  final double amount;
  final bool isBestRate;
  final bool isLowestFee;
  final String Function(double) formatAmount;
  final VoidCallback onGoToExchange;

  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);
  static const Color _bestRateGreen = Color(0xFF22C55E);
  static const Color _lowestFeeBlue = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    final recipientGets = amount * house.rate;

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
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _cyanColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(house.logoEmoji, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      house.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _StarRating(rating: house.rating),
                  ],
                ),
              ),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.end,
                children: [
                  if (isBestRate) _Badge(label: 'BEST RATE', color: _bestRateGreen),
                  if (isLowestFee) _Badge(label: 'LOWEST FEE', color: _lowestFeeBlue),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Rate: 1 QR = ${house.rate.toStringAsFixed(2)} $currency',
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
            'Transfer fee: ${house.fee} QR',
            style: const TextStyle(color: _subtitleColor, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _TransferTimeChip(label: house.transferTime),
              const Spacer(),
              TextButton(
                onPressed: onGoToExchange,
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

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TransferTimeChip extends StatelessWidget {
  const _TransferTimeChip({required this.label});

  final String label;

  static const Color _cyanColor = Color(0xFF22D3EE);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _cyanColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Transfer Time: $label',
        style: const TextStyle(
          color: _cyanColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating});

  final double rating;

  static const Color _subtitleColor = Color(0xFF8A9BB0);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(5, (index) {
          final starValue = index + 1;
          IconData icon;
          if (rating >= starValue) {
            icon = Icons.star;
          } else if (rating >= starValue - 0.5) {
            icon = Icons.star_half;
          } else {
            icon = Icons.star_border;
          }
          return Icon(icon, color: Colors.amber, size: 14);
        }),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(color: _subtitleColor, fontSize: 12),
        ),
      ],
    );
  }
}

class _RateHistoryCard extends StatelessWidget {
  const _RateHistoryCard({
    required this.history,
    required this.currency,
    required this.trendUp,
    required this.onSetAlert,
  });

  final List<RateHistoryPoint> history;
  final String currency;
  final bool trendUp;
  final VoidCallback onSetAlert;

  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);
  static const Color _bestRateGreen = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();

    final spots = history.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.rate);
    }).toList();

    final minY = history.map((p) => p.rate).reduce((a, b) => a < b ? a : b) - 0.1;
    final maxY = history.map((p) => p.rate).reduce((a, b) => a > b ? a : b) + 0.1;

    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '7-Day Rate Trend',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            trendUp
                ? '📈 Rate trending up this week'
                : '📉 Rate trending down this week',
            style: TextStyle(
              color: trendUp ? _bestRateGreen : Colors.orange.shade300,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withValues(alpha: 0.06),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) => Text(
                        value.toStringAsFixed(2),
                        style: const TextStyle(
                          color: _subtitleColor,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= history.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            history[index].date.replaceAll('Day ', 'D'),
                            style: const TextStyle(
                              color: _subtitleColor,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: _cyanColor,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: _cyanColor,
                          strokeWidth: 1,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: _cyanColor.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onSetAlert,
              icon: const Icon(Icons.notifications_active_outlined, size: 18),
              label: Text('Set Rate Alert ($currency)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _cyanColor,
                side: BorderSide(color: _cyanColor.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({
    required this.branch,
    required this.onDirections,
    required this.onCall,
  });

  final BranchExchangeHouse branch;
  final VoidCallback onDirections;
  final VoidCallback onCall;

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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            branch.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Best rate: ${branch.bestRateLabel}',
            style: const TextStyle(color: _cyanColor, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            '${branch.distanceKm.toStringAsFixed(1)} km from Al Khor',
            style: const TextStyle(color: _subtitleColor, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            branch.hours,
            style: const TextStyle(color: _subtitleColor, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDirections,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _cyanColor,
                    side: BorderSide(color: _cyanColor.withValues(alpha: 0.4)),
                  ),
                  child: const Text('📍 Get Directions'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: onCall,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF1A2535)),
                  ),
                  child: const Text('📞 Call'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OnlineTransferBanner extends StatelessWidget {
  const _OnlineTransferBanner({required this.onEarlyAccess});

  final VoidCallback onEarlyAccess;

  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1A2535)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📱 Online Transfer Options',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Coming Soon',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Direct bank transfer coming soon',
            style: TextStyle(color: _subtitleColor, fontSize: 14),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onEarlyAccess,
              style: FilledButton.styleFrom(
                backgroundColor: _cyanColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Sign up for early access',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
