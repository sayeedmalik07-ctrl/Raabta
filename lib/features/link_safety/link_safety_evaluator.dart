import 'package:flutter/foundation.dart';
import 'package:raabta/features/link_safety/link_safety_models.dart';
import 'package:raabta/features/link_safety/link_url_extractor.dart';
import 'package:raabta/features/marketplace/domain/marketplace_payment_phishing_detector.dart';
import 'package:raabta/features/scam_shield/domain/official_directory.dart';
import 'package:raabta/features/scam_shield/domain/official_directory_domain_utils.dart';
import 'package:raabta/features/scam_shield/domain/official_directory_models.dart';

/// In-memory memo only — no persistence (Phase 32).
abstract final class LinkSafetyEvaluator {
  static const maxLabelsPerItem = 2;

  static final _urlMemo = <String, LinkSafetyUrlLabel?>{};

  @visibleForTesting
  static void clearMemoForTests() => _urlMemo.clear();

  static const _urlShorteners = {
    'bit.ly',
    'tinyurl.com',
    't.co',
    'goo.gl',
    'ow.ly',
    'is.gd',
    'buff.ly',
    'cutt.ly',
    'rebrand.ly',
    'shorturl.at',
    't.ly',
    'rb.gy',
  };

  static LinkSafetyTextAssessment assessText({
    required String text,
    required LinkSafetySurface surface,
    required String locale,
  }) {
    if (text.trim().isEmpty) return LinkSafetyTextAssessment.empty;

    final urls = LinkUrlExtractor.extractUrlsInOrder(text);
    if (urls.isEmpty) return LinkSafetyTextAssessment.empty;

    final labels = <LinkSafetyUrlLabel>[];
    for (final url in urls) {
      final label = _memoizedUrlLabel(
        url,
        surface: surface,
        locale: locale,
        fullText: text,
      );
      if (label != null) labels.add(label);
    }

    labels.sort((a, b) => _priority(a.type).compareTo(_priority(b.type)));
    final capped = labels.take(maxLabelsPerItem).toList();

    return LinkSafetyTextAssessment(urls: urls, labels: capped);
  }

  static LinkSafetyUrlLabel? assessSingleUrl({
    required String url,
    required LinkSafetySurface surface,
    required String locale,
    String? fullText,
  }) {
    return _memoizedUrlLabel(
      url,
      surface: surface,
      locale: locale,
      fullText: fullText ?? url,
    );
  }

  static int _priority(LinkSafetyLabelType type) {
    return switch (type) {
      LinkSafetyLabelType.lookalikeOfficial => 0,
      LinkSafetyLabelType.apkLink => 1,
      LinkSafetyLabelType.paymentLinkInChat => 2,
      LinkSafetyLabelType.shortenedLink => 3,
    };
  }

  static LinkSafetyUrlLabel? _memoizedUrlLabel(
    String url, {
    required LinkSafetySurface surface,
    required String locale,
    required String fullText,
  }) {
    final key = '$surface|$url';
    if (_urlMemo.containsKey(key)) return _urlMemo[key];
    final result = _evaluateUrl(
      url,
      surface: surface,
      locale: locale,
      fullText: fullText,
    );
    _urlMemo[key] = result;
    return result;
  }

  static LinkSafetyUrlLabel? _evaluateUrl(
    String url, {
    required LinkSafetySurface surface,
    required String locale,
    required String fullText,
  }) {
    final host = _hostFromUrl(url);
    if (host.isEmpty) return null;

    final normalized = OfficialDirectoryDomainUtils.normalizeHost(host);

    if (OfficialDirectory.isKnownLegitimateHost(normalized)) {
      return null;
    }

    if (_isApkLink(url)) {
      return LinkSafetyUrlLabel(url: url, type: LinkSafetyLabelType.apkLink);
    }

    final lookalike = _lookalikeTarget(normalized, locale);
    if (lookalike != null) {
      return LinkSafetyUrlLabel(
        url: url,
        type: LinkSafetyLabelType.lookalikeOfficial,
        officialOrganisationName: lookalike,
      );
    }

    if (_isClassifiedChat(surface)) {
      final scan = MarketplacePaymentPhishingDetector.scan(text: fullText);
      final paymentHit = scan.signals.any(
        (s) =>
            s.kind == MarketplacePhishingSignalKind.suspiciousUrl &&
            (s.detailValue == normalized || s.detailValue == host),
      );
      if (paymentHit) {
        return LinkSafetyUrlLabel(
          url: url,
          type: LinkSafetyLabelType.paymentLinkInChat,
        );
      }
    }

    if (_isShortener(normalized)) {
      return LinkSafetyUrlLabel(
        url: url,
        type: LinkSafetyLabelType.shortenedLink,
      );
    }

    return null;
  }

  static bool _isClassifiedChat(LinkSafetySurface surface) {
    return switch (surface) {
      LinkSafetySurface.marketplaceChat ||
      LinkSafetySurface.housingChat ||
      LinkSafetySurface.servicesChat ||
      LinkSafetySurface.jobsChat =>
        true,
      _ => false,
    };
  }

  static bool _isApkLink(String url) {
    return url.toLowerCase().contains('.apk');
  }

  static bool _isShortener(String normalizedHost) {
    for (final shortener in _urlShorteners) {
      if (normalizedHost == shortener ||
          normalizedHost.endsWith('.$shortener')) {
        return true;
      }
    }
    return false;
  }

  static String? _lookalikeTarget(String normalizedHost, String locale) {
    if (OfficialDirectory.lookupByDomain(normalizedHost) != null) return null;

    OfficialDirectoryEntry? matched;
    for (final entry in OfficialDirectory.snapshot.verifiedEntries) {
      for (final domain in entry.officialDomains) {
        if (OfficialDirectoryDomainUtils.isLookalikeOf(normalizedHost, domain)) {
          matched = entry;
          break;
        }
      }
      if (matched != null) break;
    }

    if (matched == null) return null;
    return matched.displayName(locale);
  }

  static String _hostFromUrl(String raw) {
    try {
      final withScheme = raw.startsWith('http') ? raw : 'https://$raw';
      return Uri.parse(withScheme).host.toLowerCase();
    } catch (_) {
      return '';
    }
  }
}
