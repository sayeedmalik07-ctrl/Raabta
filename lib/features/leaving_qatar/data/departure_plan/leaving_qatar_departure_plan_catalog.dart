import 'package:raabta/features/leaving_qatar/data/departure_plan/leaving_qatar_departure_plan_models.dart';
import 'package:raabta/features/leaving_qatar/data/models/leaving_qatar_models.dart';

/// Curated departure-plan rows — links only; does not duplicate Firestore checklist rows.
abstract final class LeavingQatarDeparturePlanCatalog {
  static const items = <DeparturePlanItemDefinition>[
    DeparturePlanItemDefinition(
      id: 'plan_employer_settlement',
      navigationTarget: DeparturePlanNavigationTarget.externalRoute,
      routePath: '/welcome-home',
      timingBasis: DeparturePlanTimingBasis.suggested,
    ),
    DeparturePlanItemDefinition(
      id: 'plan_eosb_entitlement',
      navigationTarget: DeparturePlanNavigationTarget.externalRoute,
      routePath: '/eosb/result',
      timingBasis: DeparturePlanTimingBasis.suggested,
    ),
    DeparturePlanItemDefinition(
      id: 'plan_bank_arrangements',
      navigationTarget: DeparturePlanNavigationTarget.inScreenTimeline,
      timingBasis: DeparturePlanTimingBasis.suggested,
    ),
    DeparturePlanItemDefinition(
      id: 'plan_kahramaa_closure',
      navigationTarget: DeparturePlanNavigationTarget.inScreenTimeline,
      timingBasis: DeparturePlanTimingBasis.suggested,
    ),
    DeparturePlanItemDefinition(
      id: 'plan_health_coverage_gap',
      navigationTarget: DeparturePlanNavigationTarget.inScreenTimeline,
      timingBasis: DeparturePlanTimingBasis.suggested,
    ),
    DeparturePlanItemDefinition(
      id: 'plan_vehicle_and_fines',
      navigationTarget: DeparturePlanNavigationTarget.inScreenCloseout,
      timingBasis: DeparturePlanTimingBasis.suggested,
    ),
    DeparturePlanItemDefinition(
      id: 'plan_school_records',
      navigationTarget: DeparturePlanNavigationTarget.inScreenCloseout,
      timingBasis: DeparturePlanTimingBasis.suggested,
    ),
    DeparturePlanItemDefinition(
      id: 'plan_pets',
      navigationTarget: DeparturePlanNavigationTarget.inScreenCloseout,
      timingBasis: DeparturePlanTimingBasis.suggested,
    ),
    DeparturePlanItemDefinition(
      id: 'plan_exit_permit',
      navigationTarget: DeparturePlanNavigationTarget.officialPortal,
      officialSourceUrl: LeavingQatarOfficialLinks.metrashPortalUrl,
      timingBasis: DeparturePlanTimingBasis.official,
    ),
    DeparturePlanItemDefinition(
      id: 'plan_traffic_fines_recheck',
      navigationTarget: DeparturePlanNavigationTarget.inScreenTimeline,
      timingBasis: DeparturePlanTimingBasis.suggested,
    ),
    DeparturePlanItemDefinition(
      id: 'plan_travel_ban_inquiry',
      navigationTarget: DeparturePlanNavigationTarget.inScreenTimeline,
      timingBasis: DeparturePlanTimingBasis.suggested,
    ),
    DeparturePlanItemDefinition(
      id: 'plan_rp_cancellation',
      navigationTarget: DeparturePlanNavigationTarget.officialPortal,
      officialSourceUrl: LeavingQatarOfficialLinks.moiPortalUrl,
      timingBasis: DeparturePlanTimingBasis.official,
    ),
    DeparturePlanItemDefinition(
      id: 'plan_departure_rules_confirm',
      navigationTarget: DeparturePlanNavigationTarget.officialPortal,
      officialSourceUrl: LeavingQatarOfficialLinks.moiPortalUrl,
      timingBasis: DeparturePlanTimingBasis.official,
    ),
    DeparturePlanItemDefinition(
      id: 'plan_document_vault_copies',
      navigationTarget: DeparturePlanNavigationTarget.externalRoute,
      routePath: '/document-vault',
      timingBasis: DeparturePlanTimingBasis.suggested,
    ),
    DeparturePlanItemDefinition(
      id: 'plan_welcome_home_prep',
      navigationTarget: DeparturePlanNavigationTarget.externalRoute,
      routePath: '/welcome-home',
      timingBasis: DeparturePlanTimingBasis.suggested,
    ),
  ];

  static List<String> get itemIds =>
      items.map((item) => item.id).toList(growable: false);

  static DeparturePlanItemDefinition? definitionFor(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  static bool isKnownItemId(String id) => definitionFor(id) != null;
}
