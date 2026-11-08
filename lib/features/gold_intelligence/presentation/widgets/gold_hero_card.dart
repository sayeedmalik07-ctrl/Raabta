import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/gold_intelligence/domain/gold_qatar_models.dart';
import 'package:raabta/features/gold_intelligence/presentation/l10n/gold_intelligence_strings.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';

class GoldHeroCard extends StatelessWidget {
  const GoldHeroCard({
    super.key,
    required this.snap,
    required this.locale,
  });

  final GoldQatarSnapshot snap;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final delta = snap.qarDeltaVsYesterday ?? 0;
    final isUp = delta >= 0;
    final high = snap.dayHigh ?? snap.gold24kQarPerGram;
    final low = snap.dayLow ?? snap.gold24kQarPerGram;

    return GlassCard(
      padding: EdgeInsets.zero,
      glowColor: AppColors.accentGold,
      glowIntensity: 0.18,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentGold.withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.accentGold.withValues(alpha: 0.5),
                          ),
                          color: AppColors.accentGold.withValues(alpha: 0.12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: snap.isDirectApi
                                  ? AppColors.success
                                  : AppColors.accentGold,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              snap.isDirectApi
                                  ? GoldIntelligenceStrings.t('hero_live_spot', locale)
                                  : GoldIntelligenceStrings.t('hero_qatar_24k', locale),
                              style: AppTypography.caption.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: AppColors.accentGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (delta != 0 || snap.pctVsYesterday != 0)
                        _DeltaPill(
                          delta: delta,
                          pct: snap.pctVsYesterday,
                          isUp: isUp,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  MoneyAnimatedFigure(
                    value: snap.gold24kQarPerGram,
                    decimals: 2,
                    style: AppTypography.headline2.copyWith(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      height: 1,
                      letterSpacing: -1.2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'QAR',
                        style: AppTypography.subtitle.copyWith(
                          color: AppColors.accentGold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        GoldIntelligenceStrings.t('hero_per_gram_24k', locale),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    GoldIntelligenceStrings.t('market_label', locale),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  if (snap.isFromCache)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        GoldIntelligenceStrings.t('hero_cached_rate_pull', locale),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.arrow_upward_rounded,
                            label: GoldIntelligenceStrings.t('hero_today_high', locale),
                            value: high.toStringAsFixed(2),
                            accent: AppColors.success,
                          ),
                        ),
                        Container(
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: AppColors.glassBorder,
                        ),
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.arrow_downward_rounded,
                            label: GoldIntelligenceStrings.t('hero_today_low', locale),
                            value: low.toStringAsFixed(2),
                            accent: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (snap.updatedAt != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '${GoldIntelligenceStrings.format('hero_updated_at', locale, params: {
                        'datetime': _formatTime(snap.updatedAt!),
                      })}'
                      '${snap.spotSource != null ? ' · ${snap.spotSource}' : ''}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day}/${local.month} · ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

class _DeltaPill extends StatelessWidget {
  const _DeltaPill({
    required this.delta,
    required this.pct,
    required this.isUp,
  });

  final double delta;
  final double pct;
  final bool isUp;

  @override
  Widget build(BuildContext context) {
    final color = isUp ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.trending_up : Icons.trending_down,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(2)}',
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: accent.withValues(alpha: 0.9)),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'QAR $value',
          style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
