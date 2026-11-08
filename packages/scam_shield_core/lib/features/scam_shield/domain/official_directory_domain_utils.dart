/// Host normalisation and lookalike heuristics for the official directory.
abstract final class OfficialDirectoryDomainUtils {
  static String normalizeHost(String host) {
    var h = host.trim().toLowerCase();
    if (h.startsWith('www.')) h = h.substring(4);
    h = _punycodeToUnicode(h);
    return h;
  }

  static String registrableDomain(String host) {
    final normalized = normalizeHost(host);
    final parts = normalized.split('.').where((p) => p.isNotEmpty).toList();
    if (parts.length <= 2) return normalized;
    if (parts.length >= 3 && parts[parts.length - 2] == 'gov' && parts.last == 'qa') {
      return parts.sublist(parts.length - 3).join('.');
    }
    if (parts.last == 'qa' && parts.length >= 3) {
      return parts.sublist(parts.length - 3).join('.');
    }
    return parts.sublist(parts.length - 2).join('.');
  }

  static bool exactRegistrableMatch(String host, String officialDomain) {
    return registrableDomain(host) == registrableDomain(officialDomain);
  }

  static bool isLookalikeOf(String host, String officialDomain) {
    final candidate = normalizeHost(host);
    final official = normalizeHost(officialDomain);
    if (candidate == official) return false;
    if (exactRegistrableMatch(candidate, official)) return false;

    final brand = official.split('.').first;
    if (brand.length < 3) return false;

    if (candidate.contains('$brand-') ||
        candidate.contains('-$brand') ||
        candidate.contains('${brand}secure') ||
        candidate.contains('secure$brand')) {
      return true;
    }

    final candidateReg = registrableDomain(candidate);
    final officialReg = registrableDomain(official);
    if (candidateReg != officialReg &&
        _brandStem(brand).isNotEmpty &&
        candidateReg.contains(_brandStem(brand)) &&
        candidateReg.contains('.')) {
      return true;
    }

    if (candidate.endsWith('.com') &&
        official.endsWith('.qa') &&
        candidate.startsWith('$brand.')) {
      return true;
    }

    if (candidate.split('.').length > official.split('.').length &&
        candidate.contains('.$brand.') &&
        !candidate.endsWith('.$official')) {
      return true;
    }

    return false;
  }

  static bool domainContainsPathOrSubdomainOnly(String domainField) {
    return domainField.contains('/') ||
        domainField.startsWith('http') ||
        domainField.contains('*');
  }

  static String _brandStem(String brand) {
    return brand.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  static String _punycodeToUnicode(String host) {
    if (!host.contains('xn--')) return host;
    try {
      final labels = host.split('.');
      final decoded = labels.map((label) {
        if (!label.startsWith('xn--')) return label;
        return Uri.decodeFull(label.replaceFirst('xn--', ''));
      }).join('.');
      return decoded;
    } catch (_) {
      return host;
    }
  }
}
