import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/scam_shield/personal_context/personal_context_hive_store.dart';
import 'package:scam_shield_core/features/scam_shield/domain/evidence/personal_context_models.dart';

final personalContextSnapshotProvider =
    FutureProvider<PersonalContextSnapshot>((ref) async {
  return PersonalContextHiveStore.loadSnapshot();
});
