import 'package:raabta/features/civic_report/presentation/l10n/civic_report_strings.dart';

abstract final class CivicReportManualTemplate {
  static String build({
    required String locale,
    required String issueLabel,
  }) {
    final header = CivicReportStrings.t('civic_manual_template_header', locale);
    final footer = CivicReportStrings.t('civic_manual_template_footer', locale);
    final issueLine =
        CivicReportStrings.t('civic_manual_field_issue', locale);
    final locationLine =
        CivicReportStrings.t('civic_manual_field_location', locale);
    final whenLine = CivicReportStrings.t('civic_manual_field_when', locale);
    final factsLine = CivicReportStrings.t('civic_manual_field_facts', locale);

    return '''
$header

$issueLine: $issueLabel
$locationLine:

$whenLine:

$factsLine:


$footer
''';
  }
}
