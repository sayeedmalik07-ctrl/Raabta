import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class RegulatorRegisterLink {
  const RegulatorRegisterLink({
    required this.labelKey,
    required this.url,
    required this.verified,
    this.lastVerified,
  });

  final String labelKey;
  final String url;
  final bool verified;
  final DateTime? lastVerified;

  bool get isVisible => verified && url.trim().isNotEmpty;
}

class RegulatorRegisterEntry {
  const RegulatorRegisterEntry({
    required this.id,
    required this.nameKey,
    required this.scopeKey,
    required this.links,
  });

  final String id;
  final String nameKey;
  final String scopeKey;
  final List<RegulatorRegisterLink> links;

  List<RegulatorRegisterLink> get visibleLinks =>
      links.where((l) => l.isVisible).toList(growable: false);
}

class RegulatorRegisterCatalog {
  RegulatorRegisterCatalog({
    required this.regulators,
    required this.reportLinks,
    this.qfscamInfoUrl,
  });

  final List<RegulatorRegisterEntry> regulators;
  final List<RegulatorRegisterLink> reportLinks;
  final RegulatorRegisterLink? qfscamInfoUrl;

  List<RegulatorRegisterLink> get visibleReportLinks =>
      reportLinks.where((l) => l.isVisible).toList(growable: false);

  static const assetPath = 'assets/scam_shield/regulator_registers.json';
  static RegulatorRegisterCatalog? _cache;

  @visibleForTesting
  static void installForTest(RegulatorRegisterCatalog catalog) {
    _cache = catalog;
  }

  @visibleForTesting
  static void resetForTest() => _cache = null;

  static Future<RegulatorRegisterCatalog> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _cache = _parse(json);
    return _cache!;
  }

  static RegulatorRegisterCatalog _parse(Map<String, dynamic> json) {
    final regulatorsRaw = json['regulators'] as List<dynamic>? ?? [];
    final reportRaw = json['reportLinks'] as List<dynamic>? ?? [];
    final infoRaw = json['qfscamInfoUrl'] as Map<String, dynamic>?;
    return RegulatorRegisterCatalog(
      regulators: [
        for (final r in regulatorsRaw)
          if (r is Map<String, dynamic>) _parseRegulator(r),
      ],
      reportLinks: [
        for (final l in reportRaw)
          if (l is Map<String, dynamic>) _parseLink(l),
      ],
      qfscamInfoUrl: infoRaw == null ? null : _parseLink(infoRaw),
    );
  }

  static RegulatorRegisterEntry _parseRegulator(Map<String, dynamic> json) {
    final linksRaw = json['links'] as List<dynamic>? ?? [];
    return RegulatorRegisterEntry(
      id: json['id']?.toString() ?? '',
      nameKey: json['nameKey']?.toString() ?? '',
      scopeKey: json['scopeKey']?.toString() ?? '',
      links: [
        for (final l in linksRaw)
          if (l is Map<String, dynamic>) _parseLink(l),
      ],
    );
  }

  static RegulatorRegisterLink _parseLink(Map<String, dynamic> json) {
    final reviewed = json['lastVerified']?.toString();
    return RegulatorRegisterLink(
      labelKey: json['labelKey']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      verified: json['verified'] == true,
      lastVerified: reviewed == null || reviewed.isEmpty
          ? null
          : DateTime.tryParse(reviewed),
    );
  }
}
