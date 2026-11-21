import 'package:raabta/features/trip_planner/domain/services/trip_readiness_config.dart';

enum TripReadinessCategory {
  passportValidity,
  visaEntry,
  flightBooked,
  accommodationBooked,
  travelInsurance,
  insuranceCancellationCoverage,
  connectivity,
  currencyReady,
  emergencyContacts,
}

enum TripReadinessItemStatus {
  complete,
  incomplete,
  attention,
  blocked,
}

class TripReadinessItem {
  const TripReadinessItem({
    required this.category,
    required this.status,
    required this.isComplete,
    required this.isAutoDetected,
    this.detailKey,
    this.actionRoute,
  });

  final TripReadinessCategory category;
  final TripReadinessItemStatus status;
  final bool isComplete;
  final bool isAutoDetected;
  final String? detailKey;
  final String? actionRoute;

  String get categoryKey => category.name;
}

class TripReadinessResult {
  const TripReadinessResult({
    required this.items,
    required this.completeCount,
    required this.applicableCount,
    required this.percent,
    required this.remainingCount,
  });

  final List<TripReadinessItem> items;
  final int completeCount;
  final int applicableCount;
  final int percent;
  final int remainingCount;

  static final empty = TripReadinessResult(
    items: const [],
    completeCount: 0,
    applicableCount: TripReadinessCategory.values.length,
    percent: 0,
    remainingCount: TripReadinessCategory.values.length,
  );
}

/// Minimal vault document fields for readiness checks.
class TripVaultDocSnapshot {
  const TripVaultDocSnapshot({
    required this.docType,
    this.expiryDate,
  });

  final String docType;
  final DateTime? expiryDate;
}
