import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:scam_shield_core/features/scam_shield/pattern_packs/scam_pattern_pack_models.dart';
import 'package:scam_shield_core/features/scam_shield/pattern_packs/scam_pattern_pack_parser.dart';

typedef ScamPatternPackAssetReader = Future<String> Function(String assetPath);

abstract final class ScamPatternPackLoader {
  static const assetPaths = [
    'assets/scam_shield/pattern_packs/recovery_offer.json',
    'assets/scam_shield/pattern_packs/pay_to_earn_tasks.json',
    'assets/scam_shield/pattern_packs/fake_fine_toll.json',
    'assets/scam_shield/pattern_packs/one_ring_callback.json',
    'assets/scam_shield/pattern_packs/investment_offer.json',
  ];

  static List<ScamPatternPack>? _cache;

  /// Injected by the Flutter app (or tests) — no [rootBundle] in core.
  static ScamPatternPackAssetReader? assetReader;

  static List<ScamPatternPack> get cache => _cache ?? const [];

  @visibleForTesting
  static void installForTest(List<ScamPatternPack> packs) => _cache = packs;

  @visibleForTesting
  static void resetForTest() {
    _cache = null;
    assetReader = null;
  }

  static Future<List<ScamPatternPack>> loadAll() async {
    if (_cache != null) return _cache!;
    final read = assetReader;
    if (read == null) return const [];
    final out = <ScamPatternPack>[];
    for (final path in assetPaths) {
      final raw = await read(path);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      out.add(ScamPatternPackParser.parse(json));
    }
    _cache = out;
    return out;
  }
}
