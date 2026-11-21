import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raabta/features/prayer_mosque/data/islamic_content_repository.dart';
import 'package:raabta/features/prayer_mosque/data/mosque_data_source.dart';
import 'package:raabta/features/prayer_mosque/data/prayer_repository.dart';
import 'package:raabta/features/prayer_mosque/domain/models/mosque.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_enums.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_record.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_settings.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_schedule.dart';
import 'package:raabta/features/prayer_mosque/domain/services/prayer_calculation_service.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_analytics_service.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_location_service.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_notification_service.dart';

final prayerRepositoryProvider = FutureProvider<PrayerRepository>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return PrayerRepository(prefs);
});

final prayerCalculationServiceProvider =
    Provider((ref) => const PrayerCalculationService());

final prayerLocationServiceProvider =
    Provider((ref) => PrayerLocationService());

final mosqueDataSourceProvider = Provider((ref) => MosqueDataSource());

final islamicContentProvider = Provider((ref) => IslamicContentRepository());

class PrayerState {
  const PrayerState({
    this.settings = const PrayerSettings(),
    this.schedule,
    this.location,
    this.completedToday = const {},
    this.favoriteIds = const [],
    this.isLoading = true,
    this.error,
    this.mosqueQuery = '',
    this.mosques = const [],
    this.isLiveLocationActive = false,
    this.locationUpdatedAt,
  });

  final PrayerSettings settings;
  final PrayerScheduleDay? schedule;
  final PrayerLocationResult? location;
  final Set<String> completedToday;
  final List<String> favoriteIds;
  final bool isLoading;
  final String? error;
  final String mosqueQuery;
  final List<MosquePlace> mosques;
  final bool isLiveLocationActive;
  final DateTime? locationUpdatedAt;

  PrayerState copyWith({
    PrayerSettings? settings,
    PrayerScheduleDay? schedule,
    PrayerLocationResult? location,
    Set<String>? completedToday,
    List<String>? favoriteIds,
    bool? isLoading,
    String? error,
    String? mosqueQuery,
    List<MosquePlace>? mosques,
    bool? isLiveLocationActive,
    DateTime? locationUpdatedAt,
  }) {
    return PrayerState(
      settings: settings ?? this.settings,
      schedule: schedule ?? this.schedule,
      location: location ?? this.location,
      completedToday: completedToday ?? this.completedToday,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      mosqueQuery: mosqueQuery ?? this.mosqueQuery,
      mosques: mosques ?? this.mosques,
      isLiveLocationActive:
          isLiveLocationActive ?? this.isLiveLocationActive,
      locationUpdatedAt: locationUpdatedAt ?? this.locationUpdatedAt,
    );
  }
}

class PrayerNotifier extends StateNotifier<PrayerState> {
  PrayerNotifier(this._ref) : super(const PrayerState()) {
    _init();
  }

  final Ref _ref;
  Timer? _tickTimer;
  String? _scheduleDateKey;
  StreamSubscription<Position>? _locationSub;
  static const _scheduleRefreshDistanceMeters = 500;

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

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
    await PrayerNotificationService.schedulePrayerReminders(
      schedule: schedule,
      settings: settings,
    );

