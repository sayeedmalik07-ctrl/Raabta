import 'package:raabta/features/scam_shield/domain/scam_incident_models.dart';

/// Deterministic safe-verification guidance — no AI (Section 10).
abstract final class ScamSafeVerificationEngine {
  static const corePatternKeys = [
    'ss_safe_verify_open_official_app',
    'ss_safe_verify_known_contacts',
    'ss_safe_verify_no_supplied_links',
  ];

  static List<String> guidanceKeysFor({
    ScamImpersonationCategory? impersonation,
  }) {
    final keys = <String>[...corePatternKeys];

    switch (impersonation) {
      case ScamImpersonationCategory.government:
        keys.insert(0, 'ss_safe_verify_government');
      case ScamImpersonationCategory.bank:
        keys.insert(0, 'ss_safe_verify_bank');
      case ScamImpersonationCategory.telecom:
        keys.insert(0, 'ss_safe_verify_telecom');
      case ScamImpersonationCategory.deliveryCompany:
      case ScamImpersonationCategory.employer:
      case ScamImpersonationCategory.other:
      case null:
        break;
    }

    return keys.toSet().toList();
  }
}
