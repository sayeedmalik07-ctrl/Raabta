import 'package:raabta/features/case_timeline/data/checklist/eosb_dispute_checklist_catalog.dart';
import 'package:raabta/features/case_timeline/data/checklist/health_insurance_denial_checklist_catalog.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_checklist_item.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_engine_type.dart';
import 'package:raabta/features/sponsorship_transfer/data/transfer_document_checklist_catalog.dart';
import 'package:raabta/features/tenancy/data/tenancy_dispute_checklist_catalog.dart';

/// Resolves each Truth Engine's hardcoded checklist for gap detection.
abstract final class CaseTimelineChecklistRegistry {
  static List<CaseTimelineChecklistItemDef> itemsFor(
    CaseTimelineEngineType engine, {
    bool eosbIncludeSettlement = true,
  }) {
    return switch (engine) {
      CaseTimelineEngineType.eosb =>
        EosbDisputeChecklistCatalog.items(
          includeSettlement: eosbIncludeSettlement,
        ),
      CaseTimelineEngineType.healthInsurance =>
        HealthInsuranceDenialChecklistCatalog.items,
      CaseTimelineEngineType.tenancy => TenancyDisputeChecklistCatalog.items
          .map(
            (d) => CaseTimelineChecklistItemDef(
              id: d.id,
              titleKey: d.titleKey,
              subtitleKey: d.subtitleKey,
              optional: d.optional,
            ),
          )
          .toList(),
      CaseTimelineEngineType.sponsorshipTransfer =>
        TransferDocumentChecklistCatalog.all
            .map(
              (d) => CaseTimelineChecklistItemDef(
                id: d.id,
                titleKey: d.titleKey,
                subtitleKey: d.subtitleKey,
                informal: d.informal,
              ),
            )
            .toList(),
    };
  }

  static String titleKeyFor(
    CaseTimelineEngineType engine,
    String checklistItemId,
  ) {
    for (final item in itemsFor(engine)) {
      if (item.id == checklistItemId) return item.titleKey;
    }
    return checklistItemId;
  }
}
