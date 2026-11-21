import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/home/domain/home_doha_day_part.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_schedule.dart';
import 'package:raabta/features/prayer_mosque/providers/prayer_schedule_providers.dart';

/// Debug-only forced day part (Batch C UI can expose a hidden control).
@visibleForTesting
DohaDayPart? homeDohaDayPartDebugOverride;

/// Resolved state for the Home Doha scene.
@immutable
class HomeDohaDayPartState {
  const HomeDohaDayPartState({
    required this.part,
    required this.source,
    required this.resolvedAt,
  });

  final DohaDayPart part;
  final DohaDayPartSource source;
  final DateTime resolvedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeDohaDayPartState &&
          part == other.part &&
          source == other.source;

  @override
  int get hashCode => Object.hash(part, source);
}

/// Maps prayer strip schedule → anchor times (no network).
HomeDohaPrayerAnchorTimes? homeDohaPrayerAnchorsFromSchedule(
  PrayerScheduleDay? schedule,
) {
  if (schedule == null) return null;
  return HomeDohaPrayerAnchorTimes(
    fajr: schedule.entryFor('fajr')?.time,
    sunrise: schedule.entryFor('sunrise')?.time,
    asr: schedule.entryFor('asr')?.time,
    maghrib: schedule.entryFor('maghrib')?.time,
  );
}

class HomeDohaDayPartNotifier extends Notifier<HomeDohaDayPartState>
    with WidgetsBindingObserver {
  Timer? _boundaryTimer;
  DateTime Function() _now = DateTime.now;
  HomeDohaPrayerAnchorTimes? _anchorsOverride;
  bool _disposed = false;

  @override
  HomeDohaDayPartState build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _dispose();
    });

    ref.listen(prayerScheduleStripProvider, (previous, next) {
      _publishAndReschedule();
    });

    _publishAndReschedule();
    return _resolveState();
  }

  @visibleForTesting
  void debugSetNow(DateTime Function() now) {
    _now = now;
    _publishAndReschedule();
  }

  @visibleForTesting
  void debugSetPrayerAnchors(HomeDohaPrayerAnchorTimes? anchors) {
    _anchorsOverride = anchors;
    _publishAndReschedule();
  }

  @visibleForTesting
  void debugForceDayPart(DohaDayPart? part) {
    assert(() {
      homeDohaDayPartDebugOverride = part;
      return true;
    }());
    _publishAndReschedule();
  }

  void _dispose() {
    _disposed = true;
    _boundaryTimer?.cancel();
    _boundaryTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _publishAndReschedule();
    }
  }

  HomeDohaDayPartState _resolveState() {
    final now = _now();
    final override = kDebugMode ? homeDohaDayPartDebugOverride : null;
    if (override != null) {
      return HomeDohaDayPartState(
        part: override,
        source: DohaDayPartSource.debugOverride,
        resolvedAt: now,
      );
    }

    final anchors = _anchorsOverride ??
        homeDohaPrayerAnchorsFromSchedule(
          ref.read(prayerScheduleStripProvider).schedule,
        );
    final part = resolveDohaDayPart(now: now, prayerTimes: anchors);
    final source = anchors != null && anchors.isComplete
        ? DohaDayPartSource.prayerTimes
        : DohaDayPartSource.clockFallback;
    return HomeDohaDayPartState(
      part: part,
      source: source,
      resolvedAt: now,
    );
  }

  void _publishAndReschedule() {
    final next = _resolveState();
    state = next;
    _scheduleNextBoundary();
  }

  void _scheduleNextBoundary() {
    _boundaryTimer?.cancel();
    if (_disposed) return;
    if (kDebugMode && homeDohaDayPartDebugOverride != null) {
      return;
    }
    final now = _now();
    final anchors = _anchorsOverride ??
        homeDohaPrayerAnchorsFromSchedule(
          ref.read(prayerScheduleStripProvider).schedule,
        );
    final delay = dohaDayPartDelayUntilNextBoundary(
      now: now,
      prayerTimes: anchors,
    );
    _boundaryTimer = Timer(delay, () {
      if (_disposed) return;
      _publishAndReschedule();
    });
  }
}

final homeDohaDayPartProvider =
    NotifierProvider<HomeDohaDayPartNotifier, HomeDohaDayPartState>(
  HomeDohaDayPartNotifier.new,
);