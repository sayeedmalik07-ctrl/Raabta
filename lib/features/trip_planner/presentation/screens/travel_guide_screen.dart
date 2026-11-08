import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/hub/hub_feed_footer_notice.dart';
import 'package:raabta/core/widgets/hub/hub_subscreen_scaffold.dart';
import 'package:raabta/features/trip_planner/domain/models/travel_guide_content.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';
import 'package:raabta/features/trip_planner/providers/trip_planner_providers.dart';

enum TravelGuideType { culture, dosDonts, ramadan, transport }

class TravelGuideScreen extends ConsumerWidget {
  const TravelGuideScreen({super.key, required this.guideType});

  final TravelGuideType guideType;

  List<TravelGuideSection> get _sections {
    switch (guideType) {
      case TravelGuideType.culture:
        return TravelGuideContent.culture;
      case TravelGuideType.dosDonts:
        return TravelGuideContent.dosDonts;
      case TravelGuideType.ramadan:
        return TravelGuideContent.ramadanTourist;
      case TravelGuideType.transport:
        return TravelGuideContent.transport;
    }
  }

  String get _titleKey {
    switch (guideType) {
      case TravelGuideType.culture:
        return 'travel_culture';
      case TravelGuideType.dosDonts:
        return 'travel_dos_donts';
      case TravelGuideType.ramadan:
        return 'travel_ramadan';
      case TravelGuideType.transport:
        return 'travel_transport';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(tripPlannerProvider).preferences.locale;

    return HubSubscreenScaffold(
      title: TripStrings.t(_titleKey, locale),
      subtitle: TripStrings.t('travel_guide_hub_subtitle', locale),
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
              AppSpacing.lg,
            ),
            sliver: SliverList.separated(
              itemCount: _sections.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                final section = _sections[i];
                return GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  borderRadius: AppSpacing.radiusLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TripStrings.t(section.titleKey, locale),
                        style: AppTypography.title,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        TripStrings.resolveTransportCopy(
                          section.bodyKey,
                          locale,
                        ),
                        style: AppTypography.bodySmall,
                      ),
                      ...section.tipsKeys.map(
                        (key) => Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xxs),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• '),
                              Expanded(
                                child: Text(
                                  TripStrings.resolveTransportCopy(
                                    key,
                                    locale,
                                  ),
                                  style: AppTypography.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
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
