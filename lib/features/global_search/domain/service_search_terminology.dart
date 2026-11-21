/// Deterministic service-trade terminology for Global Search (S3 / S7).
library;

import 'package:raabta/features/global_search/domain/multilingual_query_normalizer.dart';

abstract final class ServiceSearchTerminology {
  static const jobMetaKeywords = [
    'job',
    'jobs',
    'hiring',
    'vacancy',
    'vacancies',
    'employment',
    'career',
    'position',
    'positions',
    'work permit',
  ];

  static const businessMetaKeywords = [
    'company',
    'business',
    'shop',
    'store',
    'restaurant',
    'firm',
    'enterprise',
  ];

  static const proximityNoise = [
    'near me',
    'nearby',
    'around me',
    'close to me',
  ];

  static const tradeKeywords = [
    // Electrical
    'electrician',
    'electrical',
    'electric work',
    'wiring',
    // Plumbing
    'plumber',
    'plumbing',
    'pipe repair',
    'water leak',
    // AC
    'ac repair',
    'air conditioner',
    'air conditioning',
    'hvac',
    'ac technician',
    // Cleaning
    'cleaning',
    'cleaner',
    'house cleaning',
    'deep cleaning',
    'maid service',
    // Painting
    'painter',
    'painting',
    'wall painting',
    // Carpentry
    'carpenter',
    'carpentry',
    'furniture repair',
    // Moving
    'moving',
    'mover',
    'shifting',
    'house shifting',
    // Vehicle
    'car repair',
    'mechanic',
    'auto repair',
    'car wash',
    'car detailing',
    // Technology
    'mobile repair',
    'phone repair',
    'computer repair',
    'laptop repair',
    // Pest
    'pest control',
    'pest treatment',
    // Home maintenance
    'maintenance',
    'handyman',
    'home repair',
    // Beauty
    'salon',
    'barber',
    'beauty service',
    // Tailoring
    'tailor',
    'alteration',
    // Driving
    'driver',
    'chauffeur',
  ];

  static const explicitServicePhrases = [
    'cleaning service',
    'maintenance service',
    'repair service',
    'moving service',
    'beauty service',
  ];

  /// Canonical lower-case query after multilingual normalization (S7).
  static String canonicalLower(String query) {
    return MultilingualQueryNormalizer.normalize(query).canonicalLower;
  }

  /// Keyword hit count for [findService] intent scoring.
  static int score(String query) {
    final lower = canonicalLower(query);
    var hits = 0;
    for (final phrase in explicitServicePhrases) {
      if (lower.contains(phrase)) hits += 2;
    }
    for (final keyword in tradeKeywords) {
      if (lower.contains(keyword)) hits++;
    }
    if (lower.contains(' service')) hits++;
    return hits;
  }

  static bool hasStrongJobSignal(String query) {
    final lower = canonicalLower(query);
    for (final keyword in jobMetaKeywords) {
      if (lower.contains(keyword)) return true;
    }
    return false;
  }

  static bool hasStrongBusinessSignal(String query) {
    final lower = canonicalLower(query);
    for (final keyword in businessMetaKeywords) {
      if (lower.contains(keyword)) return true;
    }
    return false;
  }

  /// Primary matched trade label for filters / subtitles.
  static String? extractTrade(String query) {
    final lower = canonicalLower(query);
    for (final phrase in explicitServicePhrases) {
      if (lower.contains(phrase)) {
        return _titleCase(phrase.replaceAll(' service', '').trim());
      }
    }
    for (final keyword in tradeKeywords) {
      if (lower.contains(keyword)) return _titleCase(keyword);
    }
    return null;
  }

  /// Strips proximity/area noise so Firestore matching focuses on the trade.
  static String cleanServiceQuery(String query) {
    var cleaned = canonicalLower(query).trim();
    for (final noise in proximityNoise) {
      cleaned = cleaned.replaceAll(noise, ' ');
    }
    cleaned = cleaned.replaceAll(RegExp(r'\bin\s+[a-z\s]+\b'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\bnear\b'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned;
  }

  static String _titleCase(String value) {
    return value
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}
