import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_settings.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_schedule.dart';
import 'package:raabta/features/prayer_mosque/providers/prayer_providers.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_location_service.dart';

/// Lightweight prayer schedule state for Home strip — no mosques/favorites/history.
class PrayerScheduleStripState {
  const PrayerScheduleStripState({
    this.settings = const PrayerSettings(),
    this.schedule,
    this.location,
    this.isLoading = true,
    this.error,
  });

  final PrayerSettings settings;
  final PrayerScheduleDay? schedule;
  final PrayerLocationResult? location;
  final bool isLoading;
  final String? error;

  PrayerScheduleStripState copyWith({
    PrayerSettings? settings,
    PrayerScheduleDay? schedule,
    PrayerLocationResult? location,
    bool? isLoading,
    String? error,
  }) {
    return PrayerScheduleStripState(
      settings: settings ?? this.settings,
      schedule: schedule ?? this.schedule,
      location: location ?? this.location,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PrayerScheduleStripNotifier extends StateNotifier<PrayerScheduleStripState> {
  PrayerScheduleStripNotifier(this._ref)
      : super(const PrayerScheduleStripState()) {
    _init();
  }

  final Ref _ref;
  Timer? _tickTimer;
  String? _scheduleDateKey;

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _init() async {
    try {
      final repo = await _ref.read(prayerRepositoryProvider.future);
      final settings = repo.loadSettings();

      final location = settings.autoLocation
          ? await _ref.read(prayerLocationServiceProvider).resolve(
                autoLocation: true,
                manualCity: settings.manualCity,
                manualLatitude: settings.manualLatitude,
                manualLongitude: settings.manualLongitude,
              )
          : repo.loadCachedLocation() ??
              PrayerLocationResult(
                latitude: settings.manualLatitude,
                longitude: settings.manualLongitude,
                label: settings.manualCity,
                source: PrayerLocationSource.manual,
              );

      final calc = _ref.read(prayerCalculationServiceProvider);
      final schedule = calc.scheduleFor(
        latitude: location.latitude,
        longitude: location.longitude,
        locationLabel: location.label,
        method: settings.calculationMethod,
        madhab: settings.madhab,
      );

      await repo.cacheSchedule(schedule);
      await repo.cacheLocation(location);

      state = PrayerScheduleStripState(
        settings: settings,
        schedule: schedule,
        location: location,
        isLoading: false,
      );

      _scheduleDateKey = _dateKey(DateTime.now());
      _tickTimer?.cancel();
      _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
    } catch (e) {
      final repo = await _ref.read(prayerRepositoryProvider.future);
      state = PrayerScheduleStripState(
        schedule: repo.loadCachedSchedule(),
        location: repo.loadCachedLocation(),
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _refreshScheduleForToday() async {
    final settings = state.settings;
    final location = state.location;
    if (location == null) return;

    final calc = _ref.read(prayerCalculationServiceProvider);
    final schedule = calc.scheduleFor(
      latitude: location.latitude,
      longitude: location.longitude,
      locationLabel: location.label,
      method: settings.calculationMethod,
      madhab: settings.madhab,
    );

    final repo = await _ref.read(prayerRepositoryProvider.future);
    await repo.cacheSchedule(schedule);
    state = state.copyWith(schedule: schedule);
  }

  void _onTick() {
    final today = _dateKey(DateTime.now());
    if (_scheduleDateKey != null && _scheduleDateKey != today) {
      _scheduleDateKey = today;
      _refreshScheduleForToday();
    } else {
      _scheduleDateKey ??= today;
    }
  }

  void syncAppLocale(String normalizedLocale) {
    if (state.settings.locale == normalizedLocale) return;
    final updated = state.settings.copyWith(locale: normalizedLocale);
    state = state.copyWith(settings: updated);
    _ref.read(prayerRepositoryProvider.future).then((repo) {
      repo.saveSettings(updated);
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }
}

final prayerScheduleStripProvider =
    StateNotifierProvider<PrayerScheduleStripNotifier, PrayerScheduleStripState>(
  PrayerScheduleStripNotifier.new,
);
