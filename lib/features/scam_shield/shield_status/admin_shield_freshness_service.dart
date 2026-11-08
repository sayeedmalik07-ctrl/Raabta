import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:raabta/config/compliance_config_fetch.dart';
import 'package:raabta/config/compliance_flags.dart';
import 'package:raabta/features/admin/models/admin_config.dart';
import 'package:raabta/features/legal_sources/data/legal_sources_seed_catalog.dart';
import 'package:raabta/features/scam_shield/domain/scam_advisory_models.dart';
import 'package:raabta/features/scam_shield/shield_status/admin_shield_freshness_models.dart';
import 'package:raabta/features/scam_shield/shield_status/shield_freshness_thresholds.dart';

/// Read-only admin freshness from bundled assets + cached config (Phase 31).
class AdminShieldFreshnessService {
  AdminShieldFreshnessService({AssetBundle? bundle, DateTime Function()? clock})
      : _bundle = bundle ?? rootBundle,
        _clock = clock ?? DateTime.now;

  final AssetBundle _bundle;
  final DateTime Function() _clock;

  Future<AdminShieldFreshnessReport> build({
    required AdminAppConfig config,
    required List<ScamAdvisory> cachedAdvisories,
  }) async {
    final now = _clock();
    final directoryRaw = await _loadJson('assets/official_directory.json');
    final entries = (directoryRaw['entries'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>();

    final attention = <AdminDirectoryStalenessEntry>[];
    final stale = <AdminDirectoryStalenessEntry>[];
    var hiddenUnverified = 0;

    for (final map in entries) {
      final verified = map['verified'] as bool? ?? false;
      if (!verified) hiddenUnverified++;

      final id = map['id']?.toString() ?? '';
      final name = map['nameEn']?.toString() ?? id;
      final lastRaw = map['lastVerified']?.toString();
      final last = lastRaw != null && lastRaw.isNotEmpty
          ? DateTime.tryParse(lastRaw)
          : null;
      final days = last != null ? now.difference(last).inDays : 9999;

      final row = AdminDirectoryStalenessEntry(
        id: id,
        displayName: name,
        daysSinceVerified: days,
        lastVerified: last,
      );

      if (days > ShieldFreshnessThresholds.directoryAttentionDays) {
        attention.add(row);
      }
      if (days > ShieldFreshnessThresholds.directoryStaleDays) {
        stale.add(row);
      }
    }

    final contentUnverified = await _countUnverifiedContentCards();
    final phraseLast = await _phraseDictionaryLastReviewed();

    var active = 0;
    var expired = 0;
    DateTime? latestPublish;
    for (final a in cachedAdvisories) {
      final published = a.publishedAt;
      if (published != null &&
          (latestPublish == null || published.isAfter(latestPublish))) {
        latestPublish = published;
      }
      if (a.status == ScamAdvisoryStatus.published &&
          a.expiresAt.isAfter(now)) {
        active++;
      } else {
        expired++;
      }
    }

    final daysSincePublish = latestPublish == null
        ? null
        : now.difference(latestPublish).inDays;

    final resolved = config.complianceFlags;
    final complianceMap = {
      for (final k in ComplianceFlagKeys.all)
        k: switch (k) {
          ComplianceFlagKeys.offersEnabled => resolved.offersEnabled,
          ComplianceFlagKeys.viewingsEnabled => resolved.viewingsEnabled,
          ComplianceFlagKeys.quotesEnabled => resolved.quotesEnabled,
          ComplianceFlagKeys.paidBoostsEnabled => resolved.paidBoostsEnabled,
          ComplianceFlagKeys.businessAdsEnabled => resolved.businessAdsEnabled,
          ComplianceFlagKeys.jobApplicationStatusEnabled =>
            resolved.jobApplicationStatusEnabled,
          ComplianceFlagKeys.businessQuotesEnabled =>
            resolved.businessQuotesEnabled,
          ComplianceFlagKeys.businessAppointmentsEnabled =>
            resolved.businessAppointmentsEnabled,
          _ => false,
        },
    };

    return AdminShieldFreshnessReport(
      directoryOlderThanAttentionDays: attention,
      directoryOlderThanStaleDays: stale,
      directoryUnverifiedHiddenCount: hiddenUnverified,
      contentCardUnverifiedCount: contentUnverified,
      activeAdvisoriesCount: active,
      expiredAdvisoriesCount: expired,
      daysSinceLastAdvisoryPublish: daysSincePublish,
      phraseDictionaryLastReviewed: phraseLast,
      legalSourcesLastUpdated: LegalSourcesSeedCatalog.seedLatestVerified,
      featureFlags: Map<String, bool>.from(config.featureFlags),
      complianceFlagsResolved: complianceMap,
      complianceFetchStale: ComplianceConfigFetch.isFetchStale,
      domainAgeEndpointEnabled: config.featureFlags['scam_domain_age'] == true,
      linkUnrollEndpointEnabled:
          config.featureFlags['scam_link_unroll'] == true,
      endpointHealthRecorded: false,
    );
  }

  Future<int> _countUnverifiedContentCards() async {
    var count = 0;
    count += await _countVerifiedFalseInJson('assets/scam_shield/security_guidance.json', [
      'topics',
    ]);
    final packs = [
      'assets/scam_shield/pattern_packs/one_ring_callback.json',
      'assets/scam_shield/pattern_packs/fake_fine_toll.json',
      'assets/scam_shield/pattern_packs/pay_to_earn_tasks.json',
      'assets/scam_shield/pattern_packs/recovery_offer.json',
      'assets/scam_shield/pattern_packs/investment_offer.json',
    ];
    for (final path in packs) {
      try {
        final map = await _loadJson(path);
        if (map['verified'] == false) count++;
      } catch (_) {}
    }
    count += await _countVerifiedFalseInJson(
      'assets/scam_shield/report_pack_channels.json',
      ['channels'],
    );
    return count;
  }

  Future<DateTime?> _phraseDictionaryLastReviewed() async {
    try {
      final map = await _loadJson('assets/scam_shield/security_guidance.json');
      final topics = map['topics'] as List<dynamic>? ?? [];
      DateTime? latest;
      for (final t in topics) {
        if (t is! Map<String, dynamic>) continue;
        final raw = t['lastReviewed']?.toString();
        final d = raw != null ? DateTime.tryParse(raw) : null;
        if (d != null && (latest == null || d.isAfter(latest))) latest = d;
      }
      final shared = map['sharedSomething'] as Map<String, dynamic>?;
      final sharedRaw = shared?['lastReviewed']?.toString();
      final sd =
          sharedRaw != null ? DateTime.tryParse(sharedRaw) : null;
      if (sd != null && (latest == null || sd.isAfter(latest))) latest = sd;
      return latest;
    } catch (_) {
      return null;
    }
  }

  Future<int> _countVerifiedFalseInJson(
    String path,
    List<String> listKeys,
  ) async {
    try {
      final map = await _loadJson(path);
      var count = 0;
      for (final key in listKeys) {
        final list = map[key] as List<dynamic>? ?? [];
        for (final item in list) {
          if (item is Map && item['verified'] == false) count++;
        }
      }
      return count;
    } catch (_) {
      return 0;
    }
  }

  Future<Map<String, dynamic>> _loadJson(String path) async {
    final raw = await _bundle.loadString(path);
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
