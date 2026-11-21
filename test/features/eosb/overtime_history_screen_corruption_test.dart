import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/persistence/local_data_isolation_keys.dart';
import 'package:raabta/core/persistence/uid_scoped_preferences.dart';
import 'package:raabta/features/eosb/data/eosb_repository.dart';
import 'package:raabta/features/eosb/domain/models/eosb_history_load_outcome.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/domain/services/eosb_calculation_service.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/screens/overtime_history_screen.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_history_corrupt_banner.dart';
import 'package:raabta/features/eosb/presentation/widgets/shared/eosb_empty_state.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/eosb/providers/overtime_truth_providers.dart';
import 'package:raabta/providers/auth_scoped_storage_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _uid = 'ot-hist-ui-uid';

String _scopedKey(String base) => UidScopedPreferences.scopedKey(_uid, base);

OvertimeMonthlyRecord _record({String id = '2025_1'}) {
  return OvertimeMonthlyRecord(
    id: id,
    year: 2025,
    month: 1,
    profile: const OvertimeEmployeeProfile(
      companyName: 'Co',
      basicSalary: 1000,
    ),
  );
}

class _TestEosbNotifier extends EosbNotifier {
  _TestEosbNotifier(Ref ref)
    : super(const EosbCalculationService(), null, ref) {
    state = const EosbState();
  }
}

OvertimeTruthNotifier _seededNotifier(Ref ref, OvertimeTruthState seed) {
  final notifier = OvertimeTruthNotifier(ref.read(eosbProvider.notifier), ref);
  notifier.state = seed;
  return notifier;
}

Future<EosbRepository> _repoCorruptWithSalvaged(
  OvertimeMonthlyRecord record,
) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _scopedKey(LocalDataIsolationKeys.eosbOvertimeHistory),
    jsonEncode([
      record.toJson(),
      {
        'id': 'bad',
        'days': [null],
      },
    ]),
  );
  final repo = EosbRepository(prefs);
  await repo.setSalaryConsent(true, uid: _uid);
  return repo;
}

Future<void> _pumpHistoryScreen(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _pumpUntilHydrated(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty &&
        (find.byType(EosbHistoryCorruptBanner).evaluate().isNotEmpty ||
            find.byIcon(Icons.star_border).evaluate().isNotEmpty)) {
      return;
    }
  }
}

Widget _harness({
  required List<Override> overrides,
  TextDirection textDirection = TextDirection.ltr,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: const OvertimeHistoryScreen(),
      builder: (context, child) =>
          Directionality(textDirection: textDirection, child: child!),
    ),
  );
}

