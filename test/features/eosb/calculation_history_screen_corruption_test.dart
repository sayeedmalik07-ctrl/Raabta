import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/persistence/local_data_isolation_keys.dart';
import 'package:raabta/core/persistence/uid_scoped_preferences.dart';
import 'package:raabta/features/eosb/data/eosb_repository.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/domain/services/eosb_calculation_service.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/screens/calculation_history_screen.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_history_corrupt_banner.dart';
import 'package:raabta/features/eosb/presentation/widgets/shared/eosb_empty_state.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/providers/auth_scoped_storage_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _uid = 'calc-hist-ui-uid';

String _scopedKey(String base) => UidScopedPreferences.scopedKey(_uid, base);

CalculationHistoryEntry _sampleEntry({String id = 'hist-1'}) {
  const calc = EosbCalculationService();
  final input = const EosbEmployeeInput(basicSalary: 5000);
  final result = calc.calculate(input);
  return CalculationHistoryEntry(
    id: id,
    input: input,
    result: result,
    savedAt: DateTime(2025, 3, 1),
    label: '5,000',
  );
}

Map<String, dynamic> _entryJson(CalculationHistoryEntry e) => {
  'id': e.id,
  'input': e.input.toJson(),
  'result': e.result.toJson(),
  'savedAt': e.savedAt.toIso8601String(),
  'label': e.label,
  'salaryDetailsStored': e.salaryDetailsStored,
};

Widget _harness({
  required List<Override> overrides,
  TextDirection textDirection = TextDirection.ltr,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: const CalculationHistoryScreen(),
      builder: (context, child) =>
          Directionality(textDirection: textDirection, child: child!),
    ),
  );
}

List<Override> _baseOverrides(EosbRepository repo) => [
  eosbLocaleProvider.overrideWith((ref) async => 'English'),
  currentAuthUidProvider.overrideWith((ref) => _uid),
  eosbRepositoryProvider.overrideWith((ref) async => repo),
];

Future<void> _pumpHistoryScreen(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  setUp(() {
    AppColors.applyBrightness(false);
    SharedPreferences.setMockInitialValues({});
  });

  group('CalculationHistoryScreen corruption UI', () {
    testWidgets('genuine empty shows standard empty copy', (tester) async {
      final repo = EosbRepository(await SharedPreferences.getInstance());
      await tester.pumpWidget(_harness(overrides: _baseOverrides(repo)));
      await _pumpHistoryScreen(tester);

      expect(find.byType(EosbEmptyState), findsOneWidget);
      expect(
        find.text(EosbStrings.t('eosb_empty_history', 'English')),
        findsOneWidget,
      );
      expect(
        find.text(EosbStrings.t('eosb_history_corrupt_empty_title', 'English')),
        findsNothing,
      );
    });

    testWidgets('corrupt with no salvage shows corrupt empty copy', (
      tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _scopedKey(LocalDataIsolationKeys.eosbCalculationHistory),
        jsonEncode([
          'bad',
          {'id': ''},
        ]),
      );
      final repo = EosbRepository(prefs);

      await tester.pumpWidget(_harness(overrides: _baseOverrides(repo)));
      await _pumpHistoryScreen(tester);

      expect(
        find.text(EosbStrings.t('eosb_history_corrupt_empty_title', 'English')),
        findsOneWidget,
      );
      expect(
        find.text(EosbStrings.t('eosb_empty_history', 'English')),
        findsNothing,
      );
    });

    testWidgets('corrupt with salvaged rows shows banner and list', (
      tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      final good = _entryJson(_sampleEntry());
      await prefs.setString(
        _scopedKey(LocalDataIsolationKeys.eosbCalculationHistory),
        jsonEncode([good, 'bad-row']),
      );
      final repo = EosbRepository(prefs);

      await tester.pumpWidget(_harness(overrides: _baseOverrides(repo)));
      await _pumpHistoryScreen(tester);

      expect(find.byType(EosbHistoryCorruptBanner), findsOneWidget);
      expect(find.byType(Dismissible), findsOneWidget);
      expect(
        find.text(EosbStrings.t('eosb_history_corrupt_banner', 'English')),
        findsOneWidget,
      );
    });

    testWidgets('provider error shows load error not empty history', (
      tester,
    ) async {
      final repo = EosbRepository(await SharedPreferences.getInstance());
      await tester.pumpWidget(
        _harness(
          overrides: [
            ..._baseOverrides(repo),
            eosbHistoryProvider.overrideWith(
              (ref) async => throw StateError('load failed'),
            ),
          ],
        ),
      );
      await _pumpHistoryScreen(tester);

      expect(
        find.text(EosbStrings.t('eosb_history_load_error', 'English')),
        findsOneWidget,
      );
      expect(
        find.text(EosbStrings.t('eosb_empty_history', 'English')),
        findsNothing,
      );
    });

    testWidgets('blocked dismiss keeps row and shows delete snack', (
      tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      final good = _entryJson(_sampleEntry(id: 'keep-me'));
      await prefs.setString(
        _scopedKey(LocalDataIsolationKeys.eosbCalculationHistory),
        jsonEncode([
          good,
          {'id': 'bad', 'input': 1},
        ]),
      );
      final repo = EosbRepository(prefs);

      await tester.pumpWidget(_harness(overrides: _baseOverrides(repo)));
      await _pumpHistoryScreen(tester);

      final dismissible = find.byType(Dismissible);
      expect(dismissible, findsOneWidget);

      await tester.drag(dismissible, const Offset(-400, 0));
      await _pumpHistoryScreen(tester);

      expect(find.byKey(const ValueKey('keep-me')), findsOneWidget);
      expect(
        find.text(
          EosbStrings.t('eosb_history_corrupt_delete_blocked', 'English'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('blocked icon delete keeps row and shows snack', (
      tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      final good = _entryJson(_sampleEntry(id: 'keep-me-2'));
      await prefs.setString(
        _scopedKey(LocalDataIsolationKeys.eosbCalculationHistory),
        jsonEncode([
          good,
          {
            'id': 'bad',
            'days': [null],
          },
        ]),
      );
      final repo = EosbRepository(prefs);

      await tester.pumpWidget(_harness(overrides: _baseOverrides(repo)));
      await _pumpHistoryScreen(tester);

      await tester.tap(
        find.descendant(
          of: find.byType(IconButton),
          matching: find.byIcon(Icons.delete_outline),
        ),
      );
      await _pumpHistoryScreen(tester);

      expect(find.byKey(const ValueKey('keep-me-2')), findsOneWidget);
      expect(
        find.text(
          EosbStrings.t('eosb_history_corrupt_delete_blocked', 'English'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Arabic RTL shows corrupt banner', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final good = _entryJson(_sampleEntry());
      await prefs.setString(
        _scopedKey(LocalDataIsolationKeys.eosbCalculationHistory),
        jsonEncode([good, 'bad']),
      );
      final repo = EosbRepository(prefs);

      await tester.pumpWidget(
        _harness(
          overrides: [
            eosbLocaleProvider.overrideWith((ref) async => 'Arabic'),
            currentAuthUidProvider.overrideWith((ref) => _uid),
            eosbRepositoryProvider.overrideWith((ref) async => repo),
          ],
          textDirection: TextDirection.rtl,
        ),
      );
      await _pumpHistoryScreen(tester);

      expect(
        find.text(EosbStrings.t('eosb_history_corrupt_banner', 'Arabic')),
        findsOneWidget,
      );
    });
  });
}
