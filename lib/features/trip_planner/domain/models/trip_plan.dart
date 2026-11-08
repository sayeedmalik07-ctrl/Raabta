import 'package:raabta/features/trip_planner/domain/models/trip_booking_segment.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_readiness_manual_checks.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_enums.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_preferences.dart';

class TripActivity {
  const TripActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.durationMinutes,
    required this.type,
    this.timeSlot = TripTimeSlot.morning,
    this.entryFee = 0,
    this.estimatedCost = 0,
    this.openingHours,
    this.rating = 4.5,
    this.crowdLevel = 'Moderate',
    this.bestVisitTime,
    this.familyFriendly = true,
    this.wheelchairAccessible = false,
    this.latitude,
    this.longitude,
    this.address,
    this.imageUrl,
    this.phone,
    this.website,
    this.cuisine,
    this.halal = true,
    this.vegetarianOptions = false,
    this.nearbyPlaceIds = const [],
    this.prayerFacilityNearby = false,
  });

  final String id;
  final String title;
  final String description;
  final String startTime;
  final int durationMinutes;
  final TripActivityType type;
  final TripTimeSlot timeSlot;
  final double entryFee;
  final double estimatedCost;
  final String? openingHours;
  final double rating;
  final String crowdLevel;
  final String? bestVisitTime;
  final bool familyFriendly;
  final bool wheelchairAccessible;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? imageUrl;
  final String? phone;
  final String? website;
  final String? cuisine;
  final bool halal;
  final bool vegetarianOptions;
  final List<String> nearbyPlaceIds;
  final bool prayerFacilityNearby;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'startTime': startTime,
        'durationMinutes': durationMinutes,
        'type': type.name,
        'timeSlot': timeSlot.name,
        'entryFee': entryFee,
        'estimatedCost': estimatedCost,
        'openingHours': openingHours,
        'rating': rating,
        'crowdLevel': crowdLevel,
        'bestVisitTime': bestVisitTime,
        'familyFriendly': familyFriendly,
        'wheelchairAccessible': wheelchairAccessible,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'imageUrl': imageUrl,
        'phone': phone,
        'website': website,
        'cuisine': cuisine,
        'halal': halal,
        'vegetarianOptions': vegetarianOptions,
        'nearbyPlaceIds': nearbyPlaceIds,
        'prayerFacilityNearby': prayerFacilityNearby,
      };

  factory TripActivity.fromJson(Map<String, dynamic> json) {
    return TripActivity(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '09:00',
      durationMinutes: json['durationMinutes'] as int? ?? 60,
      type: TripActivityType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => TripActivityType.attraction,
      ),
      timeSlot: TripTimeSlot.values.firstWhere(
        (t) => t.name == json['timeSlot'],
        orElse: () => TripTimeSlot.morning,
      ),
      entryFee: (json['entryFee'] as num?)?.toDouble() ?? 0,
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 0,
      openingHours: json['openingHours'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      crowdLevel: json['crowdLevel'] as String? ?? 'Moderate',
      bestVisitTime: json['bestVisitTime'] as String?,
      familyFriendly: json['familyFriendly'] as bool? ?? true,
      wheelchairAccessible: json['wheelchairAccessible'] as bool? ?? false,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
      imageUrl: json['imageUrl'] as String?,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      cuisine: json['cuisine'] as String?,
      halal: json['halal'] as bool? ?? true,
      vegetarianOptions: json['vegetarianOptions'] as bool? ?? false,
      nearbyPlaceIds:
          (json['nearbyPlaceIds'] as List?)?.cast<String>() ?? const [],
      prayerFacilityNearby: json['prayerFacilityNearby'] as bool? ?? false,
    );
  }
}

class TripDayPlan {
  const TripDayPlan({
    required this.dayNumber,
    required this.title,
    required this.activities,
    this.theme,
  });

  final int dayNumber;
  final String title;
  final List<TripActivity> activities;
  final String? theme;

  Map<String, dynamic> toJson() => {
        'dayNumber': dayNumber,
        'title': title,
        'theme': theme,
        'activities': activities.map((a) => a.toJson()).toList(),
      };

