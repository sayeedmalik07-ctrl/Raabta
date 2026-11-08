import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/post_engine/domain/post_price_suggester.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';

class PostMarketplaceDraftInsightsPanel extends StatelessWidget {
  const PostMarketplaceDraftInsightsPanel({
    super.key,
    required this.locale,
    this.priceSuggestion,
    this.priceGrounded = false,
    this.showUngroundedFallback = false,
    this.resellerNudgeKey,
  });

  final String locale;
  final PostPriceSuggestion? priceSuggestion;
  final bool priceGrounded;
  final bool showUngroundedFallback;
  final String? resellerNudgeKey;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    if (priceSuggestion != null && priceGrounded && priceSuggestion!.hasRange) {
      children.add(
        _InsightBlock(
          icon: Icons.payments_outlined,
          color: AppColors.cyanGlow,
          text: PostEngineStrings.format(
            'marketplace_price_grounded',
            locale,
            params: {
              'min': '${priceSuggestion!.minQar}',
              'max': '${priceSuggestion!.maxQar}',
              'median': '${priceSuggestion!.medianQar}',
              'count': '${priceSuggestion!.sampleSize}',
            },
          ),
        ),
      );
    } else if (showUngroundedFallback) {
      children.add(
        _InsightBlock(
          icon: Icons.payments_outlined,
          color: AppColors.cyanGlow,
          text: PostEngineStrings.t('marketplace_price_ungrounded', locale),
        ),
      );
    }

    if (resellerNudgeKey != null && resellerNudgeKey!.isNotEmpty) {
      children.add(
        _InsightBlock(
          icon: Icons.storefront_outlined,
          color: AppColors.warning,
          text: PostEngineStrings.t(resellerNudgeKey!, locale),
        ),
      );
    }

    if (children.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _InsightBlock extends StatelessWidget {
  const _InsightBlock({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTypography.bodySmall)),
        ],
      ),
    );
  }
}
