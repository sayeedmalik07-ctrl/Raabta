/// Exemption categories under Cabinet Decision No. 9 of 2023 (Law 22/2021 scheme).
///
/// List verified against MOPH visitor guidance, Qatar Tribune (Cabinet Decision
/// No. 9/2023), Fragomen, and Lexis Middle East (September–October 2023).
enum HealthInsuranceExemptionCategory {
  none,
  temporaryResidencePermit,
  visaOnArrival30DaysOrLess,
  temporaryEntryTraveller,
  transitPassenger,
  diplomatSpouseOrChildUnder16,
  nonQatariWomanMarriedToQatari,
  childOfQatariMotherNonQatariFather,
  widowOrDivorcedNonQatariWoman,
  domesticWorkerInQatariHousehold,
  detaineeOrPrisoner,
  orphanInCareHome,
  childWithUnknownFather,
}

/// Plain-language l10n key for each exemption option (excluding [none]).
abstract final class HealthInsuranceExemptionRules {
  static const verifiedSourceNote =
      'Cabinet Decision No. 9 of 2023 — verify your status with MOPH (moph.gov.qa).';

  static const selectableCategories = [
    HealthInsuranceExemptionCategory.temporaryResidencePermit,
    HealthInsuranceExemptionCategory.visaOnArrival30DaysOrLess,
    HealthInsuranceExemptionCategory.temporaryEntryTraveller,
    HealthInsuranceExemptionCategory.transitPassenger,
    HealthInsuranceExemptionCategory.diplomatSpouseOrChildUnder16,
    HealthInsuranceExemptionCategory.nonQatariWomanMarriedToQatari,
    HealthInsuranceExemptionCategory.childOfQatariMotherNonQatariFather,
    HealthInsuranceExemptionCategory.widowOrDivorcedNonQatariWoman,
    HealthInsuranceExemptionCategory.domesticWorkerInQatariHousehold,
    HealthInsuranceExemptionCategory.detaineeOrPrisoner,
    HealthInsuranceExemptionCategory.orphanInCareHome,
    HealthInsuranceExemptionCategory.childWithUnknownFather,
  ];

  static bool isExempt(HealthInsuranceExemptionCategory category) {
    return category != HealthInsuranceExemptionCategory.none;
  }

  static String labelKey(HealthInsuranceExemptionCategory category) {
    return 'hi_exemption_${category.name}';
  }

  static String confirmationKey(HealthInsuranceExemptionCategory category) {
    return 'hi_exemption_confirm_${category.name}';
  }
}
