import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/scam_shield/family_kit/family_verification_models.dart';
import 'package:raabta/features/scam_shield/family_kit/family_verification_prefs_repository.dart';
import 'package:raabta/features/scam_shield/family_kit/family_verification_reminder_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final familyVerificationPrefsRepositoryProvider =
    FutureProvider<FamilyVerificationPrefsRepository>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return FamilyVerificationPrefsRepository(prefs);
});

final familyVerificationPrefsProvider =
    FutureProvider<FamilyVerificationPrefs>((ref) async {
  final repo = await ref.watch(familyVerificationPrefsRepositoryProvider.future);
  return repo.load();
});

final familyVerificationReminderServiceProvider =
    FutureProvider<FamilyVerificationReminderService>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return FamilyVerificationReminderService(prefs);
});
