import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/hub/hub_feed_footer_notice.dart';
import 'package:raabta/core/widgets/hub/hub_subscreen_scaffold.dart';
import 'package:raabta/core/widgets/trust_label.dart';
import 'package:raabta/features/trip_planner/data/fair_price_guide_catalog.dart';
import 'package:raabta/features/trip_planner/domain/models/fair_price_models.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';
import 'package:raabta/features/trip_planner/providers/trip_planner_providers.dart';

class FairPriceGuideScreen extends ConsumerWidget {
  const FairPriceGuideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(tripPlannerProvider).preferences.locale;

    return HubSubscreenScaffold(
      title: TripStrings.t('fair_price_title', locale),
      subtitle: TripStrings.t('fair_price_subtitle', locale),
      onBack: () => context.pop(),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: GlassCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                borderRadius: AppSpacing.radiusLg,
                glowColor: AppColors.info,
                child: Text(
                  TripStrings.t('fair_price_disclaimer', locale),
                  style: AppTypography.bodySmall,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            sliver: SliverToBoxAdapter(
              child: TrustLabel(
                type: TrustLabelType.verified,
                locale: locale,
                verifiedDateIso: FairPriceGuideCatalog.catalogLastVerified,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                FairPriceCategory.values.map((cat) {
                  return _CategorySection(category: cat, locale: locale);
                }).toList(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: HubFeedFooterNotice(locale: locale),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxl),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.locale,
  });

  final FairPriceCategory category;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final items = FairPriceGuideCatalog.forCategory(category);
    if (items.isEmpty) return const SizedBox.shrink();

    final catKey = switch (category) {
      FairPriceCategory.taxi => 'fair_price_cat_taxi',
      FairPriceCategory.food => 'fair_price_cat_food',
      FairPriceCategory.tourist => 'fair_price_cat_tourist',
      FairPriceCategory.transport => 'fair_price_cat_transport',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TripStrings.t(catKey, locale),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GlassCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                borderRadius: AppSpacing.radiusLg,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            TripStrings.t(item.nameKey, locale),
                            style: AppTypography.subtitle,
                          ),
                          if (item.unitKey != null)
                            Text(
                              TripStrings.t(item.unitKey!, locale),
                              style: AppTypography.caption,
                            ),
                        ],
                      ),
                    ),
                    Text(
                      _rangeLabel(item, locale),
                      style: AppTypography.subtitle.copyWith(
                        color: AppColors.chipTrip,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _rangeLabel(FairPriceGuideItem item, String locale) {
    if (item.minQar == item.maxQar) {
      return TripStrings.format('fair_price_single_qar', locale, {
        'amount': _fmt(item.minQar),
      });
    }
    return TripStrings.format('fair_price_range_qar', locale, {
      'min': _fmt(item.minQar),
      'max': _fmt(item.maxQar),
    });
  }

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
}
