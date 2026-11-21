import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/persistence/local_data_isolation_keys.dart';
import 'package:raabta/core/persistence/uid_scoped_preferences.dart';
import 'package:raabta/features/eosb/data/eosb_repository.dart';
import 'package:raabta/services/drafts/draft_box_keys.dart';
import 'package:raabta/services/drafts/draft_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('DraftService EOSB employee salary consent', () {
    const uidA = 'emp-draft-a';
    const uidB = 'emp-draft-b';

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await DraftService.resetForTests();
      DraftService.hivePathOverride = 'test_hive_eosb_employee_drafts';
      DraftService.userIdResolver = () => uidA;
      await DraftService.instance.init();
    });

    tearDown(() async {
      DraftService.userIdResolver = null;
      await DraftService.resetForTests();
    });

    test('does not persist salary fields when consent is false', () async {
      final prefs = await SharedPreferences.getInstance();
      await UidScopedPreferences.setBool(
        prefs,
        LocalDataIsolationKeys.eosbSalaryConsent,
        false,
        uid: uidA,
      );

      await DraftService.instance.saveDraft(DraftBoxKeys.eosbEmployeeInfo, {
        'companyName': 'Employer',
        'basicSalary': '4000',
        'contractType': 'unlimited',
      });

      final draft = await DraftService.instance.getDraft(
        DraftBoxKeys.eosbEmployeeInfo,
      );
      expect(draft, isNotNull);
      expect(draft!.data.containsKey('basicSalary'), isFalse);
      expect(draft.data.containsKey('companyName'), isFalse);
      expect(draft.data['contractType'], 'unlimited');
    });

    test('persists full employee draft when consent is true', () async {
      final prefs = await SharedPreferences.getInstance();
      await UidScopedPreferences.setBool(
        prefs,
        LocalDataIsolationKeys.eosbSalaryConsent,
        true,
        uid: uidA,
      );

      await DraftService.instance.saveDraft(DraftBoxKeys.eosbEmployeeInfo, {
        'companyName': 'Employer',
        'basicSalary': '4000',
      });

      final draft = await DraftService.instance.getDraft(
        DraftBoxKeys.eosbEmployeeInfo,
      );
      expect(draft!.data['basicSalary'], '4000');
      expect(draft.data['companyName'], 'Employer');
    });

    test(
      'getDraft strips legacy salary payload when consent is false',
      () async {
        final prefs = await SharedPreferences.getInstance();
        await UidScopedPreferences.setBool(
          prefs,
          LocalDataIsolationKeys.eosbSalaryConsent,
          true,
          uid: uidA,
        );

        await DraftService.instance.saveDraft(DraftBoxKeys.eosbEmployeeInfo, {
          'companyName': 'Legacy Co',
          'basicSalary': '9000',
          'termination': 'employerTermination',
        });

        await UidScopedPreferences.setBool(
          prefs,
          LocalDataIsolationKeys.eosbSalaryConsent,
          false,
          uid: uidA,
        );

        final draft = await DraftService.instance.getDraft(
          DraftBoxKeys.eosbEmployeeInfo,
        );
        expect(draft, isNotNull);
        expect(draft!.data['basicSalary'], isNull);
        expect(draft.data['companyName'], isNull);
        expect(draft.data['termination'], 'employerTermination');
      },
    );

    test(
      'setSalaryConsent false revokes salary in stored employee draft',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final repo = EosbRepository(prefs);

        await repo.setSalaryConsent(true, uid: uidA);
        DraftService.userIdResolver = () => uidA;
        await DraftService.instance.saveDraft(DraftBoxKeys.eosbEmployeeInfo, {
          'basicSalary': '3000',
          'contractType': 'limited',
        });

        await repo.setSalaryConsent(false, uid: uidA);

        final draft = await DraftService.instance.getDraft(
          DraftBoxKeys.eosbEmployeeInfo,
        );
        expect(draft, isNotNull);
        expect(draft!.data.containsKey('basicSalary'), isFalse);
        expect(draft.data['contractType'], 'limited');
      },
    );

    test('employee drafts are UID-isolated', () async {
      final prefs = await SharedPreferences.getInstance();
      await UidScopedPreferences.setBool(
        prefs,
        LocalDataIsolationKeys.eosbSalaryConsent,
        true,
        uid: uidA,
      );
      await UidScopedPreferences.setBool(
        prefs,
        LocalDataIsolationKeys.eosbSalaryConsent,
        false,
        uid: uidB,
      );

      DraftService.userIdResolver = () => uidA;
      await DraftService.instance.saveDraft(DraftBoxKeys.eosbEmployeeInfo, {
        'basicSalary': '1000',
      });

      DraftService.userIdResolver = () => uidB;
      expect(
        await DraftService.instance.getDraft(DraftBoxKeys.eosbEmployeeInfo),
        isNull,
      );
    });
  });
}