void main() {
  setUp(() {
    AppColors.applyBrightness(false);
    SharedPreferences.setMockInitialValues({});
  });

  group('OvertimeHistoryScreen corruption UI', () {
    testWidgets('genuine empty shows standard OT empty copy', (tester) async {
      final seed = OvertimeTruthState(
        record: OvertimeMonthlyRecord.emptyForMonth(2025, 6),
        history: const [],
        historyLoadStatus: EosbHistoryStorageStatus.absent,
        isHydrating: false,
      );

      await tester.pumpWidget(
        _harness(
          overrides: [
            eosbLocaleProvider.overrideWith((ref) async => 'English'),
            eosbProvider.overrideWith((ref) => _TestEosbNotifier(ref)),
            overtimeTruthProvider.overrideWith(
              (ref) => _seededNotifier(ref, seed),
            ),
          ],
        ),
      );
      await _pumpHistoryScreen(tester);

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(
        find.text(EosbStrings.t('ot_history_empty', 'English')),
        findsOneWidget,
      );
    });

    testWidgets('corrupt with no salvage shows corrupt empty copy', (
      tester,
    ) async {
      final seed = OvertimeTruthState(
        record: OvertimeMonthlyRecord.emptyForMonth(2025, 6),
        history: const [],
        historyStorageCorrupt: true,
        historyLoadStatus: EosbHistoryStorageStatus.corrupt,
        isHydrating: false,
      );

      await tester.pumpWidget(
        _harness(
          overrides: [
            eosbLocaleProvider.overrideWith((ref) async => 'English'),
            eosbProvider.overrideWith((ref) => _TestEosbNotifier(ref)),
            overtimeTruthProvider.overrideWith(
              (ref) => _seededNotifier(ref, seed),
            ),
          ],
        ),
      );
      await _pumpHistoryScreen(tester);

      expect(
        find.text(EosbStrings.t('ot_history_corrupt_empty_title', 'English')),
        findsOneWidget,
      );
      expect(
        find.text(EosbStrings.t('ot_history_empty', 'English')),
        findsNothing,
      );
    });

    testWidgets('corrupt with salvaged months shows banner and tile', (
      tester,
    ) async {
      final record = _record();
      final seed = OvertimeTruthState(
        record: record,
        history: [record],
        historyStorageCorrupt: true,
        historyLoadStatus: EosbHistoryStorageStatus.corrupt,
        isHydrating: false,
      );

      await tester.pumpWidget(
        _harness(
          overrides: [
            eosbLocaleProvider.overrideWith((ref) async => 'English'),
            eosbProvider.overrideWith((ref) => _TestEosbNotifier(ref)),
            overtimeTruthProvider.overrideWith(
              (ref) => _seededNotifier(ref, seed),
            ),
          ],
        ),
      );
      await _pumpHistoryScreen(tester);

      expect(find.byType(EosbHistoryCorruptBanner), findsOneWidget);
      expect(find.text(record.label), findsOneWidget);
    });

    testWidgets('hydrating does not show false empty state', (tester) async {
      final seed = OvertimeTruthState(
        record: OvertimeMonthlyRecord.emptyForMonth(2025, 6),
        history: const [],
        isHydrating: true,
      );

      await tester.pumpWidget(
        _harness(
          overrides: [
            eosbLocaleProvider.overrideWith((ref) async => 'English'),
            eosbProvider.overrideWith((ref) => _TestEosbNotifier(ref)),
            overtimeTruthProvider.overrideWith(
              (ref) => _seededNotifier(ref, seed),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(EosbEmptyState), findsNothing);
    });

    testWidgets('blocked duplicate shows corrupt write snack', (tester) async {
      final record = _record(id: 'salvaged');
      final repo = await _repoCorruptWithSalvaged(record);

      await tester.pumpWidget(
        _harness(
          overrides: [
            eosbLocaleProvider.overrideWith((ref) async => 'English'),
            currentAuthUidProvider.overrideWith((ref) => _uid),
            eosbRepositoryProvider.overrideWith((ref) async => repo),
            eosbProvider.overrideWith((ref) => _TestEosbNotifier(ref)),
          ],
        ),
      );
      await _pumpHistoryScreen(tester);
      await _pumpUntilHydrated(tester);

      await tester.tap(find.byIcon(Icons.more_vert));
      await _pumpHistoryScreen(tester);
      await tester.tap(find.text(EosbStrings.t('ot_duplicate', 'English')));
      await _pumpHistoryScreen(tester);

      expect(
        find.text(
          EosbStrings.t('eosb_history_corrupt_write_blocked', 'English'),
        ),
        findsOneWidget,
      );
      expect(find.text(record.label), findsOneWidget);
    });

    testWidgets('blocked delete shows corrupt write snack', (tester) async {
      final record = _record(id: 'salvaged-del');
      final repo = await _repoCorruptWithSalvaged(record);

      await tester.pumpWidget(
        _harness(
          overrides: [
            eosbLocaleProvider.overrideWith((ref) async => 'English'),
            currentAuthUidProvider.overrideWith((ref) => _uid),
            eosbRepositoryProvider.overrideWith((ref) async => repo),
            eosbProvider.overrideWith((ref) => _TestEosbNotifier(ref)),
          ],
        ),
      );
      await _pumpHistoryScreen(tester);
      await _pumpUntilHydrated(tester);

      await tester.tap(find.byIcon(Icons.more_vert));
      await _pumpHistoryScreen(tester);
      await tester.tap(find.text(EosbStrings.t('ot_delete', 'English')));
      await _pumpHistoryScreen(tester);

      expect(
        find.text(
          EosbStrings.t('eosb_history_corrupt_write_blocked', 'English'),
        ),
        findsOneWidget,
      );
      expect(find.text(record.label), findsOneWidget);
    });

    testWidgets('blocked favorite shows corrupt write snack', (tester) async {
      final record = _record(id: 'salvaged-fav');
      final repo = await _repoCorruptWithSalvaged(record);

      await tester.pumpWidget(
        _harness(
          overrides: [
            eosbLocaleProvider.overrideWith((ref) async => 'English'),
            currentAuthUidProvider.overrideWith((ref) => _uid),
            eosbRepositoryProvider.overrideWith((ref) async => repo),
            eosbProvider.overrideWith((ref) => _TestEosbNotifier(ref)),
          ],
        ),
      );
      await _pumpHistoryScreen(tester);
      await _pumpUntilHydrated(tester);

      await tester.tap(find.byIcon(Icons.star_border));
      await _pumpHistoryScreen(tester);

      expect(
        find.text(
          EosbStrings.t('eosb_history_corrupt_write_blocked', 'English'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Urdu RTL shows corrupt empty title', (tester) async {
      final seed = OvertimeTruthState(
        record: OvertimeMonthlyRecord.emptyForMonth(2025, 6),
        history: const [],
        historyStorageCorrupt: true,
        historyLoadStatus: EosbHistoryStorageStatus.corrupt,
        isHydrating: false,
      );

      await tester.pumpWidget(
        _harness(
          overrides: [
            eosbLocaleProvider.overrideWith((ref) async => 'Urdu'),
            eosbProvider.overrideWith((ref) => _TestEosbNotifier(ref)),
            overtimeTruthProvider.overrideWith(
              (ref) => _seededNotifier(ref, seed),
            ),
          ],
          textDirection: TextDirection.rtl,
        ),
      );
      await _pumpHistoryScreen(tester);

      expect(
        find.text(EosbStrings.t('ot_history_corrupt_empty_title', 'Urdu')),
        findsOneWidget,
      );
    });
  });
}
