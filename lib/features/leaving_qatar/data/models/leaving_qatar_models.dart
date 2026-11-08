/// Worker category for informational exit-permit self-assessment only.
///
/// Raabta never certifies legal status — this selects general guidance copy.
enum LeavingQatarWorkerCategory {
  standardPrivateSector,
  essentialDesignated,
  domesticWorker,
  militarySecurity,
}

/// Departure planning time horizons (T-90 → departure day).
enum LeavingQatarTimelineStage {
  early,
  mid,
  late,
  departure,
}

/// One static checklist row for departure preparation.
class LeavingQatarChecklistItem {
  const LeavingQatarChecklistItem({
    required this.id,
    required this.titleKey,
    required this.bodyKey,
    required this.stage,
  });

  final String id;
  final String titleKey;
  final String bodyKey;
  final LeavingQatarTimelineStage stage;
}

/// Document category commonly needed in a departure bundle.
enum LeavingQatarBundleCategory {
  passport,
  visa,
  qid,
  contract,
  payslip,
  eosbDoc,
  exitPermit,
}

/// A vault document matched for departure bundle export.
class LeavingQatarBundleDocument {
  const LeavingQatarBundleDocument({
    required this.id,
    required this.data,
    required this.label,
    required this.categoryHint,
  });

  final String id;
  final Map<String, dynamic> data;
  final String label;
  final LeavingQatarBundleCategory categoryHint;
}

/// Official MOI / Metrash link targets — Raabta signposts only.
abstract final class LeavingQatarOfficialLinks {
  static const moiPortalUrl = 'https://portal.moi.gov.qa';
  static const metrashPortalUrl = 'https://portal.moi.gov.qa/metrash';

  /// Travel Ban Inquiry — MOI e-services (Metrash app or portal).
  static const travelBanInquiryUrl = moiPortalUrl;

  /// Entry and Exit Permits → Leave Notification Application (Metrash).
  static const exitPermitApplicationUrl = metrashPortalUrl;
}
