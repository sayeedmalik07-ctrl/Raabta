import 'package:flutter/material.dart';
import 'package:raabta/screens/money/money_screen.dart';

/// Legacy entry — opens Money Services with the Exchange Locator tab selected.
@Deprecated('Use MoneyScreen with initialTab 3 or route /money?tab=3')
class ExchangeLocatorHomeScreen extends StatelessWidget {
  const ExchangeLocatorHomeScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  Widget build(BuildContext context) {
    return MoneyScreen(
      initialTab: MoneyScreen.locatorTabIndex,
      initialLocatorTab: initialTab,
    );
  }
}
