import 'dart:convert';

import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_history_load_outcome.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';

/// OT history IDs historically used `{year}_{month}` (see overtime history tests/UI).
final RegExp _legacyOvertimeHistoryIdPattern = RegExp(
  r'^(\d{4})_(\d{1,2})(?:_|$)',
);

abstract final class EosbHistoryStorage {
  static EosbCalculationHistoryLoadOutcome parseCalculationHistory(
    String? raw,
  ) {
    if (raw == null) {
      return const EosbCalculationHistoryLoadOutcome(
        records: [],
        status: EosbHistoryStorageStatus.absent,
      );
    }

    final List<dynamic> decodedList;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        return const EosbCalculationHistoryLoadOutcome(
          records: [],
          status: EosbHistoryStorageStatus.corrupt,
        );
      }
      decodedList = decoded;
    } catch (_) {
      return const EosbCalculationHistoryLoadOutcome(
        records: [],
        status: EosbHistoryStorageStatus.corrupt,
      );
    }

    final records = <CalculationHistoryEntry>[];
    var sawMalformed = false;
    for (final element in decodedList) {
      if (element is! Map<String, dynamic>) {
        sawMalformed = true;
        continue;
      }
      final parsed = _tryParseCalculationHistoryEntry(element);
      if (parsed == null || !_isValidCalculationHistoryId(element)) {
        sawMalformed = true;
        continue;
      }
      records.add(parsed);
    }

    if (sawMalformed) {
      return EosbCalculationHistoryLoadOutcome(
        records: records,
        status: EosbHistoryStorageStatus.corrupt,
      );
    }

    return EosbCalculationHistoryLoadOutcome(
      records: records,
      status: EosbHistoryStorageStatus.valid,
    );
  }

  static OvertimeHistoryLoadOutcome parseOvertimeHistory(String? raw) {
    if (raw == null) {
      return const OvertimeHistoryLoadOutcome(
        records: [],
        status: EosbHistoryStorageStatus.absent,
      );
    }

    final List<dynamic> decodedList;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        return const OvertimeHistoryLoadOutcome(
          records: [],
          status: EosbHistoryStorageStatus.corrupt,
        );
      }
      decodedList = decoded;
    } catch (_) {
      return const OvertimeHistoryLoadOutcome(
        records: [],
        status: EosbHistoryStorageStatus.corrupt,
      );
    }

    final records = <OvertimeMonthlyRecord>[];
    var sawMalformed = false;
    for (final element in decodedList) {
      if (element is! Map<String, dynamic>) {
        sawMalformed = true;
        continue;
      }
      if (!_isValidOvertimeHistoryElement(element)) {
        sawMalformed = true;
        continue;
      }
      try {
        var record = OvertimeMonthlyRecord.fromJson(element);
        record = _normalizeLegacyOvertimeYearMonth(element, record);
        records.add(record);
      } catch (_) {
        sawMalformed = true;
      }
    }

    if (sawMalformed) {
      return OvertimeHistoryLoadOutcome(
        records: records,
        status: EosbHistoryStorageStatus.corrupt,
      );
    }

    return OvertimeHistoryLoadOutcome(
      records: records,
      status: EosbHistoryStorageStatus.valid,
    );
  }

  /// Requires non-empty [id] after trim (legacy rows always stored an explicit id).
  static bool _isValidCalculationHistoryId(Map<String, dynamic> map) {
    final id = map['id'] as String?;
    return id != null && id.trim().isNotEmpty;
  }

  /// Validates year/month with legacy fallback from [{year}_{month}] ids when
  /// year/month keys are absent (pre-metadata overtime history exports).
  static bool _isValidOvertimeHistoryElement(Map<String, dynamic> json) {
    final id = (json['id'] as String?)?.trim() ?? '';
    if (id.isEmpty) return false;

    final yearMonth = _resolveOvertimeYearMonth(json, id);
    if (yearMonth == null) return false;
    final (year, month) = yearMonth;
    return month >= 1 && month <= 12 && year >= 1970 && year <= 2100;
  }

  /// When JSON omits year/month, [fromJson] defaults to the current date.
  /// Align in-memory [year]/[month] with the legacy id rule used at validation.
  static OvertimeMonthlyRecord _normalizeLegacyOvertimeYearMonth(
    Map<String, dynamic> json,
    OvertimeMonthlyRecord record,
  ) {
    final yearRaw = json['year'];
    final monthRaw = json['month'];
    if (yearRaw is num && monthRaw is num) {
      return record;
    }

    final id = (json['id'] as String?)?.trim() ?? '';
    if (_legacyOvertimeHistoryIdPattern.firstMatch(id) == null) {
      return record;
    }

    final resolved = _resolveOvertimeYearMonth(json, id);
    if (resolved == null) {
      return record;
    }
    final (year, month) = resolved;
    return record.copyWith(year: year, month: month);
  }

  static (int year, int month)? _resolveOvertimeYearMonth(
    Map<String, dynamic> json,
    String id,
  ) {
    final yearRaw = json['year'];
    final monthRaw = json['month'];
    if (yearRaw is num && monthRaw is num) {
      return (yearRaw.toInt(), monthRaw.toInt());
    }
    final legacy = _legacyOvertimeHistoryIdPattern.firstMatch(id);
    if (legacy == null) return null;
    return (int.parse(legacy.group(1)!), int.parse(legacy.group(2)!));
  }

  static CalculationHistoryEntry? _tryParseCalculationHistoryEntry(
    Map<String, dynamic> map,
  ) {
    try {
      final inputRaw = map['input'];
      final resultRaw = map['result'];
      if (inputRaw is! Map<String, dynamic> ||
          resultRaw is! Map<String, dynamic>) {
        return null;
      }
      final id = map['id'] as String? ?? '';
      if (id.trim().isEmpty) return null;
      return CalculationHistoryEntry(
        id: id,
        input: EosbEmployeeInput.fromJson(inputRaw),
        result: EosbResult.fromJson(resultRaw),
        savedAt:
            DateTime.tryParse(map['savedAt'] as String? ?? '') ??
            DateTime.now(),
        label: map['label'] as String?,
        salaryDetailsStored: _readSalaryDetailsStored(map, inputJson: inputRaw),
      );
    } catch (_) {
      return null;
    }
  }

  static bool _readSalaryDetailsStored(
    Map<String, dynamic> map, {
    required dynamic inputJson,
  }) {
    final explicit = map['salaryDetailsStored'];
    if (explicit is bool) return explicit;
    if (inputJson is Map<String, dynamic>) {
      final basic = (inputJson['basicSalary'] as num?)?.toDouble() ?? 0;
      final consent = inputJson['storeSalaryWithConsent'] as bool? ?? false;
      return basic > 0 || consent;
    }
    return true;
  }
}
