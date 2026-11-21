import 'package:raabta/features/leaving_qatar/data/models/leaving_qatar_models.dart';

/// Static departure guidance — general information, not legal certification.
abstract final class LeavingQatarCatalog {
  static const lastContentReview = '2026-08-28';
  static const sourceMoiPortal = LeavingQatarOfficialLinks.moiPortalUrl;

  static const timelineStages = LeavingQatarTimelineStage.values;

  static const checklist = <LeavingQatarChecklistItem>[
    LeavingQatarChecklistItem(
      id: 'business_closure',
      titleKey: 'lq_check_business_title',
      bodyKey: 'lq_check_business_body',
      stage: LeavingQatarTimelineStage.early,
    ),
    LeavingQatarChecklistItem(
      id: 'health_coverage_gap',
      titleKey: 'lq_check_health_title',
      bodyKey: 'lq_check_health_body',
      stage: LeavingQatarTimelineStage.early,
    ),
    LeavingQatarChecklistItem(
      id: 'bank_accounts',
      titleKey: 'lq_check_bank_title',
      bodyKey: 'lq_check_bank_body',
      stage: LeavingQatarTimelineStage.mid,
    ),
    LeavingQatarChecklistItem(
      id: 'bank_letters',
      titleKey: 'lq_check_bank_letters_title',
      bodyKey: 'lq_check_bank_letters_body',
      stage: LeavingQatarTimelineStage.mid,
    ),
    LeavingQatarChecklistItem(
      id: 'traffic_fines',
      titleKey: 'lq_check_fines_title',
      bodyKey: 'lq_check_fines_body',
      stage: LeavingQatarTimelineStage.mid,
    ),
    LeavingQatarChecklistItem(
      id: 'rp_cancellation',
      titleKey: 'lq_check_rp_title',
      bodyKey: 'lq_check_rp_body',
      stage: LeavingQatarTimelineStage.late,
    ),
    LeavingQatarChecklistItem(
      id: 'departure_window',
      titleKey: 'lq_check_window_title',
      bodyKey: 'lq_check_window_body',
      stage: LeavingQatarTimelineStage.late,
    ),
  ];

  static Iterable<LeavingQatarChecklistItem> itemsForStage(
    LeavingQatarTimelineStage stage,
  ) {
    return checklist.where((item) => item.stage == stage);
  }

  static String stageHeadingKey(LeavingQatarTimelineStage stage) {
    switch (stage) {
      case LeavingQatarTimelineStage.early:
        return 'lq_timeline_early_heading';
      case LeavingQatarTimelineStage.mid:
        return 'lq_timeline_mid_heading';
      case LeavingQatarTimelineStage.late:
        return 'lq_timeline_late_heading';
      case LeavingQatarTimelineStage.departure:
        return 'lq_timeline_departure_heading';
    }
  }

  static String stageSubtitleKey(LeavingQatarTimelineStage stage) {
    switch (stage) {
      case LeavingQatarTimelineStage.early:
        return 'lq_timeline_early_subtitle';
      case LeavingQatarTimelineStage.mid:
        return 'lq_timeline_mid_subtitle';
      case LeavingQatarTimelineStage.late:
        return 'lq_timeline_late_subtitle';
      case LeavingQatarTimelineStage.departure:
        return 'lq_timeline_departure_subtitle';
    }
  }

  static String guidanceKeyFor(LeavingQatarWorkerCategory category) {
    switch (category) {
      case LeavingQatarWorkerCategory.standardPrivateSector:
        return 'lq_exit_guidance_standard';
      case LeavingQatarWorkerCategory.essentialDesignated:
        return 'lq_exit_guidance_essential';
      case LeavingQatarWorkerCategory.domesticWorker:
        return 'lq_exit_guidance_domestic';
      case LeavingQatarWorkerCategory.militarySecurity:
        return 'lq_exit_guidance_military';
    }
  }

  static String categoryLabelKey(LeavingQatarWorkerCategory category) {
    switch (category) {
      case LeavingQatarWorkerCategory.standardPrivateSector:
        return 'lq_category_standard';
      case LeavingQatarWorkerCategory.essentialDesignated:
        return 'lq_category_essential';
      case LeavingQatarWorkerCategory.domesticWorker:
        return 'lq_category_domestic';
      case LeavingQatarWorkerCategory.militarySecurity:
        return 'lq_category_military';
    }
  }
}
