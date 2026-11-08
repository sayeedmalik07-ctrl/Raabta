import 'package:raabta/features/trip_planner/domain/models/local_life_models.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_enums.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_preferences.dart';

/// Static visitor-type + duration config for Trip Planner content filtering.
abstract final class TripVisitorContentConfig {
  TripVisitorContentConfig._();

  /// Nav grid string keys (`travel_*`) hidden for specific purposes (still reachable elsewhere).
  static const hiddenNavKeysByPurpose = <TripVisitorPurpose, Set<String>>{
    TripVisitorPurpose.businessVisit: {'travel_bill_scan'},
  };

  /// Local Life categories fully deprioritized unless purpose matches override.
  static const deprioritizedCategoriesByPurpose =
      <TripVisitorPurpose, Set<LocalLifeCategory>>{
    TripVisitorPurpose.tourism: {LocalLifeCategory.relationships},
    TripVisitorPurpose.businessVisit: {
      LocalLifeCategory.relationships,
      LocalLifeCategory.familyPets,
    },
    TripVisitorPurpose.familyWithChildren: {LocalLifeCategory.relationships},
  };

  /// Categories boosted to primary even when category-level deprioritization applies.
  static const categoryPurposeOverrides =
      <LocalLifeCategory, Set<TripVisitorPurpose>>{};

  static LocalLifeAudience audienceFor(TripVisitorPurpose? purpose) {
    if (purpose == null || purpose == TripVisitorPurpose.preferNotToSay) {
      return LocalLifeAudience.all;
    }
    return switch (purpose) {
      TripVisitorPurpose.tourism ||
      TripVisitorPurpose.visitingFamilyFriends ||
      TripVisitorPurpose.familyWithChildren =>
        LocalLifeAudience.tourist,
      TripVisitorPurpose.businessVisit => LocalLifeAudience.businessVisitor,
      TripVisitorPurpose.relocatingForWork ||
      TripVisitorPurpose.preferNotToSay =>
        LocalLifeAudience.all,
    };
  }

  static LocalLifeDurationBand durationBandFor(TripPreferences prefs) {
    if (purposeShowsAll(prefs.visitorPurpose)) {
      return LocalLifeDurationBand.all;
    }
    final days = effectiveTripDays(prefs);
    if (days <= 3) return LocalLifeDurationBand.shortStay;
    return LocalLifeDurationBand.extendedVisit;
  }

  static int effectiveTripDays(TripPreferences prefs) {
    if (prefs.tripStartDate != null && prefs.tripEndDate != null) {
      return tripDaysFromDates(
        start: prefs.tripStartDate,
        end: prefs.tripEndDate,
        fallback: prefs.days,
      );
    }
    return prefs.days;
  }

  static bool purposeShowsAll(TripVisitorPurpose? purpose) =>
      purpose == null || purpose == TripVisitorPurpose.preferNotToSay;

  static bool isNavKeyVisible(TripVisitorPurpose? purpose, String navKey) {
    if (purposeShowsAll(purpose)) return true;
    final hidden = hiddenNavKeysByPurpose[purpose];
    return hidden == null || !hidden.contains(navKey);
  }

  static bool isCategoryDeprioritized(
    TripVisitorPurpose? purpose,
    LocalLifeCategory category,
  ) {
    if (purposeShowsAll(purpose)) return false;
    final overrides = categoryPurposeOverrides[category];
    if (overrides != null && overrides.contains(purpose)) return false;
    final set = deprioritizedCategoriesByPurpose[purpose];
    return set != null && set.contains(category);
  }
}
