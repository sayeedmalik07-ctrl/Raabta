import 'package:raabta/features/scam_shield/check_number/operator_reporting_catalog.dart';

/// Phase 21 report-pack channel picker — verified operator/regulator entries only.
abstract final class ReportPackReportingChannels {
  static Future<List<OperatorReportingEntry>> loadForPicker() =>
      OperatorReportingCatalog.channelsForReportPicker();
}
