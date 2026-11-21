import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/gold_intelligence/presentation/l10n/gold_intelligence_strings.dart';
import 'package:raabta/features/gold_intelligence/services/gold_qatar_service.dart';
import 'package:raabta/features/home/widgets/glass_loading_card.dart';
import 'package:raabta/providers/visa_providers.dart';

class GoldHomeCard extends ConsumerWidget {
  const GoldHomeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final snapAsync = ref.watch(goldLatestProvider);

    return snapAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: GlassLoadingCard(height: 120),
      ),
      error: (_, _) => _card(
        context,
        locale: locale,
        price: null,
        delta: null,
        isUp: true,
        high: null,
        low: null,
        insight: null,
        updated: null,
        offline: true,
      ),
      data: (snap) => _card(
        context,
        locale: locale,
        price: snap.gold24kQarPerGram,
        delta: snap.qarDeltaVsYesterday,
        isUp: (snap.qarDeltaVsYesterday ?? 0) >= 0,
        high: snap.dayHigh,
        low: snap.dayLow,
        insight: snap.aiInsight,
        updated: snap.updatedAt,
        offline: snap.isFromCache,
        isDirectApi: snap.isDirectApi,
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required String locale,
    required double? price,
    required double? delta,
    required bool isUp,
    required double? high,
    required double? low,
    String? insight,
    DateTime? updated,
    bool offline = false,
    bool isDirectApi = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        onTap: () => context.push('/money-services/gold'),
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppSpacing.radiusLg,
        glowColor: AppColors.accentGold,
        glowIntensity: 0.15,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('🥇', style: AppTypography.headline2),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        GoldIntelligenceStrings.t('home_card_title', locale),
                        style: AppTypography.title,
                      ),
                      Text(
                        GoldIntelligenceStrings.t('market_label', locale),
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (price != null)
              Text(
                GoldIntelligenceStrings.format(
                  'home_price_per_gram',
                  locale,
                  params: {'price': price.toStringAsFixed(2)},
                ),
                style: AppTypography.headline2.copyWith(color: AppColors.accentGold),
              )
            else
              Text(
                GoldIntelligenceStrings.t('home_rate_unavailable_retry', locale),
                style: AppTypography.subtitle.copyWith(color: AppColors.textSecondary),
              ),
            if (offline)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  GoldIntelligenceStrings.t('home_cached_rate_refresh', locale),
                  style: AppTypography.caption.copyWith(color: AppColors.warning),
                ),
              )
            else if (isDirectApi)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  GoldIntelligenceStrings.t('home_indicative_spot', locale),
                  style: AppTypography.caption.copyWith(color: AppColors.cyanGlow),
                ),
              ),
            if (delta != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(
                    isUp ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 16,
                    color: isUp ? AppColors.success : AppColors.error,
                  ),
                  Text(
                    ' ${GoldIntelligenceStrings.format('home_delta_vs_yesterday', locale, params: {
                      'delta': '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(2)}',
                    })}',
                    style: AppTypography.caption.copyWith(
                      color: isUp ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
            if (high != null && low != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                GoldIntelligenceStrings.format('home_today_hl', locale, params: {
                  'high': high.toStringAsFixed(2),
                  'low': low.toStringAsFixed(2),
                }),
                style: AppTypography.caption,
              ),
            ],
            if (updated != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  GoldIntelligenceStrings.format('home_updated_at', locale, params: {
                    'time': _formatDoha(updated),
                  }),
                  style: AppTypography.caption,
                ),
              ),
            if (insight != null && insight.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                insight,
                style: AppTypography.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                GoldIntelligenceStrings.t('ai_disclaimer', locale),
                style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDoha(DateTime dt) {
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
