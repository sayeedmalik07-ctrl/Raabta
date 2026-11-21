/// Local-only Departure Plan state — not synced to Firestore or profile.
library;

/// Whether a plan step follows Raabta planning guidance or an official source.
enum DeparturePlanTimingBasis {
  suggested,
  official,
}

/// Verified navigation for a plan row — no unverified deep-link query params.
enum DeparturePlanNavigationTarget {
  /// [routePath] via GoRouter.
  externalRoute,

  /// Opens [officialSourceUrl] in the system browser.
  officialPortal,

  /// Scrolls to the existing timeline section on `/leaving-qatar`.
  inScreenTimeline,

  /// Scrolls to the existing close-out expansion on `/leaving-qatar`.
  inScreenCloseout,
}

/// Static definition for one departure-plan row (content lives on linked surfaces).
class DeparturePlanItemDefinition {
  const DeparturePlanItemDefinition({
    required this.id,
    required this.navigationTarget,
    required this.timingBasis,
    this.routePath,
    this.officialSourceUrl,
  });

  final String id;
  final DeparturePlanNavigationTarget navigationTarget;
  final DeparturePlanTimingBasis timingBasis;

  /// GoRouter path when [navigationTarget] is [DeparturePlanNavigationTarget.externalRoute].
  final String? routePath;

  /// MOI / portal URL for [DeparturePlanNavigationTarget.officialPortal].
  final String? officialSourceUrl;
}

/// Device-local departure plan snapshot (optional date + per-item ticks).
class LeavingQatarDeparturePlanState {
  const LeavingQatarDeparturePlanState({
    this.plannedDepartureDate,
    this.completedByItemId = const {},
  });

  /// Calendar date only, `YYYY-MM-DD`, or null when unknown / not set.
  final String? plannedDepartureDate;

  /// Completion keyed by [DeparturePlanItemDefinition.id] or legacy unknown ids.
  final Map<String, bool> completedByItemId;

  LeavingQatarDeparturePlanState copyWith({
    String? plannedDepartureDate,
    bool clearPlannedDepartureDate = false,
    Map<String, bool>? completedByItemId,
  }) {
    return LeavingQatarDeparturePlanState(
      plannedDepartureDate: clearPlannedDepartureDate
          ? null
          : (plannedDepartureDate ?? this.plannedDepartureDate),
      completedByItemId: completedByItemId ?? this.completedByItemId,
    );
  }

  bool isCompleted(String itemId) => completedByItemId[itemId] == true;

  /// Completion count for [catalogItemIds] only — ignores unknown stored keys.
  int completedCountAmong(Iterable<String> catalogItemIds) {
    var done = 0;
    for (final id in catalogItemIds) {
      if (isCompleted(id)) done++;
    }
    return done;
  }

  @override
  bool operator ==(Object other) {
    return other is LeavingQatarDeparturePlanState &&
        other.plannedDepartureDate == plannedDepartureDate &&
        _mapEquals(other.completedByItemId, completedByItemId);
  }

  @override
  int get hashCode =>
      Object.hash(plannedDepartureDate, Object.hashAll(completedByItemId.entries));

  static bool _mapEquals(Map<String, bool> a, Map<String, bool> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }
}

/// Date-only helpers — always `YYYY-MM-DD`, no time zone offset in storage.
abstract final class LeavingQatarDeparturePlanDate {
  static final _pattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  static bool isValidIsoDate(String? value) {
    if (value == null || value.isEmpty) return false;
    if (!_pattern.hasMatch(value)) return false;
    final parts = value.split('-');
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return false;
    if (month < 1 || month > 12 || day < 1 || day > 31) return false;
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return false;
    return parsed.year == year && parsed.month == month && parsed.day == day;
  }

  static String formatDateOnly(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
