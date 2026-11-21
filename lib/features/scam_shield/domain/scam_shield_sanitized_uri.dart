import 'package:raabta/features/scam_shield/domain/pii_redactor.dart';

/// URI safe to send to proxied Web Risk lookups (query tokens stripped).
final class ScamShieldSanitizedUri {
  const ScamShieldSanitizedUri._(this.value);

  final String value;

  factory ScamShieldSanitizedUri.forWebRiskLookup(String rawUrl) {
    return ScamShieldSanitizedUri._(
      PiiRedactor.sanitizeUriForWebRisk(rawUrl),
    );
  }
}
