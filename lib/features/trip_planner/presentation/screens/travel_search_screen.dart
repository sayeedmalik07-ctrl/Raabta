import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/glass_text_field.dart';
import 'package:raabta/features/trip_planner/data/qatar_places_catalog.dart';
import 'package:raabta/features/trip_planner/domain/models/catalog_place.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';
import 'package:raabta/features/trip_planner/providers/trip_planner_providers.dart';

class TravelSearchScreen extends ConsumerStatefulWidget {
  const TravelSearchScreen({super.key});

  @override
  ConsumerState<TravelSearchScreen> createState() =>
      _TravelSearchScreenState();
}

class _TravelSearchScreenState extends ConsumerState<TravelSearchScreen> {
  final _controller = TextEditingController();
  List<CatalogPlace> _results = [];
  List<String> _shopping = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String q) {
    final locale = ref.read(tripPlannerProvider).preferences.locale;
    setState(() {
      _results = QatarPlacesCatalog.search(q, locale);
      _shopping = [];
      if (q.toLowerCase().contains('shop') ||
          q.toLowerCase().contains('mall')) {
        _shopping = QatarPlacesCatalog.shopping;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(tripPlannerProvider).preferences.locale;

    return GlassScreenScaffold(
      title: TripStrings.t('travel_search', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: Column(
        children: [
          GlassTextField(
            controller: _controller,
            autofocus: true,
            icon: Icons.search,
            hint: TripStrings.t('travel_search_hint', locale),
            onChanged: _search,
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView(
              children: [
                ..._results.map(
                  (item) => GlassCard(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    onTap: () =>
                        context.push('/trip-planner/place/${item.id}'),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title, style: AppTypography.title),
                              Text(
                                item.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
                ..._shopping.map(
                  (s) => ListTile(
                    leading: const Icon(Icons.shopping_bag_outlined),
                    title: Text(s),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
