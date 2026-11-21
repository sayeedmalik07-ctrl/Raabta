import 'package:scam_shield_core/features/marketplace/data/marketplace_platform_hop_patterns_config.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_multilingual_matcher.dart';

enum MarketplacePlatformHopSignalKind {
  offPlatformUrl,
  combinedMoveLanguage,
  platformWithMoveIntent,
}

class MarketplacePlatformHopSignal {
  const MarketplacePlatformHopSignal({required this.kind});

  final MarketplacePlatformHopSignalKind kind;
}

class MarketplacePlatformHopScanResult {
  const MarketplacePlatformHopScanResult({required this.signals});

  const MarketplacePlatformHopScanResult.clean() : signals = const [];

  final List<MarketplacePlatformHopSignal> signals;

  bool get hasSignal => signals.isNotEmpty;
}

/// Deterministic platform-hop scan for Marketplace chat — zero AI, non-blocking.
abstract final class MarketplacePlatformHopDetector {
  static final _urlRegex = RegExp(
    r'(?:(?:https?://)|(?:www\.))[^\s<>"{}|\\^`\[\]]+',
    caseSensitive: false,
  );

  static MarketplacePlatformHopScanResult scan({required String text}) {
    if (text.trim().isEmpty) {
      return const MarketplacePlatformHopScanResult.clean();
    }

    final signals = <MarketplacePlatformHopSignal>[];
    final normalized = _normalize(text);

    if (_hasOffPlatformUrl(text, normalized)) {
      signals.add(
        const MarketplacePlatformHopSignal(
          kind: MarketplacePlatformHopSignalKind.offPlatformUrl,
        ),
      );
      return MarketplacePlatformHopScanResult(signals: signals);
    }

    for (final phrase in MarketplacePlatformHopPatternsConfig.combinedMovePhrases) {
      if (ScamMultilingualMatcher.containsPattern(normalized, phrase)) {
        signals.add(
          const MarketplacePlatformHopSignal(
            kind: MarketplacePlatformHopSignalKind.combinedMoveLanguage,
          ),
        );
        return MarketplacePlatformHopScanResult(signals: signals);
      }
    }

    if (_hasPlatformWithMoveIntent(normalized)) {
      signals.add(
        const MarketplacePlatformHopSignal(
          kind: MarketplacePlatformHopSignalKind.platformWithMoveIntent,
        ),
      );
    }

    return MarketplacePlatformHopScanResult(signals: signals);
  }

  static String _normalize(String text) {
    return ScamMultilingualMatcher.normalize(text).replaceAll(RegExp(r'\s+'), ' ');
  }

  static bool _hasOffPlatformUrl(String raw, String normalized) {
    for (final pattern
        in MarketplacePlatformHopPatternsConfig.offPlatformUrlPatterns) {
      if (normalized.contains(pattern.toLowerCase())) return true;
    }

    for (final match in _urlRegex.allMatches(raw)) {
      final url = match.group(0)!.toLowerCase();
      for (final pattern
          in MarketplacePlatformHopPatternsConfig.offPlatformUrlPatterns) {
        if (url.contains(pattern)) return true;
      }
    }

    return false;
  }

  static bool _hasPlatformWithMoveIntent(String normalized) {
    var hasPlatform = false;
    for (final platform
        in MarketplacePlatformHopPatternsConfig.platformIdentifiers) {
      if (ScamMultilingualMatcher.containsPattern(normalized, platform)) {
        hasPlatform = true;
        break;
      }
    }
    if (!hasPlatform) return false;

    for (final move
        in MarketplacePlatformHopPatternsConfig.moveLanguagePhrases) {
      if (ScamMultilingualMatcher.containsPattern(normalized, move)) {
        return true;
      }
    }
    return false;
  }
}
