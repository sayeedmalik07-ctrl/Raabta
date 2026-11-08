import 'package:raabta/features/trip_planner/domain/models/trip_enums.dart';

class TripPreferences {
  const TripPreferences({
    this.destination = 'Doha',
    this.countryCode = 'QA',
    this.days = 3,
    this.budget = 2000,
    this.currency = 'QAR',
    this.adults = 2,
    this.children = 0,
    this.travelStyles = const [TripTravelStyle.culture],
    this.transport = TripTransportPreference.metro,
    this.pace = TripActivityPace.balanced,
    this.locale = 'English',
    this.hotelArea = 'West Bay',
    this.prayerReminders = true,
    this.vegetarian = false,
    this.halal = true,
    this.restaurantBudget = 150,
    this.wheelchairAccessible = false,
    this.seniorFriendly = false,
    this.kidsFriendly = false,
    this.freeOnly = false,
    this.naturalLanguagePrompt = '',
    this.tripStartDate,
    this.tripEndDate,
    this.visitorPurpose,
  });

  final String destination;
  final String countryCode;
  final int days;
  final double budget;
  final String currency;
  final int adults;
  final int children;
  final List<TripTravelStyle> travelStyles;
  final TripTransportPreference transport;
  final TripActivityPace pace;
  final String locale;
  final String hotelArea;
  final bool prayerReminders;
  final bool vegetarian;
  final bool halal;
  final double restaurantBudget;
  final bool wheelchairAccessible;
  final bool seniorFriendly;
  final bool kidsFriendly;
  final bool freeOnly;
  final String naturalLanguagePrompt;
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;
  final TripVisitorPurpose? visitorPurpose;

  TripPreferences copyWith({
    String? destination,
    String? countryCode,
    int? days,
    double? budget,
    String? currency,
    int? adults,
    int? children,
    List<TripTravelStyle>? travelStyles,
    TripTransportPreference? transport,
    TripActivityPace? pace,
    String? locale,
    String? hotelArea,
    bool? prayerReminders,
    bool? vegetarian,
    bool? halal,
    double? restaurantBudget,
    bool? wheelchairAccessible,
    bool? seniorFriendly,
    bool? kidsFriendly,
    bool? freeOnly,
    String? naturalLanguagePrompt,
    DateTime? tripStartDate,
    DateTime? tripEndDate,
    TripVisitorPurpose? visitorPurpose,
  }) {
    return TripPreferences(
      destination: destination ?? this.destination,
      countryCode: countryCode ?? this.countryCode,
      days: days ?? this.days,
      budget: budget ?? this.budget,
      currency: currency ?? this.currency,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      travelStyles: travelStyles ?? this.travelStyles,
      transport: transport ?? this.transport,
      pace: pace ?? this.pace,
      locale: locale ?? this.locale,
      hotelArea: hotelArea ?? this.hotelArea,
      prayerReminders: prayerReminders ?? this.prayerReminders,
      vegetarian: vegetarian ?? this.vegetarian,
      halal: halal ?? this.halal,
      restaurantBudget: restaurantBudget ?? this.restaurantBudget,
      wheelchairAccessible:
          wheelchairAccessible ?? this.wheelchairAccessible,
      seniorFriendly: seniorFriendly ?? this.seniorFriendly,
      kidsFriendly: kidsFriendly ?? this.kidsFriendly,
      freeOnly: freeOnly ?? this.freeOnly,
      naturalLanguagePrompt:
          naturalLanguagePrompt ?? this.naturalLanguagePrompt,
      tripStartDate: tripStartDate ?? this.tripStartDate,
      tripEndDate: tripEndDate ?? this.tripEndDate,
      visitorPurpose: visitorPurpose ?? this.visitorPurpose,
    );
  }

  Map<String, dynamic> toJson() => {
        'destination': destination,
        'countryCode': countryCode,
        'days': days,
        'budget': budget,
        'currency': currency,
        'adults': adults,
        'children': children,
        'travelStyles': travelStyles.map((s) => s.name).toList(),
        'transport': transport.name,
        'pace': pace.name,
        'locale': locale,
        'hotelArea': hotelArea,
        'prayerReminders': prayerReminders,
        'vegetarian': vegetarian,
        'halal': halal,
        'restaurantBudget': restaurantBudget,
        'wheelchairAccessible': wheelchairAccessible,
        'seniorFriendly': seniorFriendly,
        'kidsFriendly': kidsFriendly,
        'freeOnly': freeOnly,
        'naturalLanguagePrompt': naturalLanguagePrompt,
        'tripStartDate': tripStartDate?.toIso8601String(),
        'tripEndDate': tripEndDate?.toIso8601String(),
        'visitorPurpose': visitorPurpose?.name,
      };

  factory TripPreferences.fromJson(Map<String, dynamic> json) {
    return TripPreferences(
      destination: json['destination'] as String? ?? 'Doha',
      countryCode: json['countryCode'] as String? ?? 'QA',
      days: json['days'] as int? ?? 3,
      budget: (json['budget'] as num?)?.toDouble() ?? 2000,
      currency: json['currency'] as String? ?? 'QAR',
      adults: json['adults'] as int? ?? 2,
      children: json['children'] as int? ?? 0,
      travelStyles: (json['travelStyles'] as List?)
              ?.map(
                (s) => TripTravelStyleExt.fromKey(s as String?),
              )
              .toList() ??
          const [TripTravelStyle.culture],
      transport: TripTransportPreference.values.firstWhere(
        (t) => t.name == json['transport'],
        orElse: () => TripTransportPreference.metro,
      ),
      pace: TripActivityPace.values.firstWhere(
        (p) => p.name == json['pace'],
        orElse: () => TripActivityPace.balanced,
      ),
      locale: json['locale'] as String? ?? 'English',
      hotelArea: json['hotelArea'] as String? ?? 'West Bay',
      prayerReminders: json['prayerReminders'] as bool? ?? true,
      vegetarian: json['vegetarian'] as bool? ?? false,
      halal: json['halal'] as bool? ?? true,
      restaurantBudget:
          (json['restaurantBudget'] as num?)?.toDouble() ?? 150,
      wheelchairAccessible: json['wheelchairAccessible'] as bool? ?? false,
      seniorFriendly: json['seniorFriendly'] as bool? ?? false,
      kidsFriendly: json['kidsFriendly'] as bool? ?? false,
      freeOnly: json['freeOnly'] as bool? ?? false,
      naturalLanguagePrompt:
          json['naturalLanguagePrompt'] as String? ?? '',
      tripStartDate: DateTime.tryParse(json['tripStartDate'] as String? ?? ''),
      tripEndDate: DateTime.tryParse(json['tripEndDate'] as String? ?? ''),
      visitorPurpose: TripVisitorPurposeExt.fromKey(
        json['visitorPurpose'] as String?,
      ),
    );
  }
}

/// Inclusive day count from optional calendar bounds.
int tripDaysFromDates({
  DateTime? start,
  DateTime? end,
  int fallback = 3,
}) {
  if (start == null || end == null) return fallback;
  final days = end.difference(start).inDays + 1;
  return days.clamp(1, 30);
}
