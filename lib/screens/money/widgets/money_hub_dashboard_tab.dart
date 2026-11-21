import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/hub/hub_notice_banner.dart';
import 'package:raabta/features/home/widgets/glass_loading_card.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/money_comparator/presentation/widgets/corridor_comparator_link_button.dart';
import 'package:raabta/features/financial_wellness/presentation/widgets/ewa_awareness_card.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/money/l10n/money_hub_strings.dart';
import 'package:raabta/screens/money/widgets/money_hub_hero_card.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';
import 'package:raabta/screens/money/widgets/money_hub_tools_grid.dart';
import 'package:raabta/services/exchange_rate_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Premium Money Hub home — hero converter, tools, live rates.
class MoneyHubDashboardTab extends ConsumerWidget {
  /// Hub kit §3 — 16 horizontal padding, 24 section gaps, 12 in-section gaps.
  static const EdgeInsets _scrollPadding = EdgeInsets.fromLTRB(
    AppSpacing.md,
    AppSpacing.lg,
    AppSpacing.md,
    AppSpacing.xxxl,
  );

  static const double _ratesCrossGap = 12;
  static const double _ratesMainGap = 12;
  static const double _quickSendGap = 12;

  static int _ratesCrossAxisCount(double maxWidth) {
    if (maxWidth >= 300) return 3;
    return 2;
  }

  const MoneyHubDashboardTab({
    super.key,
    required this.ratesAsync,
    required this.selectedCurrency,
    this.currencyFilterQuery = '',
    this.scrollController,
    required this.onRefresh,
    required this.onOpenMarketsCompare,
    required this.onOpenBranches,
  });

  final AsyncValue<ExchangeRates> ratesAsync;
  final String selectedCurrency;
  /// Filters the live rates grid (code / country / English name) from Money Hub search.
  final String currencyFilterQuery;
  /// Drives hub chrome scrim while the dashboard scrolls (primary tab).
  final ScrollController? scrollController;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenMarketsCompare;
  /// Opens Money Hub **Branches** tab; [locatorTab] is the embedded locator segment (0–3).
  final void Function({int locatorTab}) onOpenBranches;

