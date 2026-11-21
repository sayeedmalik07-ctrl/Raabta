import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:raabta/config/compliance_flags.dart';
import 'package:raabta/features/scam_shield/forewarnings/forewarning_models.dart';
import 'package:raabta/features/scam_shield/forewarnings/forewarning_moment_id.dart';

/// Typed registry + bundled JSON (English/Arabic via underlying string tables).
abstract final class ForewarningMoments {
  static const assetPath = 'assets/scam_shield/forewarning_moments.json';
  static List<ForewarningMomentDefinition>? _cache;

  static Future<List<ForewarningMomentDefinition>> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = decoded['moments'] as List<dynamic>? ?? [];
    _cache = [
      for (final item in list)
        if (item is Map<String, dynamic>) _parseMoment(item),
    ];
    return _cache!;
  }

  static ForewarningMomentDefinition? byId(ForewarningMomentId id) {
    final list = _cache;
    if (list == null) return null;
    for (final m in list) {
      if (m.id == id) return m;
    }
    return null;
  }

  static ForewarningMomentDefinition _parseMoment(Map<String, dynamic> json) {
    final id = ForewarningMomentId.fromStorageKey(json['id']?.toString() ?? '');
    if (id == null) {
      throw FormatException('Unknown forewarning moment id: ${json['id']}');
    }
    final variantsRaw = json['variants'] as List<dynamic>? ?? [];
    final variants = [
      for (final v in variantsRaw)
        if (v is Map)
          ForewarningVariantRef(reuseKey: v['reuseKey']?.toString() ?? ''),
    ];
    return ForewarningMomentDefinition(
      id: id,
      sourceLabel: json['sourceLabel']?.toString() ?? 'Pattern check',
      requiresFlag: json['requiresFlag'] as String?,
      ctaTarget: _parseCta(json['ctaTarget']?.toString()),
      advisoryCategory: json['advisoryCategory'] as String?,
      variants: variants,
    );
  }

  static ForewarningCtaTarget _parseCta(String? raw) {
    return switch (raw) {
      'payment_check' => ForewarningCtaTarget.paymentCheck,
      'official_directory' => ForewarningCtaTarget.officialDirectory,
      'agency_verification' => ForewarningCtaTarget.agencyVerification,
      _ => ForewarningCtaTarget.none,
    };
  }

  static bool passesComplianceGate(
    ForewarningMomentDefinition moment,
    ComplianceFlags flags,
  ) {
    final key = moment.requiresFlag;
    if (key == null) return true;
    return switch (key) {
      ComplianceFlagKeys.offersEnabled => flags.offersEnabled,
      ComplianceFlagKeys.viewingsEnabled => flags.viewingsEnabled,
      ComplianceFlagKeys.quotesEnabled => flags.quotesEnabled,
      ComplianceFlagKeys.businessQuotesEnabled => flags.businessQuotesEnabled,
      _ => true,
    };
  }
}
