/// Trip planner enums — future-ready for multi-country expansion.
enum TripTravelStyle {
  solo,
  couple,
  family,
  friends,
  business,
  luxury,
  budget,
  adventure,
  foodLover,
  shopping,
  history,
  culture,
  photography,
  nature,
  sports,
}

enum TripTransportPreference {
  metro,
  taxi,
  uber,
  rentalCar,
  walking,
}

enum TripActivityPace {
  relaxed,
  balanced,
  busy,
}

enum TripActivityType {
  attraction,
  restaurant,
  prayer,
  transport,
  shopping,
  hotel,
  restBreak,
}

enum TripTimeSlot {
  morning,
  afternoon,
  evening,
  night,
}

/// Trip purpose — asked once at creation; drives deterministic content filtering.
enum TripVisitorPurpose {
  tourism,
  businessVisit,
  visitingFamilyFriends,
  familyWithChildren,
  relocatingForWork,
  preferNotToSay,
}

extension TripVisitorPurposeExt on TripVisitorPurpose {
  String get storageKey => name;

  String get labelKey => 'visitor_purpose_$name';

  bool get redirectsToProspective => this == TripVisitorPurpose.relocatingForWork;

  /// Selectable in preferences / trip creation (excludes redirect-only option handling).
  static const selectable = [
    TripVisitorPurpose.tourism,
    TripVisitorPurpose.businessVisit,
    TripVisitorPurpose.visitingFamilyFriends,
    TripVisitorPurpose.familyWithChildren,
    TripVisitorPurpose.relocatingForWork,
    TripVisitorPurpose.preferNotToSay,
  ];

  static TripVisitorPurpose? fromKey(String? key) {
    if (key == null || key.isEmpty) return null;
    for (final v in TripVisitorPurpose.values) {
      if (v.name == key) return v;
    }
    return null;
  }
}

extension TripTravelStyleExt on TripTravelStyle {
  String get storageKey => name;

  String get label {
    switch (this) {
      case TripTravelStyle.solo:
        return 'Solo';
      case TripTravelStyle.couple:
        return 'Couple';
      case TripTravelStyle.family:
        return 'Family';
      case TripTravelStyle.friends:
        return 'Friends';
      case TripTravelStyle.business:
        return 'Business';
      case TripTravelStyle.luxury:
        return 'Luxury';
      case TripTravelStyle.budget:
        return 'Budget';
      case TripTravelStyle.adventure:
        return 'Adventure';
      case TripTravelStyle.foodLover:
        return 'Food';
      case TripTravelStyle.shopping:
        return 'Shopping';
      case TripTravelStyle.history:
        return 'History';
      case TripTravelStyle.culture:
        return 'Culture';
      case TripTravelStyle.photography:
        return 'Photography';
      case TripTravelStyle.nature:
        return 'Nature';
      case TripTravelStyle.sports:
        return 'Sports';
    }
  }

  static TripTravelStyle fromKey(String? key) {
    return TripTravelStyle.values.firstWhere(
      (e) => e.name == key,
      orElse: () => TripTravelStyle.culture,
    );
  }
}

extension TripTransportPreferenceLabels on TripTransportPreference {
  String get label {
    switch (this) {
      case TripTransportPreference.metro:
        return 'Metro';
      case TripTransportPreference.taxi:
        return 'Taxi';
      case TripTransportPreference.uber:
        return 'Ride share';
      case TripTransportPreference.rentalCar:
        return 'Rental car';
      case TripTransportPreference.walking:
        return 'Walking';
    }
  }
}

extension TripActivityPaceLabels on TripActivityPace {
  String get label {
    switch (this) {
      case TripActivityPace.relaxed:
        return 'Relaxed';
      case TripActivityPace.balanced:
        return 'Balanced';
      case TripActivityPace.busy:
        return 'Busy';
    }
  }
}
