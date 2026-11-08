/// Raabta **suggested planning** offsets (days before departure date) — not legal deadlines.
///
/// Official-portal-only steps are omitted. Values align with Leaving Qatar timeline
/// horizons (early / mid / late) as planning nudges only.
abstract final class LeavingQatarDeparturePlanReminderTiming {
  static const offsetsByItemId = <String, List<int>>{
    'plan_employer_settlement': [60],
    'plan_eosb_entitlement': [60],
    'plan_bank_arrangements': [35],
    'plan_kahramaa_closure': [45],
    'plan_health_coverage_gap': [60],
    'plan_vehicle_and_fines': [30],
    'plan_school_records': [30],
    'plan_pets': [30],
    'plan_traffic_fines_recheck': [14, 7],
    'plan_travel_ban_inquiry': [14, 7],
    'plan_document_vault_copies': [7],
    'plan_welcome_home_prep': [7],
  };

  static List<int> offsetsFor(String itemId) =>
      offsetsByItemId[itemId] ?? const [];
}
