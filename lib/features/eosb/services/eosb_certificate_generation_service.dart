import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/eosb/domain/models/eosb_certificate_models.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/domain/rules/eosb_certificate_constants.dart';
import 'package:raabta/features/eosb/domain/services/eosb_certificate_presentation_builder.dart';
import 'package:raabta/features/eosb/domain/services/eosb_certificate_snapshot_factory.dart';

/// Bundles immutable snapshot + localized presentation for rendering.
@immutable
class EosbCertificateBundle {
  const EosbCertificateBundle({
    required this.snapshot,
    required this.presentation,
  });

  final EosbCertificateSnapshot snapshot;
  final EosbCertificatePresentation presentation;
}

/// Builds certificate data from frozen calculation output — never recalculates.
class EosbCertificateGenerationService {
  /// Creates a new certificate document from frozen calculation output.
  ///
  /// Each call issues a new [certificateId] and [generatedAt] — document identity
  /// is per export. [calculationFingerprint] remains stable for identical inputs.
  EosbCertificateBundle build({
    required EosbResult result,
    required EosbEmployeeInput input,
    required String appVersion,
    required String appBuildNumber,
    required String locale,
  }) {
    final snapshot = EosbCertificateSnapshotFactory.create(
      result: result,
      input: input,
      appVersion: appVersion,
      appBuildNumber: appBuildNumber,
      generationLocale: locale,
    );
    return buildFromSnapshot(snapshot: snapshot, locale: locale);
  }

  /// Re-localizes presentation from an existing immutable snapshot — no recalculation.
  EosbCertificateBundle buildFromSnapshot({
    required EosbCertificateSnapshot snapshot,
    required String locale,
    EosbCertificateTrustState? trustStateOverride,
    String? verificationUrl,
    bool cryptographicallySigned = false,
  }) {
    final presentation = EosbCertificatePresentationBuilder.build(
      snapshot,
      locale,
      trustStateOverride: trustStateOverride,
      verificationUrl: verificationUrl,
      cryptographicallySigned: cryptographicallySigned,
    );
    return EosbCertificateBundle(
      snapshot: snapshot,
      presentation: presentation,
    );
  }

  /// Builds presentation for a server-registered certificate (Phase 2/3).
  EosbCertificateBundle buildRegistered({
    required EosbCertificateSnapshot snapshot,
    required String locale,
    required String verificationUrl,
    bool cryptographicallySigned = false,
  }) {
    return buildFromSnapshot(
      snapshot: snapshot,
      locale: locale,
      trustStateOverride: EosbCertificateTrustState.registeredOnline,
      verificationUrl: verificationUrl,
      cryptographicallySigned: cryptographicallySigned,
    );
  }
}

final eosbCertificateGenerationServiceProvider =
    Provider<EosbCertificateGenerationService>(
  (ref) => EosbCertificateGenerationService(),
);
