import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';
import 'package:raabta/features/eosb/domain/models/employer_track_record_lookup.dart';

/// Backend lookup for aggregated employer entitlement signals (Part C).
///
/// Counts are k-anonymity gated server-side — never read Firestore aggregates
/// from the client.
class EmployerTrackRecordService {
  EmployerTrackRecordService({http.Client? client}) : _client = client ?? http.Client();

  static const _base = '${AppConfig.backendUrl}/api/employer-track-record';
  static const debounceDuration = Duration(milliseconds: 600);

  final http.Client _client;
  Timer? _debounceTimer;

  Future<EmployerTrackRecordLookup> lookup({required String companyName}) async {
    final trimmed = companyName.trim();
    if (trimmed.isEmpty) return EmployerTrackRecordLookup.insufficient();

    final uri = Uri.parse('$_base/lookup').replace(
      queryParameters: {'companyName': trimmed},
    );

    try {
      final res = await _client.get(uri).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) {
        debugPrint('EmployerTrackRecord lookup HTTP ${res.statusCode}');
        return EmployerTrackRecordLookup.insufficient();
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['success'] != true) {
        return EmployerTrackRecordLookup.insufficient();
      }

      return EmployerTrackRecordLookup.fromJson(data);
    } catch (e) {
      debugPrint('EmployerTrackRecord lookup error: $e');
      return EmployerTrackRecordLookup.insufficient();
    }
  }

  /// Debounced lookup for employer-name text fields (Part E — not per keystroke).
  void lookupDebounced({
    required String companyName,
    required void Function(EmployerTrackRecordLookup result) onResult,
  }) {
    _debounceTimer?.cancel();
    final trimmed = companyName.trim();
    if (trimmed.isEmpty) {
      onResult(EmployerTrackRecordLookup.insufficient());
      return;
    }

    _debounceTimer = Timer(debounceDuration, () async {
      onResult(await lookup(companyName: trimmed));
    });
  }

  void cancelPendingLookup() {
    _debounceTimer?.cancel();
  }

  void dispose() {
    _debounceTimer?.cancel();
    _client.close();
  }
}