  factory TripDayPlan.fromJson(Map<String, dynamic> json) {
    return TripDayPlan(
      dayNumber: json['dayNumber'] as int,
      title: json['title'] as String? ?? 'Day ${json['dayNumber']}',
      theme: json['theme'] as String?,
      activities: (json['activities'] as List?)
              ?.map(
                (e) => TripActivity.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          const [],
    );
  }
}

class BudgetBreakdown {
  const BudgetBreakdown({
    required this.tickets,
    required this.food,
    required this.transport,
    required this.shopping,
    required this.parking,
    required this.hotel,
    required this.miscellaneous,
    required this.totalBudget,
  });

  final double tickets;
  final double food;
  final double transport;
  final double shopping;
  final double parking;
  final double hotel;
  final double miscellaneous;
  final double totalBudget;

  double get totalSpent =>
      tickets + food + transport + shopping + parking + hotel + miscellaneous;

  double get remaining => totalBudget - totalSpent;

  bool get isOverBudget => remaining < 0;

  Map<String, dynamic> toJson() => {
        'tickets': tickets,
        'food': food,
        'transport': transport,
        'shopping': shopping,
        'parking': parking,
        'hotel': hotel,
        'miscellaneous': miscellaneous,
        'totalBudget': totalBudget,
      };

  factory BudgetBreakdown.fromJson(Map<String, dynamic> json) {
    return BudgetBreakdown(
      tickets: (json['tickets'] as num?)?.toDouble() ?? 0,
      food: (json['food'] as num?)?.toDouble() ?? 0,
      transport: (json['transport'] as num?)?.toDouble() ?? 0,
      shopping: (json['shopping'] as num?)?.toDouble() ?? 0,
      parking: (json['parking'] as num?)?.toDouble() ?? 0,
      hotel: (json['hotel'] as num?)?.toDouble() ?? 0,
      miscellaneous: (json['miscellaneous'] as num?)?.toDouble() ?? 0,
      totalBudget: (json['totalBudget'] as num?)?.toDouble() ?? 0,
    );
  }
}

class BudgetOptimizationTip {
  const BudgetOptimizationTip({
    required this.title,
    required this.description,
    required this.savings,
  });

  final String title;
  final String description;
  final double savings;
}

class TripPlan {
  const TripPlan({
    required this.id,
    required this.title,
    required this.preferences,
    required this.days,
    required this.budget,
    required this.travelTips,
    required this.shoppingSpots,
    required this.createdAt,
    this.isFavorite = false,
    this.shareCode,
    this.weatherSummary,
    this.budgetTips = const [],
    this.bookingSegments = const [],
    this.readinessManualChecks = const TripReadinessManualChecks(),
    this.deferredActivities = const [],
    this.itineraryDatesRevision = 0,
    this.scheduleNeedsReview = false,
  });

  final String id;
  final String title;
  final TripPreferences preferences;
  final List<TripDayPlan> days;
  final BudgetBreakdown budget;
  final List<String> travelTips;
  final List<String> shoppingSpots;
  final DateTime createdAt;
  final bool isFavorite;
  final String? shareCode;
  final String? weatherSummary;
  final List<BudgetOptimizationTip> budgetTips;
  final List<TripBookingSegment> bookingSegments;
  final TripReadinessManualChecks readinessManualChecks;
  final List<TripActivity> deferredActivities;
  final int itineraryDatesRevision;
  final bool scheduleNeedsReview;

  int get totalDays => days.length;

  List<TripActivity> get allActivities =>
      days.expand((d) => d.activities).toList();

