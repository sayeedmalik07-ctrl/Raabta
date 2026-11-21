import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/eosb/data/eosb_repository.dart';
import 'package:raabta/features/eosb/domain/models/eosb_contract_analysis.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/domain/services/eosb_salary_claude_consent.dart';
import 'package:raabta/features/eosb/domain/services/overtime_rounding_pattern_analyzer.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/domain/services/eosb_calculation_service.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/eosb/providers/eosb_salary_consent_revocation.dart';
import 'package:raabta/features/eosb/providers/overtime_rounding_providers.dart';
import 'package:raabta/features/eosb/providers/overtime_truth_providers.dart';
import 'package:raabta/features/eosb/services/eosb_contract_analysis_service.dart';
import 'package:raabta/features/eosb/services/eosb_document_import_service.dart';
import 'package:raabta/features/eosb/services/overtime_ai_service.dart';
import 'package:raabta/providers/auth_scoped_storage_providers.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _eosbTestRefProvider = Provider<Ref>((ref) => ref);

Ref _refFrom(ProviderContainer container) =>
    container.read(_eosbTestRefProvider);

class _NoOpClaude extends ClaudeAIService {
  int sendCount = 0;

  @override
  Future<String> sendMessage(
    String message, {
    String language = 'English',
    String requestType = 'chat',
    String languageCode = 'en',
    List<Map<String, String>> conversationHistory = const [],
    String? userId,
    Map<String, dynamic> userProfile = const {},
  }) async {
    sendCount++;
    return '{"confidence":0.5,"warnings":[]}';
  }
}

class _DelayedClaude extends ClaudeAIService {
  _DelayedClaude(this.onAwaitingResponse);

  final void Function() onAwaitingResponse;

  @override
  Future<String> sendMessage(
    String message, {
    String language = 'English',
    String requestType = 'chat',
    String languageCode = 'en',
    List<Map<String, String>> conversationHistory = const [],
    String? userId,
    Map<String, dynamic> userProfile = const {},
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 5));
    onAwaitingResponse();
    return '{"confidence":0.5}';
  }
}

