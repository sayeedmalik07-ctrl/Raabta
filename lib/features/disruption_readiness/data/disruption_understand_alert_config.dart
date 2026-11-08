import 'package:raabta/features/disruption_readiness/data/disruption_official_links.dart';

/// Static bundled content for the Understand an Alert guide (offline only).
abstract final class DisruptionUnderstandAlertConfig {
  static const lastVerifiedIso = '2026-10-16';

  static const qnaEwsReportingDate = '2026-02-19';
  static const qnaAllClearArabicDate = '2026-07-09';
  static const gulfTimesAllClearEnglishDate = '2026-07-12';

  static const moiEarlyWarningUrl =
      DisruptionOfficialLinks.moiEarlyWarningPortal;

  /// Tier B elevated-threat phone quotes — must not appear in shipped strings.
  static const tierBForbiddenSubstrings = [
    'security threat level is elevated',
    'remain indoors, refrain from going out',
    'stay away from windows and exposed areas',
    'homes and safe places',
  ];

  static const allClearArabicMaster =
      'زوال التهديد الأمني وعودة الأوضاع إلى طبيعتها وتدعو الجميع إلى الالتزام بالتعليمات الصادرة من الجهات المختصة';

  static const allClearEnglishReporting =
      'End of the security threat, return to normalcy, and follow instructions issued by the relevant authorities.';
}
