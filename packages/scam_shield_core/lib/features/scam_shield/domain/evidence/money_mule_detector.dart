import 'package:scam_shield_core/features/scam_shield/domain/scam_multilingual_matcher.dart';

/// Bundled money-mule recruitment phrases — generic, no accused parties.
abstract final class MoneyMuleDetector {
  static const _strongGroups = [
    ['receive and forward', 'forward money', 'transfer money for'],
    ['use your bank account', 'rent your bank account', 'lend your account'],
    ['use your sim', 'rent your sim', 'lend your sim'],
    ['use your qid', 'lend your id', 'open account for employer'],
    ['keep a commission', 'commission on transfer'],
    ['buy crypto for', 'purchase crypto for someone'],
  ];

  static const _jobContext = [
    'job offer',
    'work from home',
    'easy money',
    'earn money',
    'employment opportunity',
    'وظيفة',
    'عمل من المنزل',
    'اربح',
  ];

  static bool detect(String text) {
    final lower = text.toLowerCase();
    var groupHits = 0;
    for (final group in _strongGroups) {
      if (group.any((p) => ScamMultilingualMatcher.containsPattern(lower, p))) {
        groupHits++;
      }
    }
    if (groupHits >= 2) return true;
    if (groupHits >= 1 &&
        _jobContext.any((p) => ScamMultilingualMatcher.containsPattern(lower, p))) {
      return true;
    }
    return false;
  }
}
