import 'package:raabta/features/trip_planner/domain/models/trip_booking_segment.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_enums.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_plan.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_preferences.dart';
import 'package:raabta/features/trip_planner/domain/services/trip_template_engine.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';
import 'package:raabta/services/ai/document_extraction_service.dart';

/// Overlap detection and trip assembly for booking imports.
abstract final class TripBookingImportService {
  TripBookingImportService._();

  static List<TripPlan> findOverlappingTrips({
    required List<TripPlan> savedTrips,
    required TripPreferences candidate,
  }) {
    final start = candidate.tripStartDate;
    final end = candidate.tripEndDate;
    if (start == null || end == null) return const [];

    return savedTrips.where((trip) {
      final tStart = trip.preferences.tripStartDate;
      final tEnd = trip.preferences.tripEndDate;
      if (tStart == null || tEnd == null) return false;
      if (start.isAfter(tEnd) || tStart.isAfter(end)) return false;

      final dest = candidate.destination.trim().toLowerCase();
      final existing = trip.preferences.destination.trim().toLowerCase();
      if (dest.isEmpty || existing.isEmpty) return true;
      return dest == existing;
    }).toList();
  }

  static TripPreferences preferencesFromExtraction({
    required BookingConfirmationExtractionResult extraction,
    required TripPreferences base,
  }) {
    final destination = extraction.destinationCity?.trim();
    final country = extraction.destinationCountry?.trim();
    final start = extraction.startDateTime;
    final end = extraction.endDateTime;
    final days = tripDaysFromDates(
      start: start,
      end: end,
      fallback: base.days,
    );

    var countryCode = base.countryCode;
    if (country != null) {
      final lower = country.toLowerCase();
      if (lower.contains('qatar') || lower == 'qa') countryCode = 'QA';
    }

    return base.copyWith(
      destination: destination?.isNotEmpty == true
          ? destination!
          : base.destination,
      countryCode: countryCode,
      days: days,
      tripStartDate: start ?? base.tripStartDate,
      tripEndDate: end ?? base.tripEndDate,
    );
  }

  static TripBookingSegment segmentFromExtraction({
    required BookingConfirmationExtractionResult extraction,
    String? vaultDocumentId,
  }) {
    return TripBookingSegment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: extraction.bookingType ?? TripBookingType.hotel,
      destinationCity: extraction.destinationCity,
      destinationCountry: extraction.destinationCountry,
      startDateTime: extraction.startDateTime,
      endDateTime: extraction.endDateTime,
      confirmationNumber: extraction.confirmationNumber,
      providerName: extraction.providerName,
      guestName: extraction.guestName,
      vaultDocumentId: vaultDocumentId,
      fieldConfidence: extraction.fieldConfidence,
      importedAt: DateTime.now(),
    );
  }

  static TripPlan mergeIntoExisting({
    required TripPlan existing,
    required TripBookingSegment segment,
    required TripPreferences updatedPrefs,
  }) {
    final segments = [...existing.bookingSegments, segment];
    final days = _ensureBookingActivity(
      existing.days,
      segment,
      existing.preferences.locale,
    );
    final budget = TripBudgetService.calculate(days, updatedPrefs);

    return TripPlan(
      id: existing.id,
      title: existing.title,
      preferences: updatedPrefs,
      days: days,
      budget: budget,
      travelTips: existing.travelTips,
      shoppingSpots: existing.shoppingSpots,
      createdAt: existing.createdAt,
      isFavorite: existing.isFavorite,
      shareCode: existing.shareCode,
      weatherSummary: existing.weatherSummary,
      budgetTips: existing.budgetTips,
      bookingSegments: segments,
      readinessManualChecks: existing.readinessManualChecks,
    );
  }

  static TripPlan createNewTrip({
    required TripPreferences prefs,
    required TripBookingSegment segment,
    required String locale,
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final activity = _bookingActivity(segment);
    final dayPlans = [
      TripDayPlan(
        dayNumber: 1,
        title: _dayTitle(segment, locale),
        activities: [activity],
      ),
    ];
    final budget = TripBudgetService.calculate(dayPlans, prefs);

    return TripPlan(
      id: id,
      title: _tripTitle(prefs, segment),
      preferences: prefs,
      days: dayPlans,
      budget: budget,
      travelTips: const [
        'Your booking details are saved — generate a full AI itinerary when ready.',
      ],
      shoppingSpots: const [],
      createdAt: DateTime.now(),
      shareCode: id.substring(0, 8).toUpperCase(),
      bookingSegments: [segment],
    );
  }

  static List<TripDayPlan> _ensureBookingActivity(
    List<TripDayPlan> days,
    TripBookingSegment segment,
    String locale,
  ) {
    if (days.isEmpty) {
      return [
        TripDayPlan(
          dayNumber: 1,
          title: TripStrings.t('trip_booking_day_one', locale),
          activities: [_bookingActivity(segment)],
        ),
      ];
    }
    final first = days.first;
    final updated = TripDayPlan(
      dayNumber: first.dayNumber,
      title: first.title,
      theme: first.theme,
      activities: [_bookingActivity(segment), ...first.activities],
    );
    return [updated, ...days.skip(1)];
  }

  static TripActivity _bookingActivity(TripBookingSegment segment) {
    final provider = segment.providerName ?? 'Booking';
    final ref = segment.confirmationNumber;
    final title = switch (segment.type) {
      TripBookingType.flight => 'Flight — $provider',
      TripBookingType.hotel => 'Hotel check-in — $provider',
      TripBookingType.carRental => 'Car pick-up — $provider',
    };
    final description = ref == null ? '' : 'Confirmation: $ref';

    return TripActivity(
      id: 'booking_${segment.id}',
      title: title,
      description: description,
      startTime: _formatTime(segment.startDateTime),
      durationMinutes: 60,
      type: switch (segment.type) {
        TripBookingType.flight => TripActivityType.transport,
        TripBookingType.hotel => TripActivityType.hotel,
        TripBookingType.carRental => TripActivityType.transport,
      },
    );
  }

  static String _formatTime(DateTime? dt) {
    if (dt == null) return '09:00';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static String _tripTitle(TripPreferences prefs, TripBookingSegment segment) {
    final dest = segment.destinationCity ?? prefs.destination;
    return '$dest Trip';
  }

  static String _dayTitle(TripBookingSegment segment, String locale) {
    return switch (segment.type) {
      TripBookingType.flight => 'Arrival',
      TripBookingType.hotel => 'Check-in',
      TripBookingType.carRental => 'Pick-up',
    };
  }
}
