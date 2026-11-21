import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';
import 'package:raabta/providers/my_activity_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/profile/l10n/my_activity_strings.dart';
import 'package:raabta/features/post_engine/presentation/providers/post_engine_drafts_provider.dart';
import 'package:raabta/screens/profile/models/my_activity_item.dart';
import 'package:raabta/screens/profile/providers/life_intelligence_activity_providers.dart';
import 'package:raabta/screens/profile/widgets/my_activity_drafts_section.dart';

class MyActivityScreen extends ConsumerWidget {
  const MyActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final aggregationAsync = ref.watch(myActivityPendingItemsProvider);
    final lifeIntelligenceAsync =
        ref.watch(lifeIntelligenceActivityItemsProvider);
    final draftsAsync = ref.watch(postEngineDraftsProvider);
    final draftCount = draftsAsync.valueOrNull?.length ?? 0;

    return GlassScreenScaffold(
      title: MyActivityStrings.t('my_activity_title', locale),
      body: aggregationAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.purpleGlow),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(
              MyActivityStrings.t('my_activity_load_failed', locale),
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (aggregation) {
          final lifeIntelligenceItems =
              lifeIntelligenceAsync.valueOrNull ?? const [];
          final hasTransactional = !aggregation.isConfirmedEmpty;
          final hasLifeIntelligence = lifeIntelligenceItems.isNotEmpty;

          if (!hasTransactional && !hasLifeIntelligence && draftCount == 0) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  MyActivityStrings.t('my_activity_empty', locale),
                  style: AppTypography.body,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final items = aggregation.items;
          final grouped = <MyActivityVertical, List<MyActivityItem>>{};
          for (final item in items) {
            grouped.putIfAbsent(item.vertical, () => []).add(item);
          }

          final verticalOrder = MyActivityVertical.values
              .where((v) => grouped.containsKey(v))
              .toList();

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              const MyActivityDraftsSection(),
              if (aggregation.hasPartialFailure)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(
                    MyActivityStrings.t('my_activity_incomplete', locale),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.warning,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (hasLifeIntelligence) ...[
                Text(
                  MyActivityStrings.t(
                    'my_activity_section_life_intelligence',
                    locale,
                  ),
                  style: AppTypography.subtitle,
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final item in lifeIntelligenceItems)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: GlassCard(
                      onTap: () => context.push(item.route),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  MyActivityStrings.t(item.titleKey, locale),
                                  style: AppTypography.subtitle.copyWith(
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  MyActivityStrings.t(item.bodyKey, locale),
                                  style: AppTypography.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Column(
                            children: [
                              StatusBadge(
                                label: MyActivityStrings.t(
                                  'my_activity_li_advisory',
                                  locale,
                                ),
                                color: AppColors.cyanGlow,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              TextButton(
                                onPressed: () => dismissLifeIntelligenceActivityItem(
                                  ref,
                                  item,
                                ),
                                child: Text(
                                  MyActivityStrings.t(
                                    'my_activity_li_dismiss',
                                    locale,
                                  ),
                                  style: AppTypography.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
              ],
              for (final vertical in verticalOrder) ...[
                Text(
                  MyActivityStrings.sectionTitle(vertical, locale),
                  style: AppTypography.subtitle,
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final item in grouped[vertical]!)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: GlassCard(
                      onTap: () => context.push(item.route),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: AppTypography.subtitle.copyWith(
                                    fontSize: 15,
                                  ),
                                ),
                                if (item.subtitle != null &&
                                    item.subtitle!.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    item.subtitle!,
                                    style: AppTypography.bodySmall,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          StatusBadge(
                            label: MyActivityStrings.statusLabel(
                              item.vertical,
                              item.statusLabel,
                              locale,
                            ),
                            color: _statusColor(item.vertical),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          );
        },
      ),
    );
  }

  Color _statusColor(MyActivityVertical vertical) {
    return switch (vertical) {
      MyActivityVertical.marketplace => AppColors.cyanGlow,
      MyActivityVertical.housing => AppColors.purpleGlow,
      MyActivityVertical.services => AppColors.success,
      MyActivityVertical.jobs => AppColors.amberGlow,
      MyActivityVertical.business => AppColors.accentGold,
    };
  }
}
