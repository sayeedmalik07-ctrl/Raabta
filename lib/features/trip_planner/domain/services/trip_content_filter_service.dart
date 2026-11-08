import 'package:raabta/features/trip_planner/data/trip_visitor_content_config.dart';
import 'package:raabta/features/trip_planner/domain/models/local_life_models.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_enums.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_preferences.dart';

/// Partitioned Local Life content for a trip's visitor context — no AI.
class TripLocalLifeFilterResult {
  const TripLocalLifeFilterResult({
    required this.primary,
    required this.deprioritized,
    required this.audience,
    required this.durationBand,
    required this.purpose,
  });

  final List<LocalLifeEntry> primary;
  final List<LocalLifeEntry> deprioritized;
  final LocalLifeAudience audience;
  final LocalLifeDurationBand durationBand;
  final TripVisitorPurpose? purpose;

  bool get hasDeprioritized => deprioritized.isNotEmpty;
  bool get filteringActive =>
      !TripVisitorContentConfig.purposeShowsAll(purpose);
}

class TripContentFilterService {
  const TripContentFilterService();

  TripLocalLifeFilterResult filterLocalLifeEntries(
    List<LocalLifeEntry> entries,
    TripPreferences prefs,
  ) {
    final purpose = prefs.visitorPurpose;
    final audience = TripVisitorContentConfig.audienceFor(purpose);
    final band = TripVisitorContentConfig.durationBandFor(prefs);

    if (!TripVisitorContentConfig.purposeShowsAll(purpose)) {
      final primary = <LocalLifeEntry>[];
      final deprioritized = <LocalLifeEntry>[];

      for (final entry in entries) {
        if (_entryMatches(entry, audience, band, purpose, entry.category)) {
          primary.add(entry);
        } else {
          deprioritized.add(entry);
        }
      }

      _sortByPriority(primary);
      _sortByPriority(deprioritized);

      return TripLocalLifeFilterResult(
        primary: primary,
        deprioritized: deprioritized,
        audience: audience,
        durationBand: band,
        purpose: purpose,
      );
    }

    final all = List<LocalLifeEntry>.from(entries);
    _sortByPriority(all);
    return TripLocalLifeFilterResult(
      primary: all,
      deprioritized: const [],
      audience: audience,
      durationBand: band,
      purpose: purpose,
    );
  }

  bool _entryMatches(
    LocalLifeEntry entry,
    LocalLifeAudience audience,
    LocalLifeDurationBand band,
    TripVisitorPurpose? purpose,
    LocalLifeCategory category,
  ) {
    if (TripVisitorContentConfig.isCategoryDeprioritized(purpose, category)) {
      return false;
    }

    final audienceMatch = entry.audience.contains(LocalLifeAudience.all) ||
        entry.audience.contains(audience);
    final bandMatch = entry.durationBand == LocalLifeDurationBand.all ||
        entry.durationBand == band ||
        band == LocalLifeDurationBand.all;

    return audienceMatch && bandMatch;
  }

  void _sortByPriority(List<LocalLifeEntry> entries) {
    entries.sort((a, b) {
      final p = a.priority.index.compareTo(b.priority.index);
      if (p != 0) return p;
      return a.titleKey.compareTo(b.titleKey);
    });
  }
}
