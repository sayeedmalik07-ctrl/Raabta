import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/static_search_entry.dart';

/// Money Hub tabs and sub-features — static discoverability index.
abstract final class MoneySearchIndex {
  static List<StaticSearchEntry> get all => [
        const StaticSearchEntry(
          id: 'money_rates',
          titleKey: 'search_money_rates_title',
          subtitleKey: 'search_money_rates_subtitle',
          keywords: ['exchange', 'rate', 'currency', 'inr', 'pkr', 'convert', 'qar'],
          routePath: '/money?tab=0',
          category: GlobalSearchCategory.money,
        ),
        const StaticSearchEntry(
          id: 'money_compare',
          titleKey: 'search_money_compare_title',
          subtitleKey: 'search_money_compare_subtitle',
          keywords: ['compare', 'exchange house', 'remittance', 'rate', 'money'],
          routePath: '/money?tab=2',
          category: GlobalSearchCategory.money,
        ),
        const StaticSearchEntry(
          id: 'money_gold',
          titleKey: 'search_money_gold_title',
          subtitleKey: 'search_money_gold_subtitle',
          keywords: ['gold', 'price', 'intelligence', '22k', '24k', 'jewellery'],
          routePath: '/money-services/gold',
          category: GlobalSearchCategory.money,
        ),
        const StaticSearchEntry(
          id: 'money_cost_of_living',
          titleKey: 'search_money_cpi_title',
          subtitleKey: 'search_money_cpi_subtitle',
          keywords: [
            'cost of living',
            'cpi',
            'inflation',
            'housing',
            'utilities',
            'food prices',
            'npc',
          ],
          routePath: '/money-services/cost-of-living',
          category: GlobalSearchCategory.money,
        ),
        const StaticSearchEntry(
          id: 'money_personal_budget',
          titleKey: 'search_money_personal_budget_title',
          subtitleKey: 'search_money_personal_budget_subtitle',
          keywords: [
            'personal budget',
            'savings rate',
            'budget pressure',
            'monthly cost',
            'salary',
            'expenses',
            'living costs',
          ],
          routePath: '/money-services/personal-budget',
          category: GlobalSearchCategory.money,
        ),
        const StaticSearchEntry(
          id: 'money_corridor',
          titleKey: 'search_money_corridor_title',
          subtitleKey: 'search_money_corridor_subtitle',
          keywords: ['corridor', 'remittance', 'transfer', 'compare', 'send money'],
          routePath: '/money-services/corridor-comparator',
          category: GlobalSearchCategory.money,
        ),
        const StaticSearchEntry(
          id: 'money_locator',
          titleKey: 'search_money_locator_title',
          subtitleKey: 'search_money_locator_subtitle',
          keywords: ['exchange', 'locator', 'branch', 'nearby', 'money changer'],
          routePath: '/money?tab=2&locatorTab=1',
          category: GlobalSearchCategory.money,
        ),
      ];
}
