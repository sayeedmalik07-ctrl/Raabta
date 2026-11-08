import 'dart:io';

import 'package:raabta/features/leaving_qatar/data/departure_plan/leaving_qatar_departure_plan_models.dart';
import 'package:raabta/features/leaving_qatar/presentation/l10n/leaving_qatar_strings.dart';
import 'package:raabta/features/leaving_qatar/services/leaving_qatar_departure_plan_pdf_service.dart';
import 'package:share_plus/share_plus.dart';

/// On-device PDF share for the local Departure Plan — no upload or Firestore.
class LeavingQatarDeparturePlanExportService {
  LeavingQatarDeparturePlanExportService(this._pdf);

  final LeavingQatarDeparturePlanPdfService _pdf;

  Future<File> buildPdf({
    required LeavingQatarDeparturePlanState plan,
    required String locale,
  }) {
    return _pdf.generate(plan: plan, locale: locale);
  }

  Future<void> sharePdf({
    required LeavingQatarDeparturePlanState plan,
    required String locale,
  }) async {
    final file = await buildPdf(plan: plan, locale: locale);
    final title = LeavingQatarStrings.t('lq_dp_pdf_title', locale);
    await Share.shareXFiles(
      [
        XFile(
          file.path,
          mimeType: 'application/pdf',
          name: 'RAABTA_Departure_Plan.pdf',
        ),
      ],
      subject: title,
      text: title,
    );
  }
}
