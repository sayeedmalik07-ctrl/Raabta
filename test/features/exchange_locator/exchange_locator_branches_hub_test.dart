import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/widgets/glass_error_state.dart';
import 'package:raabta/features/exchange_locator/presentation/l10n/exchange_locator_strings.dart';
import 'package:raabta/screens/money/l10n/money_hub_strings.dart';

import 'exchange_locator_branches_test_helpers.dart';

void main() {
  group('Exchange Locator Branches hub', () {
    testWidgets('shows panel header and four segment labels', (tester) async {
      await pumpExchangeLocatorPanel(tester);
      await settleLocatorContent(tester);

      expect(
        find.text(
          MoneyHubStrings.t(
            'branches_find_exchange_branches',
            kBranchesTestLocale,
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          MoneyHubStrings.t('dashboard_compliance_footer', kBranchesTestLocale),
        ),
        findsOneWidget,
      );

      for (final key in [
        'tab_companies',
        'tab_finder',
        'tab_map',
        'tab_favorites',
      ]) {
        expect(
          find.text(ExchangeLocatorStrings.t(key, kBranchesTestLocale)),
          findsWidgets,
        );
      }
    });

    testWidgets('segment tap switches to finder content', (tester) async {
      await pumpExchangeLocatorPanel(tester);
      await settleLocatorContent(tester);

      final finderLabel =
          ExchangeLocatorStrings.t('tab_finder', kBranchesTestLocale);
      await tester.tap(find.text(finderLabel).last);
      await settleLocatorContent(tester);

      expect(
        find.text(
          ExchangeLocatorStrings.t('search_hint', kBranchesTestLocale),
        ),
        findsOneWidget,
      );
    });

    testWidgets('initialTab opens finder without segment tap', (tester) async {
      await pumpExchangeLocatorPanel(tester, initialTab: 1);
      await settleLocatorContent(tester);

      expect(
        find.text(
          ExchangeLocatorStrings.t('search_hint', kBranchesTestLocale),
        ),
        findsOneWidget,
      );
    });

    testWidgets('updates visible tab when initialTab changes', (tester) async {
      final tab = ValueNotifier<int>(0);

      await pumpExchangeLocatorPanel(
        tester,
        child: LocatorTabHarness(tabListenable: tab),
      );
      await settleLocatorContent(tester);

      final recentHeading = ExchangeLocatorStrings.t(
        'recent_visits_heading',
        kBranchesTestLocale,
      );
      expect(find.text(recentHeading), findsNothing);

      tab.value = 3;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await settleLocatorContent(tester);

      expect(find.text(recentHeading), findsOneWidget);
    });

    testWidgets('companies tab shows money hub empty state', (tester) async {
      await pumpExchangeLocatorPanel(tester, initialTab: 0);
      await settleLocatorContent(tester);

      expect(
        find.text(
          ExchangeLocatorStrings.t('empty_companies_title', kBranchesTestLocale),
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.account_balance_outlined), findsOneWidget);
    });

    testWidgets('companies error shows retry and recovers on tap', (tester) async {
      final repo = FakeExchangeLocatorRepository(
        companiesException: Exception('companies-load-fail'),
        failCompaniesFetchTimes: 1,
      );

      await pumpExchangeLocatorPanel(tester, repository: repo);
      await settleLocatorContent(tester);

      expect(find.textContaining('companies-load-fail'), findsOneWidget);
      expect(find.byType(GlassErrorState), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await settleLocatorContent(tester);

      expect(repo.companiesFetchCount, greaterThanOrEqualTo(2));
      expect(
        find.text(
          ExchangeLocatorStrings.t('empty_companies_title', kBranchesTestLocale),
        ),
        findsOneWidget,
      );
    });
  });
}
