import 'dart:math';

import 'package:raabta/features/eosb/domain/rules/eosb_certificate_constants.dart';
import 'package:raabta/features/eosb/domain/services/crockford_base32.dart';

/// Generates opaque Truth Certificate IDs — 128-bit CSPRNG, non-PII.
///
/// ## Certificate ID vs authenticity (Phase 1)
///
/// - **Certificate ID** identifies a certificate document — it does NOT prove
///   authenticity, verification, or legal certification.
/// - **Calculation fingerprint** identifies the frozen calculation payload.
/// - Phase 1 trust state is [EosbCertificateTrustState.visualEstimate] only.
/// - Phase 2 introduces server registration and online verification.
/// - Phase 3 may introduce cryptographic signing.
///
/// Do NOT describe a Phase 1 certificate as verified, government verified,
/// legally certified, cryptographically signed, or tamper-proof.
abstract final class EosbCertificateIdGenerator {
  static const storagePrefix = 'eosb_';
  static const displayPrefix = 'EOSB-';
  static const entropyBytes = 16;
  static const encodedLength = 26;

  /// Raw storage ID: `eosb_{26-char Crockford Base32 uppercase}`.
  static String generate({Random? random}) {
    final rng = random ?? Random.secure();
    final bytes = List<int>.generate(entropyBytes, (_) => rng.nextInt(256));
    final encoded = CrockfordBase32.encode(bytes);
    assert(encoded.length == encodedLength);
    return '$storagePrefix$encoded';
  }

  /// Human-readable groups from first 16 encoded characters: EOSB-XXXX-XXXX-XXXX-XXXX.
  static String displayFormat(String storageId) {
    if (!storageId.startsWith(storagePrefix)) {
      throw ArgumentError.value(storageId, 'storageId', 'missing eosb_ prefix');
    }
    final body = storageId.substring(storagePrefix.length);
    if (body.length < 16) {
      throw ArgumentError.value(storageId, 'storageId', 'encoded body too short');
    }
    final head = body.substring(0, 16);
    final groups = [
      head.substring(0, 4),
      head.substring(4, 8),
      head.substring(8, 12),
      head.substring(12, 16),
    ];
    return '$displayPrefix${groups.join('-')}';
  }

  /// Validates storage ID structure (not collision check).
  static bool isValidStorageId(String id) {
    if (!id.startsWith(storagePrefix)) return false;
    final body = id.substring(storagePrefix.length);
    if (body.length != encodedLength) return false;
    try {
      CrockfordBase32.decode(body);
      return true;
    } catch (_) {
      return false;
    }
  }
}
