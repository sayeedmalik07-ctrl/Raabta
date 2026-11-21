import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';
import 'package:raabta/features/trip_planner/data/fair_price_guide_catalog.dart';
import 'package:raabta/features/trip_planner/data/qatar_local_life_catalog.dart';
import 'package:raabta/features/trip_planner/data/trip_visitor_content_config.dart';
import 'package:raabta/features/trip_planner/domain/models/local_life_models.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_preferences.dart';
import 'package:raabta/features/trip_planner/domain/services/trip_content_filter_service.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';
import 'package:raabta/features/trip_planner/providers/trip_content_filter_providers.dart';
import 'package:raabta/features/trip_planner/providers/trip_planner_providers.dart';
import 'package:raabta/core/widgets/trust_label.dart';

class LocalLifeHubScreen extends ConsumerWidget {
  const LocalLifeHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(tripPlannerProvider).preferences.locale;
    final filter = ref.watch(tripLocalLifeFilterProvider);
    final service = ref.watch(tripContentFilterServiceProvider);
    final plannerState = ref.watch(tripPlannerProvider);
    final prefs =
        plannerState.activeTrip?.preferences ?? plannerState.preferences;

    final visibleCategories = QatarLocalLifeCatalog.categories.where((cat) {
      final result = service.filterLocalLifeEntries(
        QatarLocalLifeCatalog.entriesFor(cat),
        prefs,
      );
      return result.primary.isNotEmpty || result.deprioritized.isNotEmpty;
    });