  TripPlan copyWith({
    String? id,
    String? title,
    TripPreferences? preferences,
    List<TripDayPlan>? days,
    BudgetBreakdown? budget,
    List<String>? travelTips,
    List<String>? shoppingSpots,
    DateTime? createdAt,
    String? shareCode,
    bool? isFavorite,
    String? weatherSummary,
    List<BudgetOptimizationTip>? budgetTips,
    List<TripBookingSegment>? bookingSegments,
    TripReadinessManualChecks? readinessManualChecks,
    List<TripActivity>? deferredActivities,
    int? itineraryDatesRevision,
    bool? scheduleNeedsReview,
  }) {
    return TripPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      preferences: preferences ?? this.preferences,
      days: days ?? this.days,
      budget: budget ?? this.budget,
      travelTips: travelTips ?? this.travelTips,
      shoppingSpots: shoppingSpots ?? this.shoppingSpots,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      shareCode: shareCode ?? this.shareCode,
      weatherSummary: weatherSummary ?? this.weatherSummary,
      budgetTips: budgetTips ?? this.budgetTips,
      bookingSegments: bookingSegments ?? this.bookingSegments,
      readinessManualChecks:
          readinessManualChecks ?? this.readinessManualChecks,
      deferredActivities: deferredActivities ?? this.deferredActivities,
      itineraryDatesRevision:
          itineraryDatesRevision ?? this.itineraryDatesRevision,
      scheduleNeedsReview: scheduleNeedsReview ?? this.scheduleNeedsReview,
    );
  }

  /// Fresh ids for duplicate / cache-resubmit without Claude.
  TripPlan cloneWithNewIdentity({String? titleSuffix}) {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    return copyWith(
      id: newId,
      title: titleSuffix == null ? title : '$title$titleSuffix',
      createdAt: DateTime.now(),
      shareCode: newId.substring(0, 8).toUpperCase(),
      isFavorite: false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'preferences': preferences.toJson(),
        'days': days.map((d) => d.toJson()).toList(),
        'budget': budget.toJson(),
        'travelTips': travelTips,
        'shoppingSpots': shoppingSpots,
        'createdAt': createdAt.toIso8601String(),
        'isFavorite': isFavorite,
        'shareCode': shareCode,
        'weatherSummary': weatherSummary,
        'budgetTips': budgetTips
            .map(
              (t) => {
                'title': t.title,
                'description': t.description,
                'savings': t.savings,
              },
            )
            .toList(),
        'bookingSegments':
            bookingSegments.map((s) => s.toJson()).toList(),
        'readinessManualChecks': readinessManualChecks.toJson(),
        if (deferredActivities.isNotEmpty)
          'deferredActivities':
              deferredActivities.map((a) => a.toJson()).toList(),
        if (itineraryDatesRevision > 0)
          'itineraryDatesRevision': itineraryDatesRevision,
        if (scheduleNeedsReview) 'scheduleNeedsReview': scheduleNeedsReview,
      };

  factory TripPlan.fromJson(Map<String, dynamic> json) {
    return TripPlan(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Qatar Trip',
      preferences: TripPreferences.fromJson(
        Map<String, dynamic>.from(json['preferences'] as Map),
      ),
      days: (json['days'] as List?)
              ?.map(
                (e) => TripDayPlan.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          const [],
      budget: BudgetBreakdown.fromJson(
        Map<String, dynamic>.from(json['budget'] as Map? ?? {}),
      ),
      travelTips: (json['travelTips'] as List?)?.cast<String>() ?? const [],
      shoppingSpots:
          (json['shoppingSpots'] as List?)?.cast<String>() ?? const [],
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      isFavorite: json['isFavorite'] as bool? ?? false,
      shareCode: json['shareCode'] as String?,
      weatherSummary: json['weatherSummary'] as String?,
      budgetTips: (json['budgetTips'] as List?)
              ?.map(
                (e) => BudgetOptimizationTip(
                  title: (e as Map)['title'] as String,
                  description: e['description'] as String,
                  savings: (e['savings'] as num).toDouble(),
                ),
              )
              .toList() ??
          const [],
      bookingSegments: (json['bookingSegments'] as List?)
              ?.map(
                (e) => TripBookingSegment.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          const [],
      readinessManualChecks: TripReadinessManualChecks.fromJson(
        json['readinessManualChecks'] as Map<String, dynamic>?,
      ),
      deferredActivities: (json['deferredActivities'] as List?)
              ?.map(
                (e) => TripActivity.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          const [],
      itineraryDatesRevision:
          json['itineraryDatesRevision'] as int? ?? 0,
      scheduleNeedsReview: json['scheduleNeedsReview'] as bool? ?? false,
    );
  }
}