  void _selectCurrency(WidgetRef ref, String code) {
    moneyHubSelectionHaptic();
    ref.read(selectedCurrencyProvider.notifier).setCurrency(code);
    ref.read(rateHistoryProvider(code));
    ref.read(exchangeCompareProvider(code));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final query = currencyFilterQuery.trim().toLowerCase();
    final filteredCurrencies = query.isEmpty
        ? raabtaCurrencies
        : raabtaCurrencies
            .where(
              (c) =>
                  c.code.toLowerCase().contains(query) ||
                  c.country.toLowerCase().contains(query) ||
                  c.name.toLowerCase().contains(query),
            )
            .toList();

    return RefreshIndicator(
      color: AppColors.goldFamilyMain,
      backgroundColor: AppColors.surface,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: _scrollPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MoneyHubHeroCard(
              ratesAsync: ratesAsync,
              selectedCurrency: selectedCurrency,
              onCurrencySelected: (code) => _selectCurrency(ref, code),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: onOpenMarketsCompare,
                icon: Icon(Icons.compare_arrows, size: 18, color: moneyHubAccent),
                label: Text(
                  MoneyHubStrings.t('markets_segment_compare', locale),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: moneyHubAccent,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            MoneyHubSectionHeader(
              title: MoneyHubStrings.t('dashboard_finance_tools_title', locale),
              compact: true,
            ),
            const SizedBox(height: _ratesCrossGap),
            const MoneyHubToolsGrid(),
            const SizedBox(height: AppSpacing.lg),
            MoneyHubSectionHeader(
              title: MoneyHubStrings.t(
                'dashboard_financial_wellness_title',
                locale,
              ),
              compact: true,
            ),
            const SizedBox(height: _ratesCrossGap),
            const EwaAwarenessCard(),
            const SizedBox(height: AppSpacing.lg),
            MoneyHubSectionHeader(
              title: MoneyHubStrings.t('dashboard_live_rates_title', locale),
              compact: true,
            ),
            const SizedBox(height: _ratesCrossGap),
            ratesAsync.when(
              loading: () => LayoutBuilder(
                builder: (context, c) => _ratesShimmer(c.maxWidth),
              ),
              error: (_, _) => const SizedBox.shrink(),
              data: (rates) => filteredCurrencies.isEmpty
                  ? Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Text(
                        MoneyHubStrings.t(
                          'dashboard_no_currencies_match',
                          locale,
                        ),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textOnGlassMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final crossCount =
                            _ratesCrossAxisCount(constraints.maxWidth);
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossCount,
                            crossAxisSpacing: _ratesCrossGap,
                            mainAxisSpacing: _ratesMainGap,
                            childAspectRatio: crossCount >= 3 ? 1.15 : 1.28,
                          ),
                          itemCount: filteredCurrencies.length,
                          itemBuilder: (ctx, i) {
                            final currency = filteredCurrencies[i];
                            final rate = rates.rates[currency.code];
                            final isSelected =
                                selectedCurrency == currency.code;
                            return GestureDetector(
                              onTap: () =>
                                  _selectCurrency(ref, currency.code),
                              child: _RateTile(
                                currency: currency,
                                rate: rate,
                                isSelected: isSelected,
                                locale: locale,
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            const SizedBox(height: AppSpacing.md),
            const CorridorComparatorLinkButton(compact: true),
            const SizedBox(height: AppSpacing.md),
            _QuickSendRow(onOpenBranches: onOpenBranches, locale: locale),
            const SizedBox(height: AppSpacing.lg),
            HubNoticeBanner(
              text: MoneyHubStrings.t('dashboard_compliance_footer', locale),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _ratesShimmer(double maxWidth) {
    final crossCount = _ratesCrossAxisCount(maxWidth);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossCount,
        crossAxisSpacing: _ratesCrossGap,
        mainAxisSpacing: _ratesMainGap,
        childAspectRatio: crossCount >= 3 ? 1.15 : 1.28,
      ),
      itemCount: 6,
      itemBuilder: (_, _) => const GlassLoadingCard(height: 88),
    );
  }
}

class _RateTile extends StatelessWidget {
  const _RateTile({
    required this.currency,
    required this.rate,
    required this.isSelected,
    required this.locale,
  });

  final CurrencyInfo currency;
  final double? rate;
  final bool isSelected;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(10),
      borderRadius: AppSpacing.radiusMd,
      glowColor: isSelected ? currency.chartColor : null,
      glowIntensity: isSelected ? 0.12 : 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${currency.flag} ${currency.code}',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              color: AppColors.textOnGlassMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: rate != null
                ? MoneyAnimatedFigure(
                    value: rate!,
                    prefix: '1 QAR = ',
                    decimals: 2,
                    suffix: ' ${currency.code}',
                    style: AppTypography.tabular(
                      AppTypography.title.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  )
                : Text(
                    '—',
                    textAlign: TextAlign.center,
                    style: AppTypography.title.copyWith(
                      fontSize: 17,
                      color: AppColors.textTertiary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _QuickSendRow extends StatelessWidget {
  const _QuickSendRow({
    required this.onOpenBranches,
    required this.locale,
  });

  final void Function({int locatorTab}) onOpenBranches;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GlassCard(
            onTap: () async {
              moneyHubSelectionHaptic();
              final url = Uri.parse('https://www.alfardanexchange.com.qa');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.md,
            ),
            borderRadius: AppSpacing.radiusMd,
            glowColor: moneyHubAccent,
            glowIntensity: 0.08,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                HomeIconBadge(
                  icon: Icons.language_outlined,
                  accentColor: moneyHubAccent,
                  variant: HomeIconBadgeVariant.goldBrand,
                  size: 36,
                  iconSize: 20,
                  chipBorderRadius: HomeCardTier.coreServiceIconChipRadius,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  MoneyHubStrings.t('dashboard_online_transfer', locale),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  MoneyHubStrings.t('dashboard_via_exchange_app', locale),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.chipLabel.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textOnGlassMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: MoneyHubDashboardTab._quickSendGap),
        Expanded(
          child: GlassCard(
            onTap: () {
              moneyHubSelectionHaptic();
              onOpenBranches(locatorTab: 1);
            },
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.md,
            ),
            borderRadius: AppSpacing.radiusMd,
            glowColor: moneyHubAccent,
            glowIntensity: 0.08,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                HomeIconBadge(
                  icon: Icons.store_outlined,
                  accentColor: moneyHubAccent,
                  variant: HomeIconBadgeVariant.goldBrand,
                  size: 36,
                  iconSize: 20,
                  chipBorderRadius: HomeCardTier.coreServiceIconChipRadius,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  MoneyHubStrings.t('dashboard_walk_in', locale),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  MoneyHubStrings.t('dashboard_find_nearest_branch', locale),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.chipLabel.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textOnGlassMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
