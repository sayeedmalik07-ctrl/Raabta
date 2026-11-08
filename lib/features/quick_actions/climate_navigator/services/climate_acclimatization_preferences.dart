import 'package:flutter/foundation.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/heat_risk_calculator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local acclimatization plan metadata (PDPPL-local only; no health profile fields).
enum ClimateAcclimatizationType {
  newToQatarHeat,
  returningAfterLeave,
}

enum ClimateAcclimatizationStatus {
  inactive,
  active,
}

enum ClimateOutdoorEligibility {
  unset,
  eligible,
  ineligible,
}

class ClimateAcclimatizationPreferences {
  const ClimateAcclimatizationPreferences({
    required this.status,
    required this.outdoorEligibility,
    this.type,
    this.startDate,
  });

  final ClimateAcclimatizationStatus status;
  final ClimateOutdoorEligibility outdoorEligibility;
  final ClimateAcclimatizationType? type;
  final DateTime? startDate;

  bool get isActive =>
      status == ClimateAcclimatizationStatus.active &&
      type != null &&
      startDate != null;

  bool get shouldHideAcclimatizationSection =>
      outdoorEligibility == ClimateOutdoorEligibility.ineligible;

  static const _statusKey = 'climate_acclimat_status_v1';
  static const _typeKey = 'climate_acclimat_type_v1';
  static const _startDateKey = 'climate_acclimat_start_date_v1';
  static const _outdoorKey = 'climate_acclimat_outdoor_v1';

  static const _outdoorEligible = 'eligible';
  static const _outdoorIneligible = 'ineligible';

