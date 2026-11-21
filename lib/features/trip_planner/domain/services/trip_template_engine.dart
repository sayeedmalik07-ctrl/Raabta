import 'package:raabta/features/trip_planner/data/qatar_places_catalog.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_enums.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_plan.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_preferences.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';

/// Offline itinerary builder when AI is unavailable.
class TripTemplateEngine {
  const TripTemplateEngine();

  TripPlan generate({
    required TripPreferences prefs,
    String? weatherContext,
    String id = 'local',
    String? shareCode,
  }) {
    final attractions = QatarPlacesCatalog.attractionsForStyles(
      prefs.travelStyles,
    );
    if (prefs.freeOnly) {
      attractions.removeWhere((a) => a.entryFee > 0);
    }
    if (prefs.wheelchairAccessible) {
      attractions.retainWhere((a) => a.wheelchairAccessible);
    }
    if (prefs.kidsFriendly) {
      attractions.retainWhere((a) => a.familyFriendly || a.kidsFriendly);
    }

    final restaurants = QatarPlacesCatalog.restaurants.where((r) {
      if (prefs.halal && !r.halal) return false;
      if (prefs.vegetarian && !r.vegetarianOptions && r.cuisine != 'Local') {
        // still allow local
      }
      if (prefs.travelStyles.contains(TripTravelStyle.budget)) {
        return r.estimatedMeal <= prefs.restaurantBudget;
      }
      if (prefs.travelStyles.contains(TripTravelStyle.luxury)) {
        return r.estimatedMeal >= 100;
      }
      return true;
    }).toList();

    final days = <TripDayPlan>[];
    final locale = prefs.locale;
    var attrIndex = 0;
    var restIndex = 0;

    for (var d = 1; d <= prefs.days; d++) {
      final activities = <TripActivity>[];

      // Breakfast
      if (restaurants.isNotEmpty) {
        activities.add(
          restaurants[restIndex % restaurants.length].toActivity(
            startTime: '08:00',
            type: TripActivityType.restaurant,
            slot: TripTimeSlot.morning,
            locale: locale,
          ),
        );
        restIndex++;
      }

      // Morning attraction
      if (attractions.isNotEmpty) {
        activities.add(
          attractions[attrIndex % attractions.length].toActivity(
            startTime: '09:30',
            type: TripActivityType.attraction,
            slot: TripTimeSlot.morning,
            locale: locale,
          ),
        );
        attrIndex++;
      }

      // Lunch
      if (restaurants.isNotEmpty) {
        activities.add(
          restaurants[restIndex % restaurants.length].toActivity(
            startTime: '13:00',
            type: TripActivityType.restaurant,
            slot: TripTimeSlot.afternoon,
            locale: locale,
          ),
        );
        restIndex++;
      }

      // Afternoon
      if (attractions.length > 1) {
        activities.add(
          attractions[attrIndex % attractions.length].toActivity(
            startTime: '15:00',
            type: TripActivityType.attraction,
            slot: TripTimeSlot.afternoon,
            locale: locale,
          ),
        );
        attrIndex++;
      }

      if (prefs.prayerReminders) {
        activities.add(
          TripActivity(
            id: 'maghrib_prayer',
            title: TripStrings.t('trip_template_maghrib', locale),
            description: 'Nearest mosque — use Prayer & Mosque for directions.',
            startTime: '17:45',
            durationMinutes: 20,
            type: TripActivityType.prayer,
            timeSlot: TripTimeSlot.evening,
            estimatedCost: 0,
          ),
        );
      }

      // Evening
      if (attractions.isNotEmpty) {
        activities.add(
          attractions[(attrIndex + 1) % attractions.length].toActivity(
            startTime: '18:30',
            type: TripActivityType.attraction,
            slot: TripTimeSlot.evening,
            locale: locale,
          ),
        );
      }

      // Dinner
      if (restaurants.isNotEmpty) {
        activities.add(
          restaurants[restIndex % restaurants.length].toActivity(
            startTime: '20:00',
            type: TripActivityType.restaurant,
            slot: TripTimeSlot.night,
            locale: locale,
          ),
        );
        restIndex++;
      }

      days.add(
        TripDayPlan(
          dayNumber: d,
          title: TripStrings.format(
            'trip_template_day_title',
            locale,
            {'day': '$d', 'destination': prefs.destination},
          ),
          theme: _themeForDay(d, prefs),
          activities: activities,
        ),
      );
    }

    final budget = TripBudgetService.calculate(days, prefs);
    final tips = _travelTips(prefs, weatherContext);
    final budgetTips = TripBudgetService.optimizationTips(budget, prefs);

    return TripPlan(
      id: id,
      title: _titleFor(prefs),
      preferences: prefs,
      days: days,
      budget: budget,
      travelTips: tips,
      shoppingSpots: QatarPlacesCatalog.shopping,
      createdAt: DateTime.now(),
      shareCode: shareCode ?? _shareCode(id),
      weatherSummary: weatherContext,
      budgetTips: budgetTips,
    );
  }

