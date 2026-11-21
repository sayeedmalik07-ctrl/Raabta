import 'package:raabta/config/compliance_flags_gate.dart';
import 'package:raabta/features/link_safety/link_safety_models.dart';

abstract final class LinkSafetyGating {
  static bool labelsEnabled(LinkSafetySurface surface) {
    return switch (surface) {
      LinkSafetySurface.communityFeed ||
      LinkSafetySurface.askQatar ||
      LinkSafetySurface.lostFound ||
      LinkSafetySurface.events =>
        true,
      LinkSafetySurface.marketplaceListing ||
      LinkSafetySurface.marketplaceChat =>
        ComplianceFlagsGate.current.offersEnabled,
      LinkSafetySurface.housingListing ||
      LinkSafetySurface.housingChat =>
        ComplianceFlagsGate.current.viewingsEnabled,
      LinkSafetySurface.servicesListing ||
      LinkSafetySurface.servicesChat =>
        ComplianceFlagsGate.current.quotesEnabled,
      LinkSafetySurface.jobsListing ||
      LinkSafetySurface.jobsChat =>
        ComplianceFlagsGate.current.jobApplicationStatusEnabled,
      LinkSafetySurface.businessListing =>
        ComplianceFlagsGate.current.businessQuotesEnabled,
    };
  }
}
