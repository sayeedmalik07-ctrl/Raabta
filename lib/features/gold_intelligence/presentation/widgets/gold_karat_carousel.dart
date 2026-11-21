import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/gold_intelligence/domain/gold_qatar_constants.dart';
import 'package:raabta/features/gold_intelligence/presentation/l10n/gold_intelligence_strings.dart';

/// Horizontal karat cards — inspired by premium gold tracker apps (not table rows).
class GoldKaratCarousel extends StatefulWidget {
  const GoldKaratCarousel({
    super.key,
    required this.price24k,
    required this.locale,
    this.initialPurity = 22,
    this.onPuritySelected,
  });

  final double price24k;
  final String locale;
  final int initialPurity;
  final ValueChanged<int>? onPuritySelected;

  @override
  State<GoldKaratCarousel> createState() => _GoldKaratCarouselState();
}

class _GoldKaratCarouselState extends State<GoldKaratCarousel> {
  late int _selected;

  static const _karatHue = {
    24: 0.12,
    22: 0.08,
    21: 0.05,
    18: 0.02,
  };

  @override
  void initState() {
    super.initState();
    _selected = widget.initialPurity;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: GoldQatarConstants.purities.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final purity = GoldQatarConstants.purities[index];
          final price = GoldQatarConstants.priceForPurity(widget.price24k, purity);
          final hue = _karatHue[purity] ?? 0.02;
          final metaLabel = GoldIntelligenceStrings.karatMetaLabel(purity, widget.locale);
          final badgeLabel = GoldIntelligenceStrings.karatBadgeLabel(purity, widget.locale);
          final selected = _selected == purity;

          return GestureDetector(
            onTap: () {
              setState(() => _selected = purity);
              widget.onPuritySelected?.call(purity);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: 148,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: selected
                      ? [
                          AppColors.accentGold.withValues(alpha: 0.35),
                          AppColors.amberGlow.withValues(alpha: 0.12),
                          AppColors.surface.withValues(alpha: 0.6),
                        ]
                      : [
                          AppColors.surface.withValues(alpha: 0.55),
                          AppColors.surfaceElevated.withValues(alpha: 0.35),
                        ],
                ),
                border: Border.all(
                  color: selected
                      ? AppColors.accentGold.withValues(alpha: 0.85)
                      : AppColors.glassBorder,
                  width: selected ? 1.5 : 1,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.accentGold.withValues(alpha: 0.22),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.accentGold.withValues(
                                alpha: 0.35 + hue,
                              ),
                              AppColors.amberGlow.withValues(alpha: 0.08),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.accentGold.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          '$purity',
                          style: AppTypography.subtitle.copyWith(
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (badgeLabel != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            badgeLabel,
                            style: AppTypography.caption.copyWith(
                              fontSize: 9,
                              color: AppColors.accentGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'QAR ${price.toStringAsFixed(2)}',
                    style: AppTypography.subtitle.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    metaLabel,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
