import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';

/// Local history blob state for EOSB / Overtime (distinct from in-memory lists).
enum EosbHistoryStorageStatus {
  /// No persisted history JSON for this UID scope.
  absent,

  /// JSON parses and every record is valid.
  valid,

  /// JSON is truncated/invalid and/or one or more records are malformed.
  corrupt,
}

class EosbCalculationHistoryLoadOutcome {
  const EosbCalculationHistoryLoadOutcome({
    required this.records,
    required this.status,
  });

  final List<CalculationHistoryEntry> records;
  final EosbHistoryStorageStatus status;

  bool get isStorageCorrupt => status == EosbHistoryStorageStatus.corrupt;

  /// True when there is no on-disk history (not corrupt).
  bool get isGenuinelyEmpty =>
      status == EosbHistoryStorageStatus.absent ||
      (status == EosbHistoryStorageStatus.valid && records.isEmpty);
}

class OvertimeHistoryLoadOutcome {
  const OvertimeHistoryLoadOutcome({
    required this.records,
    required this.status,
  });

  final List<OvertimeMonthlyRecord> records;
  final EosbHistoryStorageStatus status;

  bool get isStorageCorrupt => status == EosbHistoryStorageStatus.corrupt;

  bool get isGenuinelyEmpty =>
      status == EosbHistoryStorageStatus.absent ||
      (status == EosbHistoryStorageStatus.valid && records.isEmpty);
}
