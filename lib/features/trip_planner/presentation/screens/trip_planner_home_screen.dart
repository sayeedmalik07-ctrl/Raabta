import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/ai_suggestion_card.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/glass_tag.dart';
import 'package:raabta/core/widgets/glass_text_field.dart';
import 'package:raabta/features/know_qatar/presentation/l10n/know_qatar_strings.dart';
import 'package:raabta/features/know_qatar/presentation/screens/know_qatar_screen.dart';
import 'package:raabta/features/trip_planner/data/qatar_places_catalog.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_enums.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';
import 'package:raabta/features/trip_planner/providers/trip_planner_providers.dart';
import 'package:raabta/features/trip_planner/services/trip_planner_analytics_service.dart';
import 'package:raabta/features/trip_planner/data/trip_visitor_content_config.dart';
import 'package:raabta/features/trip_planner/presentation/widgets/trip_visitor_purpose_selector.dart';

class TripPlannerHomeScreen extends ConsumerStatefulWidget {
  const TripPlannerHomeScreen({super.key});

  @override
  ConsumerState<TripPlannerHomeScreen> createState() =>
      _TripPlannerHomeScreenState();
}

class _TripPlannerHomeScreenState extends ConsumerState<TripPlannerHomeScreen> {
  final _promptController = TextEditingController();

  static const _examples = [
    'I have 3 days in Doha with QAR 2,000',
    'Luxury weekend in Qatar',
    'Family trip with kids',
    'Budget sightseeing — free attractions only',
    'I only have 6 hours in Doha',
    'Photography tour of Doha',
  ];

  @override
  void initState() {
    super.initState();
    TripPlannerAnalyticsService.homeVisit();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    var prefs = ref.read(tripPlannerProvider).preferences;
    final locale = prefs.locale;

    if (prefs.visitorPurpose == null) {
      final purpose = await showVisitorPurposeSheet(context, locale);
      if (!mounted || purpose == null) return;
      prefs = prefs.copyWith(
        visitorPurpose: purpose,
        kidsFriendly: purpose == TripVisitorPurpose.familyWithChildren
            ? true
            : prefs.kidsFriendly,
      );
      ref.read(tripPlannerProvider.notifier).updatePreferences(prefs);
      await ref.read(tripPlannerProvider.notifier).savePreferences();
    }

    prefs = ref.read(tripPlannerProvider).preferences.copyWith(
          naturalLanguagePrompt: _promptController.text.trim(),
        );
    ref.read(tripPlannerProvider.notifier).updatePreferences(prefs);
    await ref.read(tripPlannerProvider.notifier).savePreferences();

    if (!mounted) return;
    context.push('/trip-planner/generating');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tripPlannerProvider);
    final locale = state.preferences.locale;
    final trending = QatarPlacesCatalog.allPlaces(locale).take(3).toList();

