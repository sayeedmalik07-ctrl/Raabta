import 'package:raabta/core/intelligence/capabilities.dart';
import 'package:raabta/models/intelligence/opportunity.dart';
import 'package:raabta/models/intelligence/risk.dart';
import 'package:raabta/services/intelligence/consistency_checker.dart';

/// Maps intelligence insight types to Phase 10 [Capability] entries.
abstract final class IntelligenceCapabilityMapper {
  static const _typeToCapabilityId = <String, String>{
    Risk.typeDocumentExpiry: 'document_vault',
    Risk.typeBillDue: 'bill_tracker',
    Risk.typeEosbViolation: 'eosb',
    Risk.typeLabourComplaintDeadline: 'evidence_trail',
    Opportunity.typeEntitlementGap: 'eosb',
    Opportunity.typeExchangeRate: 'exchange_locator',
    ConsistencyChecker.typeDataMismatch: 'expat_score',
  };

  /// Returns the navigable capability for [insightType], if one exists.
  static Capability? capabilityForInsightType(String insightType) {
    final id = _typeToCapabilityId[insightType];
    if (id == null) return null;
    for (final cap in raabtaCapabilities) {
      if (cap.id == id) return cap;
    }
    return null;
  }
}
