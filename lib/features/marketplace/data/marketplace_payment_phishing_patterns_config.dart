/// Marketplace payment-quishing patterns — bundled, offline, scoped for Phase 4 extension.
abstract final class MarketplacePaymentPhishingPatternsConfig {
  static const version = 1;

  /// Payment-authorization framing (EN + AR) — not generic OTP/urgency alone.
  static const paymentAuthorizationPatterns = [
    'scan this to receive payment',
    'scan to receive payment',
    'scan this to get paid',
    'scan to get paid',
    'verify to get paid',
    'verify to receive payment',
    'confirm your card to release funds',
    'confirm card to release',
    'authorize payment',
    'payment authorization',
    'release funds',
    'receive your payment',
    'click to receive payment',
    'qr code to receive',
    'scan qr to receive',
    'امسح هذا لاستلام الدفع',
    'امسح لاستلام المبلغ',
    'امسح لاستلام الدفع',
    'تحقق لاستلام المبلغ',
    'أكد بطاقتك لتحرير الأموال',
    'رمز qr للدفع',
    'مسح رمز',
    'تأكيد الدفع',
  ];
}
