import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_progress_indicator.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_enums.dart';
import 'package:raabta/features/trip_planner/presentation/widgets/trip_visitor_purpose_selector.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_preferences.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';
import 'package:raabta/features/trip_planner/providers/trip_planner_providers.dart';

class TripPreferencesScreen extends ConsumerStatefulWidget {
  const TripPreferencesScreen({super.key});

  @override
  ConsumerState<TripPreferencesScreen> createState() =>
      _TripPreferencesScreenState();
}

class _TripPreferencesScreenState extends ConsumerState<TripPreferencesScreen> {
  TripPreferences? _draft;
  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  Future<void> _hydrate() async {
    await ref.read(tripPlannerProvider.notifier).refreshPreferencesFromStorage();
    if (!mounted) return;
    setState(() {
      _draft = _normalize(ref.read(tripPlannerProvider).preferences);
      _isLoading = false;
    });
  }

  TripPreferences _normalize(TripPreferences prefs) {
    return prefs.copyWith(
      destination: TripPreferenceOptions.destinations.contains(prefs.destination)
          ? prefs.destination
          : TripPreferenceOptions.destinations.first,
      hotelArea: TripPreferenceOptions.hotelAreas.contains(prefs.hotelArea)
          ? prefs.hotelArea
          : TripPreferenceOptions.hotelAreas.first,
      currency: TripPreferenceOptions.currencies.contains(prefs.currency)
          ? prefs.currency
          : TripPreferenceOptions.currencies.first,
      locale: TripPreferenceOptions.locales.contains(prefs.locale)
          ? prefs.locale
          : TripPreferenceOptions.locales.first,
    );
  }

  void _updateDraft(TripPreferences Function(TripPreferences current) patch) {
    final current = _draft;
    if (current == null) return;
    setState(() => _draft = patch(current));
  }

  void _toggleStyle(TripTravelStyle style) {
    _updateDraft((current) {
      final styles = List<TripTravelStyle>.from(current.travelStyles);
      if (styles.contains(style)) {
        if (styles.length > 1) styles.remove(style);
      } else {
        styles.add(style);
      }
      return current.copyWith(travelStyles: styles);
    });
  }

