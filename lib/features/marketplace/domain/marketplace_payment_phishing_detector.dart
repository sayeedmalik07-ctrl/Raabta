import 'package:raabta/features/marketplace/data/marketplace_payment_phishing_patterns_config.dart';
import 'package:raabta/features/marketplace/domain/marketplace_payment_url_allowlist.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';

enum MarketplacePhishingSignalKind {
  suspiciousUrl,
  paymentAuthorizationLanguage,
  qrCodeEmbedded,
}

class MarketplacePhishingSignal {
  const MarketplacePhishingSignal({
    required this.kind,
    required this.detailKey,
    this.detailValue,
  });

  final MarketplacePhishingSignalKind kind;
  final String detailKey;
  final String? detailValue;
}

class MarketplacePhishingScanResult {
  const MarketplacePhishingScanResult({
    required this.signals,
    required this.severity,
  });

  const MarketplacePhishingScanResult.clean()
      : signals = const [],
        severity = ScamShieldLocalSignal.low;

  final List<MarketplacePhishingSignal> signals;
  final ScamShieldLocalSignal severity;

  bool get hasSignals => signals.isNotEmpty;
}

/// Local deterministic scan for marketplace payment-quishing — zero AI.
abstract final class MarketplacePaymentPhishingDetector {
  static final _urlRegex = RegExp(
    r'(?:(?:https?://)|(?:www\.))[^\s<>"{}|\\^`\[\]]+',
    caseSensitive: false,
  );

  static final _bareDomainRegex = RegExp(
    r'\b([a-z0-9][-a-z0-9]*(?:\.[a-z0-9][-a-z0-9]*)+\.[a-z]{2,})\b',
    caseSensitive: false,
  );

  static MarketplacePhishingScanResult scan({
    required String text,
    String? embeddedQrPayload,
  }) {
    final signals = <MarketplacePhishingSignal>[];

    for (final url in _extractUrls(text)) {
      final host = _hostFromUrl(url);
      if (host.isNotEmpty && !MarketplacePaymentUrlAllowlist.isAllowedHost(host)) {
        signals.add(
          MarketplacePhishingSignal(
            kind: MarketplacePhishingSignalKind.suspiciousUrl,
            detailKey: 'mp_phish_signal_url',
            detailValue: host,
          ),
        );
      }
    }

    for (final domain in _extractBareDomains(text)) {
      if (MarketplacePaymentUrlAllowlist.isAllowedHost(domain)) continue;
      if (signals.any((s) => s.detailValue == domain)) continue;
      signals.add(
        MarketplacePhishingSignal(
          kind: MarketplacePhishingSignalKind.suspiciousUrl,
          detailKey: 'mp_phish_signal_url',
          detailValue: domain,
        ),
      );
    }

    final lower = text.toLowerCase();
    for (final pattern
        in MarketplacePaymentPhishingPatternsConfig.paymentAuthorizationPatterns) {
      if (lower.contains(pattern.toLowerCase())) {
        signals.add(
          const MarketplacePhishingSignal(
            kind: MarketplacePhishingSignalKind.paymentAuthorizationLanguage,
            detailKey: 'mp_phish_signal_payment_language',
          ),
        );
        break;
      }
    }

    if (embeddedQrPayload != null && embeddedQrPayload.trim().isNotEmpty) {
      signals.add(
        MarketplacePhishingSignal(
          kind: MarketplacePhishingSignalKind.qrCodeEmbedded,
          detailKey: 'mp_phish_signal_qr',
          detailValue: embeddedQrPayload.trim(),
        ),
      );
      final qrHost = _hostFromUrl(embeddedQrPayload);
      if (qrHost.isNotEmpty &&
          !MarketplacePaymentUrlAllowlist.isAllowedHost(qrHost) &&
          !signals.any((s) => s.kind == MarketplacePhishingSignalKind.suspiciousUrl)) {
        signals.add(
          MarketplacePhishingSignal(
            kind: MarketplacePhishingSignalKind.suspiciousUrl,
            detailKey: 'mp_phish_signal_url',
            detailValue: qrHost,
          ),
        );
      }
    }

    return MarketplacePhishingScanResult(
      signals: signals,
      severity: _severityFor(signals),
    );
  }

  static ScamShieldLocalSignal _severityFor(List<MarketplacePhishingSignal> signals) {
    if (signals.isEmpty) return ScamShieldLocalSignal.low;
    final kinds = signals.map((s) => s.kind).toSet();
    if (kinds.contains(MarketplacePhishingSignalKind.qrCodeEmbedded) &&
        kinds.contains(MarketplacePhishingSignalKind.paymentAuthorizationLanguage)) {
      return ScamShieldLocalSignal.high;
    }
    if (signals.length >= 2) return ScamShieldLocalSignal.medium;
    return ScamShieldLocalSignal.low;
  }

  static Iterable<String> _extractUrls(String text) sync* {
    for (final match in _urlRegex.allMatches(text)) {
      yield match.group(0)!;
    }
  }

  static Iterable<String> _extractBareDomains(String text) sync* {
    for (final match in _bareDomainRegex.allMatches(text)) {
      yield match.group(1)!;
    }
  }

  static String _hostFromUrl(String raw) {
    try {
      final normalized = raw.startsWith('http') ? raw : 'https://$raw';
      return Uri.parse(normalized).host.toLowerCase();
    } catch (_) {
      return '';
    }
  }
}
