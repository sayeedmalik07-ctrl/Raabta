import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/trip_planner/data/qatar_places_catalog.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_plan.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_preferences.dart';
import 'package:raabta/features/trip_planner/domain/services/trip_template_engine.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';

class TripPlannerAiService {
  TripPlannerAiService(this._claude, this._engine);

  final ClaudeAIService _claude;
  final TripTemplateEngine _engine;

  Future<TripPlan> generateTrip({
    required TripPreferences preferences,
    required String weatherContext,
    required String tripId,
  }) async {
    final prompt = _buildPrompt(preferences, weatherContext);

    try {
      final reply = await _claude.sendMessage(
        prompt,
        language: preferences.locale,
        requestType: 'trip_planner',
      );

      final parsed = _tryParseJsonPlan(reply, preferences, tripId);
      if (parsed != null) {
        return parsed.copyWith(weatherSummary: weatherContext);
      }
    } catch (_) {
      // Fall through to template engine.
    }

    return _engine.generate(
      prefs: preferences,
      weatherContext: weatherContext,
      id: tripId,
    );
  }

  String _buildPrompt(TripPreferences prefs, String weather) {
    return '''
You are RAABTA Trip Planner. Create a ${prefs.days}-day itinerary for ${prefs.destination}, Qatar.
Budget: ${prefs.currency} ${prefs.budget}. Adults: ${prefs.adults}, Children: ${prefs.children}.
Styles: ${prefs.travelStyles.map((s) => s.name).join(', ')}.
Transport: ${prefs.transport.name}. Pace: ${prefs.pace.name}.
Halal: ${prefs.halal}. Vegetarian: ${prefs.vegetarian}. Free only: ${prefs.freeOnly}.
Prayer reminders: ${prefs.prayerReminders}. Hotel area: ${prefs.hotelArea}.
Meal budget/person: ${prefs.currency} ${prefs.restaurantBudget}.
Accessibility: wheelchair=${prefs.wheelchairAccessible}, senior=${prefs.seniorFriendly}, kids=${prefs.kidsFriendly}.
User request: "${prefs.naturalLanguagePrompt.isEmpty ? 'General Qatar trip' : prefs.naturalLanguagePrompt}"
Weather: $weather

Return ONLY valid JSON (no markdown) with this structure:
{
  "title": "string",
  "days": [{"dayNumber": 1, "title": "string", "activities": [{
    "id": "string", "title": "string", "description": "string",
    "startTime": "HH:mm", "durationMinutes": 90, "type": "attraction|restaurant|prayer",
    "entryFee": 0, "estimatedCost": 0, "rating": 4.5, "latitude": 25.28, "longitude": 51.53,
    "address": "string", "familyFriendly": true
  }]}],
  "travelTips": ["tip1", "tip2"],
  "shoppingSpots": ["spot1"]
}
Include real Qatar places: National Museum, MIA, Souq Waqif, Katara, The Pearl, desert safari.
Insert Maghrib prayer slots if prayerReminders is true.
''';
  }

  TripPlan? _tryParseJsonPlan(
    String reply,
    TripPreferences prefs,
    String tripId,
  ) {
    try {
      var jsonStr = reply.trim();
      final start = jsonStr.indexOf('{');
      final end = jsonStr.lastIndexOf('}');
      if (start < 0 || end <= start) return null;
      jsonStr = jsonStr.substring(start, end + 1);

      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final days = (map['days'] as List?)
              ?.map(
                (e) => TripDayPlan.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          [];

      if (days.isEmpty) return null;

      final budget = TripBudgetService.calculate(days, prefs);
      final budgetTips = TripBudgetService.optimizationTips(budget, prefs);

      return TripPlan(
        id: tripId,
        title: map['title'] as String? ?? '${prefs.days} Days in Qatar',
        preferences: prefs,
        days: days,
        budget: budget,
        budgetTips: budgetTips,
        travelTips: (map['travelTips'] as List?)?.cast<String>() ??
            const ['Use Metro for faster travel.'],
        shoppingSpots: (map['shoppingSpots'] as List?)?.cast<String>() ??
            QatarPlacesCatalog.shopping,
        createdAt: DateTime.now(),
        shareCode: tripId.substring(0, 8).toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }
}

final tripPlannerAiServiceProvider = Provider<TripPlannerAiService>((ref) {
  return TripPlannerAiService(
    ref.watch(claudeAIServiceProvider),
    TripTemplateEngine(),
  );
});

final tripTemplateEngineProvider = Provider((ref) => TripTemplateEngine());
