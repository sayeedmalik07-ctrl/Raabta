import 'dart:convert';

import 'package:flutter/services.dart';

/// Bundled allowlist — must match server `services/data/link_shorteners.json`.
abstract final class LinkShortenerConfig {
  static const assetPath = 'assets/scam_shield/link_shorteners.json';
  static Set<String>? _hosts;

  static Future<void> ensureLoaded() async {
    if (_hosts != null) return;
    final raw = await rootBundle.loadString(assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final list = json['hosts'] as List<dynamic>? ?? [];
    _hosts = list.map((e) => _normalizeHost(e.toString())).toSet();
  }

  static void installForTest(Set<String> hosts) {
    _hosts = hosts.map(_normalizeHost).toSet();
  }

  static void resetForTest() {
    _hosts = null;
  }

  static bool isShortenerHost(String host) {
    final h = _normalizeHost(host);
    final allowed = _hosts;
    if (allowed == null || allowed.isEmpty) return false;
    if (allowed.contains(h)) return true;
    for (final entry in allowed) {
      if (h == entry || h.endsWith('.$entry')) return true;
    }
    return false;
  }

  static bool isShortenerUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return isShortenerHost(uri.host);
    } catch (_) {
      return false;
    }
  }

  static String _normalizeHost(String host) {
    var h = host.trim().toLowerCase();
    if (h.startsWith('www.')) h = h.substring(4);
    return h;
  }
}
