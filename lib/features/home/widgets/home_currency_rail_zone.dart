import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/design/raabta_solid_surface_tokens.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/l10n/home_currency_rail_strings.dart';
import 'package:raabta/features/home/utils/home_directional_icons.dart';
import 'package:raabta/features/home/utils/home_send_money_rate_utils.dart';
import 'package:raabta/features/home/widgets/glass_loading_card.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/features/home/widgets/home_send_money_currency_segment.dart';
import 'package:raabta/features/home/widgets/home_send_money_rate_status_chip.dart';
import 'package:raabta/features/home/widgets/home_send_money_sparkline.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart'
    show moneyHubSelectionHaptic;
import 'package:raabta/services/exchange_rate_service.dart';

/// Home exchange rates — kit gold indicative rate card ([liveExchangeRatesProvider]).
class HomeCurrencyRailZone extends ConsumerWidget {
  const HomeCurrencyRailZone({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final selectedCode = ref.watch(selectedCurrencyProvider);
    final displayCode = homeSendMoneyDisplayCurrency(selectedCode);
    final ratesAsync = ref.watch(liveExchangeRatesProvider);
    final historyAsync = ref.watch(rateHistorySeriesProvider(displayCode));
    final sectionTitle =
        AppShellStrings.t('home_exchange_rates_section', locale);
    final moneyHubAction = AppShellStrings.t('home_money_hub_action', locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          title: sectionTitle,
          compact: true,
          actionText: moneyHubAction,
          onActionTap: () => context.push('/money'),
        ),
        ratesAsync.when(
          loading: () => const GlassLoadingCard(
            height: HomeCardTier.sendMoneyRateLoadingHeight,
          ),
          error: (_, _) => _UnavailableGoldCard(locale: locale),
          data: (rates) {
            final effectiveRates = rates;

            final rate =
                homeSendMoneyRateForCurrency(effectiveRates, displayCode);
            if (rate == null) {
              return _UnavailableGoldCard(locale: locale);
            }

            return _SendMoneyGoldCard(
              locale: locale,
              sectionSemanticsLabel: sectionTitle,
              displayCode: displayCode,
              rates: effectiveRates,
              historyAsync: historyAsync,
              onSelectCurrency: (code) => _selectCurrency(ref, code),
              onCompareTap: () => _openMoneyHub(ref, context, displayCode),
            );
          },
        ),
      ],
    );
  }

  void _selectCurrency(WidgetRef ref, String code) {
    moneyHubSelectionHaptic();
    ref.read(selectedCurrencyProvider.notifier).setCurrency(code);
  }

  void _openMoneyHub(WidgetRef ref, BuildContext context, String code) {
    ref.read(selectedCurrencyProvider.notifier).setCurrency(code);
    context.push('/money');
  }
}

class _UnavailableGoldCard extends StatelessWidget {
  const _UnavailableGoldCard({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: HomeCardTier.homeCardRadius,
      glowIntensity: 0,
      solidSurfaceFamily: RaabtaSolidSurfaceFamily.gold,
      child: Text(
        HomeCurrencyRailStrings.t('home_currency_rail_unavailable', locale),
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textOnGlassMuted,
        ),
      ),
    );
  }
}

class _SendMoneyGoldCard extends StatelessWidget {
  const _SendMoneyGoldCard({
    required this.locale,
    required this.sectionSemanticsLabel,
    required this.displayCode,
    required this.rates,
    required this.historyAsync,
    required this.onSelectCurrency,
    required this.onCompareTap,
  });

  final String locale;
  final String sectionSemanticsLabel;
  final String displayCode;
  final ExchangeRates rates;
  final AsyncValue<RateHistorySeries> historyAsync;
  final ValueChanged<String> onSelectCurrency;
  final VoidCallback onCompareTap;

  @override
  Widget build(BuildContext context) {
    final goldMain = AppColors.goldFamilyMain;
    final goldText = AppColors.goldFamilyText;
    final rate = homeSendMoneyRateForCurrency(rates, displayCode)!;
    final updatedLabel = homeSendMoneyRatesUpdatedLabel(rates, locale);

    RateHistorySeries? historySeries;
    historyAsync.whenData((value) => historySeries = value);

    final historyPoints = historySeries?.points;
    final marketHistory = historySeries != null && historySeries!.isMarketSourced
        ? historyPoints
        : null;
    final weeklyChange =
        homeSendMoneyDisplayWeeklyChangePercent(marketHistory);
    final sparkValues = homeSendMoneyHomeCardSparklineValues(marketHistory);

    final indicativeBadge =
        HomeCurrencyRailStrings.t('home_currency_indicative_badge', locale);

    final conversionLine = HomeCurrencyRailStrings.format(
      'home_currency_rail_rate',
      locale,
      params: {
        'rate': rate.toStringAsFixed(2),
        'code': displayCode,
      },
    );

    return Semantics(
      container: true,
      label: sectionSemanticsLabel,
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.sm + 4),
        borderRadius: HomeCardTier.homeCardRadius,
        glowIntensity: 0,
        solidSurfaceFamily: RaabtaSolidSurfaceFamily.gold,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: HomeSendMoneyRateStatusChip(
                rates: rates,
                locale: locale,
                showUpdatedSubtitle: false,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            HomeSendMoneyCurrencySegment(
              selectedCode: displayCode,
              onSelect: onSelectCurrency,
              goldMain: goldMain,
              goldText: goldText,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              rate.toStringAsFixed(2),
              style: AppTypography.forLocale(
                AppTypography.rateHero.copyWith(
                  fontSize: HomeCardTier.sendMoneyRateBigFontSize,
                  height: 1.05,
                ),
                locale,
              ),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: conversionLine,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textOnGlassMuted,
                    ),
                  ),
                  TextSpan(
                    text: ' · $indicativeBadge',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textOnGlassMuted,
                    ),
                  ),
                  if (weeklyChange != null) ...[
                    TextSpan(
                      text: ' · ',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textOnGlassMuted,
                      ),
                    ),
                    TextSpan(
                      text: homeSendMoneyWeeklyChangeLabel(
                        weeklyChange,
                        locale,
                      ),
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: weeklyChange >= 0
                            ? goldText
                            : AppColors.warning,
                      ),
                    ),
                  ],
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (sparkValues != null) ...[
              const SizedBox(height: AppSpacing.sm),
              HomeSendMoneySparkline(
                key: const Key('home_send_money_sparkline'),
                values: sparkValues,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(
              updatedLabel,
              style: AppTypography.caption.copyWith(
                color: AppColors.textOnGlassMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              HomeCurrencyRailStrings.t(
                'home_currency_indicative_disclaimer',
                locale,
              ),
              style: AppTypography.caption.copyWith(
                color: AppColors.textOnGlassMuted,
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: _CompareExchangeLink(
                locale: locale,
                goldText: goldText,
                maxWidth: double.infinity,
                onTap: onCompareTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompareExchangeLink extends StatelessWidget {
  const _CompareExchangeLink({
    required this.locale,
    required this.goldText,
    required this.maxWidth,
    required this.onTap,
  });

  final String locale;
  final Color goldText;
  final double maxWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label =
        HomeCurrencyRailStrings.t('home_currency_compare_link', locale);

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 44,
              minHeight: 44,
              maxWidth: maxWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: goldText,
                      ),
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Icon(
                    HomeDirectionalIcons.forwardArrowRounded(context),
                    size: AppSpacing.iconSm,
                    color: goldText,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