EosbSalaryClaudeConsentGuard _guard(bool Function() read) =>
    EosbSalaryClaudeConsentGuard(read);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('salary Claude consent gates', () {
    test('contract analysis throws when persisted consent is off', () {
      final claude = _NoOpClaude();
      final service = EosbContractAnalysisService(claude, _guard(() => false));

      expect(
        () => service.analyzeDocumentText(
          documentText: 'x' * 30,
          documentKind: 'Contract',
          language: 'English',
        ),
        throwsA(isA<EosbSalaryClaudeConsentRequired>()),
      );
      expect(claude.sendCount, 0);
    });

    test(
      'contract analysis calls Claude when persisted consent is on',
      () async {
        final claude = _NoOpClaude();
        final service = EosbContractAnalysisService(claude, _guard(() => true));

        await service.analyzeDocumentText(
          documentText: 'x' * 30,
          documentKind: 'Contract',
          language: 'English',
        );

        expect(claude.sendCount, 1);
      },
    );

    test('overtime import throws when persisted consent is off', () {
      final claude = _NoOpClaude();
      final service = OvertimeAiService(claude, _guard(() => false));

      expect(
        service.extractFromDocument(
          documentText: 'x' * 24,
          documentKind: 'Salary Slip',
          language: 'English',
        ),
        throwsA(isA<EosbSalaryClaudeConsentRequired>()),
      );
      expect(claude.sendCount, 0);
    });

    test(
      'rounding explain calls Claude when persisted consent is on',
      () async {
        final claude = _NoOpClaude();
        final service = OvertimeAiService(claude, _guard(() => true));
        const pattern = OvertimeRoundingPatternResult(
          dualShiftCount: 3,
          minRequiredShifts: 2,
          clockInEmployerFavorCount: 0,
          clockOutEmployerFavorCount: 0,
          avgClockInLossMinutes: 5,
          avgClockOutLossMinutes: 0,
          avgTotalMinutesLostPerShift: 5,
          estimatedQarImpact: 100,
          direction: OvertimeRoundingDirection.employerFavor,
          currency: 'QAR',
        );

        final text = await service.explainRoundingPattern(
          pattern: pattern,
          locale: 'English',
        );

        expect(claude.sendCount, 1);
        expect(text, isNotEmpty);
      },
    );

    test('rounding explain throws when persisted consent is off', () {
      final service = OvertimeAiService(_NoOpClaude(), _guard(() => false));
      const pattern = OvertimeRoundingPatternResult(
        dualShiftCount: 3,
        minRequiredShifts: 2,
        clockInEmployerFavorCount: 0,
        clockOutEmployerFavorCount: 0,
        avgClockInLossMinutes: 5,
        avgClockOutLossMinutes: 0,
        avgTotalMinutesLostPerShift: 5,
        estimatedQarImpact: 100,
        direction: OvertimeRoundingDirection.employerFavor,
        currency: 'QAR',
      );

      expect(
        service.explainRoundingPattern(pattern: pattern, locale: 'English'),
        throwsA(isA<EosbSalaryClaudeConsentRequired>()),
      );
    });

    test('discards response when consent revoked before post-check', () async {
      var consent = true;
      final service = EosbContractAnalysisService(
        _DelayedClaude(() => consent = false),
        _guard(() => consent),
      );

      await expectLater(
        service.analyzeDocumentText(
          documentText: 'x' * 30,
          documentKind: 'Contract',
          language: 'English',
        ),
        throwsA(isA<EosbSalaryClaudeConsentRequired>()),
      );
    });
  });

  group('EosbDocumentImportService consent propagation', () {
    test(
      'importFromText uses analysis guard for acceptable documents',
      () async {
        final claude = _NoOpClaude();
        final import = EosbDocumentImportService(
          EosbContractAnalysisService(claude, _guard(() => true)),
        );

        final words = List.generate(30, (i) => 'salary').join(' ');
        final result = await import.importFromText(
          ocrText: words,
          documentKind: 'Employment Contract',
          language: 'English',
        );

        expect(claude.sendCount, 1);
        expect(result.warnings, isEmpty);
      },
    );
  });

  group('provider salary consent revocation', () {
    test('EosbNotifier strips salary from state', () {
      final container = ProviderContainer(
        overrides: [currentAuthUidProvider.overrideWith((ref) => null)],
      );
      addTearDown(container.dispose);
      final ref = _refFrom(container);
      final notifier = EosbNotifier(const EosbCalculationService(), null, ref);
      notifier.updateInput(
        const EosbEmployeeInput(basicSalary: 5000, companyName: 'Co'),
      );
      notifier.applySalaryConsentRevocation();
      expect(notifier.state.input.basicSalary, 0);
      expect(notifier.state.input.companyName, isEmpty);
    });

    test('OvertimeTruthNotifier strips salary from state', () {
      final container = ProviderContainer(
        overrides: [currentAuthUidProvider.overrideWith((ref) => null)],
      );
      addTearDown(container.dispose);
      final ref = _refFrom(container);
      final eosb = EosbNotifier(const EosbCalculationService(), null, ref);
      final ot = OvertimeTruthNotifier(eosb, ref);
      ot.updateRecord(
        OvertimeMonthlyRecord(
          id: '1',
          year: 2025,
          month: 1,
          profile: const OvertimeEmployeeProfile(
            companyName: 'Co',
            basicSalary: 4000,
          ),
        ),
      );
      ot.applySalaryConsentRevocation();
      expect(ot.state.record.profile.basicSalary, 0);
      expect(ot.state.record.profile.companyName, isEmpty);
      expect(ot.state.result, isNull);
    });

    test(
      'applyEosbSalaryConsentRevocation (Ref) orchestrates full cleanup',
      () {
        final container = ProviderContainer(
          overrides: [
            currentAuthUidProvider.overrideWith((ref) => null),
            eosbProvider.overrideWith((ref) {
              final calc = ref.watch(eosbCalculationServiceProvider);
              return EosbNotifier(calc, null, ref);
            }),
            overtimeTruthProvider.overrideWith((ref) {
              final eosb = ref.watch(eosbProvider.notifier);
              return OvertimeTruthNotifier(eosb, ref);
            }),
          ],
        );
        addTearDown(container.dispose);

        container
            .read(eosbProvider.notifier)
            .updateInput(const EosbEmployeeInput(basicSalary: 9000));
        container.read(eosbContractAnalysisProvider.notifier).state =
            const EosbContractAnalysis(basicSalary: 5000);
        container.read(overtimeRoundingAiExplanationProvider.notifier).state =
            'Claude said QAR 100';

        final claude = container.read(claudeAIServiceProvider);
        final eosbKey = claude.generateCacheKeyForTest(
          EosbSalarySensitiveClaudeRequestTypes.eosbContractAnalysis,
          'p',
          'English',
        );
        claude.seedResponseCacheForTest(
          eosbKey,
          'r',
          requestType:
              EosbSalarySensitiveClaudeRequestTypes.eosbContractAnalysis,
        );

        applyEosbSalaryConsentRevocation(_refFrom(container));

        expect(container.read(eosbProvider).input.basicSalary, 0);
        expect(container.read(eosbContractAnalysisProvider), isNull);
        expect(container.read(overtimeRoundingAiExplanationProvider), isNull);
        expect(claude.isResponseCachedForTest(eosbKey), isFalse);
      },
    );

    testWidgets(
      'applyEosbSalaryConsentRevocationWithWidgetRef orchestrates full cleanup',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            currentAuthUidProvider.overrideWith((ref) => null),
            eosbProvider.overrideWith((ref) {
              final calc = ref.watch(eosbCalculationServiceProvider);
              return EosbNotifier(calc, null, ref);
            }),
            overtimeTruthProvider.overrideWith((ref) {
              final eosb = ref.watch(eosbProvider.notifier);
              return OvertimeTruthNotifier(eosb, ref);
            }),
          ],
        );
        addTearDown(container.dispose);

        container
            .read(eosbProvider.notifier)
            .updateInput(const EosbEmployeeInput(basicSalary: 9000));
        container.read(eosbContractAnalysisProvider.notifier).state =
            const EosbContractAnalysis(basicSalary: 5000);
        container.read(overtimeRoundingAiExplanationProvider.notifier).state =
            'Claude said QAR 100';

        final claude = container.read(claudeAIServiceProvider);
        final eosbKey = claude.generateCacheKeyForTest(
          EosbSalarySensitiveClaudeRequestTypes.eosbContractAnalysis,
          'p',
          'English',
        );
        claude.seedResponseCacheForTest(
          eosbKey,
          'r',
          requestType:
              EosbSalarySensitiveClaudeRequestTypes.eosbContractAnalysis,
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Consumer(
                  builder: (context, ref, _) {
                    return ElevatedButton(
                      onPressed: () =>
                          applyEosbSalaryConsentRevocationWithWidgetRef(ref),
                      child: const Text('REVOKE'),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('REVOKE'));
        await tester.pump();

        expect(container.read(eosbProvider).input.basicSalary, 0);
        expect(container.read(eosbContractAnalysisProvider), isNull);
        expect(container.read(overtimeRoundingAiExplanationProvider), isNull);
        expect(claude.isResponseCachedForTest(eosbKey), isFalse);
      },
    );

    test('guard provider reads repository salaryConsent', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = EosbRepository(prefs);
      await repo.setSalaryConsent(true, uid: 'uid');

      final container = ProviderContainer(
        overrides: [
          eosbRepositoryProvider.overrideWith((ref) async => repo),
          currentAuthUidProvider.overrideWith((ref) => 'uid'),
        ],
      );
      addTearDown(container.dispose);

      await container.read(eosbRepositoryProvider.future);
      final guard = container.read(eosbSalaryClaudeConsentGuardProvider);
      expect(() => guard.requireConsent(), returnsNormally);

      await repo.setSalaryConsent(false, uid: 'uid');
      container.invalidate(eosbSalaryConsentProvider);
      container.invalidate(eosbSalaryClaudeConsentGuardProvider);
      final guardAfter = container.read(eosbSalaryClaudeConsentGuardProvider);
      expect(
        () => guardAfter.requireConsent(),
        throwsA(isA<EosbSalaryClaudeConsentRequired>()),
      );
    });
  });

  test('consent UX string is localized', () {
    final message = EosbStrings.t(
      'eosb_salary_claude_consent_required',
      'English',
    );
    expect(message, contains('Store salary data securely'));
    expect(message, contains('Privacy'));
  });

  group('ClaudeAIService targeted cache clear', () {
    test('clearCacheForRequestTypes removes only listed types', () {
      final claude = ClaudeAIService();
      final eosbKey = claude.generateCacheKeyForTest(
        EosbSalarySensitiveClaudeRequestTypes.eosbContractAnalysis,
        'prompt',
        'English',
      );
      final chatKey = claude.generateCacheKeyForTest('chat', 'hi', 'English');

      claude.seedResponseCacheForTest(
        eosbKey,
        'eosb-reply',
        requestType: EosbSalarySensitiveClaudeRequestTypes.eosbContractAnalysis,
      );
      claude.seedResponseCacheForTest(
        chatKey,
        'chat-reply',
        requestType: 'chat',
      );

      expect(claude.isResponseCachedForTest(eosbKey), isTrue);
      expect(claude.isResponseCachedForTest(chatKey), isTrue);

      claude.clearCacheForRequestTypes(
        EosbSalarySensitiveClaudeRequestTypes.all,
      );

      expect(claude.isResponseCachedForTest(eosbKey), isFalse);
      expect(claude.isResponseCachedForTest(chatKey), isTrue);
    });

    test('legacy unindexed salary cache cleared without backfill', () {
      final claude = ClaudeAIService();
      final eosbKey = claude.generateCacheKeyForTest(
        EosbSalarySensitiveClaudeRequestTypes.eosbOvertimeImport,
        'legacy',
        'English',
      );
      final chatKey = claude.generateCacheKeyForTest('chat', 'hi', 'English');

      claude.seedLegacyUnindexedCacheForTest(
        eosbKey,
        'legacy-reply',
        EosbSalarySensitiveClaudeRequestTypes.eosbOvertimeImport,
      );
      claude.seedLegacyUnindexedCacheForTest(chatKey, 'chat-reply', 'chat');

      expect(claude.isResponseCachedForTest(eosbKey), isTrue);
      expect(claude.isResponseCachedForTest(chatKey), isTrue);

      claude.clearCacheForRequestTypes({
        EosbSalarySensitiveClaudeRequestTypes.eosbOvertimeImport,
      });

      expect(claude.isResponseCachedForTest(eosbKey), isFalse);
      expect(claude.isResponseCachedForTest(chatKey), isTrue);
    });

    test(
      'post-check consent failure evicts the response cache entry',
      () async {
        var consent = true;
        final claude = _CachingClaude(onBeforeReturn: () => consent = false);
        final guard = EosbSalaryClaudeConsentGuard(() => consent);
        const message = 'payroll extraction payload';
        const requestType =
            EosbSalarySensitiveClaudeRequestTypes.eosbOvertimeImport;

        final cacheKey = claude.generateCacheKeyForTest(
          requestType,
          message,
          'English',
        );

        await expectLater(
          guard.sendClaudeMessage(
            claude,
            message: message,
            language: 'English',
            requestType: requestType,
          ),
          throwsA(isA<EosbSalaryClaudeConsentRequired>()),
        );

        expect(claude.isResponseCachedForTest(cacheKey), isFalse);
      },
    );

    test('sendMessage registers cache entry for targeted clear', () async {
      final claude = _RegisteringClaude();
      final guard = _guard(() => true);
      final service = OvertimeAiService(claude, guard);

      await service.extractFromDocument(
        documentText: 'x' * 24,
        documentKind: 'Salary Slip',
        language: 'English',
      );

      expect(
        claude.lastRequestType,
        EosbSalarySensitiveClaudeRequestTypes.eosbOvertimeImport,
      );
      final key = claude.lastCacheKey;
      expect(key, isNotNull);
      expect(claude.isResponseCachedForTest(key!), isTrue);

      claude.clearCacheForRequestTypes(
        EosbSalarySensitiveClaudeRequestTypes.all,
      );
      expect(claude.isResponseCachedForTest(key), isFalse);
    });
  });
}

