import 'package:raabta/features/trip_planner/domain/models/trip_booking_segment.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_plan.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_readiness_manual_checks.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_readiness_models.dart';
import 'package:raabta/features/trip_planner/domain/services/trip_readiness_config.dart';
import 'package:raabta/models/visa_models.dart';

/// Pure arithmetic readiness scoring — zero AI, no cached score.
abstract final class TripReadinessCalculator {
  TripReadinessCalculator._();

  static TripReadinessResult compute({
    required TripPlan trip,
    required List<DocumentDeadline> deadlines,
    required List<TripVaultDocSnapshot> vaultDocs,
  }) {
    final manual = trip.readinessManualChecks;
    final tripEnd = _tripEndDate(trip);
    final passportExpiry = _bestExpiry(
      vaultDocs: vaultDocs,
      deadlines: deadlines,
      vaultType: 'passport',
      deadlineTypeId: 'passport',
    );
    final visaExpiry = _bestExpiry(
      vaultDocs: vaultDocs,
      deadlines: deadlines,
      vaultType: 'visa',
      deadlineTypeId: 'visitVisa',
    );

    final items = <TripReadinessItem>[
      _passportItem(
        tripEnd: tripEnd,
        passportExpiry: passportExpiry,
        manual: manual,
      ),
      _visaItem(tripEnd: tripEnd, visaExpiry: visaExpiry, manual: manual),
      _flightItem(trip),
      _accommodationItem(trip),
      _manualItem(
        TripReadinessCategory.travelInsurance,
        complete: manual.travelInsurance,
      ),
      _manualItem(
        TripReadinessCategory.insuranceCancellationCoverage,
        complete: manual.insuranceCancellationCoverage,
        pendingDetailKey: 'readiness_insurance_cancellation_detail',
      ),
      _manualItem(
        TripReadinessCategory.connectivity,
        complete: manual.connectivity,
      ),
      _manualItem(
        TripReadinessCategory.currencyReady,
        complete: manual.currencyReady,
      ),
      _manualItem(
        TripReadinessCategory.emergencyContacts,
        complete: manual.emergencyContacts,
        actionRoute: TripReadinessConfig.routeEmergency,
      ),
    ];

    final applicable = items.length;
    final complete = items.where((i) => i.isComplete).length;
    final remaining = applicable - complete;
    final percent =
        applicable == 0 ? 0 : ((complete / applicable) * 100).round();

    return TripReadinessResult(
      items: items,
      completeCount: complete,
      applicableCount: applicable,
      percent: percent,
      remainingCount: remaining,
    );
  }

  static TripReadinessItem _passportItem({
    required DateTime? tripEnd,
    required DateTime? passportExpiry,
    required TripReadinessManualChecks manual,
  }) {
    if (passportExpiry != null && tripEnd != null) {
      final requiredUntil = _addMonths(
        tripEnd,
        TripReadinessConfig.passportValidityBufferMonths,
      );
      if (!passportExpiry.isBefore(requiredUntil)) {
        return const TripReadinessItem(
          category: TripReadinessCategory.passportValidity,
          status: TripReadinessItemStatus.complete,
          isComplete: true,
          isAutoDetected: true,
          detailKey: 'readiness_passport_valid',
          actionRoute: TripReadinessConfig.routeDocumentVault,
        );
      }
      return const TripReadinessItem(
        category: TripReadinessCategory.passportValidity,
        status: TripReadinessItemStatus.blocked,
        isComplete: false,
        isAutoDetected: true,
        detailKey: 'readiness_passport_expired',
        actionRoute: TripReadinessConfig.routeDocumentVault,
      );
    }

    if (passportExpiry == null && manual.passportConfirmed) {
      return const TripReadinessItem(
        category: TripReadinessCategory.passportValidity,
        status: TripReadinessItemStatus.complete,
        isComplete: true,
        isAutoDetected: false,
        detailKey: 'readiness_passport_manual',
        actionRoute: TripReadinessConfig.routeDocumentVault,
      );
    }

    return TripReadinessItem(
      category: TripReadinessCategory.passportValidity,
      status: TripReadinessItemStatus.attention,
      isComplete: false,
      isAutoDetected: false,
      detailKey: tripEnd == null
          ? 'readiness_passport_no_trip_date'
          : 'readiness_passport_no_data',
      actionRoute: TripReadinessConfig.routeDocumentVault,
    );
  }

