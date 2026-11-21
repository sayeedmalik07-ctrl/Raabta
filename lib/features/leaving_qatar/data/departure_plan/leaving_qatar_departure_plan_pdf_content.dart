import 'package:raabta/features/leaving_qatar/data/departure_plan/leaving_qatar_departure_plan_catalog.dart';
import 'package:raabta/features/leaving_qatar/data/departure_plan/leaving_qatar_departure_plan_models.dart';
import 'package:raabta/features/leaving_qatar/data/departure_plan/leaving_qatar_departure_plan_pdf_typography.dart';
import 'package:raabta/features/leaving_qatar/presentation/l10n/leaving_qatar_strings.dart';

/// One row in the exported Departure Plan PDF (catalog-only, not Firestore timeline).
class DeparturePlanPdfRow {
  const DeparturePlanPdfRow({
    required this.title,
    required this.timingLabel,
    required this.statusLabel,
    required this.referenceLabel,
  });

  final String title;
  final String timingLabel;
  final String statusLabel;
  final String referenceLabel;
}

/// Localized snapshot used to render and test the Departure Plan PDF.
class DeparturePlanPdfSnapshot {
  const DeparturePlanPdfSnapshot({
    required this.title,
    required this.intro,
    required this.departureDateLine,
    required this.progressLine,
    required this.rows,
    required this.disclaimer,
    required this.brandingLine,
  });

  final String title;
  final String intro;
  final String departureDateLine;
  final String progressLine;
  final List<DeparturePlanPdfRow> rows;
  final String disclaimer;
  final String brandingLine;
}

abstract final class LeavingQatarDeparturePlanPdfContent {
  static DeparturePlanPdfSnapshot build({
    required LeavingQatarDeparturePlanState plan,
    required String locale,
    required DateTime generatedAt,
  }) {
    final catalogIds = LeavingQatarDeparturePlanCatalog.itemIds;
    final done = plan.completedCountAmong(catalogIds);
    final total = catalogIds.length;

    final dateLine = _departureDateLine(plan.plannedDepartureDate, locale);

    final rows = <DeparturePlanPdfRow>[];
    for (final item in LeavingQatarDeparturePlanCatalog.items) {
      rows.add(
        DeparturePlanPdfRow(
          title: _pdfText(
            LeavingQatarStrings.departurePlanItemTitle(item.id, locale),
            locale,
          ),
          timingLabel: _pdfText(
            item.timingBasis == DeparturePlanTimingBasis.official
                ? LeavingQatarStrings.t('lq_dp_pdf_timing_official', locale)
                : LeavingQatarStrings.t('lq_dp_pdf_timing_suggested', locale),
            locale,
          ),
          statusLabel: _pdfText(
            plan.isCompleted(item.id)
                ? LeavingQatarStrings.t('lq_dp_pdf_status_done', locale)
                : LeavingQatarStrings.t('lq_dp_pdf_status_pending', locale),
            locale,
          ),
          referenceLabel: _pdfText(_referenceLabel(item, locale), locale),
        ),
      );
    }

    return DeparturePlanPdfSnapshot(
      title: _pdfText(LeavingQatarStrings.t('lq_dp_pdf_title', locale), locale),
      intro: _pdfText(LeavingQatarStrings.t('lq_dp_pdf_intro', locale), locale),
      departureDateLine: _pdfText(dateLine, locale),
      progressLine: _pdfText(
        LeavingQatarStrings.tf(
          'lq_dp_pdf_progress',
          locale,
          {'done': '$done', 'total': '$total'},
        ),
        locale,
      ),
      rows: rows,
      disclaimer: _pdfText(
        LeavingQatarStrings.t('lq_dp_pdf_disclaimer', locale),
        locale,
      ),
      brandingLine: _pdfText(
        LeavingQatarStrings.t('lq_dp_pdf_branding', locale),
        locale,
      ),
    );
  }

  static String _pdfText(String raw, String locale) =>
      LeavingQatarDeparturePlanPdfTypography.forPdf(raw, locale);

  static String _departureDateLine(String? raw, String locale) {
    if (raw == null ||
        raw.isEmpty ||
        !LeavingQatarDeparturePlanDate.isValidIsoDate(raw)) {
      return LeavingQatarStrings.t('lq_dp_pdf_date_not_set', locale);
    }
    return LeavingQatarStrings.tf(
      'lq_dp_pdf_date_set',
      locale,
      {'date': raw},
    );
  }

  static String _referenceLabel(
    DeparturePlanItemDefinition item,
    String locale,
  ) {
    switch (item.navigationTarget) {
      case DeparturePlanNavigationTarget.externalRoute:
        final path = item.routePath ?? '';
        return LeavingQatarStrings.tf(
          'lq_dp_pdf_ref_route',
          locale,
          {'route': path},
        );
      case DeparturePlanNavigationTarget.officialPortal:
        return LeavingQatarStrings.t('lq_dp_pdf_ref_portal', locale);
      case DeparturePlanNavigationTarget.inScreenTimeline:
        return LeavingQatarStrings.t('lq_dp_pdf_ref_timeline', locale);
      case DeparturePlanNavigationTarget.inScreenCloseout:
        return LeavingQatarStrings.t('lq_dp_pdf_ref_closeout', locale);
    }
  }
}
