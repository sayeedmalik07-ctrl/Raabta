import 'package:raabta/config/compliance_flags_gate.dart';

/// Decision 25 — hide classifieds-linked entry when offers are gated off.
abstract final class PaymentCheckEntryPoints {
  static bool get marketplaceLinkVisible =>
      ComplianceFlagsGate.current.offersEnabled;
}