  static TripReadinessItem _visaItem({
    required DateTime? tripEnd,
    required DateTime? visaExpiry,
    required TripReadinessManualChecks manual,
  }) {
    if (visaExpiry != null && tripEnd != null) {
      if (!visaExpiry.isBefore(_dateOnly(tripEnd))) {
        return const TripReadinessItem(
          category: TripReadinessCategory.visaEntry,
          status: TripReadinessItemStatus.complete,
          isComplete: true,
          isAutoDetected: true,
          detailKey: 'readiness_visa_valid',
          actionRoute: TripReadinessConfig.routeDeadlineTracker,
        );
      }
      return const TripReadinessItem(
        category: TripReadinessCategory.visaEntry,
        status: TripReadinessItemStatus.blocked,
        isComplete: false,
        isAutoDetected: true,
        detailKey: 'readiness_visa_expired',
        actionRoute: TripReadinessConfig.routeDeadlineTracker,
      );
    }

    if (visaExpiry == null && manual.visaConfirmed) {
      return const TripReadinessItem(
        category: TripReadinessCategory.visaEntry,
        status: TripReadinessItemStatus.complete,
        isComplete: true,
        isAutoDetected: false,
        detailKey: 'readiness_visa_manual',
        actionRoute: TripReadinessConfig.routeDeadlineTracker,
      );
    }

    return TripReadinessItem(
      category: TripReadinessCategory.visaEntry,
      status: TripReadinessItemStatus.attention,
      isComplete: false,
      isAutoDetected: false,
      detailKey: tripEnd == null
          ? 'readiness_visa_no_trip_date'
          : 'readiness_visa_no_data',
      actionRoute: TripReadinessConfig.routeDeadlineTracker,
    );
  }

  static TripReadinessItem _flightItem(TripPlan trip) {
    final hasFlight = trip.bookingSegments
        .any((s) => s.type == TripBookingType.flight);
    return TripReadinessItem(
      category: TripReadinessCategory.flightBooked,
      status: hasFlight
          ? TripReadinessItemStatus.complete
          : TripReadinessItemStatus.incomplete,
      isComplete: hasFlight,
      isAutoDetected: hasFlight,
      detailKey: hasFlight
          ? 'readiness_flight_found'
          : 'readiness_flight_missing',
      actionRoute: TripReadinessConfig.routeBookingImport,
    );
  }

  static TripReadinessItem _accommodationItem(TripPlan trip) {
    final hasHotel = trip.bookingSegments
        .any((s) => s.type == TripBookingType.hotel);
    return TripReadinessItem(
      category: TripReadinessCategory.accommodationBooked,
      status: hasHotel
          ? TripReadinessItemStatus.complete
          : TripReadinessItemStatus.incomplete,
      isComplete: hasHotel,
      isAutoDetected: hasHotel,
      detailKey: hasHotel
          ? 'readiness_hotel_found'
          : 'readiness_hotel_missing',
      actionRoute: TripReadinessConfig.routeBookingImport,
    );
  }

  static TripReadinessItem _manualItem(
    TripReadinessCategory category, {
    required bool complete,
    String? actionRoute,
    String? pendingDetailKey,
  }) {
    return TripReadinessItem(
      category: category,
      status: complete
          ? TripReadinessItemStatus.complete
          : TripReadinessItemStatus.incomplete,
      isComplete: complete,
      isAutoDetected: false,
      detailKey: complete
          ? 'readiness_manual_done'
          : (pendingDetailKey ?? 'readiness_manual_pending'),
      actionRoute: actionRoute,
    );
  }

  static DateTime? _tripEndDate(TripPlan trip) {
    final prefs = trip.preferences;
    if (prefs.tripEndDate != null) return _dateOnly(prefs.tripEndDate!);
    if (prefs.tripStartDate != null) {
      return _dateOnly(
        prefs.tripStartDate!.add(Duration(days: prefs.days - 1)),
      );
    }
    DateTime? latest;
    for (final s in trip.bookingSegments) {
      final end = s.endDateTime ?? s.startDateTime;
      if (end == null) continue;
      if (latest == null || end.isAfter(latest)) latest = end;
    }
    return latest == null ? null : _dateOnly(latest);
  }

  static DateTime? _bestExpiry({
    required List<TripVaultDocSnapshot> vaultDocs,
    required List<DocumentDeadline> deadlines,
    required String vaultType,
    required String deadlineTypeId,
  }) {
    DateTime? best;

    for (final doc in vaultDocs) {
      if (doc.docType != vaultType || doc.expiryDate == null) continue;
      final exp = _dateOnly(doc.expiryDate!);
      if (best == null || exp.isAfter(best)) best = exp;
    }

    for (final d in deadlines) {
      if (d.typeId != deadlineTypeId) continue;
      final exp = _dateOnly(d.expiryDate);
      if (best == null || exp.isAfter(best)) best = exp;
    }

    return best;
  }

  static DateTime _dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  static DateTime _addMonths(DateTime date, int months) {
    final year = date.year + (date.month + months - 1) ~/ 12;
    final month = (date.month + months - 1) % 12 + 1;
    final day = date.day;
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, day > lastDay ? lastDay : day);
  }
}
