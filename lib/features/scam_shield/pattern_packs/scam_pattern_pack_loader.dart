import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:scam_shield_core/features/scam_shield/pattern_packs/scam_pattern_pack_loader.dart'
    as core;
import 'package:scam_shield_core/features/scam_shield/pattern_packs/scam_pattern_pack_models.dart';

export 'package:scam_shield_core/features/scam_shield/pattern_packs/scam_pattern_pack_models.dart';

/// Flutter asset binding for [core.ScamPatternPackLoader].
abstract final class ScamPatternPackLoader {
  static const assetPaths = core.ScamPatternPackLoader.assetPaths;

  static List<ScamPatternPack> get cache => core.ScamPatternPackLoader.cache;

  @visibleForTesting
  static void installForTest(List<ScamPatternPack> packs) =>
      core.ScamPatternPackLoader.installForTest(packs);

  @visibleForTesting
  static void resetForTest() => core.ScamPatternPackLoader.resetForTest();

  static Future<List<ScamPatternPack>> loadAll() async {
    core.ScamPatternPackLoader.assetReader ??= rootBundle.loadString;
    return core.ScamPatternPackLoader.loadAll();
  }
}
