/// Single source of truth for Qatar utility bill providers in Bill Tracker.
///
/// Residential gas is billed through [kahramaa] (electricity & water) — not a
/// separate consumer brand. Qatargas is an LNG producer, not a household biller.
abstract final class QatarBillProviders {
  static const all = [
    kahramaa,
    ooredoo,
    vodafoneQatar,
    qatarCool,
    marafeqQatar,
    bein,
    privateRent,
    other,
  ];

  /// Providers with an official online payment portal (footer deep-links).
  static List<QatarBillProvider> get withPaymentUrl =>
      all.where((p) => p.url.isNotEmpty).toList();

  static QatarBillProvider? byName(String name) {
    final trimmed = name.trim();
    if (deprecatedProviderNames.contains(trimmed)) return kahramaa;
    final normalized = trimmed.toLowerCase();
    for (final provider in all) {
      if (provider.name.toLowerCase() == normalized) return provider;
      for (final alias in provider.aliases) {
        if (alias.toLowerCase() == normalized) return provider;
      }
    }
    return null;
  }

  static const kahramaa = QatarBillProvider(
    id: 'kahramaa',
    name: 'Kahramaa',
    category: 'Electricity & Water',
    emoji: '⚡',
    url: 'https://www.km.qa/',
    aliases: ['KAHRAMAA', 'Qatar General Electricity'],
  );

  static const ooredoo = QatarBillProvider(
    id: 'ooredoo',
    name: 'Ooredoo',
    category: 'Telecom',
    emoji: '📱',
    url: 'https://www.ooredoo.qa/',
  );

  static const vodafoneQatar = QatarBillProvider(
    id: 'vodafone',
    name: 'Vodafone Qatar',
    category: 'Telecom',
    emoji: '📡',
    url: 'https://www.vodafone.qa/',
    aliases: ['Vodafone'],
  );

  static const qatarCool = QatarBillProvider(
    id: 'qatar_cool',
    name: 'Qatar Cool',
    category: 'District Cooling',
    emoji: '❄️',
    url: 'https://www.qatarcool.com/',
  );

  /// District cooling for Lusail City and other Marafeq-served developments.
  static const marafeqQatar = QatarBillProvider(
    id: 'marafeq',
    name: 'Marafeq Qatar',
    category: 'District Cooling',
    emoji: '🌡️',
    url: 'https://www.marafeq.qa/',
    aliases: ['Marafeq', 'MARAFEQ'],
  );

  static const bein = QatarBillProvider(
    id: 'bein',
    name: 'beIN',
    category: 'Entertainment',
    emoji: '📺',
    url: 'https://www.bein.com/',
    aliases: ['beIN SPORTS', 'beIN Media'],
  );

  static const privateRent = QatarBillProvider(
    id: 'private_rent',
    name: 'Private Rent',
    category: 'Housing',
    emoji: '🏠',
    url: '',
  );

  static const other = QatarBillProvider(
    id: 'other',
    name: 'Other',
    category: 'Other',
    emoji: '📄',
    url: '',
  );

  /// Legacy stored value — map to [kahramaa] in UI when editing old bills.
  static const deprecatedProviderNames = {'Qatar Gas', 'Qatargas'};

  /// Maps legacy stored provider names (e.g. removed Qatargas) for display/save.
  static String normalizeStoredProviderName(String stored) =>
      byName(stored)?.name ?? stored;
}

class QatarBillProvider {
  const QatarBillProvider({
    required this.id,
    required this.name,
    required this.category,
    required this.emoji,
    required this.url,
    this.aliases = const [],
  });

  final String id;
  final String name;
  final String category;
  final String emoji;
  final String url;
  final List<String> aliases;
}

/// Provider names accepted by Claude bill extraction fallback.
const qatarBillProviderClaudeList =
    'Kahramaa|Ooredoo|Vodafone Qatar|Qatar Cool|Marafeq Qatar|beIN|unknown';
