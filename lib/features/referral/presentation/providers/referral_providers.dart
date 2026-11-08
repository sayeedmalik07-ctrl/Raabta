import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/services/referral/referral_service.dart';

final referralServiceProvider = Provider<ReferralService>(
  (ref) => ReferralService.instance,
);

final referralProfileProvider = FutureProvider<ReferralProfileSnapshot>((ref) async {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return const ReferralProfileSnapshot();
  return ReferralService.instance.loadProfile(uid);
});

final referrerByCodeProvider =
    FutureProvider.family<ReferrerProfile?, String>((ref, code) async {
  return ReferralService.instance.lookupReferrerByCode(code);
});
