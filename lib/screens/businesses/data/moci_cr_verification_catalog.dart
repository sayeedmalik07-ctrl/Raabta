/// Official link-outs for mainland MOCI CR and QFC registry checks — not Raabta-hosted.
abstract final class MociCrVerificationCatalog {
  /// MOCI Business Map Portal — Unified Economic Register / CR verification hub.
  static const mociBusinessMapUrl = 'https://businessmap.moci.gov.qa/';

  /// MOCI e-services landing — durable fallback if Business Map path changes.
  static const mociEServicesUrl = 'https://www.moci.gov.qa/en/e-services/';

  /// Qatar Chamber commercial directory — supplementary lookup, not official MOCI registry.
  static const qatarCidUrl = 'https://www.qatarcid.com/?lang=en';

  /// QFC Public Register — separate from mainland MOCI CR.
  static const qfcPublicRegisterUrl =
      'https://www.qfcra.com/public_registers/search-all-firms/';
}
