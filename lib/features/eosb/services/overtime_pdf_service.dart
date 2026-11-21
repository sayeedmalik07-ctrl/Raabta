import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:share_plus/share_plus.dart';

class OvertimePdfService {
  static const _version = 'RAABTA OT Engine v2.0';

  Future<File> generateReport({
    required OvertimeTruthResult result,
    required String locale,
  }) async {
    final record = result.record;
    final profile = record.profile;
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              EosbStrings.t('ot_report_title', locale),
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(_version, style: const pw.TextStyle(fontSize: 9)),
          pw.Text(
            EosbStrings.t('eosb_disclaimer', locale),
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 16),
          pw.Text('${EosbStrings.t("ot_emp_name", locale)}: ${profile.employeeName}'),
          if (profile.companyName.isNotEmpty)
            pw.Text('${EosbStrings.t("eosb_company_name", locale)}: ${profile.companyName}'),
          pw.Text('${EosbStrings.t("ot_period", locale)}: ${record.label}'),
          pw.Text(
            '${EosbStrings.t("ot_basic_salary", locale)}: '
            '${formatEosbCurrency(profile.basicSalary, symbol: profile.currency)}',
          ),
          pw.Text(
            '${EosbStrings.t("ot_hourly_rate", locale)}: '
            '${formatEosbCurrency(result.rateBreakdown.hourlyRate, symbol: profile.currency)}',
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            EosbStrings.t('ot_legal_owed', locale),
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(formatEosbCurrency(result.totalLegalOwed, symbol: profile.currency)),
          pw.SizedBox(height: 12),
          pw.Text('Breakdown', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ...result.lineItems.map(
            (item) => pw.Text(
              '${_categoryLabel(item.category, locale)} '
              '${item.hours.toStringAsFixed(1)}h × ${item.rateMultiplier} = '
              '${formatEosbCurrency(item.amount, symbol: profile.currency)}',
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            EosbStrings.t('ot_calendar_mode', locale),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          ...record.days.where((d) => d.totalHours > 0).map(
                (d) => pw.Text(
                  '${d.date.day}/${d.date.month}: '
                  '${d.totalHours.toStringAsFixed(1)}h (${d.dayCategory.name})',
                ),
              ),
          pw.SizedBox(height: 12),
          pw.Text(EosbStrings.t('ot_employer_comparison', locale),
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(
            '${EosbStrings.t("ot_employer_paid", locale)}: '
            '${formatEosbCurrency(result.comparison.employerPaid, symbol: profile.currency)}',
          ),
          pw.Text(
            '${EosbStrings.t("ot_unpaid_gap", locale)}: '
            '${formatEosbCurrency(result.comparison.unpaidGap, symbol: profile.currency)}',
          ),
          pw.SizedBox(height: 8),
          ...result.rateBreakdown.steps.map(pw.Text.new),
          pw.SizedBox(height: 12),
          pw.Text(
            '${EosbStrings.t("ot_confidence", locale)}: ${result.confidenceScore}%',
          ),
          pw.Text(
            'Generated: ${result.calculatedAt.toIso8601String()}',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            EosbStrings.t('ot_report_footer', locale),
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/overtime_report_${result.calculatedAt.millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await doc.save());
    return file;
  }

  Future<void> shareReport(File file, String locale) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      text: EosbStrings.t('ot_report_share', locale),
    );
  }

  String _categoryLabel(OvertimeRateCategory cat, String locale) {
    return switch (cat) {
      OvertimeRateCategory.weekdayExtra =>
        EosbStrings.t('ot_cat_weekday', locale),
      OvertimeRateCategory.restDay => EosbStrings.t('ot_cat_restday', locale),
      OvertimeRateCategory.publicHoliday =>
        EosbStrings.t('ot_cat_holiday', locale),
      OvertimeRateCategory.nightShift =>
        EosbStrings.t('ot_cat_night', locale),
      OvertimeRateCategory.emergency =>
        EosbStrings.t('ot_cat_emergency', locale),
      OvertimeRateCategory.standby =>
        EosbStrings.t('ot_cat_standby', locale),
      OvertimeRateCategory.custom => EosbStrings.t('ot_cat_custom', locale),
    };
  }
}

final overtimePdfServiceProvider = Provider<OvertimePdfService>(
  (ref) => OvertimePdfService(),
);