  String _titleFor(TripPreferences prefs) {
    if (prefs.naturalLanguagePrompt.isNotEmpty) {
      return '${prefs.days}-Day ${prefs.destination} Trip';
    }
    return '${prefs.days} Days in ${prefs.destination}';
  }

  String _themeForDay(int day, TripPreferences prefs) {
    if (prefs.travelStyles.contains(TripTravelStyle.luxury)) {
      return 'Luxury & Culture';
    }
    if (prefs.travelStyles.contains(TripTravelStyle.adventure)) {
      return 'Adventure & Outdoors';
    }
    if (day == 1) return 'Icons of Qatar';
    if (day == 2) return 'Culture & Cuisine';
    return 'Explore & Relax';
  }

  List<String> _travelTips(TripPreferences prefs, String? weather) {
    final tips = <String>[
      'Visit Souq Waqif after sunset for the best atmosphere.',
      'Use Doha Metro for fast, affordable travel.',
      'Carry water — Qatar summers are extremely hot.',
      'Thursday evenings are usually busier at malls.',
    ];
    if (weather != null && weather.contains('PEAK HEAT')) {
      tips.add('Schedule outdoor activities for early morning or evening.');
    }
    if (prefs.travelStyles.contains(TripTravelStyle.budget)) {
      tips.add('Many museums offer free entry on certain days.');
    }
    return tips;
  }

  String _shareCode(String id) {
    final base = id.length >= 8 ? id.substring(0, 8) : id.padRight(8, '0');
    return base.toUpperCase();
  }
}

/// Budget calculation and optimization.
class TripBudgetService {
  static BudgetBreakdown calculate(
    List<TripDayPlan> days,
    TripPreferences prefs,
  ) {
    var tickets = 0.0;
    var food = 0.0;
    var transport = 0.0;
    var shopping = 0.0;
    var parking = 0.0;

    for (final day in days) {
      for (final act in day.activities) {
        switch (act.type) {
          case TripActivityType.attraction:
            tickets += act.entryFee;
          case TripActivityType.restaurant:
            food += act.estimatedCost;
          case TripActivityType.transport:
            transport += act.estimatedCost;
          case TripActivityType.shopping:
            shopping += act.estimatedCost;
          default:
            break;
        }
      }
    }

    transport += _transportDaily(prefs) * prefs.days;
    parking += prefs.transport == TripTransportPreference.rentalCar
        ? 30 * prefs.days
        : 10 * prefs.days;
    shopping += prefs.travelStyles.contains(TripTravelStyle.shopping)
        ? prefs.budget * 0.15
        : prefs.budget * 0.05;

    final hotel = prefs.travelStyles.contains(TripTravelStyle.luxury)
        ? 800 * prefs.days
        : 350 * prefs.days;

    return BudgetBreakdown(
      tickets: tickets,
      food: food,
      transport: transport,
      shopping: shopping,
      parking: parking,
      hotel: hotel.toDouble(),
      miscellaneous: prefs.budget * 0.05,
      totalBudget: prefs.budget,
    );
  }

  static double _transportDaily(TripPreferences prefs) {
    switch (prefs.transport) {
      case TripTransportPreference.metro:
        return 20;
      case TripTransportPreference.walking:
        return 0;
      case TripTransportPreference.taxi:
        return 80;
      case TripTransportPreference.uber:
        return 70;
      case TripTransportPreference.rentalCar:
        return 150;
    }
  }

  static List<BudgetOptimizationTip> optimizationTips(
    BudgetBreakdown budget,
    TripPreferences prefs,
  ) {
    if (!budget.isOverBudget) return const [];

    final locale = prefs.locale;
    return [
      BudgetOptimizationTip(
        title: TripStrings.t('trip_suggestion_swap_restaurant', locale),
        description: 'Try Al Manchab or local karak spots instead.',
        savings: 120.0,
      ),
      BudgetOptimizationTip(
        title: TripStrings.t('trip_suggestion_free_attractions', locale),
        description: 'MIA and Souq Waqif have no entry fee.',
        savings: 50.0,
      ),
      BudgetOptimizationTip(
        title: TripStrings.t('trip_suggestion_use_metro', locale),
        description: 'Save on daily transport between West Bay and Souq.',
        savings: 40.0 * prefs.days,
      ),
    ];
  }
}
