import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/eosb/data/eosb_repository.dart';
import 'package:raabta/features/eosb/domain/models/eosb_certificate_models.dart';
import 'package:raabta/features/eosb/domain/models/eosb_public_verification_record.dart';
import 'package:raabta/features/eosb/domain/rules/eosb_certificate_constants.dart';
import 'package:raabta/features/eosb/domain/services/eosb_salary_claude_consent.dart';
import 'package:raabta/features/eosb/services/eosb_certificate_registration_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

EosbPublicVerificationRecord _sampleRecord() {
  return EosbPublicVerificationRecord(
    certificateId: 'RAABTA-EOSB-TEST',
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EosbCertificateRegistrationService consent', () {
    test('throws when persisted consent is off', () {
      final service = EosbCertificateRegistrationService(
        salaryConsent: () => false,
      );

      expect(
        () => service.register(_sampleRecord()),
        throwsA(isA<EosbSalaryStorageConsentRequired>()),
      );
    });

    test('passes consent gate when on (network may fail)', () async {
      final service = EosbCertificateRegistrationService(
        salaryConsent: () => true,
      );

      final result = await service.register(_sampleRecord());
      expect(result.success, isFalse);
      expect(result.error, isNot('salary_consent_required'));
    });
  });

  group('UID-scoped consent reader', () {
    test('repository salaryConsent respects uid', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = EosbRepository(prefs);
      await repo.setSalaryConsent(true, uid: 'user-a');
      expect(repo.salaryConsent(uid: 'user-a'), isTrue);
      expect(repo.salaryConsent(uid: 'user-b'), isFalse);
    });
  });
}
