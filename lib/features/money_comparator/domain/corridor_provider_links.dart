/// Stable outbound links for common remittance providers (comparison only — no transfers).
abstract final class CorridorProviderLinks {
  static String? urlForProvider(String providerName) {
    final key = providerName.trim().toLowerCase();
    if (_links.containsKey(key)) return _links[key];
    for (final entry in _links.entries) {
      if (key.contains(entry.key) || entry.key.contains(key)) {
        return entry.value;
      }
    }
    return null;
  }

  static const Map<String, String> _links = {
    'western union': 'https://www.westernunion.com/qa/en/home.html',
    'moneygram': 'https://www.moneygram.com/qa/en',
    'al fardan': 'https://www.alfardanexchange.com.qa',
    'alfardan': 'https://www.alfardanexchange.com.qa',
    'doha bank': 'https://www.dohabank.com.qa',
    'qnb': 'https://www.qnb.com.qa',
    'commercial bank': 'https://www.cbq.qa',
    'cbq': 'https://www.cbq.qa',
    'ria': 'https://www.riamoneytransfer.com/en-us/',
    'wise': 'https://wise.com/',
    'remitly': 'https://www.remitly.com/',
    'worldremit': 'https://www.worldremit.com/',
    'tap tap send': 'https://www.taptapsend.com/',
    'taptap send': 'https://www.taptapsend.com/',
    'xpress money': 'https://www.xpressmoney.com/',
  };
}