  Future<void> _save() async {
    final draft = _draft;
    if (draft == null || _isSaving) return;

    setState(() => _isSaving = true);
    final saved =
        await ref.read(tripPlannerProvider.notifier).persistPreferences(draft);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            TripStrings.t('trip_preferences_save_failed', draft.locale),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(TripStrings.t('trip_preferences_saved', draft.locale)),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final locale = _draft?.locale ??
        ref.watch(tripPlannerProvider).preferences.locale;

    if (_isLoading || _draft == null) {
      return GlassScreenScaffold(
        title: TripStrings.t('trip_preferences', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        body: const Center(child: GlassProgressIndicator()),
      );
    }

    final prefs = _draft!;

    return GlassScreenScaffold(
      title: TripStrings.t('trip_preferences', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              children: [
                _SectionTitle(TripStrings.t('trip_pref_trip_details', locale)),
                const SizedBox(height: AppSpacing.sm),
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TripVisitorPurposeSelector(
                        locale: locale,
                        selected: prefs.visitorPurpose,
                        onSelected: (purpose) {
                          _updateDraft((c) {
                            var next = c.copyWith(visitorPurpose: purpose);
                            if (purpose ==
                                TripVisitorPurpose.familyWithChildren) {
                              next = next.copyWith(kidsFriendly: true);
                            }
                            return next;
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _PickerTile<String>(
                        label: TripStrings.t('trip_pref_destination', locale),
                        value: prefs.destination,
                        options: TripPreferenceOptions.destinations,
                        onChanged: (v) =>
                            _updateDraft((c) => c.copyWith(destination: v)),
                      ),
                      _SliderTile(
                        label: TripStrings.t('trip_days', locale),
                        value: prefs.days.toDouble(),
                        displayValue: '${prefs.days}',
                        min: 1,
                        max: 14,
                        divisions: 13,
                        onChanged: (v) =>
                            _updateDraft((c) => c.copyWith(days: v.round())),
                      ),
                      _SliderTile(
                        label: TripStrings.t('trip_budget_label', locale),
                        value: prefs.budget,
                        displayValue: formatTripCurrency(
                          prefs.budget,
                          symbol: prefs.currency,
                        ),
                        min: 500,
                        max: 20000,
                        divisions: 39,
                        onChanged: (v) =>
                            _updateDraft((c) => c.copyWith(budget: v)),
                      ),
                      _PickerTile<String>(
                        label: TripStrings.t('trip_pref_currency', locale),
                        value: prefs.currency,
                        options: TripPreferenceOptions.currencies,
                        onChanged: (v) =>
                            _updateDraft((c) => c.copyWith(currency: v)),
                      ),
                      _PickerTile<String>(
                        label: TripStrings.t('trip_pref_language', locale),
                        value: prefs.locale,
                        options: TripPreferenceOptions.locales,
                        onChanged: (v) =>
                            _updateDraft((c) => c.copyWith(locale: v)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionTitle(TripStrings.t('trip_pref_travelers', locale)),
                const SizedBox(height: AppSpacing.sm),
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PickerTile<int>(
                        label: TripStrings.t('trip_pref_adults', locale),
                        value: prefs.adults,
                        options: const [1, 2, 3, 4, 5, 6],
                        labelBuilder: (v) => '$v',
                        onChanged: (v) =>
                            _updateDraft((c) => c.copyWith(adults: v)),
                      ),
                      _PickerTile<int>(
                        label: TripStrings.t('trip_pref_children', locale),
                        value: prefs.children,
                        options: const [0, 1, 2, 3, 4],
                        labelBuilder: (v) => '$v',
                        onChanged: (v) =>
                            _updateDraft((c) => c.copyWith(children: v)),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        TripStrings.t('trip_pref_styles', locale),
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children:
                            TripPreferenceOptions.styleOptions.map((style) {
                          final selected = prefs.travelStyles.contains(style);
                          return FilterChip(
                            label: Text(style.label),
                            selected: selected,
                            onSelected: (_) => _toggleStyle(style),
                            selectedColor:
                                AppColors.chipTrip.withValues(alpha: 0.2),
                            checkmarkColor: AppColors.chipTrip,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _PickerTile<TripActivityPace>(
                        label: TripStrings.t('trip_pref_pace', locale),
                        value: prefs.pace,
                        options: TripActivityPace.values,
                        labelBuilder: (v) => v.label,
                        onChanged: (v) =>
                            _updateDraft((c) => c.copyWith(pace: v)),
                      ),
                      _SwitchTile(
                        label: TripStrings.t('trip_pref_kids', locale),
                        value: prefs.kidsFriendly,
                        onChanged: (v) =>
                            _updateDraft((c) => c.copyWith(kidsFriendly: v)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionTitle(
                  TripStrings.t('trip_pref_food_transport', locale),
                ),
                const SizedBox(height: AppSpacing.sm),
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PickerTile<TripTransportPreference>(
                        label: TripStrings.t('trip_pref_transport', locale),
                        value: prefs.transport,
                        options: TripTransportPreference.values,
                        labelBuilder: (v) => v.label,
                        onChanged: (v) =>
                            _updateDraft((c) => c.copyWith(transport: v)),
                      ),
                      _PickerTile<String>(
                        label: TripStrings.t('trip_pref_hotel_area', locale),
                        value: prefs.hotelArea,
                        options: TripPreferenceOptions.hotelAreas,
                        onChanged: (v) =>
                            _updateDraft((c) => c.copyWith(hotelArea: v)),
                      ),
                      _SliderTile(
                        label: TripStrings.t(
                          'trip_pref_restaurant_budget',
                          locale,
                        ),
                        value: prefs.restaurantBudget,
                        displayValue: formatTripCurrency(
                          prefs.restaurantBudget,
                          symbol: prefs.currency,
                        ),
                        min: 50,
                        max: 500,
                        divisions: 18,
                        onChanged: (v) => _updateDraft(
                          (c) => c.copyWith(restaurantBudget: v),
                        ),
                      ),
                      _SwitchTile(
                        label: TripStrings.t('trip_pref_prayer', locale),
                        value: prefs.prayerReminders,
                        onChanged: (v) => _updateDraft(
                          (c) => c.copyWith(prayerReminders: v),
                        ),
                      ),
                      _SwitchTile(
                        label: TripStrings.t('trip_halal', locale),
                        value: prefs.halal,
                        onChanged: (v) =>
                            _updateDraft((c) => c.copyWith(halal: v)),
                      ),
                      _SwitchTile(
                        label: TripStrings.t('trip_pref_vegetarian', locale),
                        value: prefs.vegetarian,
                        onChanged: (v) =>
                            _updateDraft((c) => c.copyWith(vegetarian: v)),
                      ),
                      _SwitchTile(
                        label: TripStrings.t('trip_pref_free_only', locale),
                        value: prefs.freeOnly,
                        onChanged: (v) =>
                            _updateDraft((c) => c.copyWith(freeOnly: v)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionTitle(TripStrings.t('trip_pref_accessibility', locale)),
                const SizedBox(height: AppSpacing.sm),
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SwitchTile(
                        label: TripStrings.t('trip_pref_wheelchair', locale),
                        value: prefs.wheelchairAccessible,
                        onChanged: (v) => _updateDraft(
                          (c) => c.copyWith(wheelchairAccessible: v),
                        ),
                      ),
                      _SwitchTile(
                        label: TripStrings.t('trip_pref_senior', locale),
                        value: prefs.seniorFriendly,
                        onChanged: (v) => _updateDraft(
                          (c) => c.copyWith(seniorFriendly: v),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GlassPrimaryButton(
            label: _isSaving
                ? TripStrings.t('trip_preferences_saving', locale)
                : TripStrings.t('trip_save_preferences', locale),
            icon: Icons.save_outlined,
            expand: true,
            onPressed: _isSaving ? null : _save,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTypography.title);
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.label,
    required this.value,
    required this.displayValue,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final double value;
  final String displayValue;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: $displayValue', style: AppTypography.bodySmall),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _PickerTile<T> extends StatelessWidget {
  const _PickerTile({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.labelBuilder,
  });

  final String label;
  final T value;
  final List<T> options;
  final ValueChanged<T> onChanged;
  final String Function(T value)? labelBuilder;

  @override
  Widget build(BuildContext context) {
    final safeValue = options.contains(value) ? value : options.first;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTypography.bodySmall),
          ),
          DropdownButton<T>(
            value: safeValue,
            underline: const SizedBox.shrink(),
            items: options
                .map(
                  (option) => DropdownMenuItem(
                    value: option,
                    child: Text(labelBuilder?.call(option) ?? option.toString()),
                  ),
                )
                .toList(),
            onChanged: (selected) {
              if (selected != null) onChanged(selected);
            },
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTypography.bodySmall),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
