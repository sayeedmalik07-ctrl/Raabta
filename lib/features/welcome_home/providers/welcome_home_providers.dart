import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/eosb/data/models/return_support_models.dart';
import 'package:raabta/features/eosb/domain/services/welcome_home_return_support_service.dart';
import 'package:raabta/features/eosb/providers/home_country_support_providers.dart';
import 'package:raabta/features/welcome_home/domain/welcome_home_fly_checklist_service.dart';

final welcomeHomeReturnSupportServiceProvider =
    Provider<WelcomeHomeReturnSupportService>(
  (ref) => const WelcomeHomeReturnSupportService(),
);

final welcomeHomeFlyChecklistServiceProvider =
    Provider<WelcomeHomeFlyChecklistService>(
  (ref) => WelcomeHomeFlyChecklistService(),
);

final welcomeHomeReturnSupportViewProvider =
    FutureProvider.family<WelcomeHomeReturnSupportView, String?>(
  (ref, sessionCountryId) async {
    final context = await ref.watch(homeCountryUserContextProvider.future);
    final service = ref.watch(welcomeHomeReturnSupportServiceProvider);
    return service.resolve(
      context: context,
      sessionCountryId: sessionCountryId,
    );
  },
);

final welcomeHomeFlyChecklistProvider =
    FutureProvider<Map<String, bool>>((ref) async {
  return ref.watch(welcomeHomeFlyChecklistServiceProvider).load();
});
