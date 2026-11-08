import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/horizontal_scroll_fade.dart';
import 'package:raabta/features/home/l10n/home_currency_rail_strings.dart';
import 'package:raabta/features/home/utils/home_directional_icons.dart';
import 'package:raabta/features/home/utils/home_send_money_rate_utils.dart';
import 'package:raabta/features/home/widgets/glass_loading_card.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart'
    show moneyHubSelectionHaptic;
import 'package:raabta/services/exchange_rate_service.dart';

/// Send money home — kit gold indicative rate card ([liveExchangeRatesProvider]).
class HomeCurrencyRailZone extends ConsumerWidget {
  const HomeCurrencyRailZone({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final selectedCode = ref.watch(selectedCurrencyProvider);
    final displayCode = homeSendMoneyDisplayCurrency(selectedCode);
    final ratesAsync = ref.watch(liveExchangeRatesProvider);
    final historyAsync = ref.watch(rateHistorySeriesProvider(displayCode));

    return ratesAsync.when(
      loading: () => const GlassLoadingCard(
        height: HomeCardTier.sendMoneyRateLoadingHeight,
      ),
      error: (_, _) => _SendMoneyGoldCard(
        locale: locale,
        displayCode: displayCode,
        rates: ExchangeRates(
          rates: Map<String, double>.from(kFallbackRates),
          lastUpdated: DateTime.now(),
          isFallback: true,
        ),
        historyAsync: historyAsync,
        onSelectCurrency: (code) => _selectCurrency(ref, code),
        onCompareTap: () => _openMoneyHub(ref, context, displayCode),
      ),
      data: (rates) {
        final effectiveRates = rates.rates.isEmpty
            ? ExchangeRates(
                rates: Map<String, double>.from(kFallbackRates),
                lastUpdated: rates.lastUpdated,
                isFallback: true,
              )
            : rates;

        final rate = homeSendMoneyRateForCurrency(effectiveRates, displayCode);
        if (rate == null) {
          return _UnavailableGoldCard(locale: locale);
        }

        return _SendMoneyGoldCard(
          locale: locale,
          displayCode: displayCode,
          rates: effectiveRates,
          historyAsync: historyAsync,
          onSelectCurrency: (code) => _selectCurrency(ref, code),
          onCompareTap: () => _openMoneyHub(ref, context, displayCode),
        );
      },
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
    final goldMain = AppColors.goldFamilyMain;
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: HomeCardTier.homeCardRadius,
      glowColor: goldMain,
      glowIntensity: HomeCardTier.homeCardGlowIntensity,
      backgroundColor: goldMain.withValues(
        alpha: HomeCardTier.sendMoneyRateFamilyTintAlpha,
      ),
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
    required this.displayCode,
    required this.rates,
    required this.historyAsync,
    required this.onSelectCurrency,
    required this.onCompareTap,
  });

  final String locale;
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

    final marketHistory = historySeries != null &&
            historySeries!.isMarketSourced
        ? historySeries!.points
        : null;
    final weeklyChange =
        homeSendMoneyDisplayWeeklyChangePercent(marketHistory);
    final sparkValues = homeSendMoneyDisplaySparklineValues(marketHistory);

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
      label: HomeCurrencyRailStrings.t('home_currency_rail_title', locale),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        borderRadius: HomeCardTier.homeCardRadius,
        glowColor: goldMain,
        glowIntensity: HomeCardTier.homeCardGlowIntensity,
        backgroundColor: goldMain.withValues(
          alpha: HomeCardTier.sendMoneyRateFamilyTintAlpha,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    HomeCurrencyRailStrings.t(
                      'home_currency_rail_title',
                      locale,
                    ),
                    style: AppTypography.title.copyWith(fontSize: 14.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                _IndicativeBadge(locale: locale),
              ],
            ),
            const SizedBox(height: 10),
            _CurrencySegmentRow(
              selectedCode: displayCode,
              onSelect: onSelectCurrency,
              goldMain: goldMain,
              goldText: goldText,
            ),
            const SizedBox(height: 10),
            Text(
              rate.toStringAsFixed(2),
              style: AppTypography.title.copyWith(
                fontSize: HomeCardTier.sendMoneyRateBigFontSize,
                fontWeight: FontWeight.w800,
                height: 1.05,
                letterSpacing: -0.5,
                fontFeatures: const [FontFeature.tabularFigures()],
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
            if (sparkValues != null && sparkValues.length >= 2) ...[
              const SizedBox(height: 10),
              _RateSparkline(
                key: const Key('home_send_money_sparkline'),
                values: sparkValues,
                color: goldMain,
                height: HomeCardTier.sendMoneyRateSparklineHeight,
              ),
            ],
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final maxW = constraints.maxWidth;
                return Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xxs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxW),
                      child: Text(
                        updatedLabel,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textOnGlassMuted,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _CompareExchangeLink(
                      locale: locale,
                      goldText: goldText,
                      maxWidth: maxW,
                      onTap: onCompareTap,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _IndicativeBadge extends StatelessWidget {
  const _IndicativeBadge({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.textPrimary.withValues(alpha: 0.08),
      ),
      child: Text(
        HomeCurrencyRailStrings.t('home_currency_indicative_badge', locale),
        style: AppTypography.caption.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textOnGlassMuted,
        ),
      ),
    );
  }
}

class _CurrencySegmentRow extends StatelessWidget {
  const _CurrencySegmentRow({
    required this.selectedCode,
    required this.onSelect,
    required this.goldMain,
    required this.goldText,
  });

  static const _rowHeight = 36.0;

  final String selectedCode;
  final ValueChanged<String> onSelect;
  final Color goldMain;
  final Color goldText;

  @override
  Widget build(BuildContext context) {
    return HorizontalScrollFade(
      height: _rowHeight,
      fadeWidth: 20,
      builder: (controller) {
        return ListView.separated(
          controller: controller,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: homeSendMoneyKitSegmentCodes.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final code = homeSendMoneyKitSegmentCodes[index];
            return _CurrencySegmentPill(
              code: code,
              selected: selectedCode == code,
              goldMain: goldMain,
              goldText: goldText,
              onTap: () => onSelect(code),
            );
          },
        );
      },
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

class _CurrencySegmentPill extends StatelessWidget {
  const _CurrencySegmentPill({
    required this.code,
    required this.selected,
    required this.goldMain,
    required this.goldText,
    required this.onTap,
  });

  final String code;
  final bool selected;
  final Color goldMain;
  final Color goldText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: selected
                ? goldMain.withValues(alpha: 0.22)
                : Colors.transparent,
            border: Border.all(
              color: selected
                  ? goldMain.withValues(alpha: 0.55)
                  : AppColors.textPrimary.withValues(alpha: 0.16),
            ),
          ),
          child: Text(
            code,
            style: AppTypography.caption.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? goldText : AppColors.textOnGlassMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _RateSparkline extends StatelessWidget {
  const _RateSparkline({
    super.key,
    required this.values,
    required this.color,
    required this.height,
  });

  final List<double> values;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _RateSparklinePainter(values: values, color: color),
      ),
    );
  }
}

class _RateSparklinePainter extends CustomPainter {
  _RateSparklinePainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs() < 0.0001 ? 1.0 : (maxV - minV);

    final linePath = Path();
    final fillPath = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * (i / (values.length - 1));
      final normalized = (values[i] - minV) / range;
      final y = size.height * (1 - normalized * 0.75) - size.height * 0.08;
      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.35),
          color.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _RateSparklinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}
