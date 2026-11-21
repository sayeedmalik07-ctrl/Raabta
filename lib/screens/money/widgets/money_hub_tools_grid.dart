import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/features/quick_actions/l10n/quick_actions_strings.dart';
import 'package:raabta/features/ramadan/l10n/zakat_strings.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/money/l10n/money_hub_strings.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';

/// Hub kit §4 — 3-column MoneyTool grid (responsive), even gutters, last row start-aligned.
class MoneyHubToolsGrid extends ConsumerWidget {
  const MoneyHubToolsGrid({super.key});

  static const double _gutter = 12;

  /// 3 columns at phone width; 2 only when too narrow for kit tiles.
  static int _columnCount(double maxWidth) {
    if (maxWidth >= 300) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columnCount(constraints.maxWidth);
        final totalGutter = _gutter * (columns - 1);
        final tileWidth = (constraints.maxWidth - totalGutter) / columns;

        final tools = <Widget>[
          MoneyHubFeatureTile(
            compact: true,
            icon: Icons.monetization_on_outlined,
            title: MoneyHubStrings.t('tool_gold_intelligence_title', locale),
            subtitle:
                MoneyHubStrings.t('tool_gold_intelligence_subtitle', locale),
            accentColor: moneyHubAccent,
            onTap: () => context.push('/money-services/gold'),
          ),
          MoneyHubFeatureTile(
            compact: true,
            icon: Icons.compare_arrows,
            title: MoneyHubStrings.t('tool_send_home_title', locale),
            subtitle: MoneyHubStrings.t('tool_send_home_subtitle', locale),
            accentColor: moneyHubAccent,
            onTap: () => context.push('/money-services/corridor-comparator'),
          ),
          MoneyHubFeatureTile(
            compact: true,
            icon: Icons.home_work_outlined,
            title: MoneyHubStrings.t('tool_cost_of_living_title', locale),
            subtitle:
                MoneyHubStrings.t('tool_cost_of_living_subtitle', locale),
            accentColor: moneyHubAccent,
            onTap: () => context.push('/money-services/cost-of-living'),
          ),
          MoneyHubFeatureTile(
            compact: true,
            icon: Icons.account_balance_wallet_outlined,
            title: MoneyHubStrings.t('tool_personal_budget_title', locale),
            subtitle:
                MoneyHubStrings.t('tool_personal_budget_subtitle', locale),
            accentColor: moneyHubAccent,
            onTap: () => context.push('/money-services/personal-budget'),
          ),
          MoneyHubFeatureTile(
            compact: true,
            icon: Icons.volunteer_activism_outlined,
            title: ZakatStrings.t('zakat_title', locale),
            subtitle: MoneyHubStrings.t('tool_zakat_subtitle', locale),
            accentColor: moneyHubAccent,
            onTap: () => context.push('/ramadan/zakat'),
          ),
          MoneyHubFeatureTile(
            compact: true,
            icon: Icons.receipt_outlined,
            title: QuickActionsStrings.t('tool_bill_tracker_title', locale),
            subtitle:
                QuickActionsStrings.t('tool_bill_tracker_description', locale),
            accentColor: moneyHubAccent,
            onTap: () => context.push('/bill-tracker'),
          ),
          MoneyHubFeatureTile(
            compact: true,
            icon: Icons.receipt_long_outlined,
            title: QuickActionsStrings.t('tool_bill_splitter_title', locale),
            subtitle:
                QuickActionsStrings.t('tool_bill_splitter_description', locale),
            accentColor: moneyHubAccent,
            onTap: () => context.push('/bill-splitter'),
          ),
        ];

        return Wrap(
          spacing: _gutter,
          runSpacing: _gutter,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            for (final tile in tools)
              SizedBox(
                width: tileWidth,
                child: tile,
              ),
          ],
        );
      },
    );
  }
}