  static Future<ClimateAcclimatizationPreferences> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final outdoor = _readOutdoorEligibility(prefs.getString(_outdoorKey));
      final repaired = await _loadValidated(prefs);
      return repaired.copyWithOutdoor(outdoor);
    } catch (e, st) {
      debugPrint('ClimateAcclimatizationPreferences.load failed: $e\n$st');
      return const ClimateAcclimatizationPreferences(
        status: ClimateAcclimatizationStatus.inactive,
        outdoorEligibility: ClimateOutdoorEligibility.unset,
      );
    }
  }

  static Future<ClimateAcclimatizationPreferences> _loadValidated(
    SharedPreferences prefs,
  ) async {
    final statusName = prefs.getString(_statusKey);
    final typeName = prefs.getString(_typeKey);
    final packed = prefs.getInt(_startDateKey);

    final status = _parseStatus(statusName);
    final type = _parseType(typeName);
    final startDate = packed != null ? _tryUnpackDate(packed) : null;

    final malformed = _isPlanMalformed(
      status: status,
      type: type,
      typeName: typeName,
      startDate: startDate,
      packed: packed,
    );

    if (malformed) {
      await _clearPlanKeys(prefs);
      return const ClimateAcclimatizationPreferences(
        status: ClimateAcclimatizationStatus.inactive,
        outdoorEligibility: ClimateOutdoorEligibility.unset,
      );
    }

    if (status == ClimateAcclimatizationStatus.active) {
      return ClimateAcclimatizationPreferences(
        status: status,
        outdoorEligibility: ClimateOutdoorEligibility.unset,
        type: type,
        startDate: startDate,
      );
    }

    return const ClimateAcclimatizationPreferences(
      status: ClimateAcclimatizationStatus.inactive,
      outdoorEligibility: ClimateOutdoorEligibility.unset,
    );
  }

  @visibleForTesting
  static bool isPlanMalformed({
    required ClimateAcclimatizationStatus status,
    required ClimateAcclimatizationType? type,
    required String? typeName,
    required DateTime? startDate,
    required int? packed,
  }) {
    return _isPlanMalformed(
      status: status,
      type: type,
      typeName: typeName,
      startDate: startDate,
      packed: packed,
    );
  }

  static bool _isPlanMalformed({
    required ClimateAcclimatizationStatus status,
    required ClimateAcclimatizationType? type,
    required String? typeName,
    required DateTime? startDate,
    required int? packed,
  }) {
    if (typeName != null && type == null) return true;
    if (packed != null && startDate == null) return true;
    if (status == ClimateAcclimatizationStatus.active) {
      if (type == null || startDate == null) return true;
    }
    if (status == ClimateAcclimatizationStatus.inactive) {
      if (type != null || startDate != null || typeName != null) return true;
    }
    return false;
  }

  static ClimateAcclimatizationStatus _parseStatus(String? name) {
    if (name == null) return ClimateAcclimatizationStatus.inactive;
    for (final value in ClimateAcclimatizationStatus.values) {
      if (value.name == name) return value;
    }
    return ClimateAcclimatizationStatus.inactive;
  }

  static ClimateAcclimatizationType? _parseType(String? name) {
    if (name == null) return null;
    for (final value in ClimateAcclimatizationType.values) {
      if (value.name == name) return value;
    }
    return null;
  }

  static ClimateOutdoorEligibility _readOutdoorEligibility(String? raw) {
    if (raw == _outdoorEligible) return ClimateOutdoorEligibility.eligible;
    if (raw == _outdoorIneligible) return ClimateOutdoorEligibility.ineligible;
    return ClimateOutdoorEligibility.unset;
  }

  /// Persists outdoor gate; clears active plan when [worksOutdoor] is false.
  static Future<bool> setWorksOutdoorInHeat(bool worksOutdoor) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (worksOutdoor) {
        await prefs.setString(_outdoorKey, _outdoorEligible);
        return true;
      }
      await prefs.setString(_outdoorKey, _outdoorIneligible);
      await _clearPlanKeys(prefs);
      return true;
    } catch (e, st) {
      debugPrint(
        'ClimateAcclimatizationPreferences.setWorksOutdoorInHeat failed: $e\n$st',
      );
      return false;
    }
  }

  /// Persists an active plan for users who work outdoors in the heat.
  static Future<bool> saveActivePlan({
    required ClimateAcclimatizationType type,
    required DateTime startDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final normalized = qatarCalendarDate(startDate);
      await prefs.setString(_outdoorKey, _outdoorEligible);
      await prefs.setString(
        _statusKey,
        ClimateAcclimatizationStatus.active.name,
      );
      await prefs.setString(_typeKey, type.name);
      await prefs.setInt(_startDateKey, packDate(normalized));
      return true;
    } catch (e, st) {
      debugPrint(
        'ClimateAcclimatizationPreferences.saveActivePlan failed: $e\n$st',
      );
      return false;
    }
  }

  /// Clears type/start/status and resets outdoor eligibility to unset.
  static Future<bool> clearActivePlan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _clearPlanKeys(prefs);
      await prefs.remove(_outdoorKey);
      return true;
    } catch (e, st) {
      debugPrint(
        'ClimateAcclimatizationPreferences.clearActivePlan failed: $e\n$st',
      );
      return false;
    }
  }

  @visibleForTesting
  static Future<bool> clearEverything() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _clearPlanKeys(prefs);
      await prefs.remove(_outdoorKey);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _clearPlanKeys(SharedPreferences prefs) async {
    await prefs.remove(_statusKey);
    await prefs.remove(_typeKey);
    await prefs.remove(_startDateKey);
  }

  /// Qatar-local calendar date for any instant (Concierge UTC, picker local, etc.).
  static DateTime qatarCalendarDate(DateTime at) {
    final qatar = HeatRiskCalculator.toQatarLocal(at);
    return DateTime(qatar.year, qatar.month, qatar.day);
  }

  static DateTime? _tryUnpackDate(int packed) {
    if (packed < 10101 || packed > 99991231) return null;
    final year = packed ~/ 10000;
    final month = (packed % 10000) ~/ 100;
    final day = packed % 100;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    return DateTime(year, month, day);
  }

  static int packDate(DateTime date) =>
      date.year * 10000 + date.month * 100 + date.day;

  static DateTime unpackDate(int packed) {
    final decoded = _tryUnpackDate(packed);
    if (decoded == null) {
      throw FormatException('Invalid packed date: $packed');
    }
    return decoded;
  }

  ClimateAcclimatizationPreferences copyWithOutdoor(
    ClimateOutdoorEligibility outdoorEligibility,
  ) {
    return ClimateAcclimatizationPreferences(
      status: status,
      outdoorEligibility: outdoorEligibility,
      type: type,
      startDate: startDate,
    );
  }
}
