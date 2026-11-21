import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/gold_intelligence/domain/gold_qatar_constants.dart';
import 'package:raabta/features/gold_intelligence/presentation/l10n/gold_intelligence_strings.dart';

/// Interactive weight × karat pricing — card stack, not spreadsheet tables.
class GoldWeightPricingPanel extends StatefulWidget {
  const GoldWeightPricingPanel({
    super.key,
    required this.price24k,
    required this.locale,
  });

  final double price24k;
  final String locale;

  @override
  State<GoldWeightPricingPanel> createState() => _GoldWeightPricingPanelState();
}

class _GoldWeightPricingPanelState extends State<GoldWeightPricingPanel> {
  int _weightIndex = 0;

  static final _icons = [
    Icons.looks_one_outlined,
    Icons.token_outlined,
    Icons.diamond_outlined,
    Icons.balance_outlined,
    Icons.water_drop_outlined,
    Icons.inventory_2_outlined,
    Icons.scale_outlined,
  ];

  String _shortLabel(String key) {
    switch (key) {
      case '1_gram':
        return GoldIntelligenceStrings.t('weight_row_short_1g', widget.locale);
      case '8_gram_sovereign':
        return GoldIntelligenceStrings.t('weight_row_short_8g', widget.locale);
      case '10_grams':
        return GoldIntelligenceStrings.t('weight_row_short_10g', widget.locale);
      case 'tola':
        return GoldIntelligenceStrings.t('weight_row_short_tola', widget.locale);
      case 'ounce':
        return GoldIntelligenceStrings.t('weight_row_short_oz', widget.locale);
      case '100_grams':
        return GoldIntelligenceStrings.t('weight_row_short_100g', widget.locale);
      case 'kilogram':
        return GoldIntelligenceStrings.t('weight_row_short_1kg', widget.locale);
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final row = GoldQatarConstants.weightRows[_weightIndex];
    final maxTotal = GoldQatarConstants.priceForPurity(widget.price24k, 24) *
        GoldQatarConstants.weightRows.last.grams;
    final gramsDisplay = row.grams.toStringAsFixed(
      row.grams == row.grams.roundToDouble() ? 0 : 4,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: GoldQatarConstants.weightRows.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
            itemBuilder: (context, i) {
              final r = GoldQatarConstants.weightRows[i];
              final selected = i == _weightIndex;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _weightIndex = i),
                  borderRadius: BorderRadius.circular(999),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: selected
                          ? AppColors.accentGold.withValues(alpha: 0.22)
                          : AppColors.surface.withValues(alpha: 0.45),
                      border: Border.all(
                        color: selected
                            ? AppColors.accentGold.withValues(alpha: 0.7)
                            : AppColors.glassBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _icons[i],
                          size: 16,
                          color: selected
                              ? AppColors.accentGold
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _shortLabel(r.key),
                          style: AppTypography.caption.copyWith(
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w500,
                            color: selected
                                ? AppColors.accentGold
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          glowColor: AppColors.accentGold,
          glowIntensity: 0.08,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          GoldIntelligenceStrings.weightRowLabel(row.key, widget.locale),
                          style: AppTypography.subtitle.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          GoldIntelligenceStrings.format(
                            'weight_panel_live_base',
                            widget.locale,
                            params: {'grams': gramsDisplay},
                          ),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '22K',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              ...GoldQatarConstants.purities.map((purity) {
                final perGram =
                    GoldQatarConstants.priceForPurity(widget.price24k, purity);
                final total = perGram * row.grams;
                final ratio = (total / maxTotal).clamp(0.08, 1.0);

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _KaratPriceBar(
                    purity: purity,
                    total: total,
                    ratio: ratio,
                    highlight: purity == 22,
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _KaratPriceBar extends StatelessWidget {
  const _KaratPriceBar({
    required this.purity,
    required this.total,
    required this.ratio,
    required this.highlight,
  });

  final int purity;
  final double total;
  final double ratio;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 38,
          child: Text(
            '${purity}K',
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: highlight ? AppColors.accentGold : AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 6,
                  backgroundColor: AppColors.surface.withValues(alpha: 0.6),
                  color: highlight
                      ? AppColors.accentGold
                      : AppColors.accentGold.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'QAR ${_formatTotal(total)}',
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  String _formatTotal(double v) {
    if (v >= 10000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }
}
