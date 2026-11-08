import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/exchange_locator/presentation/widgets/exchange_locator_panel.dart';

/// Branches tab — full Exchange Locator (companies, finder, map, favorites) per Money Hub kit
/// (`hub_kit_money_*.png`: exchange-house list on this tab).
///
/// Pull-to-refresh lives on each sub-tab ([ExchangeLocatorPanel]); compliance footer is
/// inside the panel (money copy, no FAB clearance padding).
class MoneyHubBranchesTab extends ConsumerWidget {
  const MoneyHubBranchesTab({
    super.key,
    this.initialLocatorTab = 0,
  });

  /// Sub-tab (0–3): companies, finder, map, favorites — from `/money?tab=2&locatorTab=`.
  final int initialLocatorTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locatorIndex = initialLocatorTab.clamp(0, 3);

    return ExchangeLocatorPanel(initialTab: locatorIndex);
  }
}
