import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/eosb/domain/models/eosb_certificate_models.dart';
import 'package:raabta/features/eosb/domain/models/eosb_certificate_verification_result.dart';
import 'package:raabta/features/eosb/domain/models/eosb_public_verification_record.dart';
import 'package:raabta/features/eosb/domain/rules/eosb_certificate_constants.dart';
import 'package:raabta/features/eosb/services/eosb_certificate_generation_service.dart';
import 'package:raabta/features/eosb/services/eosb_certificate_registration_service.dart';
import 'package:raabta/features/eosb/services/eosb_certificate_verification_service.dart';

final eosbCertificateRegistrationServiceProvider =
    Provider<EosbCertificateRegistrationService>(
  (ref) => EosbCertificateRegistrationService(),
);

final eosbCertificateVerificationServiceProvider =
    Provider<EosbCertificateVerificationService>(
  (ref) => EosbCertificateVerificationService(),
);

/// Session cache after successful registration (Phase 2/3).
@immutable
class EosbRegisteredCertificateCacheEntry {
  const EosbRegisteredCertificateCacheEntry({
    required this.verificationUrl,
    this.cryptographicallySigned = false,
  });

  final String verificationUrl;
  final bool cryptographicallySigned;
}

/// Session cache: certificateId → registration metadata.
final eosbRegisteredVerificationUrlsProvider =
    StateProvider<Map<String, EosbRegisteredCertificateCacheEntry>>((ref) => {});

/// Registers a public record and caches the verification URL on success.
Future<EosbCertificateRegistrationResult> registerEosbCertificate(
  WidgetRef ref,
  EosbPublicVerificationRecord record,
) async {
  final service = ref.read(eosbCertificateRegistrationServiceProvider);
  final result = await service.register(record);
  if (result.success && result.verificationUrl != null) {
    final cache = Map<String, EosbRegisteredCertificateCacheEntry>.from(
      ref.read(eosbRegisteredVerificationUrlsProvider),
    );
    cache[record.certificateId] = EosbRegisteredCertificateCacheEntry(
      verificationUrl: result.verificationUrl!,
      cryptographicallySigned: result.record?.isCryptographicallySigned ?? false,
    );
    ref.read(eosbRegisteredVerificationUrlsProvider.notifier).state = cache;
  }
  return result;
}

String? registeredVerificationUrl(WidgetRef ref, String certificateId) {
  return ref.read(eosbRegisteredVerificationUrlsProvider)[certificateId]
      ?.verificationUrl;
}

EosbRegisteredCertificateCacheEntry? registeredCertificateCacheEntry(
  WidgetRef ref,
  String certificateId,
) {
  return ref.read(eosbRegisteredVerificationUrlsProvider)[certificateId];
}

/// Registers snapshot online and returns a bundle with verification QR (Phase 2).
Future<EosbCertificateRegistrationOutcome> registerEosbCertificateBundle({
  required WidgetRef ref,
  required EosbCertificateSnapshot snapshot,
  required String locale,
}) async {
  final certGen = ref.read(eosbCertificateGenerationServiceProvider);
  final record = EosbPublicVerificationRecord.fromSnapshot(
    snapshot,
    certificateStatus: EosbCertificateTrustState.registeredOnline,
  );
  final result = await registerEosbCertificate(ref, record);
  if (!result.success) {
    return EosbCertificateRegistrationOutcome.failure(result.error);
  }
  final url = result.verificationUrl;
  if (url == null || url.isEmpty) {
    return const EosbCertificateRegistrationOutcome.failure('register_failed');
  }
  final bundle = certGen.buildRegistered(
        snapshot: snapshot,
        locale: locale,
        verificationUrl: url,
        cryptographicallySigned: result.record?.isCryptographicallySigned ?? false,
      );
  return EosbCertificateRegistrationOutcome.success(
    bundle,
    idempotent: result.idempotent,
  );
}

@immutable
class EosbCertificateRegistrationOutcome {
  const EosbCertificateRegistrationOutcome._({
    required this.success,
    this.bundle,
    this.error,
    this.idempotent = false,
  });

  const EosbCertificateRegistrationOutcome.success(
    EosbCertificateBundle bundle, {
    bool idempotent = false,
  }) : this._(success: true, bundle: bundle, idempotent: idempotent);

  const EosbCertificateRegistrationOutcome.failure(String? error)
      : this._(success: false, error: error);

  final bool success;
  final EosbCertificateBundle? bundle;
  final String? error;
  final bool idempotent;
}
