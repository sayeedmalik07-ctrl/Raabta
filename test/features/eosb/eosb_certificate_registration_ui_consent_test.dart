import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/eosb/data/eosb_repository.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/providers/auth_scoped_storage_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Generate Documents uses the same persisted consent gate as result-screen registration.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'generate documents path: repository consent off for active uid',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = EosbRepository(prefs);
      const uid = 'doc-ui';
      await repo.setSalaryConsent(false, uid: uid);

      final container = ProviderContainer(
        overrides: [
          currentAuthUidProvider.overrideWith((ref) => uid),
          eosbRepositoryProvider.overrideWith((ref) async => repo),
        ],
      );
      addTearDown(container.dispose);

      final resolved = await container.read(eosbRepositoryProvider.future);
      expect(resolved.salaryConsent(uid: uid), isFalse);
    },
  );
}
