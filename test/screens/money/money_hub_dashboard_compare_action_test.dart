import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/money/l10n/money_hub_strings.dart';
import 'package:raabta/screens/money/widgets/money_hub_dashboard_tab.dart';
import 'package:raabta/services/exchange_rate_service.dart';

void main() {
  testWidgets('Dashboard compare shortcut calls onOpenMarketsCompare', (
    tester,
  ) async {
    var compareTaps = 0;

    final rates = ExchangeRates(
      rates: {'INR': 22.5},
      lastUpdated: DateTime(2025, 6, 15, 12, 0),
      isFallback: false,
      isDirectApi: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userLanguageProvider.overrideWith((ref) => 'English'),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: MoneyHubDashboardTab(
              ratesAsync: AsyncValue.data(rates),
              selectedCurrency: 'INR',
              onRefresh: () async {},
              onOpenMarketsCompare: () => compareTaps++,
              onOpenBranches: ({int locatorTab = 0}) {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final compareLabel = MoneyHubStrings.t('markets_segment_compare', 'English');
    expect(find.text(compareLabel), findsOneWidget);

    await tester.tap(find.text(compareLabel));
    expect(compareTaps, 1);
  });
}
