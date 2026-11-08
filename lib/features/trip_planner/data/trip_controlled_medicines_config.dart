/// Official MoPH signposts for controlled medicines when travelling (link-out only).
abstract final class TripControlledMedicinesConfig {
  /// Date URLs were last checked in implementation QA (not MoPH publication date).
  static const lastVerifiedIso = '2026-10-16';

  /// MoPH user guide publication line shown in copy (UserGuideEn.pdf footer).
  static const mophUserGuidePublicationLine = 'MoPH user guide, v1.0, © 2025';

  static const mophPortal = 'https://fli.moph.gov.qa/';
  static const travelerGuidelinesPdf = 'https://fli.moph.gov.qa/GuideEn.pdf';
  static const applicationUserGuidePdf =
      'https://fli.moph.gov.qa/UserGuideEn.pdf';

  /// Copy guard for unit tests — phrases that must not appear in localized card text.
  static const forbiddenCopySubstrings = <String>[
    '10-day',
    '10 day',
    '60-day',
    '60 day',
    'qar',
    'is allowed',
    'your medicine is',
    'will be approved',
    'guaranteed approval',
    'we verify',
    'raabta verifies',
    'raabta submits',
    'customs',
  ];
}
