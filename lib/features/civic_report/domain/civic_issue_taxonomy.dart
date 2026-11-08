/// Stable issue category IDs for Report It Right (Part A).
enum CivicIssueTypeId {
  streetLighting('street_lighting'),
  roadDamage('road_damage'),
  drainageSewage('drainage_sewage'),
  waterLeakSupply('water_leak_supply'),
  electricityFault('electricity_fault'),
  pests('pests'),
  abandonedVehicle('abandoned_vehicle'),
  wasteCollection('waste_collection'),
  workersAccommodationSanitation('workers_accommodation_sanitation'),
  labourEmployerDispute('labour_employer_dispute'),
  heatOutdoorWork('heat_outdoor_work'),
  scamFraudCyber('scam_fraud_cyber'),
  immediateDanger('immediate_danger'),
  tenancyLeaseDeposit('tenancy_lease_deposit'),
  consumerDispute('consumer_dispute'),
  otherUnsure('other_unsure');

  const CivicIssueTypeId(this.id);

  final String id;

  static CivicIssueTypeId? tryParse(String raw) {
    final normalized = raw.trim();
    for (final value in CivicIssueTypeId.values) {
      if (value.id == normalized) return value;
    }
    return null;
  }

  /// User-selectable categories (excludes routing-only aliases).
  static List<CivicIssueTypeId> selectableCategories() => [
        CivicIssueTypeId.streetLighting,
        CivicIssueTypeId.roadDamage,
        CivicIssueTypeId.drainageSewage,
        CivicIssueTypeId.waterLeakSupply,
        CivicIssueTypeId.electricityFault,
        CivicIssueTypeId.pests,
        CivicIssueTypeId.abandonedVehicle,
        CivicIssueTypeId.wasteCollection,
        CivicIssueTypeId.workersAccommodationSanitation,
        CivicIssueTypeId.labourEmployerDispute,
        CivicIssueTypeId.heatOutdoorWork,
        CivicIssueTypeId.scamFraudCyber,
        CivicIssueTypeId.immediateDanger,
        CivicIssueTypeId.tenancyLeaseDeposit,
        CivicIssueTypeId.consumerDispute,
        CivicIssueTypeId.otherUnsure,
      ];

  String labelKey() => 'civic_issue_${id}_label';
}
