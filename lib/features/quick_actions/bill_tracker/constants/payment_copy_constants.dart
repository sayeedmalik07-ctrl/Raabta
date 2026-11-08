// ─────────────────────────────────────────────────────────
// PAYMENT COPY CONSTANTS — Bill Tracker
//
// IMPORTANT: RAABTA does NOT settle utility bills directly.
// All payment actions are deep-links to the provider's own
// app or website. This is intentional until official
// aggregator agreements with Kahramaa, Ooredoo, Vodafone Qatar,
// Qatar Cool, Marafeq Qatar, and beIN are in place.
//
// Any copy that implies RAABTA processes utility payments
// is incorrect and must use these constants instead.
// ─────────────────────────────────────────────────────────

class PaymentCopyConstants {
  PaymentCopyConstants._();

  static const String openProviderSite = 'Pay on Provider Website';

  static const String openProviderApp = 'Open Provider App';

  static const String payDirectlyHeader = '🔗  Pay Directly with Provider';

  static const String paymentDisclaimer =
      'RAABTA tracks your bills. '
      'Payment is made directly on the provider\'s '
      'website or app.';

  static const String tapPaymentsNotForBills =
      'In-app payment for utility bills requires an '
      'official aggregator agreement with this provider. '
      'Pay directly on their website for now.';

  static const String markPaidLabel = 'Mark as Paid';

  static const String markPaidTooltip =
      'Mark this bill as paid in your tracker. '
      'This does not process any payment.';

  static const String addBillSectionTitle = 'Add Bill';
  static const String myBillsTitle = 'Bill Tracker';
}
