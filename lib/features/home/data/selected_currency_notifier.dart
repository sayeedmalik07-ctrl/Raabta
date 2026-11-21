import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/services/exchange_rate_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences key for last remittance currency (Home + Money hub).
const selectedRemittanceCurrencyPrefsKey = 'raabta_selected_remittance_currency';

const selectedCurrencyDefaultCode = 'INR';

/// Validates [raw] against [targetCurrencyCodes]; null when invalid/absent.
String? parseStoredSelectedCurrencyCode(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final upper = raw.trim().toUpperCase();
  if (targetCurrencyCodes.contains(upper)) return upper;
  return null;
}

String normalizeSelectedCurrencyCode(String code) {
  return parseStoredSelectedCurrencyCode(code) ?? selectedCurrencyDefaultCode;
}

/// Selected QAR→home currency — persisted locally for Home and Money hub.
class SelectedCurrencyNotifier extends Notifier<String> {
  @override
  String build() {
    unawaited(_restoreFromDisk());
    return selectedCurrencyDefaultCode;
  }

  void setCurrency(String code) {
    final normalized = normalizeSelectedCurrencyCode(code);
    if (state == normalized) return;
    state = normalized;
    unawaited(_persist(normalized));
  }

  Future<void> _restoreFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final restored = parseStoredSelectedCurrencyCode(
      prefs.getString(selectedRemittanceCurrencyPrefsKey),
    );
    if (restored != null && restored != state) {
      state = restored;
    }
  }

  Future<void> _persist(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(selectedRemittanceCurrencyPrefsKey, code);
  }
}

final selectedCurrencyProvider =
    NotifierProvider<SelectedCurrencyNotifier, String>(
  SelectedCurrencyNotifier.new,
);
