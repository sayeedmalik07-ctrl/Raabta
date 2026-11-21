import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/eosb/domain/services/eosb_salary_claude_consent.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/providers/auth_scoped_storage_providers.dart';

/// UID-scoped persisted salary consent for non-Claude salary-bearing actions.
Future<bool> readEosbSalaryStorageConsent(WidgetRef ref) async {
  final uid = ref.read(currentAuthUidProvider);
  final repoAsync = ref.read(eosbRepositoryProvider);
  final repo =
      repoAsync.valueOrNull ?? await ref.read(eosbRepositoryProvider.future);
  if (repo == null) return false;
  return repo.salaryConsent(uid: uid);
}

void requireEosbSalaryStorageConsentSync(WidgetRef ref) {
  final repo = ref.read(eosbRepositoryProvider).valueOrNull;
  if (repo == null) {
    throw const EosbSalaryStorageConsentRequired();
  }
  final uid = ref.read(currentAuthUidProvider);
  if (!repo.salaryConsent(uid: uid)) {
    throw const EosbSalaryStorageConsentRequired();
  }
}

Future<void> requireEosbSalaryStorageConsent(WidgetRef ref) async {
  final allowed = await readEosbSalaryStorageConsent(ref);
  if (!allowed) {
    throw const EosbSalaryStorageConsentRequired();
  }
}
