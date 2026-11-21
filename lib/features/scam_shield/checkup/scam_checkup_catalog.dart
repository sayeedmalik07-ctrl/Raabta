import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:raabta/features/scam_shield/checkup/scam_checkup_models.dart';
import 'package:raabta/features/scam_shield/platform/scam_proactive_protection_platform.dart';

abstract final class ScamCheckupCatalog {
  static const assetPath = 'assets/scam_shield/scam_checkup_items.json';
  static List<ScamCheckupItem>? _cache;

  @visibleForTesting
  static void installForTest(List<ScamCheckupItem> items) {
    _cache = items;
  }

  @visibleForTesting
  static void resetForTest() {
    _cache = null;
  }

  static Future<List<ScamCheckupItem>> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = decoded['items'] as List<dynamic>? ?? [];
    _cache = [
      for (final item in list)
        if (item is Map<String, dynamic>) _parseItem(item),
    ];
    return _cache!;
  }

  static List<ScamCheckupItem> visibleItems(List<ScamCheckupItem> all) {
    return all.where((i) => i.isVisibleOnCurrentPlatform).toList();
  }

  static ScamCheckupProgress progress({
    required List<ScamCheckupItem> visible,
    required Set<String> checkedIds,
    required ScamProactiveProtectionStatus? proactive,
  }) {
    var done = 0;
    for (final item in visible) {
      if (_isDone(item, checkedIds, proactive)) done++;
    }
    return ScamCheckupProgress(done: done, total: visible.length);
  }

  static bool _isDone(
    ScamCheckupItem item,
    Set<String> checkedIds,
    ScamProactiveProtectionStatus? proactive,
  ) {
    final phase7 = item.phase7StatusKey;
    if (phase7 != null && proactive != null) {
      final active = switch (phase7) {
        ScamCheckupPhase7StatusKey.callScreeningActive =>
          proactive.callScreeningActive,
        ScamCheckupPhase7StatusKey.smsFilterUserConfirmed =>
          proactive.smsFilterUserConfirmed,
      };
      if (active) return true;
    }
    return checkedIds.contains(item.id);
  }

  static bool phase7Detectable(ScamCheckupPhase7StatusKey key) {
    return switch (key) {
      ScamCheckupPhase7StatusKey.callScreeningActive => true,
      ScamCheckupPhase7StatusKey.smsFilterUserConfirmed => true,
    };
  }

  static ScamCheckupItem _parseItem(Map<String, dynamic> json) {
    return ScamCheckupItem(
      id: json['id']?.toString() ?? '',
      group: _group(json['group']?.toString()),
      platform: _platform(json['platform']?.toString()),
      titleKey: json['titleKey']?.toString() ?? '',
      whyKey: json['whyKey']?.toString() ?? '',
      stepKeys: _stringList(json['stepKeys']),
      deepLink: _deepLink(json['deepLink']?.toString()),
      verified: json['verified'] == true,
      lastVerified: DateTime.tryParse(json['lastVerified']?.toString() ?? ''),
      phase7StatusKey: _phase7(json['phase7StatusKey']?.toString()),
    );
  }

  static ScamCheckupGroup _group(String? raw) {
    return switch (raw) {
      'phone' => ScamCheckupGroup.phone,
      'raabta' => ScamCheckupGroup.raabta,
      'money' => ScamCheckupGroup.money,
      _ => ScamCheckupGroup.whatsapp,
    };
  }

  static ScamCheckupPlatformFilter _platform(String? raw) {
    return switch (raw) {
      'ios' => ScamCheckupPlatformFilter.ios,
      'android' => ScamCheckupPlatformFilter.android,
      _ => ScamCheckupPlatformFilter.both,
    };
  }

  static ScamCheckupDeepLink _deepLink(String? raw) {
    return switch (raw) {
      'openAppSettings' => ScamCheckupDeepLink.openAppSettings,
      'officialDirectory' => ScamCheckupDeepLink.officialDirectory,
      'callScreeningGuide' => ScamCheckupDeepLink.callScreeningGuide,
      'smsFilterGuide' => ScamCheckupDeepLink.smsFilterGuide,
      'personalContextSettings' =>
        ScamCheckupDeepLink.personalContextSettings,
      _ => ScamCheckupDeepLink.none,
    };
  }

  static ScamCheckupPhase7StatusKey? _phase7(String? raw) {
    return switch (raw) {
      'callScreeningActive' => ScamCheckupPhase7StatusKey.callScreeningActive,
      'smsFilterUserConfirmed' =>
        ScamCheckupPhase7StatusKey.smsFilterUserConfirmed,
      _ => null,
    };
  }

  static List<String> _stringList(Object? raw) {
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
  }
}
