import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/glass_error_state.dart';
import 'package:raabta/core/widgets/hub/hub_notice_banner.dart';
import 'package:raabta/features/exchange_locator/presentation/l10n/exchange_locator_strings.dart';
import 'package:raabta/features/exchange_locator/presentation/providers/exchange_locator_providers.dart';
import 'package:raabta/features/exchange_locator/presentation/screens/branch_finder_tab.dart';
import 'package:raabta/features/exchange_locator/presentation/screens/branch_map_tab.dart';
import 'package:raabta/features/exchange_locator/presentation/screens/favorites_tab.dart';
import 'package:raabta/features/exchange_locator/presentation/widgets/company_card.dart';
import 'package:raabta/features/exchange_locator/presentation/widgets/exchange_locator_skeleton.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/money/l10n/money_hub_strings.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';

/// Embedded Exchange Locator experience (companies, finder, map, favorites).
/// Used inside Money Services — no duplicate live-rates UI.
class ExchangeLocatorPanel extends ConsumerStatefulWidget {
  const ExchangeLocatorPanel({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  ConsumerState<ExchangeLocatorPanel> createState() =>
      _ExchangeLocatorPanelState();
}

class _ExchangeLocatorPanelState extends ConsumerState<ExchangeLocatorPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _scrollController = ScrollController();

  static const _locatorSegmentPadding = EdgeInsets.fromLTRB(
    AppSpacing.xl,
    AppSpacing.sm,
    AppSpacing.xl,
    AppSpacing.sm,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 3),
    );
    _tabController.addListener(_onTabIndexChanged);
    _scrollController.addListener(_onScroll);
  }

  void _onTabIndexChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(ExchangeLocatorPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      final index = widget.initialTab.clamp(0, 3);
      if (_tabController.index != index) {
        _tabController.animateTo(index);
      }
    }
  }

  void _onScroll() {
    if (_tabController.index != 0) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(companiesNotifierProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabIndexChanged);
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);

    final segmentLabels = [
      ExchangeLocatorStrings.t('tab_companies', locale),
      ExchangeLocatorStrings.t('tab_finder', locale),
      ExchangeLocatorStrings.t('tab_map', locale),
      ExchangeLocatorStrings.t('tab_favorites', locale),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: moneyHubScreenPadding.copyWith(
            top: AppSpacing.sm,
            bottom: AppSpacing.xs,
          ),
          child: MoneyHubSectionHeader(
            title: MoneyHubStrings.t('branches_find_exchange_branches', locale),
            subtitle: MoneyHubStrings.t('branches_hero_subtitle', locale),
          ),
        ),
        Padding(
          padding: _locatorSegmentPadding,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: moneyHubAccent,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: moneyHubAccent,
            dividerColor: Colors.transparent,
            tabs: [
              for (final label in segmentLabels) Tab(text: label),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _CompaniesTab(scrollController: _scrollController, locale: locale),
              const BranchFinderTab(),
              const BranchMapTab(),
              const FavoritesTab(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xs,
            AppSpacing.xl,
            AppSpacing.sm,
          ),
          child: HubNoticeBanner(
            text: MoneyHubStrings.t('dashboard_compliance_footer', locale),
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

class _CompaniesTab extends ConsumerWidget {
  const _CompaniesTab({
    required this.scrollController,
    required this.locale,
  });

  final ScrollController scrollController;
  final String locale;

  Widget _companiesSectionHeader() {
    return MoneyHubSectionHeader(
      title: MoneyHubStrings.t('branches_exchange_companies_title', locale),
      subtitle: MoneyHubStrings.t('branches_exchange_companies_subtitle', locale),
      compact: true,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(companiesNotifierProvider);
    final contentPadding = moneyHubScreenPadding.copyWith(top: AppSpacing.sm);

    if (state.isLoading && state.companies.isEmpty) {
      return ListView(
        padding: contentPadding,
        children: const [
          ExchangeLocatorSkeletonList(),
        ],
      );
    }

    if (state.error != null && state.companies.isEmpty) {
      return ListView(
        padding: contentPadding,
        children: [
          GlassErrorState(
            message: state.error!,
            onRetry: () =>
                ref.read(companiesNotifierProvider.notifier).refresh(),
          ),
        ],
      );
    }

    if (state.companies.isEmpty) {
      return ListView(
        padding: contentPadding,
        children: [
          MoneyHubEmptyState(
            icon: Icons.account_balance_outlined,
            title: ExchangeLocatorStrings.t('empty_companies_title', locale),
            description: ExchangeLocatorStrings.t(
              'empty_companies_description',
              locale,
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      color: moneyHubAccent,
      backgroundColor: AppColors.surface,
      onRefresh: () => ref.read(companiesNotifierProvider.notifier).refresh(),
      child: ListView.builder(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: contentPadding,
        itemCount: state.companies.length + 1 + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _companiesSectionHeader(),
            );
          }

          final companyIndex = index - 1;
          if (companyIndex >= state.companies.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: CircularProgressIndicator(color: moneyHubAccent),
              ),
            );
          }
          return CompanyCard(
            company: state.companies[companyIndex],
            locale: locale,
          );
        },
      ),
    );
  }
}
