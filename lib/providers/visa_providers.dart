import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/config/monetization_state.dart';
import 'package:raabta/core/l10n/app_locale_notifier.dart';
import 'package:raabta/features/visa/data/deadline_tracker_repository.dart';
import 'package:raabta/models/visa_models.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:raabta/services/raabta_notification_service.dart';
import 'package:raabta/services/smart_notification_engine.dart';
import 'package:raabta/services/visa_api_service.dart';
import 'package:raabta/services/visa_firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final visaApiServiceProvider = Provider<VisaApiService>((ref) {
  return VisaApiService();
});

final deadlineTrackerRepositoryProvider =
    Provider((ref) => DeadlineTrackerRepository());

/// Synchronous normalized locale — rebuilds instantly on toggle.
final userLanguageProvider = appLocaleProvider;

final visaGuideProvider =
    FutureProvider.autoDispose.family<VisaGuide, String>((ref, categoryId) async {
  final language = ref.watch(userLanguageProvider);
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

final _deadlineUserIdProvider = FutureProvider<String>((ref) async {
  return RaabtaNotificationService.instance.getOrCreateUserId();
});

final documentDeadlinesProvider = StreamProvider<List<DocumentDeadline>>((ref) async* {
  final userId = await ref.watch(_deadlineUserIdProvider.future);
  await _migrateLegacyDeadlines(ref, userId);
  final repo = ref.watch(deadlineTrackerRepositoryProvider);
  yield* repo.watchDeadlines(userId);
});

class DocumentDeadlinesController {
  DocumentDeadlinesController(this._ref);

  final Ref _ref;

  DeadlineTrackerRepository get _repo =>
      _ref.read(deadlineTrackerRepositoryProvider);

  Future<String> _userId() =>
      _ref.read(_deadlineUserIdProvider.future);

  Future<void> addDeadline({
    required DocumentDeadlineTypeDef typeDef,
    required DateTime expiryDate,
    bool remind30Days = true,
    bool remind7Days = true,
    bool remind1Day = true,
    String? vaultDocumentId,
    String? visitVisaNickname,
  }) async {
    final userId = await _userId();
    final documentType = typeDef.type == DocumentDeadlineType.visitVisa
        ? VisitVisaNicknamePolicy.documentTypeForPersistence(
            rawNickname: visitVisaNickname,
            defaultVisitVisaLabel: typeDef.label,
          )
        : typeDef.label;
    final deadline = DocumentDeadline(
      id: '',
      documentType: documentType,
      typeId: typeDef.id,
      expiryDate: expiryDate,
      guideCategoryId: typeDef.guideCategoryId,
      remind30Days: remind30Days,
      remind7Days: remind7Days,
      remind1Day: remind1Day,
      vaultDocumentId: vaultDocumentId,
    );
    final id = await _repo.add(userId: userId, deadline: deadline);
    final notificationLabel = deadline.notificationDocumentLabel;
    await SmartNotificationEngine.instance.scheduleDocumentDeadlineReminders(
      deadlineId: id,
      documentType: notificationLabel,
      expiryDate: expiryDate,
      remind30Days: remind30Days,
      remind7Days: remind7Days,
      remind1Day: remind1Day,
    );
  }

  Future<void> attachVaultDocument({
    required String deadlineId,
    required String vaultDocumentId,
  }) async {
    await _repo.update(deadlineId, {'vaultDocumentId': vaultDocumentId});
  }

  Future<void> updateReminderToggles({
    required DocumentDeadline deadline,
    required bool remind30Days,
    required bool remind7Days,
    required bool remind1Day,
  }) async {
    await _repo.update(deadline.id, {
      'remind30Days': remind30Days,
      'remind7Days': remind7Days,
      'remind1Day': remind1Day,
    });
    await SmartNotificationEngine.instance.cancelDocumentDeadlineReminders(
      deadline.id,
    );
    await SmartNotificationEngine.instance.scheduleDocumentDeadlineReminders(
      deadlineId: deadline.id,
      documentType: deadline.notificationDocumentLabel,
      expiryDate: deadline.expiryDate,
      remind30Days: remind30Days,
      remind7Days: remind7Days,
      remind1Day: remind1Day,
    );
  }

  Future<void> removeDeadline(String id) async {
    await SmartNotificationEngine.instance.cancelDocumentDeadlineReminders(id);
    await _repo.delete(id);
  }
}

final documentDeadlinesControllerProvider =
    Provider((ref) => DocumentDeadlinesController(ref));

Future<void> _migrateLegacyDeadlines(Ref ref, String userId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    const legacyKey = 'document_deadlines';
    final raw = prefs.getStringList(legacyKey) ?? [];
    if (raw.isEmpty) return;

    final repo = ref.read(deadlineTrackerRepositoryProvider);
    for (final entry in raw) {
      final json = jsonDecode(entry) as Map<String, dynamic>;
      final legacy = DocumentDeadline.fromJson(json);
      final typeDef = deadlineTypeDefForLegacyLabel(legacy.documentType);
      await repo.add(
        userId: userId,
        deadline: legacy.copyWith(
          typeId: typeDef.id,
          documentType: typeDef.label,
          guideCategoryId: typeDef.guideCategoryId,
        ),
      );
    }
    await prefs.remove(legacyKey);
  } catch (_) {}
}

final isPremiumUserProvider = FutureProvider<bool>((ref) async {
  if (!MonetizationState.grantsPaidEntitlements) {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('is_premium_user') == true) {
        await prefs.setBool('is_premium_user', false);
      }
    } catch (_) {}
    return false;
  }
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_premium_user') ?? false;
  } catch (_) {
    return false;
  }
});