    state = state.copyWith(schedule: schedule);
  }

  Future<List<MosquePlace>> _loadMosques({
    required double latitude,
    required double longitude,
    String query = '',
  }) {
    return _ref.read(mosqueDataSourceProvider).nearbyLive(
          latitude: latitude,
          longitude: longitude,
          query: query,
        );
  }

  Future<void> _applyLocationUpdate(
    PrayerLocationResult location, {
    required bool refreshSchedule,
    String? mosqueQuery,
  }) async {
    final query = mosqueQuery ?? state.mosqueQuery;
    final repo = await _ref.read(prayerRepositoryProvider.future);
    await repo.cacheLocation(location);

    final mosques = await _loadMosques(
      latitude: location.latitude,
      longitude: location.longitude,
      query: query,
    );

    if (refreshSchedule) {
      final settings = state.settings;
      final calc = _ref.read(prayerCalculationServiceProvider);
      final schedule = calc.scheduleFor(
        latitude: location.latitude,
        longitude: location.longitude,
        locationLabel: location.label,
        method: settings.calculationMethod,
        madhab: settings.madhab,
      );
      await repo.cacheSchedule(schedule);
      await PrayerNotificationService.schedulePrayerReminders(
        schedule: schedule,
        settings: settings,
      );
      state = state.copyWith(
        location: location,
        mosques: mosques,
        schedule: schedule,
        locationUpdatedAt: DateTime.now(),
        error: null,
      );
    } else {
      state = state.copyWith(
        location: location,
        mosques: mosques,
        locationUpdatedAt: DateTime.now(),
        error: null,
      );
    }
  }

  Future<void> _startLiveLocationTracking() async {
    await _locationSub?.cancel();
    _locationSub = null;

    if (!state.settings.autoLocation) {
      state = state.copyWith(isLiveLocationActive: false);
      return;
    }

    final locationService = _ref.read(prayerLocationServiceProvider);
    final permitted = await locationService.ensurePermission();
    if (!permitted) {
      state = state.copyWith(isLiveLocationActive: false);
      return;
    }

    state = state.copyWith(isLiveLocationActive: true);
    _locationSub = locationService.watchPosition().listen(
      _onLivePosition,
      onError: (_) {
        state = state.copyWith(isLiveLocationActive: false);
      },
    );
  }

  Future<void> _onLivePosition(Position position) async {
    if (!state.settings.autoLocation) return;

    final locationService = _ref.read(prayerLocationServiceProvider);
    final location = locationService.locationFromPosition(position);
    final previous = state.location;

    var refreshSchedule = previous == null;
    if (previous != null) {
      final moved = Geolocator.distanceBetween(
        previous.latitude,
        previous.longitude,
        location.latitude,
        location.longitude,
      );
      if (moved < 20) return;
      refreshSchedule = moved >= _scheduleRefreshDistanceMeters;
    }

    await _applyLocationUpdate(
      location,
      refreshSchedule: refreshSchedule,
    );
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

  Future<void> _init() async {
    try {
      final repo = await _ref.read(prayerRepositoryProvider.future);
      final settings = repo.loadSettings();
      final completed = repo.loadCompletedToday();
      final favorites = repo.loadFavoriteIds();

      var location = settings.autoLocation
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
      var schedule = calc.scheduleFor(
        latitude: location.latitude,
        longitude: location.longitude,
        locationLabel: location.label,
        method: settings.calculationMethod,
        madhab: settings.madhab,
      );

      await repo.cacheSchedule(schedule);
      await repo.cacheLocation(location);
      await PrayerNotificationService.schedulePrayerReminders(
        schedule: schedule,
        settings: settings,
      );

      final mosques = await _loadMosques(
        latitude: location.latitude,
        longitude: location.longitude,
      );

      state = state.copyWith(
        settings: settings,
        schedule: schedule,
        location: location,
        completedToday: completed,
        favoriteIds: favorites,
        mosques: mosques,
        isLoading: false,
        locationUpdatedAt: DateTime.now(),
      );

      _tickTimer?.cancel();
      _scheduleDateKey = _dateKey(DateTime.now());
      _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
      await _startLiveLocationTracking();
    } catch (e) {
      final repo = await _ref.read(prayerRepositoryProvider.future);
      state = state.copyWith(
        schedule: repo.loadCachedSchedule(),
        location: repo.loadCachedLocation(),
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshLocation() async {
    state = state.copyWith(isLoading: true);
    if (state.settings.autoLocation) {
      final locationService = _ref.read(prayerLocationServiceProvider);
      final location = await locationService.resolve(
        autoLocation: true,
        manualCity: state.settings.manualCity,
        manualLatitude: state.settings.manualLatitude,
        manualLongitude: state.settings.manualLongitude,
      );
      await _applyLocationUpdate(location, refreshSchedule: true);
      state = state.copyWith(isLoading: false);
      await _startLiveLocationTracking();
      return;
    }
    await _init();
  }

  Future<void> updateSettings(PrayerSettings settings) async {
    final repo = await _ref.read(prayerRepositoryProvider.future);
    await repo.saveSettings(settings);
    state = state.copyWith(settings: settings);
    await _init();
  }

  /// Keeps prayer UI in sync with the global app language toggle.
  void syncAppLocale(String normalizedLocale) {
    if (state.settings.locale == normalizedLocale) return;
    final updated = state.settings.copyWith(locale: normalizedLocale);
    state = state.copyWith(settings: updated);
    _ref.read(prayerRepositoryProvider.future).then((repo) {
      repo.saveSettings(updated);
    });
  }

  Future<void> toggleCompleted(String prayerKey) async {
    final repo = await _ref.read(prayerRepositoryProvider.future);
    await repo.toggleCompleted(prayerKey);
    state = state.copyWith(
      completedToday: repo.loadCompletedToday(),
    );
    final today = _todayKey();
    await repo.saveRecord(
      PrayerRecord(
        dateKey: today,
        prayerKey: prayerKey,
        status: state.completedToday.contains(prayerKey)
            ? PrayerTrackingStatus.prayed
            : PrayerTrackingStatus.missed,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> toggleFavorite(String mosqueId) async {
    final repo = await _ref.read(prayerRepositoryProvider.future);
    await repo.toggleFavorite(mosqueId);
    state = state.copyWith(favoriteIds: repo.loadFavoriteIds());
  }

  Future<void> searchMosques(String query) async {
    final loc = state.location;
    if (loc == null) return;
    PrayerAnalyticsService.mosqueSearch(query);
    final results = await _loadMosques(
      latitude: loc.latitude,
      longitude: loc.longitude,
      query: query,
    );
    state = state.copyWith(mosqueQuery: query, mosques: results);
  }

  String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _locationSub?.cancel();
    super.dispose();
  }
}

final prayerProvider =
    StateNotifierProvider<PrayerNotifier, PrayerState>((ref) {
  return PrayerNotifier(ref);
});

final prayerStatsProvider = FutureProvider<PrayerStats>((ref) async {
  final repo = await ref.watch(prayerRepositoryProvider.future);
  return repo.computeStats();
});

final prayerDailyContentProvider = Provider<IslamicDailyContent>((ref) {
  return ref.watch(islamicContentProvider).forDay();
});

final prayerCalendarEventsProvider =
    Provider<List<IslamicCalendarEvent>>((ref) {
  return ref.watch(islamicContentProvider).upcomingEvents();
});

final favoriteMosquesProvider = Provider<List<MosquePlace>>((ref) {
  final state = ref.watch(prayerProvider);
  final source = ref.watch(mosqueDataSourceProvider);
  return state.favoriteIds
      .map(source.byId)
      .whereType<MosquePlace>()
      .toList();
});

class PrayerLiveClockNotifier extends StateNotifier<DateTime> {
  PrayerLiveClockNotifier() : super(DateTime.now()) {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = DateTime.now();
    });
  }

  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final prayerLiveClockProvider =
    StateNotifierProvider<PrayerLiveClockNotifier, DateTime>((ref) {
  return PrayerLiveClockNotifier();
});
