import 'package:raabta/features/eosb/domain/services/eosb_certificate_presentation_builder.dart';

/// Static audit helpers for Phase 1 certificate outputs — no PII / no verification URLs.
abstract final class EosbCertificateSecurityAudit {
  static final _forbiddenPatterns = [
    RegExp(r'https?://', caseSensitive: false),
    RegExp(r'\bQID\b', caseSensitive: false),
    RegExp(r'\bpassport\b', caseSensitive: false),
    RegExp(r'@[a-z0-9.-]+\.[a-z]{2,}', caseSensitive: false),
    RegExp(r'\+\d{3,}', caseSensitive: false),
    RegExp(r'\bemployer\s*name\b', caseSensitive: false),
    RegExp(r'\bcompany\s*name\b', caseSensitive: false),
  ];

  /// Approved legal domain references inside disclaimer text are allowed.
  static const _allowedDomainFragments = ['almeezan.qa', 'mol.gov.qa'];

  /// Returns true when [text] contains no forbidden private-data or URL patterns,
  /// except approved legal disclaimer domain fragments.
  static bool textIsSafe(String text) {
    var sanitized = text;
    for (final allowed in _allowedDomainFragments) {
      sanitized = sanitized.replaceAll(allowed, '');
    }
    for (final pattern in _forbiddenPatterns) {
      if (pattern.hasMatch(sanitized)) return false;
    }
    return true;
  }

  /// Audits all user-visible strings in a certificate presentation.
  static bool presentationIsSafe(EosbCertificatePresentation p) {
    final strings = <String>[
      p.brandLabel,
      p.certificateHeading,
      p.entitlementHeading,
      p.entitlementAmountDisplay,
      p.trustStateHeading,
      p.trustStateLabel,
      p.employmentSummaryTitle,
      p.legalBasisTitle,
      p.basicSalaryLabel,
      p.serviceDurationLabel,
      p.calculatedAtLabel,
      p.inputCompletenessLabel,
      p.estimateConfidenceLabel,
      p.legalSourceLabel,
      p.articleReferenceLabel,
      p.sourceVerifiedLabel,
      p.disclaimer,
      p.confidenceDisclaimer,
      p.certificateIdDisplay,
      p.fingerprintShort,
      p.rulesetVersionValue,
      ...p.warningLines,
      ...p.breakdownLines.map((l) => '${l.title} ${l.amount} ${l.estimatedSuffix}'),
    ];
    return strings.every(textIsSafe);
  }
}