    return GlassScreenScaffold(
      title: TripStrings.t('ll_hub_title', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            glowColor: AppColors.chipTrip,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TripStrings.t('ll_hub_intro', locale),
                  style: AppTypography.bodySmall,
                ),
                if (filter.filteringActive) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    TripStrings.t('visitor_filter_active_hint', locale),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.cyanGlow,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                TrustLabel(
                  type: TrustLabelType.verified,
                  locale: locale,
                  verifiedDateIso: QatarLocalLifeCatalog.catalogLastVerified,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...visibleCategories.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _CategoryTile(
                category: cat,
                locale: locale,
                prefs: prefs,
                service: service,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LocalLifeCategoryScreen extends ConsumerStatefulWidget {
  const LocalLifeCategoryScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  ConsumerState<LocalLifeCategoryScreen> createState() =>
      _LocalLifeCategoryScreenState();
}

class _LocalLifeCategoryScreenState extends ConsumerState<LocalLifeCategoryScreen> {
  bool _showDeprioritized = false;

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(tripPlannerProvider).preferences.locale;
    final category = LocalLifeCategoryExt.fromId(widget.categoryId);
    if (category == null) {
      return GlassScreenScaffold(
        title: TripStrings.t('ll_hub_title', locale),
        body: Center(child: Text(TripStrings.t('ll_not_found', locale))),
      );
    }

    final filter = ref.watch(tripLocalLifeCategoryFilterProvider(category));

    return GlassScreenScaffold(
      title: TripStrings.t(category.titleKey, locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          Text(
            TripStrings.t(category.descriptionKey, locale),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (filter.primary.isEmpty && filter.deprioritized.isEmpty)
            Text(
              TripStrings.t('ll_not_found', locale),
              style: AppTypography.bodySmall,
            )
          else ...[
            ...filter.primary.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _EntryTile(
                  entry: e,
                  categoryId: widget.categoryId,
                  locale: locale,
                ),
              ),
            ),
            if (filter.hasDeprioritized) ...[
              const SizedBox(height: AppSpacing.md),
              InkWell(
                onTap: () =>
                    setState(() => _showDeprioritized = !_showDeprioritized),
                child: Row(
                  children: [
                    Icon(
                      _showDeprioritized
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        TripStrings.format('visitor_filter_deprioritized', locale, {
                          'count': '${filter.deprioritized.length}',
                        }),
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_showDeprioritized) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  TripStrings.t('visitor_filter_deprioritized_hint', locale),
                  style: AppTypography.caption,
                ),
                const SizedBox(height: AppSpacing.sm),
                ...filter.deprioritized.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Opacity(
                      opacity: 0.85,
                      child: _EntryTile(
                        entry: e,
                        categoryId: widget.categoryId,
                        locale: locale,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.entry,
    required this.categoryId,
    required this.locale,
  });

  final LocalLifeEntry entry;
  final String categoryId;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () => context.push(
        '/trip-planner/local-life/$categoryId/${entry.id}',
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TripStrings.t(entry.titleKey, locale),
                  style: AppTypography.title.copyWith(fontSize: 15),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  TripStrings.t(entry.summaryKey, locale),
                  style: AppTypography.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          StatusBadge(
            label: TripStrings.t(entry.priorityKey, locale),
            color: _priorityColor(entry.priority),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class LocalLifeEntryScreen extends ConsumerWidget {
  const LocalLifeEntryScreen({
    super.key,
    required this.categoryId,
    required this.entryId,
  });

  final String categoryId;
  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(tripPlannerProvider).preferences.locale;
    final entry = QatarLocalLifeCatalog.entryById(entryId);

    if (entry == null || entry.category.id != categoryId) {
      return GlassScreenScaffold(
        title: TripStrings.t('ll_hub_title', locale),
        body: Center(child: Text(TripStrings.t('ll_not_found', locale))),
      );
    }

    return GlassScreenScaffold(
      title: TripStrings.t(entry.titleKey, locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          StatusBadge(
            label: TripStrings.t(entry.priorityKey, locale),
            color: _priorityColor(entry.priority),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            TripStrings.resolveTransportCopy(entry.summaryKey, locale),
            style: AppTypography.body,
          ),
          const SizedBox(height: AppSpacing.lg),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            glowColor: AppColors.cyanGlow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TripStrings.t('ll_action_heading', locale),
                  style: AppTypography.title.copyWith(fontSize: 14),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  TripStrings.t(entry.actionKey, locale),
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          if (entry.tipKeys.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(TripStrings.t('ll_tips_heading', locale), style: AppTypography.title),
            const SizedBox(height: AppSpacing.sm),
            ...entry.tipKeys.map(
              (key) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(
                      child: Text(
                        TripStrings.resolveTransportCopy(key, locale),
                        style: AppTypography.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (entry.fairPriceItemId != null) ...[
            const SizedBox(height: AppSpacing.md),
            _FairPriceRef(entry: entry, locale: locale),
          ],
          if (entry.ambiguousGuidance) ...[
            const SizedBox(height: AppSpacing.md),
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              glowColor: AppColors.accentGold,
              child: Text(
                TripStrings.t('ll_ambiguous_notice', locale),
                style: AppTypography.bodySmall,
              ),
            ),
          ],
          if (entry.sourceLabelKey != null ||
              entry.dateLastVerified != null) ...[
            const SizedBox(height: AppSpacing.md),
            LocalLifeTrustLabels(
              locale: locale,
              sourceLabelKey: entry.sourceLabelKey,
              sourceUrl: entry.sourceUrl,
              dateLastVerified: entry.dateLastVerified,
            ),
          ],
          if (entry.relatedRoute != null) ...[
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: () => context.push(entry.relatedRoute!),
              icon: const Icon(Icons.open_in_new),
              label: Text(TripStrings.t('ll_open_related', locale)),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.locale,
    required this.prefs,
    required this.service,
  });

  final LocalLifeCategory category;
  final String locale;
  final TripPreferences prefs;
  final TripContentFilterService service;

  @override
  Widget build(BuildContext context) {
    final result = service.filterLocalLifeEntries(
      QatarLocalLifeCatalog.entriesFor(category),
      prefs,
    );
    final count = result.primary.length;
    final deprioritized = TripVisitorContentConfig.isCategoryDeprioritized(
      prefs.visitorPurpose,
      category,
    );

    return GlassCard(
      onTap: () => context.push('/trip-planner/local-life/${category.id}'),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Icon(category.icon, color: AppColors.chipTrip),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TripStrings.t(category.titleKey, locale),
                  style: AppTypography.title.copyWith(fontSize: 15),
                ),
                Text(
                  TripStrings.t(category.descriptionKey, locale),
                  style: AppTypography.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$count', style: AppTypography.caption),
              if (deprioritized && result.deprioritized.isNotEmpty)
                Text(
                  TripStrings.t('visitor_filter_more_available', locale),
                  style: AppTypography.caption.copyWith(fontSize: 10),
                ),
            ],
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}


class _FairPriceRef extends StatelessWidget {
  const _FairPriceRef({required this.entry, required this.locale});

  final LocalLifeEntry entry;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final item = FairPriceGuideCatalog.byId(entry.fairPriceItemId!);
    if (item == null) return const SizedBox.shrink();

    final range = item.minQar == item.maxQar
        ? 'QAR ${item.minQar.toStringAsFixed(0)}'
        : 'QAR ${item.minQar.toStringAsFixed(0)}–${item.maxQar.toStringAsFixed(0)}';

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TrustLabel(
            type: TrustLabelType.verified,
            locale: locale,
            verifiedDateIso: FairPriceGuideCatalog.catalogLastVerified,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            TripStrings.t('ll_fair_price_ref', locale),
            style: AppTypography.caption,
          ),
          Text(range, style: AppTypography.bodySmall),
          TextButton(
            onPressed: () => context.push('/trip-planner/fair-prices'),
            child: Text(TripStrings.t('travel_fair_prices', locale)),
          ),
        ],
      ),
    );
  }
}

Color _priorityColor(LocalLifePriority priority) {
  return switch (priority) {
    LocalLifePriority.mustKnow => AppColors.errorBright,
    LocalLifePriority.useful => AppColors.accentGold,
    LocalLifePriority.situational => AppColors.textSecondary,
  };
}
