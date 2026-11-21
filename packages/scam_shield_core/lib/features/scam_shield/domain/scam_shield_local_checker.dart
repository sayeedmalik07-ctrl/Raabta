import 'package:scam_shield_core/features/marketplace/domain/marketplace_platform_hop_detector.dart';
import 'package:scam_shield_core/features/scam_shield/data/scam_multilingual_dictionary_config.dart';
import 'package:scam_shield_core/features/scam_shield/domain/evidence/money_mule_detector.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_multilingual_matcher.dart';
import 'package:scam_shield_core/features/scam_shield/domain/official_directory.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_shield_models.dart';
import 'package:scam_shield_core/features/scam_shield/pattern_packs/scam_pattern_pack_detector.dart';
import 'package:scam_shield_core/features/scam_shield/pattern_packs/scam_pattern_pack_loader.dart';

/// Level 0 deterministic checks — zero AI cost.
abstract final class ScamShieldLocalChecker {
  static final _urlRegex = RegExp(
    r'(?:(?:https?://)|(?:www\.))[^\s<>"{}|\\^`\[\]]+',
    caseSensitive: false,
  );

  static final _bareDomainRegex = RegExp(
    r'\b([a-z0-9][-a-z0-9]*(?:\.[a-z0-9][-a-z0-9]*)+\.[a-z]{2,})\b',
    caseSensitive: false,
  );

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

  static final _keywordRules = [
    _KeywordRule('ss_flag_otp', ScamMultilingualDictionaryConfig.legacyFlagPatterns['ss_flag_otp']!),
    _KeywordRule('ss_flag_urgency', ScamMultilingualDictionaryConfig.legacyFlagPatterns['ss_flag_urgency']!),
    _KeywordRule('ss_flag_unusual_payment', ScamMultilingualDictionaryConfig.legacyFlagPatterns['ss_flag_unusual_payment']!),
    _KeywordRule('ss_flag_prize', ScamMultilingualDictionaryConfig.legacyFlagPatterns['ss_flag_prize']!),
    _KeywordRule('ss_flag_upfront_fee', ScamMultilingualDictionaryConfig.legacyFlagPatterns['ss_flag_upfront_fee']!),
    _KeywordRule('ss_flag_impersonation', ScamMultilingualDictionaryConfig.legacyFlagPatterns['ss_flag_impersonation']!),
  ];

  static ScamShieldLocalCheckResult check({
    required String text,
    required ScamShieldContentType contentType,
  }) {
    final redFlags = <String>[];
    final urlFindings = <ScamShieldUrlFinding>[];

    if (contentType == ScamShieldContentType.websiteUrl && text.trim().isNotEmpty) {
      final urls = _extractUrls(text);
      if (urls.isEmpty) {
        redFlags.add('ss_flag_no_valid_url');
      }
    }

    for (final url in _extractUrls(text)) {
      urlFindings.add(_analyzeUrl(url));
    }

    for (final domain in _extractBareDomains(text)) {
      if (urlFindings.any((f) => f.domain == domain)) continue;
      urlFindings.add(_analyzeDomain(domain, original: domain));
    }

    for (final rule in _keywordRules) {
      if (_matchesAny(text, rule.patterns)) {
        redFlags.add(rule.flagKey);
      }
    }

    if (OfficialDirectory.detectSideloadApp(text)) {
      redFlags.add('ss_flag_sideload_app');
    }

    if (MoneyMuleDetector.detect(text)) {
      // Risk merge: transferRequest (14) + paymentRequest (12) via [ScamRiskSignalX.fromLegacyFlag].
      redFlags.add('ss_flag_money_mule');
    }

    if (MarketplacePlatformHopDetector.scan(text: text).hasSignal) {
      // Risk merge: secrecyRequest (12) + antiVerificationInstruction (16).
      redFlags.add('ss_flag_platform_hop');
    }

    for (final finding in urlFindings) {
      redFlags.addAll(finding.flags);
    }

    redFlags.addAll(ScamPatternPackDetector.detectLocalFlagsSync(text));
    if (ScamPatternPackDetector.detectFakeFineToll(
          text: text,
          urlFindings: urlFindings,
        ) &&
        ScamPatternPackLoader.cache.any(
          (p) => p.id == 'fake_fine_toll' && p.verified,
        )) {
      redFlags.add('ss_flag_fake_fine_toll');
    }

    final uniqueFlags = redFlags.toSet().toList();
    final signal = ScamShieldLocalSignalX.fromFlagCount(uniqueFlags.length);

    return ScamShieldLocalCheckResult(
      signal: signal,
      redFlags: uniqueFlags,
      urlFindings: urlFindings,
      flagCount: uniqueFlags.length,
    );
  }

  static List<String> _extractUrls(String text) {
    return _urlRegex
        .allMatches(text)
        .map((m) => m.group(0)!)
        .map((u) => u.endsWith('.') || u.endsWith(',') ? u.substring(0, u.length - 1) : u)
        .toList();
  }

  static List<String> _extractBareDomains(String text) {
    return _bareDomainRegex
        .allMatches(text)
        .map((m) => m.group(1)!)
        .where((d) => !d.contains('@'))
        .toList();
  }

  static ScamShieldUrlFinding _analyzeUrl(String url) {
    var host = url.toLowerCase();
    host = host.replaceFirst(RegExp(r'^https?://'), '');
    host = host.replaceFirst(RegExp(r'^www\.'), '');
    host = host.split('/').first.split(':').first;
    return _analyzeDomain(host, original: url);
  }

  static ScamShieldUrlFinding _analyzeDomain(
    String domain, {
    required String original,
  }) {
    final flags = <String>[];
    final normalized = domain.toLowerCase().replaceFirst(RegExp(r'^www\.'), '');

    if (OfficialDirectory.isKnownLegitimateHost(normalized)) {
      return ScamShieldUrlFinding(
        url: original,
        domain: normalized,
        isKnownLegitimate: true,
        flags: flags,
      );
    }

    if (_looksLikeIpHost(normalized)) {
      flags.add('ss_flag_ip_url');
    }

    for (final shortener in _urlShorteners) {
      if (normalized == shortener || normalized.endsWith('.$shortener')) {
        flags.add('ss_flag_url_shortener');
        break;
      }
    }

    if (OfficialDirectory.detectLookalikeDomain(normalized)) {
      flags.add('ss_flag_lookalike_domain');
    }

    if (_claimsGovBankInDomain(normalized) && !normalized.endsWith('.gov.qa')) {
      flags.add('ss_flag_nonstandard_gov_tld');
    }

    if (normalized.contains('-secure') ||
        normalized.contains('-verify') ||
        normalized.contains('secure-')) {
      flags.add('ss_flag_suspicious_subdomain');
    }

    return ScamShieldUrlFinding(
      url: original,
      domain: normalized,
      isKnownLegitimate: false,
      flags: flags,
    );
  }

  static bool _looksLikeIpHost(String host) {
    return RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(host);
  }

  static bool _claimsGovBankInDomain(String host) {
    const tokens = ['gov', 'moi', 'qnb', 'hukoomi', 'metrash', 'adlsa', 'mol'];
    return tokens.any((t) => host.contains(t));
  }

  static bool _matchesAny(String text, List<String> patterns) {
    return patterns.any((p) => ScamMultilingualMatcher.containsPattern(text, p));
  }
}

class _KeywordRule {
  const _KeywordRule(this.flagKey, this.patterns);

  final String flagKey;
  final List<String> patterns;
}
