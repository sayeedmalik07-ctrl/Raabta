import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:raabta/features/eosb/data/eosb_repository.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/employer_track_record_lookup.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/domain/services/eosb_calculation_service.dart';
import 'package:raabta/features/eosb/domain/services/employer_track_record_service.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/eosb/providers/overtime_truth_providers.dart';
import 'package:raabta/features/eosb/services/eosb_analytics_service.dart';
import 'package:raabta/features/eosb/domain/models/eosb_public_verification_record.dart';
import 'package:raabta/features/eosb/domain/services/eosb_certificate_id_generator.dart';
import 'package:raabta/features/eosb/domain/rules/eosb_certificate_constants.dart';
import 'package:raabta/features/eosb/services/eosb_certificate_registration_service.dart';
import 'package:raabta/features/eosb/services/eosb_certificate_verification_service.dart';
import 'package:raabta/providers/auth_scoped_storage_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _eosbTestRefProvider = Provider<Ref>((ref) => ref);

Ref _refFrom(ProviderContainer container) =>
    container.read(_eosbTestRefProvider);

EosbEmployeeInput _sampleEosbInput() => EosbEmployeeInput(
  basicSalary: 8000,
  joiningDate: DateTime(2019, 6, 1),
  lastWorkingDate: DateTime(2025, 6, 1),
);

class _ThrowingOnCacheEosbRepository extends EosbRepository {
  _ThrowingOnCacheEosbRepository(super.prefs);

  @override
  Future<void> cacheInput(EosbEmployeeInput input, {String? uid}) async {
    throw StateError('sensitive cache failure');
  }

  @override
  Future<void> cacheOvertimeInput(
    OvertimeTruthInput input, {
    String? uid,
  }) async {
    throw StateError('sensitive overtime cache failure');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EosbAnalyticsService', () {
    test('calculator and comparison events omit numeric values', () {
      final lines = <String>[];
      final previous = debugPrint;
      debugPrint = (message, {wrapWidth}) {
        lines.add(message ?? '');
      };
      addTearDown(() => debugPrint = previous);

      final analytics = EosbAnalyticsService();
      analytics.trackCalculatorUsed(totalEntitlement: 99999.5);
      analytics.trackComparisonViewed(difference: -1234.0);

      expect(lines, hasLength(2));
      expect(lines[0], '[EOSB Analytics] calculator_used');
      expect(lines[1], '[EOSB Analytics] comparison_viewed');
      for (final line in lines) {
        expect(line, isNot(contains('99999')));
        expect(line, isNot(contains('1234')));
      }
    });
  });

  group('EmployerTrackRecordService', () {
    test(
      'network failure returns insufficient without surfacing exception',
      () async {
        final service = EmployerTrackRecordService(client: http.Client());
        addTearDown(service.dispose);

        final result = await service.lookup(
          companyName: 'http://127.0.0.1:1/unreachable',
        );
        expect(
          result.status,
          EmployerTrackRecordDisplayStatus.insufficientData,
        );
      },
    );
  });

  group('Provider stable error codes', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('EosbNotifier uses eosb_calculation_failed on failure', () async {
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final ref = _refFrom(container);
      final repo = _ThrowingOnCacheEosbRepository(prefs);
      final notifier = EosbNotifier(const EosbCalculationService(), repo, ref);
      notifier.updateInput(_sampleEosbInput());

      final result = await notifier.calculate(saveHistory: false);

      expect(result, isNull);
      expect(notifier.state.error, eosbCalculationFailedErrorCode);
      expect(notifier.state.error, isNot(contains('sensitive')));
    });

    test(
      'OvertimeTruthNotifier uses overtime_calculation_failed on failure',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            currentAuthUidProvider.overrideWith((ref) => 'ot-step5-test-uid'),
          ],
        );
        addTearDown(container.dispose);
        final ref = _refFrom(container);
        final eosbNotifier = EosbNotifier(
          const EosbCalculationService(),
          null,
          ref,
        );
        final repo = _ThrowingOnCacheEosbRepository(prefs);
        final ot = OvertimeTruthNotifier(eosbNotifier, ref);
        ot.attachRepository(repo);
        await ot.flushHydration();

        final result = await ot.calculate();

        expect(result, isNull);
        expect(ot.state.error, overtimeCalculationFailedErrorCode);
        expect(ot.state.error, isNot(contains('sensitive')));
      },
    );
  });

  group('Certificate services', () {
    test('registration maps thrown client errors to network_error', () async {
      final service = EosbCertificateRegistrationService(
        client: _ThrowingHttpClient(),
        salaryConsent: () => true,
      );

      final result = await service.register(_minimalPublicRecord());

      expect(result.success, isFalse);
      expect(result.error, 'network_error');
    });

    test('verification maps thrown client errors to network_error', () async {
      final certificateId = EosbCertificateIdGenerator.generate();
      final service = EosbCertificateVerificationService(
        client: _ThrowingHttpClient(),
      );

      final result = await service.verify(certificateId: certificateId);

      expect(result.found, isFalse);
      expect(result.error, 'network_error');
    });
  });
}

class _ThrowingHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    throw Exception('raw socket error must not leak');
  }
}

EosbPublicVerificationRecord _minimalPublicRecord() {
  return EosbPublicVerificationRecord(
    certificateId: 'RAABTA-EOSB-OBS',
    certificateStatus: EosbCertificateTrustState.registeredOnline,
    estimatedEntitlement: '10000',
    currency: 'QAR',
    eosbRulesetVersion: '1',
    legalSourceVersion: '1',
    legalSourceSummary: 'Law 14/2004',
    legalSourceVerifiedDate: '2025-01-01',
    confidenceBand: EosbCertificateConfidenceBand.high,
    calculationFingerprint: 'abc',
    generatedAt: DateTime.utc(2025, 1, 1),
  );
}
