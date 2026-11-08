import 'package:scam_shield_core/features/scam_shield/domain/evidence/outdated_brand_catalog.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_multilingual_matcher.dart';

class OutdatedBrandHit {
  const OutdatedBrandHit({required this.entry});

  final OutdatedBrandEntry entry;
}

abstract final class OutdatedBrandDetector {
  static const _actionCues = [
    'open',
    'update',
    'verify',
    'log in',
    'login',
    'click',
    'download',
    'install',
    'link',
    'tap',
    'افتح',
    'حدّث',
    'تحديث',
    'تحقق',
    'سجل',
    'اضغط',
    'رابط',
  ];

  static OutdatedBrandHit? detect(String text) {
    final lower = text.toLowerCase();
    final hasAction = _actionCues.any(
      (c) => ScamMultilingualMatcher.containsPattern(lower, c),
    );
    final hasUrl = RegExp(r'https?://', caseSensitive: false).hasMatch(text);
    if (!hasAction && !hasUrl) return null;

    for (final entry in OutdatedBrandCatalog.entries) {
      if (!entry.verified) continue;
      final terms = [entry.name, ...entry.matchAliases];
      if (terms.any((t) => ScamMultilingualMatcher.containsPattern(lower, t))) {
        return OutdatedBrandHit(entry: entry);
      }
    }
    return null;
  }
}
