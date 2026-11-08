import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/scam_shield/forewarnings/forewarning_models.dart';
import 'package:raabta/features/scam_shield/forewarnings/forewarning_moments.dart';
import 'package:raabta/features/scam_shield/forewarnings/forewarning_state_repository.dart';
import 'package:raabta/providers/compliance_flags_provider.dart';

final forewarningRepositoryProvider = Provider<ForewarningStateRepository>(
  (ref) => ForewarningStateRepository(),
);

final forewarningTipsEnabledProvider = FutureProvider<bool>((ref) async {
  return ref.watch(forewarningRepositoryProvider).tipsEnabled();
});

final forewarningMomentsCatalogProvider =
    FutureProvider<List<ForewarningMomentDefinition>>((ref) async {
  return ForewarningMoments.load();
});

final forewarningComplianceProvider = Provider((ref) {
  return ref.watch(complianceFlagsProvider);
});
