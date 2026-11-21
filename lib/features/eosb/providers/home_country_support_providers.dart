import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/eosb/data/models/home_country_support_models.dart';
import 'package:raabta/features/eosb/domain/services/home_country_support_service.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/services/firebase_service.dart';

final homeCountrySupportServiceProvider =
    Provider<HomeCountrySupportService>((ref) {
  return const HomeCountrySupportService();
});

/// Reads nationality from profile / Firestore and optional home-state fields.
final homeCountryUserContextProvider =
    FutureProvider<HomeCountryUserContext>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return const HomeCountryUserContext(nationality: '');
  }

  var aiProfile = ref.watch(userAIProfileProvider);
  if (UserProfileOwnership.needsInit(aiProfile, user.uid)) {
    await ref.read(userAIProfileProvider.notifier).initProfile(user.uid);
    aiProfile = ref.read(userAIProfileProvider);
  }
  if (aiProfile == null || aiProfile.uid != user.uid) {
    aiProfile = UserAIProfile.defaultProfile(user.uid);
  }

  var nationality = aiProfile.nationality.trim();
  var homeState = '';

  if (FirebaseService.isReady) {
    try {
      final snap =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = snap.data() ?? {};
      nationality = (data['nationality'] as String? ?? nationality).trim();
      homeState = _readHomeState(data);
    } catch (_) {
      // Offline or rules — profile cache only.
    }
  }

  return HomeCountryUserContext(
    nationality: nationality,
    homeState: homeState,
  );
});

String _readHomeState(Map<String, dynamic> data) {
  for (final key in ['homeState', 'home_state', 'state', 'homeRegion']) {
    final value = data[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return '';
}

final homeCountrySupportViewProvider =
    FutureProvider<HomeCountrySupportView>((ref) async {
  final context = await ref.watch(homeCountryUserContextProvider.future);
  final service = ref.watch(homeCountrySupportServiceProvider);
  return service.resolve(context);
});

final beforeYouSignViewProvider =
    FutureProvider<BeforeYouSignView>((ref) async {
  final context = await ref.watch(homeCountryUserContextProvider.future);
  final service = ref.watch(homeCountrySupportServiceProvider);
  return service.resolveBeforeYouSign(context);
});
