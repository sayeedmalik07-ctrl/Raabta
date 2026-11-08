import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_progress_indicator.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';
import 'package:raabta/features/trip_planner/presentation/widgets/trip_budget_chart.dart';
import 'package:raabta/features/disruption_readiness/presentation/widgets/disruption_trip_readiness_card.dart';
import 'package:raabta/features/trip_planner/presentation/widgets/trip_readiness_widgets.dart';
import 'package:raabta/features/trip_planner/providers/trip_readiness_providers.dart';
import 'package:raabta/features/trip_planner/presentation/screens/trip_subscreens.dart';
import 'package:raabta/features/trip_planner/providers/trip_planner_providers.dart';
import 'package:raabta/features/trip_planner/services/trip_pdf_service.dart';
import 'package:raabta/features/trip_planner/presentation/widgets/trip_change_of_plans_section.dart';
import 'package:raabta/features/trip_planner/presentation/widgets/trip_controlled_medicines_card.dart';
import 'package:raabta/features/trip_planner/presentation/widgets/trip_official_links_card.dart';
import 'package:raabta/features/trip_planner/services/trip_planner_analytics_service.dart';
import 'package:raabta/services/sharing/models/shareable_card_data.dart';
import 'package:raabta/services/sharing/widgets/share_card_sheet.dart';

class GeneratedItineraryScreen extends ConsumerWidget {
  const GeneratedItineraryScreen({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tripPlannerProvider);
    final trip = tripForId(state, tripId);
    final locale = state.preferences.locale;
    final readiness = ref.watch(tripReadinessProvider(tripId));

    if (trip == null || trip.id != tripId) {
      return GlassScreenScaffold(
        title: TripStrings.t('trip_itinerary', locale),
        body: const Center(child: GlassProgressIndicator()),
      );
    }

    return GlassScreenScaffold(
      title: trip.title,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(
            trip.isFavorite ? Icons.favorite : Icons.favorite_border,
          ),
          onPressed: () =>
              ref.read(tripPlannerProvider.notifier).toggleFavorite(trip.id),
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            ShareCardSheet.show(
              context,
              TripItineraryCardData(
                tripTitle: trip.title,
                totalDays: trip.totalDays,
                totalBudget: trip.budget.totalSpent,
                currency: trip.preferences.currency,
                shareCode: trip.shareCode ?? '',
                activityCount: trip.days.fold<int>(
                  0,
                  (s, d) => s + d.activities.length,
                ),
                shareCaption:
                    '${trip.title} — ${trip.totalDays} days in Qatar with RAABTA',
              ),
            );
            TripPlannerAnalyticsService.tripShared(trip.id);
          },
        ),
        IconButton(
          icon: const Icon(Icons.picture_as_pdf_outlined),
          onPressed: () async {
            final pdf = ref.read(tripPdfServiceProvider);
            final file = await pdf.generateReport(trip: trip, locale: locale);
            await pdf.sharePdf(file);
          },
        ),
      ],
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          TripReadinessSummaryCard(
            tripId: tripId,
            locale: locale,
            result: readiness,
            compact: true,
            onTap: () => context.push('/trip-planner/readiness/$tripId'),
          ),
          const SizedBox(height: AppSpacing.md),
          DisruptionTripReadinessCard(tripId: tripId, locale: locale),
          const SizedBox(height: AppSpacing.md),
          TripOfficialLinksCard(
            locale: locale,
            showStopoverRow: trip.totalDays <= 2,
          ),
          const SizedBox(height: AppSpacing.md),
          TripControlledMedicinesCard(locale: locale),
          const SizedBox(height: AppSpacing.md),
          TripChangeOfPlansSection(trip: trip, locale: locale),
          const SizedBox(height: AppSpacing.sm),
          TripFlightReminderToggle(trip: trip, locale: locale),
          const SizedBox(height: AppSpacing.md),
          TripDeferredActivitiesSection(trip: trip, locale: locale),
          const SizedBox(height: AppSpacing.lg),
          TripBudgetChart(
            budget: trip.budget,
            locale: locale,
            currency: trip.preferences.currency,
          ),
          const SizedBox(height: AppSpacing.lg),
          ...trip.days.map(
            (day) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GlassCard(
                onTap: () => context.push(
                  '/trip-planner/day/$tripId/${day.dayNumber}',
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(day.title, style: AppTypography.title),
                          Text(
                            '${day.activities.length} activities',
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
          ),
          const SizedBox(height: AppSpacing.md),
          _NavRow(
            locale: locale,
            tripId: tripId,
            icons: const [
              (Icons.map_outlined, '/trip-planner/map/'),
              (Icons.wb_sunny_outlined, '/trip-planner/weather/'),
              (Icons.summarize_outlined, '/trip-planner/summary/'),
            ],
          ),
          if (trip.budgetTips.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              TripStrings.t('trip_over_budget', locale),
              style: AppTypography.title,
            ),
            ...trip.budgetTips.map(
              (tip) => ListTile(
                title: Text(tip.title),
                subtitle: Text(tip.description),
                trailing: Text(
                  '-${formatTripCurrency(tip.savings, symbol: trip.preferences.currency)}',
                ),
              ),
            ),
          ],
          if (trip.travelTips.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(TripStrings.t('trip_tips', locale), style: AppTypography.title),
            ...trip.travelTips.map(
              (t) => ListTile(
                leading: const Icon(Icons.lightbulb_outline),
                title: Text(t),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.locale,
    required this.tripId,
    required this.icons,
  });

  final String locale;
  final String tripId;
  final List<(IconData, String)> icons;

  @override
  Widget build(BuildContext context) {
    final labels = [
      TripStrings.t('trip_map', locale),
      TripStrings.t('trip_weather', locale),
      TripStrings.t('trip_summary', locale),
    ];
    return Row(
      children: [
        for (var i = 0; i < icons.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: i < icons.length - 1 ? AppSpacing.sm : 0,
              ),
              child: GlassCard(
                onTap: () => context.push('${icons[i].$2}$tripId'),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    Icon(icons[i].$1),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(labels[i], style: AppTypography.bodySmall, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
