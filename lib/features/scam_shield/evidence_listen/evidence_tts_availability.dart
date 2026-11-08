import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:raabta/features/scam_shield/evidence_listen/evidence_tts_locale_config.dart';

/// Queries installed TTS voices — no network (Phase 22).
abstract final class EvidenceTtsAvailability {
  static Future<String?> resolveAvailableTag(String locale) async {
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.windows) {
      return null;
    }
    final tts = FlutterTts();
    for (final tag in EvidenceTtsLocaleConfig.ttsCandidatesFor(locale)) {
      try {
        final ok = await tts.isLanguageAvailable(tag);
        if (ok == true) return tag;
      } catch (_) {
        continue;
      }
    }
    return null;
  }
}
