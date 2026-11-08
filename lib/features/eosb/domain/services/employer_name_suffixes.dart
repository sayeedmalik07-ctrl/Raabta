/// Common employer legal/trade suffixes stripped during normalization.
///
/// Matched as trailing tokens only (longest-first) after lowercasing and
/// punctuation collapse. Extend this list as new Qatar/GCC patterns appear.
abstract final class EmployerNameSuffixes {
  static const suffixTokens = [
    'establishment',
    'corporation',
    'international',
    'holdings',
    'company',
    'trading',
    'limited',
    'holding',
    'qpsc',
    'group',
    'corp',
    'intl',
    'ltd',
    'inc',
    'est',
    'qsc',
    'wll',
    'llc',
    'co',
  ];
}
