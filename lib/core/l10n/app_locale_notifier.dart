import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/app_locale_refresh.dart';
import 'package:raabta/features/prayer_mosque/providers/prayer_providers.dart';
import 'package:raabta/features/prayer_mosque/providers/prayer_schedule_providers.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/screens/language_screen.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reactive app locale — mirrors [ThemeNotifier] pattern for instant rebuilds.
class AppLocaleNotifier extends StateNotifier<String> {
  AppLocaleNotifier(this._ref) : super('English') {
    _loadSaved();
  }

  final Ref _ref;

  Future<void> _loadSaved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(LanguageScreen.languageKey);
      state = AppLocale.normalize(stored);
    } catch (_) {
      state = 'English';
    }
  }

  /// Persist picker label + update normalized catalog key synchronously.
  Future<void> setFromPickerLabel(String pickerLabel) async {
    final normalized = AppLocale.normalize(pickerLabel);
    if (normalized == state) return;
    state = normalized;
    _onLocaleChanged(normalized);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(LanguageScreen.languageKey, pickerLabel);
    } catch (_) {}

    await _syncFirestore(pickerLabel);
  }

  void _onLocaleChanged(String normalized) {
    appLocaleRefreshListenable.refreshRoutes();
    _ref.read(prayerProvider.notifier).syncAppLocale(normalized);
    _ref.read(prayerScheduleStripProvider.notifier).syncAppLocale(normalized);
  }

  /// Set by normalized catalog key (English, Arabic, …).
  Future<void> setLocale(String normalizedLocale) async {
    await setFromPickerLabel(AppLocale.toPickerLabel(normalizedLocale));
  }

  /// One-tap English ↔ Arabic toggle for Home shortcut.
  Future<void> toggleQuickPair() async {
    final nextPicker = AppLocale.normalize(state) == 'Arabic'
        ? AppLocalePickerLabels.quickToggleA
        : AppLocalePickerLabels.quickToggleB;
    await setFromPickerLabel(nextPicker);
  }

  Future<void> _syncFirestore(String pickerLabel) async {
    final uid = _ref.read(currentUserProvider)?.uid;
    if (uid == null || !FirebaseService.isReady) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {'language': pickerLabel, 'lastActive': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
    } catch (_) {}
  }
}

final appLocaleNotifierProvider =
    StateNotifierProvider<AppLocaleNotifier, String>(
  AppLocaleNotifier.new,
);

/// Normalized catalog locale — synchronous, app-wide reactive.
final appLocaleProvider = Provider<String>(
  (ref) => ref.watch(appLocaleNotifierProvider),
);