    return GlassScreenScaffold(
      title: TripStrings.t('travel_companion_title', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => context.push('/trip-planner/search'),
        ),
      ],
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            glowColor: AppColors.chipTrip,
            glowIntensity: 0.2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🇶🇦', style: TextStyle(fontSize: 36)),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  TripStrings.t('travel_welcome', locale),
                  style: AppTypography.headline2,
                ),
                Text(
                  TripStrings.t('travel_welcome_sub', locale),
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AISuggestionCard(
            title: KnowQatarStrings.t('kq_section_culture_title', locale),
            description: KnowQatarStrings.t('kq_section_culture_teaser', locale),
            icon: Icons.menu_book_outlined,
            accentColor: AppColors.cyanGlow,
            actionLabel: KnowQatarStrings.t('kq_action_open', locale),
            onTap: () => context.push(
              KnowQatarScreen.route(sectionKey: 'culture_society'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            TripStrings.t('travel_quick_actions', locale),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          _NavGrid(
            locale: locale,
            activeTripId: state.activeTrip?.id,
          ),
          if (trending.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              TripStrings.t('travel_trending', locale),
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.sm),
            ...trending.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: GlassCard(
                  onTap: () => context.push('/trip-planner/place/${p.id}'),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.title, style: AppTypography.title),
                            Text(
                              p.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '★ ${p.rating.toStringAsFixed(1)}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.accentGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          GlassCard(
            onTap: () => context.push('/trip-planner/preferences'),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.tune, color: AppColors.cyanGlow, size: 28),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TripStrings.t('trip_preferences', locale),
                        style: AppTypography.title,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        '${state.preferences.days} ${TripStrings.t('trip_days', locale).toLowerCase()} · '
                        '${formatTripCurrency(state.preferences.budget, symbol: state.preferences.currency)} · '
                        '${state.preferences.adults} ${TripStrings.t('trip_pref_adults', locale).toLowerCase()}'
                        '${state.preferences.children > 0 ? ', ${state.preferences.children} ${TripStrings.t('trip_pref_children', locale).toLowerCase()}' : ''} · '
                        '${state.preferences.travelStyles.map((s) => s.label).take(2).join(', ')}',
                        style: AppTypography.bodySmall,
                      ),
                      Text(
                        TripStrings.t('trip_preferences_summary', locale),
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            TripStrings.t('trip_title', locale),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          GlassTextField(
            controller: _promptController,
            maxLines: 3,
            hint: TripStrings.t('trip_prompt_hint', locale),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: _examples.map((e) {
              return GlassTag(
                label: e,
                accentColor: AppColors.chipTrip,
                onTap: () => _promptController.text = e,
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          GlassPrimaryButton(
            label: TripStrings.t('trip_generate', locale),
            icon: Icons.auto_awesome,
            expand: true,
            onPressed: state.isGenerating ? null : _generate,
            accentColor: AppColors.chipTrip,
          ),
          const SizedBox(height: AppSpacing.sm),
          GlassPrimaryButton(
            label: TripStrings.t('travel_import_booking', locale),
            icon: Icons.upload_file_outlined,
            expand: true,
            onPressed: () => context.push('/trip-planner/import-booking'),
            accentColor: AppColors.cyanGlow,
          ),
          if (state.activeTrip != null) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(
              TripStrings.t('trip_itinerary', locale),
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(
              onTap: () => context.push(
                '/trip-planner/itinerary/${state.activeTrip!.id}',
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.activeTrip!.title,
                          style: AppTypography.title,
                        ),
                        Text(
                          '${state.activeTrip!.totalDays} days · '
                          '${formatTripCurrency(state.activeTrip!.budget.totalSpent, symbol: state.activeTrip!.preferences.currency)}',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavGrid extends ConsumerWidget {
  const _NavGrid({required this.locale, this.activeTripId});

  final String locale;
  final String? activeTripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purpose = ref.watch(tripPlannerProvider).preferences.visitorPurpose;

    final items = [
      ('travel_explore', Icons.explore_outlined, '/trip-planner/explore'),
      ('trip_map', Icons.map_outlined,
          activeTripId != null ? '/trip-planner/map/$activeTripId' : '/trip-planner/explore'),
      ('travel_know_before_you_go', Icons.lightbulb_outline,
          '/trip-planner/local-life'),
      ('travel_emergency', Icons.emergency_outlined,
          '/trip-planner/emergency'),
      ('travel_wallet', Icons.account_balance_wallet_outlined,
          '/trip-planner/wallet'),
      ('travel_fair_prices', Icons.price_check_outlined,
          '/trip-planner/fair-prices'),
      ('travel_bill_scan', Icons.receipt_long_outlined,
          '/trip-planner/bill-scan'),
      ('travel_import_booking', Icons.upload_file_outlined,
          '/trip-planner/import-booking'),
      ('trip_saved', Icons.bookmark_outline, '/trip-planner/saved'),
    ].where((e) => TripVisitorContentConfig.isNavKeyVisible(purpose, e.$1));

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: items
          .map(
            (e) => SizedBox(
              width: (MediaQuery.sizeOf(context).width -
                      AppSpacing.lg * 2 -
                      AppSpacing.sm) /
                  2,
              child: GlassCard(
                onTap: () => context.push(e.$3),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(e.$2, color: AppColors.chipTrip, size: 22),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      TripStrings.t(e.$1, locale),
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
