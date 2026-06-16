import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/models/visa_models.dart';
import 'package:raabta/screens/language_screen.dart';
import 'package:raabta/services/deadline_notification_service.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:raabta/services/visa_api_service.dart';
import 'package:raabta/services/visa_firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final visaApiServiceProvider = Provider<VisaApiService>((ref) {
  return VisaApiService();
});

final userLanguageProvider = FutureProvider<String>((ref) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(LanguageScreen.languageKey) ?? 'English';
  } catch (_) {
    return 'English';
  }
});

final visaGuideProvider =
    FutureProvider.autoDispose.family<VisaGuide, String>((ref, categoryId) async {
  final language = await ref.watch(userLanguageProvider.future);
  final api = ref.watch(visaApiServiceProvider);

  try {
    if (FirebaseService.isReady) {
      final firestore = VisaFirestoreService();
      return await firestore.fetchGuide(
        categoryId: categoryId,
        language: language,
      );
    }
    return await api.fetchGuide(categoryId: categoryId, language: language);
  } catch (_) {
    try {
      return await api.fetchGuide(categoryId: categoryId, language: language);
    } catch (_) {
      return fallbackVisaGuide(categoryId, language);
    }
  }
});

final documentDeadlinesProvider =
    StateNotifierProvider<DocumentDeadlinesNotifier, List<DocumentDeadline>>(
        (ref) {
  return DocumentDeadlinesNotifier();
});

class DocumentDeadlinesNotifier extends StateNotifier<List<DocumentDeadline>> {
  DocumentDeadlinesNotifier() : super([]) {
    _load();
  }

  static const _key = 'document_deadlines';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key) ?? [];
      final deadlines = raw
          .map((e) => DocumentDeadline.fromJson(
                jsonDecode(e) as Map<String, dynamic>,
              ))
          .toList()
        ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
      state = deadlines;
    } catch (_) {}
  }

  Future<void> addDeadline({
    required String documentType,
    required DateTime expiryDate,
    required String guideCategoryId,
  }) async {
    final deadline = DocumentDeadline(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      documentType: documentType,
      expiryDate: expiryDate,
      guideCategoryId: guideCategoryId,
    );

    final updated = [...state, deadline]
      ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    state = updated;
    await _persist(updated);
    await DeadlineNotificationService.instance
        .scheduleDeadlineNotifications(deadline);
  }

  Future<void> removeDeadline(String id) async {
    await DeadlineNotificationService.instance.cancelDeadlineNotifications(id);
    final updated = state.where((d) => d.id != id).toList();
    state = updated;
    await _persist(updated);
  }

  Future<void> _persist(List<DocumentDeadline> deadlines) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _key,
        deadlines.map((d) => jsonEncode(d.toJson())).toList(),
      );
    } catch (_) {}
  }
}

final isPremiumUserProvider = FutureProvider<bool>((ref) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_premium_user') ?? false;
  } catch (_) {
    return false;
  }
});

final documentScanUsageProvider =
    FutureProvider<DocumentScanUsage>((ref) async {
  return DocumentScanUsage.load();
});

class DocumentScanUsage {
  DocumentScanUsage({required this.count, required this.monthKey});

  final int count;
  final String monthKey;

  static const freeLimit = 3;

  bool get hasRemaining => count < freeLimit;

  int get remaining => (freeLimit - count).clamp(0, freeLimit);

  static String currentMonthKey() {
    final now = DateTime.now();
    return '${now.year}_${now.month.toString().padLeft(2, '0')}';
  }

  static Future<DocumentScanUsage> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final monthKey = currentMonthKey();
      final storedMonth = prefs.getString('scan_month_key') ?? monthKey;
      if (storedMonth != monthKey) {
        await prefs.setString('scan_month_key', monthKey);
        await prefs.setInt('scan_count', 0);
        return DocumentScanUsage(count: 0, monthKey: monthKey);
      }
      return DocumentScanUsage(
        count: prefs.getInt('scan_count') ?? 0,
        monthKey: monthKey,
      );
    } catch (_) {
      return DocumentScanUsage(count: 0, monthKey: currentMonthKey());
    }
  }

  static Future<void> increment() async {
    final usage = await load();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('scan_count', usage.count + 1);
      await prefs.setString('scan_month_key', usage.monthKey);
    } catch (_) {}
  }
}
