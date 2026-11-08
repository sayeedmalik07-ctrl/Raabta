import 'package:raabta/config/compliance_flags.dart';
import 'package:raabta/features/business/domain/business_contact_mode.dart';

/// Structured appointment/quote CTA visibility (flags off → call/WhatsApp only).
bool businessStructuredContactCtaVisible({
  required BusinessContactMode contactMode,
  required ComplianceFlags flags,
}) {
  return switch (contactMode) {
    BusinessContactMode.messageOnly => false,
    BusinessContactMode.appointment => flags.businessAppointmentsEnabled,
    BusinessContactMode.quote => flags.businessQuotesEnabled,
  };
}
