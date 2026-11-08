import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/money/l10n/money_hub_strings.dart';
import 'package:raabta/screens/money/widgets/money_hub_branches_tab.dart';
import 'package:raabta/screens/money/widgets/money_hub_dashboard_tab.dart';
import 'package:raabta/screens/money/widgets/money_hub_markets_tab.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';
import 'package:raabta/services/exchange_rate_service.dart';

class MoneyScreen extends ConsumerStatefulWidget {
  const MoneyScreen({
    super.key,
    this.initialTab = 0,
    this.initialLocatorTab = 0,
    this.initialMarketsSegment = 0,
  });

  /// Top-level Money Hub tab (0–2). Legacy tab=3 maps to Branches (2).
  final int initialTab;

  /// Locator sub-tab (0–3) when opening Money Hub with e.g. `/money?tab=2&locatorTab=1`.
  final int initialLocatorTab;

  /// Markets segment: 0 = trend, 1 = compare (legacy tab=2 → compare).
  final int initialMarketsSegment;

  static const int locatorTabIndex = 2;

  static int normalizeInitialTab(int tab) {
    if (tab >= 3) return locatorTabIndex;
    if (tab == 1 || tab == 2) return 1;
    return tab.clamp(0, locatorTabIndex);
  }

  static int normalizeMarketsSegment(int tab, int segment) {
    if (tab == 2) return 1;
    return segment.clamp(0, 1);
  }

  @override
  ConsumerState<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends ConsumerState<MoneyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final TextEditingController _amountController;
  late final TextEditingController _hubSearchController;
  late final ScrollController _dashboardScrollController;
  late int _marketsSegment;
  late int _branchesLocatorTab;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: MoneyScreen.normalizeInitialTab(widget.initialTab),
    );
    _marketsSegment = MoneyScreen.normalizeMarketsSegment(
      widget.initialTab,
      widget.initialMarketsSegment,
    );
    _branchesLocatorTab = widget.initialLocatorTab.clamp(0, 3);
    _amountController = TextEditingController(
      text: ref.read(converterAmountProvider).toInt().toString(),
    );
    _hubSearchController = TextEditingController();
    _hubSearchController.addListener(() => setState(() {}));
    _dashboardScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rateHistoryProvider('INR'));
      ref.read(exchangeCompareProvider('INR'));
    });
  }

  @override
  void didUpdateWidget(MoneyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLocatorTab != widget.initialLocatorTab) {
      setState(() {
        _branchesLocatorTab = widget.initialLocatorTab.clamp(0, 3);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _hubSearchController.dispose();
    _dashboardScrollController.dispose();
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

  void _openMarketsCompare() {
    setState(() => _marketsSegment = 1);
    _tabController.animateTo(1);
  }

  void _openBranches({int locatorTab = 0}) {
    setState(() {
      _branchesLocatorTab = locatorTab.clamp(0, 3);
    });
    _tabController.animateTo(MoneyScreen.locatorTabIndex);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(exchangeAutoRefreshProvider);
    final ratesAsync = ref.watch(liveExchangeRatesProvider);
    final selectedCurrency = ref.watch(selectedCurrencyProvider);
    final locale = ref.watch(userLanguageProvider);

    return MoneyHubShell(
      shellTitle: MoneyHubStrings.t('shell_title', locale),
      shellSubtitle: MoneyHubStrings.t('shell_subtitle', locale),
      searchHint: MoneyHubStrings.t('shell_search_hint', locale),
      tabLabels: [
        MoneyHubStrings.t('shell_tab_dashboard', locale),
        MoneyHubStrings.t('shell_tab_markets', locale),
        MoneyHubStrings.t('shell_tab_branches', locale),
      ],
      searchController: _hubSearchController,
      tabController: _tabController,
      isRefreshing: _isRefreshing,
      onRefresh: _refresh,
      canPop: context.canPop(),
      body: TabBarView(
        controller: _tabController,
        children: [
          MoneyHubDashboardTab(
            ratesAsync: ratesAsync,
            selectedCurrency: selectedCurrency,
            currencyFilterQuery: _hubSearchController.text,
            scrollController: _dashboardScrollController,
            onRefresh: _refresh,
            onOpenMarketsCompare: _openMarketsCompare,
            onOpenBranches: _openBranches,
          ),
          MoneyHubMarketsTab(
            key: ValueKey('markets-segment-$_marketsSegment'),
            ratesAsync: ratesAsync,
            selectedCurrency: selectedCurrency,
            amountController: _amountController,
            onRefresh: _refresh,
            initialSegment: _marketsSegment,
          ),
          MoneyHubBranchesTab(
            key: ValueKey(_branchesLocatorTab),
            initialLocatorTab: _branchesLocatorTab,
          ),
        ],
      ),
    );
  }
}
