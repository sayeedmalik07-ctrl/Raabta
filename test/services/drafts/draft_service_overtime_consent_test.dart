import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:raabta/core/persistence/local_data_isolation_keys.dart';
import 'package:raabta/core/persistence/uid_scoped_preferences.dart';
import 'package:raabta/services/drafts/draft_box_keys.dart';
import 'package:raabta/services/drafts/draft_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('DraftService overtime salary consent', () {
    const uid = 'draft-user-1';

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await DraftService.resetForTests();
      DraftService.hivePathOverride = 'test_hive_ot_drafts';
      DraftService.userIdResolver = () => uid;
      await DraftService.instance.init();
    });

    tearDown(() async {
      DraftService.userIdResolver = null;
      await DraftService.resetForTests();
    });

    test(
      'does not persist overtime input draft when consent is false',
      () async {
        final prefs = await SharedPreferences.getInstance();
        await UidScopedPreferences.setBool(
          prefs,
          LocalDataIsolationKeys.eosbSalaryConsent,
          false,
          uid: uid,
        );

        await DraftService.instance.saveDraft(DraftBoxKeys.overtimeInput, {
          'company': 'Co',
          'salary': '5000',
        });

        final draft = await DraftService.instance.getDraft(
          DraftBoxKeys.overtimeInput,
        );
        expect(draft, isNull);
      },
    );

    test('persists overtime input draft when consent is true', () async {
      final prefs = await SharedPreferences.getInstance();
      await UidScopedPreferences.setBool(
        prefs,
        LocalDataIsolationKeys.eosbSalaryConsent,
        true,
        uid: uid,
      );

      await DraftService.instance.saveDraft(DraftBoxKeys.overtimeInput, {
        'company': 'Co',
        'salary': '5000',
      });

      final draft = await DraftService.instance.getDraft(
        DraftBoxKeys.overtimeInput,
      );
      expect(draft, isNotNull);
      expect(draft!.data['salary'], '5000');
    });

    test(
      'clearOvertimeSalaryDraftsForUid removes overtime draft keys',
      () async {
        final prefs = await SharedPreferences.getInstance();
        await UidScopedPreferences.setBool(
          prefs,
          LocalDataIsolationKeys.eosbSalaryConsent,
          true,
          uid: uid,
        );

        await DraftService.instance.saveDraft(DraftBoxKeys.overtimeInput, {
          'salary': '1',
        });
        await DraftService.instance.saveDraft(
          DraftBoxKeys.overtimeEmployeeProfile,
          {'basicSalary': '2'},
        );
        await DraftService.instance.saveDraft(
          DraftBoxKeys.overtimeCalendarEntry('2025-03-01'),
          {'hours': '3'},
        );

        await DraftService.instance.clearOvertimeSalaryDraftsForUid(uid);

        expect(
          await DraftService.instance.getDraft(DraftBoxKeys.overtimeInput),
          isNull,
        );
        expect(
          await DraftService.instance.getDraft(
            DraftBoxKeys.overtimeEmployeeProfile,
          ),
          isNull,
        );
        expect(
          await DraftService.instance.getDraft(
            DraftBoxKeys.overtimeCalendarEntry('2025-03-01'),
          ),
          isNull,
        );
      },
    );
  });
}
