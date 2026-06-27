import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/services/exchange_rate_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class MoneyScreen extends ConsumerStatefulWidget {
  const MoneyScreen({super.key});

  @override
  ConsumerState<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends ConsumerState<MoneyScreen>
    with SingleTickerProviderStateMixin {
  static const Color _backgroundColor = Color(0xFF0F0F0F);
  static const Color _cardColor = Color(0xFF1A1A2E);
  static const Color _purpleColor = Color(0xFF6C3FC5);
  static const Color _goldColor = Color(0xFFFFB627);
  static const Color _cyanColor = Color(0xFF00D4FF);

  late TabController _tabController;
  late final TextEditingController _amountController;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _amountController = TextEditingController(
      text: ref.read(converterAmountProvider).toInt().toString(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rateHistoryProvider('INR'));
      ref.read(exchangeCompareProvider('INR'));
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    ref.read(exchangeRateServiceProvider).clearCache();
    ref.invalidate(liveExchangeRatesProvider);
    final selected = ref.read(selectedCurrencyProvider);
    ref.invalidate(rateHistoryProvider(selected));
    ref.invalidate(exchangeCompareProvider(selected));
    await Future<void>.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratesAsync = ref.watch(liveExchangeRatesProvider);
    final selectedCurrency = ref.watch(selectedCurrencyProvider);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _cardColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Money Services',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Exchange rates updated every 30 min',
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _goldColor,
                    ),
                  )
                : const Icon(Icons.refresh, color: _goldColor),
            onPressed: _isRefreshing ? null : _refresh,
            tooltip: 'Refresh rates',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _goldColor,
          labelColor: _goldColor,
          unselectedLabelColor: Colors.white38,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Rates & Convert'),
            Tab(text: '7-Day Trend'),
            Tab(text: 'Compare Houses'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRatesTab(ratesAsync, selectedCurrency),
          _buildTrendTab(selectedCurrency),
          _buildCompareTab(selectedCurrency),
        ],
      ),
    );
  }

  Widget _buildRatesTab(
    AsyncValue<ExchangeRates> ratesAsync,
    String selectedCurrency,
  ) {
    return RefreshIndicator(
      color: _goldColor,
      backgroundColor: _cardColor,
      onRefresh: _refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ratesAsync.when(
              loading: () => _buildRatesShimmer(),
              error: (e, _) => _buildErrorCard(),
              data: (rates) => Column(
                children: [
                  _buildStatusBar(rates),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.55,
                    ),
                    itemCount: raabtaCurrencies.length,
                    itemBuilder: (ctx, i) {
                      final currency = raabtaCurrencies[i];
                      final rate = rates.rates[currency.code];
                      final isSelected = selectedCurrency == currency.code;
                      return GestureDetector(
                        onTap: () {
                          ref.read(selectedCurrencyProvider.notifier).state =
                              currency.code;
                        },
                        child: _buildRateCard(
                          currency: currency,
                          rate: rate,
                          isSelected: isSelected,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildConverterSection(ratesAsync, selectedCurrency),
            const SizedBox(height: 20),
            _buildQuickSendSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(ExchangeRates rates) {
    final timeStr =
        '${rates.lastUpdated.hour.toString().padLeft(2, '0')}'
        ':${rates.lastUpdated.minute.toString().padLeft(2, '0')}';

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: rates.isFallback ? Colors.orange : Colors.green,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            rates.isFallback
                ? '⚠ Using cached rates — check connection'
                : '✓ Live rates as of $timeStr today',
            style: TextStyle(
              color: rates.isFallback ? Colors.orange : Colors.white54,
              fontSize: 11,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _tabController.animateTo(1),
          child: const Text(
            'View 7-day trend →',
            style: TextStyle(color: _goldColor, fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _buildRateCard({
    required CurrencyInfo currency,
    required double? rate,
    required bool isSelected,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? currency.chartColor : Colors.white12,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: currency.chartColor.withValues(alpha: 0.2),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(currency.flag, style: const TextStyle(fontSize: 18)),
              const Spacer(),
              if (isSelected)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: currency.chartColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'SELECTED',
                    style: TextStyle(
                      color: currency.chartColor,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rate != null ? '1 QR = ${rate.toStringAsFixed(2)}' : '—',
                style: TextStyle(
                  color: currency.chartColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                currency.code,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConverterSection(
    AsyncValue<ExchangeRates> ratesAsync,
    String selectedCurrency,
  ) {
    final currency = raabtaCurrencies.firstWhere(
      (c) => c.code == selectedCurrency,
      orElse: () => raabtaCurrencies.first,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Currency Converter',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'I want to send',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            onChanged: (val) {
                              final amount = double.tryParse(val) ?? 0;
                              ref.read(converterAmountProvider.notifier).state =
                                  amount;
                            },
                          ),
                        ),
                        const Text(
                          'QR',
                          style: TextStyle(
                            color: _goldColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.swap_horiz, color: Colors.white38),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Recipient gets (${currency.code})',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ratesAsync.when(
                      loading: () => const Text(
                        '…',
                        style: TextStyle(color: Colors.white54, fontSize: 28),
                      ),
                      error: (_, _) => const Text(
                        '—',
                        style: TextStyle(color: Colors.white38, fontSize: 28),
                      ),
                      data: (rates) {
                        final amount = ref.watch(converterAmountProvider);
                        final rate = rates.rates[selectedCurrency] ?? 0;
                        final result = amount * rate;
                        return Text(
                          result.toStringAsFixed(0),
                          style: TextStyle(
                            color: currency.chartColor,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white12),
          const SizedBox(height: 8),
          const Text(
            'Send to',
            style: TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: raabtaCurrencies.map((curr) {
                final isSelected = selectedCurrency == curr.code;
                return GestureDetector(
                  onTap: () {
                    ref.read(selectedCurrencyProvider.notifier).state =
                        curr.code;
                    ref.read(rateHistoryProvider(curr.code));
                    ref.read(exchangeCompareProvider(curr.code));
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? curr.chartColor.withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? curr.chartColor : Colors.white24,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      '${curr.flag} ${curr.country}',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white60,
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _tabController.animateTo(2),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purpleColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Compare exchange houses →',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSendSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Send',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _quickSendCard(
              '💳 Online Transfer',
              'Via Al Fardan app',
              _goldColor,
              () async {
                final url = Uri.parse('https://www.alfardanexchange.com.qa');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            ),
            const SizedBox(width: 10),
            _quickSendCard(
              '🏦 Walk In',
              'Find nearest house',
              _cyanColor,
              () => _tabController.animateTo(2),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickSendCard(
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendTab(String selectedCurrency) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '7-Day Rate Trend — All Currencies',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap any currency to see full chart',
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(height: 16),
          ...raabtaCurrencies.map((currency) {
            final isSelected = selectedCurrency == currency.code;
            return _buildTrendCard(currency, isSelected);
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTrendCard(CurrencyInfo currency, bool isSelected) {
    final historyAsync = ref.watch(rateHistoryProvider(currency.code));

    return GestureDetector(
      onTap: () {
        ref.read(selectedCurrencyProvider.notifier).state = currency.code;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? currency.chartColor : Colors.white12,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(
                children: [
                  Text(currency.flag, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${currency.country} — ${currency.code}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        currency.name,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ref.watch(liveExchangeRatesProvider).when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                        data: (rates) {
                          final rate = rates.rates[currency.code];
                          if (rate == null) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                rate.toStringAsFixed(2),
                                style: TextStyle(
                                  color: currency.chartColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                '1 QR',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                ],
              ),
            ),
            SizedBox(
              height: isSelected ? 120 : 70,
              child: historyAsync.when(
                loading: () => Shimmer.fromColors(
                  baseColor: const Color(0xFF2A2A3E),
                  highlightColor: const Color(0xFF3A3A5E),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                error: (_, _) => const Center(
                  child: Text(
                    'Chart unavailable',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ),
                data: (history) {
                  final validPoints =
                      history.where((p) => p.rate != null).toList();
                  if (validPoints.length < 2) {
                    return const Center(
                      child: Text(
                        'Not enough data',
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    );
                  }

                  final minRate = validPoints
                      .map((p) => p.rate!)
                      .reduce((a, b) => a < b ? a : b);
                  final maxRate = validPoints
                      .map((p) => p.rate!)
                      .reduce((a, b) => a > b ? a : b);
                  final range = maxRate - minRate;
                  final padding = range == 0 ? 0.5 : range * 0.1;

                  final firstRate = validPoints.first.rate!;
                  final lastRate = validPoints.last.rate!;
                  final isUp = lastRate >= firstRate;

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 14, 8),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: isSelected,
                          drawVerticalLine: false,
                          horizontalInterval: range == 0 ? 1 : range / 3,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: Colors.white.withValues(alpha: 0.08),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: isSelected,
                              reservedSize: 40,
                              getTitlesWidget: (val, _) => Text(
                                val.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: isSelected,
                              getTitlesWidget: (val, _) {
                                final idx = val.toInt();
                                if (idx < 0 || idx >= validPoints.length) {
                                  return const SizedBox.shrink();
                                }
                                final date = validPoints[idx].date;
                                final parts = date.split('-');
                                return Text(
                                  '${parts[2]}/${parts[1]}',
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 8,
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: (validPoints.length - 1).toDouble(),
                        minY: minRate - padding,
                        maxY: maxRate + padding,
                        lineBarsData: [
                          LineChartBarData(
                            spots: validPoints
                                .asMap()
                                .entries
                                .map(
                                  (e) => FlSpot(
                                    e.key.toDouble(),
                                    e.value.rate!,
                                  ),
                                )
                                .toList(),
                            isCurved: true,
                            color: isUp
                                ? currency.chartColor
                                : const Color(0xFFEF5350),
                            barWidth: isSelected ? 2.5 : 1.5,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: isSelected,
                              getDotPainter:
                                  (spot, percent, bar, index) =>
                                  FlDotCirclePainter(
                                radius: 3,
                                color: currency.chartColor,
                                strokeWidth: 0,
                              ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  (isUp
                                          ? currency.chartColor
                                          : const Color(0xFFEF5350))
                                      .withValues(alpha: 0.25),
                                  Colors.transparent,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          enabled: isSelected,
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (spots) => spots.map((s) {
                              final idx = s.x.toInt();
                              final date = idx < validPoints.length
                                  ? validPoints[idx].date
                                  : '';
                              return LineTooltipItem(
                                '$date\n${s.y.toStringAsFixed(3)} ${currency.code}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            historyAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (history) {
                final valid =
                    history.where((p) => p.rate != null).toList();
                if (valid.length < 2) return const SizedBox.shrink();
                final change = valid.last.rate! - valid.first.rate!;
                final pct = (change / valid.first.rate!) * 100;
                final isUp = change >= 0;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                  child: Row(
                    children: [
                      Icon(
                        isUp ? Icons.trending_up : Icons.trending_down,
                        color: isUp ? Colors.green : Colors.red,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${isUp ? '+' : ''}${pct.toStringAsFixed(2)}% vs 7 days ago',
                        style: TextStyle(
                          color: isUp ? Colors.green : Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompareTab(String selectedCurrency) {
    final compareAsync =
        ref.watch(exchangeCompareProvider(selectedCurrency));
    final currency = raabtaCurrencies.firstWhere(
      (c) => c.code == selectedCurrency,
      orElse: () => raabtaCurrencies.first,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${currency.flag} Qatar Exchange Houses',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Best rate to send QR → ${currency.code} today',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: raabtaCurrencies.map((curr) {
                final isSelected = selectedCurrency == curr.code;
                return GestureDetector(
                  onTap: () {
                    ref.read(selectedCurrencyProvider.notifier).state =
                        curr.code;
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? curr.chartColor.withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? curr.chartColor : Colors.white24,
                      ),
                    ),
                    child: Text(
                      '${curr.flag} ${curr.code}',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white54,
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          compareAsync.when(
            loading: () => _buildCompareShimmer(),
            error: (_, _) => _buildErrorCard(),
            data: (houses) {
              if (houses.isEmpty) {
                return const Center(
                  child: Text(
                    'Comparison unavailable.\nCheck your connection.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                );
              }
              return Column(
                children: houses
                    .asMap()
                    .entries
                    .map(
                      (entry) => _buildHouseCard(
                        entry.value,
                        isTop: entry.key == 0,
                        currency: currency,
                        amount: ref.watch(converterAmountProvider),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Rates shown are indicative based on mid-market with '
                    'typical spreads. Visit exchange house for final rate. '
                    'Rates change throughout the day.',
                    style: TextStyle(color: Colors.orange, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHouseCard(
    ExchangeHouseRate house, {
    required bool isTop,
    required CurrencyInfo currency,
    required double amount,
  }) {
    final receives = amount * house.rate;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isTop ? _goldColor : Colors.white12,
          width: isTop ? 1.5 : 1,
        ),
        boxShadow: isTop
            ? [
                BoxShadow(
                  color: _goldColor.withValues(alpha: 0.12),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isTop ? _goldColor : Colors.white12,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      isTop ? '🥇' : (house.rating > 4.3 ? '🥈' : ''),
                      style: TextStyle(
                        color: isTop ? Colors.black : Colors.white54,
                        fontSize: isTop ? 14 : 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            house.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          if (isTop) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _goldColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'BEST RATE',
                                style: TextStyle(
                                  color: _goldColor,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (i) => Icon(
                              i < house.rating.floor()
                                  ? Icons.star
                                  : i < house.rating
                                      ? Icons.star_half
                                      : Icons.star_border,
                              color: _goldColor,
                              size: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            house.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                            ),
                          ),
                          if (house.hasApp) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.phone_android,
                              color: _cyanColor,
                              size: 11,
                            ),
                            const Text(
                              ' App',
                              style: TextStyle(
                                color: _cyanColor,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '1 QR = ${house.rate.toStringAsFixed(3)}',
                      style: TextStyle(
                        color: isTop ? _goldColor : currency.chartColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currency.code,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (amount > 0) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      '${amount.toStringAsFixed(0)} QR',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white38,
                      size: 14,
                    ),
                    const Spacer(),
                    Text(
                      '${receives.toStringAsFixed(0)} ${currency.code}',
                      style: TextStyle(
                        color: isTop ? _goldColor : Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      house.fee == 'Free' ? '✓ No fee' : '+ ${house.fee} fee',
                      style: TextStyle(
                        color:
                            house.fee == 'Free' ? Colors.green : Colors.orange,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (house.website != null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      final url = Uri.parse(house.website!);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isTop ? _goldColor : Colors.white24,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Visit ${house.name.split(' ').first}',
                      style: TextStyle(
                        color: isTop ? _goldColor : Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatesShimmer() {
    return Shimmer.fromColors(
      baseColor: _cardColor,
      highlightColor: const Color(0xFF2A2A4E),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.55,
        ),
        itemCount: 8,
        itemBuilder: (_, _) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildCompareShimmer() {
    return Shimmer.fromColors(
      baseColor: _cardColor,
      highlightColor: const Color(0xFF2A2A4E),
      child: Column(
        children: List.generate(
          4,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.wifi_off, color: Colors.white38, size: 32),
          const SizedBox(height: 8),
          const Text(
            'Could not load rates',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _refresh,
            child: const Text(
              'Tap to retry',
              style: TextStyle(color: _goldColor),
            ),
          ),
        ],
      ),
    );
  }
}
