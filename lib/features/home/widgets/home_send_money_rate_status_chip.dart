import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/features/home/l10n/home_currency_rail_strings.dart';
import 'package:raabta/features/home/utils/home_send_money_rate_utils.dart';
import 'package:raabta/screens/money/l10n/money_hub_strings.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';
import 'package:raabta/services/exchange_rate_service.dart';

/// Live vs offline honesty chip for Send money home (kit + Money Hub).
class HomeSendMoneyRateStatusChip extends StatelessWidget {
  const HomeSendMoneyRateStatusChip({
    super.key,
    required this.rates,
    required this.locale,
    this.showUpdatedSubtitle = true,
  });

  final ExchangeRates rates;
  final String locale;

  /// When false, freshness is shown elsewhere (Home card footer).
  final bool showUpdatedSubtitle;

  @override
  Widget build(BuildContext context) {
    final live = homeSendMoneyRatesAreLive(rates);
    final gold = AppColors.goldFamilyMain;

    return MoneyLiveChip(
      label: live
          ? HomeCurrencyRailStrings.t('home_currency_live_indicative', locale)
          : MoneyHubStrings.t('hero_indicative_rates', locale),
      updatedAt: showUpdatedSubtitle ? rates.lastUpdated : null,
      isLive: live,
      accentColor: gold,
      warningLabel: live
          ? null
          : MoneyHubStrings.t('hero_approximate_check_connection', locale),
    );
  }
}