class _CachingClaude extends ClaudeAIService {
  _CachingClaude({required this.onBeforeReturn});

  final void Function() onBeforeReturn;

  @override
  Future<String> sendMessage(
    String message, {
    String language = 'English',
    String requestType = 'chat',
    String languageCode = 'en',
    List<Map<String, String>> conversationHistory = const [],
    String? userId,
    Map<String, dynamic> userProfile = const {},
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 2));
    onBeforeReturn();
    final key = generateCacheKeyForTest(requestType, message, language);
    seedResponseCacheForTest(
      key,
      '{"basicSalary":1}',
      requestType: requestType,
    );
    return '{"basicSalary":1}';
  }
}

class _RegisteringClaude extends ClaudeAIService {
  String? lastRequestType;
  String? lastCacheKey;

  @override
  Future<String> sendMessage(
    String message, {
    String language = 'English',
    String requestType = 'chat',
    String languageCode = 'en',
    List<Map<String, String>> conversationHistory = const [],
    String? userId,
    Map<String, dynamic> userProfile = const {},
  }) async {
    lastRequestType = requestType;
    final key = generateCacheKeyForTest(requestType, message, language);
    lastCacheKey = key;
    seedResponseCacheForTest(
      key,
      '{"basicSalary":1,"overtimeEntries":[]}',
      requestType: requestType,
    );
    return '{"basicSalary":1,"overtimeEntries":[]}';
  }
}
