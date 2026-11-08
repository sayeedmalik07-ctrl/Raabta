import 'package:raabta/features/scam_shield/domain/scam_qatar_domain_allowlist.dart';

/// Legitimate domains for marketplace link context — low-confidence flag if absent.
abstract final class MarketplacePaymentUrlAllowlist {
  static const _paymentProcessorHosts = {
    'tap.company',
    'stripe.com',
    'paypal.com',
    'pay.google.com',
    'apple.com',
  };

  static const _raabtaHosts = {
    'raabtaone.com',
    'raabta.app',
    'www.raabtaone.com',
  };

  static bool isAllowedHost(String host) {
    final normalized = _normalizeHost(host);
    if (ScamQatarDomainAllowlist.isKnownLegitimate(normalized)) return true;
    if (_raabtaHosts.contains(normalized)) return true;
    if (_paymentProcessorHosts.contains(normalized)) return true;
    return _paymentProcessorHosts.any(
      (allowed) => normalized == allowed || normalized.endsWith('.$allowed'),
    );
  }

  static String _normalizeHost(String host) {
    var h = host.trim().toLowerCase();
    if (h.startsWith('www.')) h = h.substring(4);
    return h;
  }
}
