import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/buddy/data/buddy_profile_repository.dart';
import 'package:raabta/features/buddy/domain/buddy_constants.dart';
import 'package:raabta/features/buddy/domain/buddy_profile_validation.dart';
import 'package:raabta/features/buddy/domain/buddy_supported_countries.dart';
import 'package:raabta/features/buddy/models/buddy_profile.dart';
import 'package:raabta/screens/profile/profile_field_persistence.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

class BuddyProfilePersistenceResult {
  const BuddyProfilePersistenceResult.success(this.profile)
      : errors = const [],
        profileWriteFailed = false,
        userProfileWriteFailed = false;

  const BuddyProfilePersistenceResult.validationFailed(this.errors)
      : profile = null,
        profileWriteFailed = false,
        userProfileWriteFailed = false;

  const BuddyProfilePersistenceResult.userProfileFailed(this.errors)
      : profile = null,
        profileWriteFailed = false,
        userProfileWriteFailed = true;

  const BuddyProfilePersistenceResult.buddyProfileFailed(this.errors)
      : profile = null,
        profileWriteFailed = true,
        userProfileWriteFailed = false;

  final BuddyProfile? profile;
  final List<BuddyValidationError> errors;
  final bool profileWriteFailed;
  final bool userProfileWriteFailed;
}

/// Sequences UserAIProfile writeback then buddy_profiles write (not atomic).
abstract final class BuddyProfilePersistenceService {
  static Future<BuddyProfilePersistenceResult> save({
    required WidgetRef ref,
    required BuddyProfile draft,
    required String selectedCountryId,
    required bool isCreate,
  }) async {
    final errors = BuddyProfileValidation.validate(draft);
    if (errors.isNotEmpty) {
      return BuddyProfilePersistenceResult.validationFailed(errors);
    }

    final country = BuddySupportedCountries.byCountryId(selectedCountryId);
    if (country == null) {
      return BuddyProfilePersistenceResult.validationFailed([
        BuddyValidationError.invalidCountryId,
      ]);
    }

    final uid = draft.uid;
    try {
      final nationalityOk = await ProfileFieldPersistence.saveNationality(
        ref,
        uid: uid,
        value: country.nationalityPersistValue,
      );
      if (!nationalityOk) {
        return BuddyProfilePersistenceResult.userProfileFailed([
          BuddyValidationError.invalidCountryId,
        ]);
      }

      await ref.read(userAIProfileProvider.notifier).updateProfile({
        'spokenLanguageCodes': draft.spokenLanguageCodes,
        'preferredArea': draft.areaCode,
        'areaCode': draft.areaCode,
      });

      final cached = ref.read(userAIProfileProvider);
      final languagesOk = cached != null &&
          _listEquals(cached.spokenLanguageCodes, draft.spokenLanguageCodes);
      final areaOk =
          cached != null && cached.areaCode == draft.areaCode.trim();
      if (!languagesOk || !areaOk) {
        return BuddyProfilePersistenceResult.userProfileFailed([
          BuddyValidationError.noSpokenLanguages,
        ]);
      }
    } catch (_) {
      return BuddyProfilePersistenceResult.userProfileFailed(errors);
    }

    try {
      await BuddyProfileRepository().save(draft, isCreate: isCreate);
    } catch (_) {
      return BuddyProfilePersistenceResult.buddyProfileFailed(errors);
    }

    return BuddyProfilePersistenceResult.success(draft);
  }

  static Future<void> deleteProfile(String uid) async {
    await BuddyProfileRepository().delete(uid);
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static BuddyProfile buildDraft({
    required String uid,
    required String displayNickname,
    required bool isNewcomer,
    required bool isHelper,
    required bool paused,
    required String nationalityCountryId,
    required List<String> spokenLanguageCodes,
    required String areaCode,
    required String yearsInQatarBand,
    required List<String> interestTagIds,
    required DateTime adultAttestationAt,
    DateTime? existingOptInAt,
  }) {
    final now = DateTime.now();
    return BuddyProfile(
      uid: uid,
      isNewcomer: isNewcomer,
      isHelper: isHelper,
      paused: paused,
      displayNickname: displayNickname,
      nationalityCountryId: nationalityCountryId,
      spokenLanguageCodes: spokenLanguageCodes,
      areaCode: areaCode,
      yearsInQatarBand: yearsInQatarBand,
      interestTagIds: interestTagIds,
      consentVersion: BuddyConstants.consentVersion,
      adultAttestationAt: adultAttestationAt,
      optInAt: existingOptInAt ?? now,
      updatedAt: now,
    );
  }
}
