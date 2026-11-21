import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/arabic_companion/data/arabic_companion_usage_repository.dart';
import 'package:raabta/features/arabic_companion/data/arabic_translations_cache_service.dart';
import 'package:raabta/features/arabic_companion/arabic_companion_config.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

final arabicTranslationsCacheServiceProvider =
    Provider<ArabicTranslationsCacheService>(
  (ref) => ArabicTranslationsCacheService(),
);

final arabicCompanionUsageRepositoryProvider =
    FutureProvider<ArabicCompanionUsageRepository>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return ArabicCompanionUsageRepository(prefs);
});

final arabicCompanionRemainingAiProvider = FutureProvider<int>((ref) async {
  final repo = await ref.watch(arabicCompanionUsageRepositoryProvider.future);
  final isPremium = await ref.watch(isPremiumUserProvider.future);
  if (isPremium) return ArabicCompanionConfig.freeMonthlyAiLimit;
  return repo.remainingFreeCalls();
});

Future<bool> arabicCompanionCanUseAi(WidgetRef ref) async {
  final repo = await ref.read(arabicCompanionUsageRepositoryProvider.future);
  final isPremium = await ref.read(isPremiumUserProvider.future);
  return repo.canUseAiLocally(isPremium: isPremium);
}

Future<void> arabicCompanionRecordAiUsage(WidgetRef ref) async {
  final repo = await ref.read(arabicCompanionUsageRepositoryProvider.future);
  await repo.incrementLocalMonthlyCount();
  ref.invalidate(arabicCompanionRemainingAiProvider);
}
