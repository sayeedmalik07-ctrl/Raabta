import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:raabta/features/leaving_qatar/data/departure_plan/leaving_qatar_departure_plan_models.dart';

/// Serializes [LeavingQatarDeparturePlanState] for SharedPreferences — state only.
abstract final class LeavingQatarDeparturePlanCodec {
  static const storageVersion = 1;

  static String encode(LeavingQatarDeparturePlanState state) {
    final map = <String, dynamic>{
      'v': storageVersion,
      if (state.plannedDepartureDate != null)
        'plannedDepartureDate': state.plannedDepartureDate,
      'completed': Map<String, bool>.from(state.completedByItemId),
    };
    return jsonEncode(map);
  }

  static LeavingQatarDeparturePlanState decode(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const LeavingQatarDeparturePlanState();
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return const LeavingQatarDeparturePlanState();
      }
      final version = decoded['v'];
      if (version is! num || version.toInt() != storageVersion) {
        return _decodeLenient(decoded);
      }
      return _fromMap(decoded);
    } catch (_) {
      return const LeavingQatarDeparturePlanState();
    }
  }

  /// Older or partial payloads — keep completions when possible.
  static LeavingQatarDeparturePlanState _decodeLenient(Map<dynamic, dynamic> map) {
    return _fromMap(map);
  }

  static LeavingQatarDeparturePlanState _fromMap(Map<dynamic, dynamic> map) {
    final dateRaw = map['plannedDepartureDate'];
    String? date;
    if (dateRaw is String &&
        LeavingQatarDeparturePlanDate.isValidIsoDate(dateRaw)) {
      date = dateRaw;
    }

    final completedRaw = map['completed'];
    final completed = <String, bool>{};
    if (completedRaw is Map) {
      for (final entry in completedRaw.entries) {
        final key = entry.key?.toString();
        if (key == null || key.isEmpty) continue;
        final value = entry.value;
        if (value is bool) {
          completed[key] = value;
        } else if (value == true || value == false) {
          completed[key] = value == true;
        }
      }
    }

    return LeavingQatarDeparturePlanState(
      plannedDepartureDate: date,
      completedByItemId: completed,
    );
  }

  @visibleForTesting
  static LeavingQatarDeparturePlanState decodeForTest(String? raw) => decode(raw);
}
