import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/scam_shield/checkup/scam_checkup_catalog.dart';
import 'package:raabta/features/scam_shield/checkup/scam_checkup_models.dart';
import 'package:raabta/features/scam_shield/checkup/scam_checkup_state_repository.dart';
import 'package:raabta/features/scam_shield/providers/scam_shield_providers.dart';

final scamCheckupRepositoryProvider = Provider<ScamCheckupStateRepository>(
  (ref) => ScamCheckupStateRepository(),
);

final scamCheckupCatalogProvider =
    FutureProvider<List<ScamCheckupItem>>((ref) async {
  return ScamCheckupCatalog.load();
});

final scamCheckupStateProvider = FutureProvider<ScamCheckupState>((ref) async {
  return ref.watch(scamCheckupRepositoryProvider).load();
});

final scamCheckupVisibleProvider =
    FutureProvider<List<ScamCheckupItem>>((ref) async {
  final all = await ref.watch(scamCheckupCatalogProvider.future);
  return ScamCheckupCatalog.visibleItems(all);
});

final scamCheckupProgressProvider = FutureProvider<ScamCheckupProgress>((ref) async {
  final visible = await ref.watch(scamCheckupVisibleProvider.future);
  final state = await ref.watch(scamCheckupStateProvider.future);
  final proactive = await ref.watch(scamProactiveProtectionStatusProvider.future);
  return ScamCheckupCatalog.progress(
    visible: visible,
    checkedIds: state.checkedIds,
    proactive: proactive,
  );
});
