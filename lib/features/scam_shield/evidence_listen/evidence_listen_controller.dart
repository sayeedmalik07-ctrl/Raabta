import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:raabta/features/scam_shield/evidence_listen/evidence_tts_locale_config.dart';

enum EvidenceListenPlaybackState { idle, speaking, paused }

/// On-device TTS for evidence scripts — no network (Phase 22).
class EvidenceListenController {
  EvidenceListenController({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  EvidenceListenPlaybackState state = EvidenceListenPlaybackState.idle;
  String? _lastScript;
  String? _resolvedTag;
  var _slow = true;
  VoidCallback? onStateChanged;

  bool get isSpeaking => state == EvidenceListenPlaybackState.speaking;

  Future<void> configureForLocale(String locale) async {
    _slow = EvidenceTtsLocaleConfig.prefersSlowSpeech(locale);
  }

  Future<bool> prepareVoice(
    String locale,
    Future<String?> Function() resolveTag,
  ) async {
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.windows) {
      return false;
    }
    _resolvedTag = await resolveTag();
    return _resolvedTag != null;
  }

  Future<void> speak(String script, {required String locale}) async {
    if (script.trim().isEmpty) return;
    await stop();
    final tag = _resolvedTag;
    if (tag == null) return;
    _lastScript = script;
    try {
      await _tts.setLanguage(tag);
      await _tts.setSpeechRate(
        EvidenceTtsLocaleConfig.speechRate(slow: _slow),
      );
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [IosTextToSpeechAudioCategoryOptions.defaultToSpeaker],
          IosTextToSpeechAudioMode.defaultMode,
        );
      }
      _tts.setCompletionHandler(_onComplete);
      _tts.setErrorHandler((_) => _onComplete());
      state = EvidenceListenPlaybackState.speaking;
      onStateChanged?.call();
      await _tts.speak(script);
    } catch (_) {
      _onComplete();
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    state = EvidenceListenPlaybackState.idle;
    onStateChanged?.call();
  }

  /// Best-effort stop during widget/screen dispose (does not await platform TTS).
  void stopForDispose() {
    state = EvidenceListenPlaybackState.idle;
    onStateChanged?.call();
    _tts.stop().catchError((_) {});
  }

  Future<void> repeat() async {
    if (_lastScript == null) return;
    await speak(_lastScript!, locale: '');
  }

  void toggleSpeed() {
    _slow = !_slow;
  }

  bool get slow => _slow;

  void _onComplete() {
    state = EvidenceListenPlaybackState.idle;
    onStateChanged?.call();
  }

  Future<void> dispose() async {
    await stop();
  }
}
