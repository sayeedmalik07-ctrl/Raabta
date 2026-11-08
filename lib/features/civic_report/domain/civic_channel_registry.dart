import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:raabta/features/civic_report/domain/civic_channel.dart';
import 'package:raabta/features/civic_report/domain/civic_issue_taxonomy.dart';

abstract final class CivicChannelRegistry {
  static const assetPath = 'assets/civic_report/civic_channels.json';
  static List<CivicChannel>? _cache;

  @visibleForTesting
  static void installForTest(List<CivicChannel> channels) => _cache = channels;

  @visibleForTesting
  static void resetForTest() => _cache = null;

  static Future<List<CivicChannel>> loadAll() async {
    await _ensureLoaded();
    return List.unmodifiable(_cache!);
  }

  static Future<List<CivicChannel>> enabledForIssue(
    CivicIssueTypeId issue,
  ) async {
    final all = await loadAll();
    return all
        .where((c) => c.supportsIssue(issue) && c.hasAnyEnabledAction)
        .toList(growable: false);
  }

  static Future<List<CivicChannel>> matchingIssue(
    CivicIssueTypeId issue,
  ) async {
    final all = await loadAll();
    return all.where((c) => c.supportsIssue(issue)).toList(growable: false);
  }

  static Future<void> _ensureLoaded() async {
    if (_cache != null) return;
    final raw = await rootBundle.loadString(assetPath);
    _cache = parseChannelsJson(raw);
  }

  @visibleForTesting
  static List<CivicChannel> parseChannelsJson(String raw) {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = decoded['channels'] as List<dynamic>? ?? [];
    return [
      for (final item in list)
        if (item is Map<String, dynamic>) CivicChannel.fromJson(item),
    ];
  }
}
