import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class RaabtaLanguage {
  final String code;
  final String displayName;
  final String flag;
  final String sttLocale;
  final String ttsLanguage;
  final String ttsCountry;

  const RaabtaLanguage({
    required this.code,
    required this.displayName,
    required this.flag,
    required this.sttLocale,
    required this.ttsLanguage,
    required this.ttsCountry,
  });

  String get ttsLocale => '$ttsLanguage-$ttsCountry';
}

const List<RaabtaLanguage> supportedLanguages = [
  RaabtaLanguage(
    code: 'en',
    displayName: 'English',
    flag: '🇬🇧',
    sttLocale: 'en-US',
    ttsLanguage: 'en',
    ttsCountry: 'US',
  ),
  RaabtaLanguage(
    code: 'ar',
    displayName: 'العربية',
    flag: '🇶🇦',
    sttLocale: 'ar-QA',
    ttsLanguage: 'ar',
    ttsCountry: 'QA',
  ),
  RaabtaLanguage(
    code: 'hi',
    displayName: 'हिंदी',
    flag: '🇮🇳',
    sttLocale: 'hi-IN',
    ttsLanguage: 'hi',
    ttsCountry: 'IN',
  ),
  RaabtaLanguage(
    code: 'ur',
    displayName: 'اردو',
    flag: '🇵🇰',
    sttLocale: 'ur-PK',
    ttsLanguage: 'ur',
    ttsCountry: 'PK',
  ),
  RaabtaLanguage(
    code: 'ta',
    displayName: 'தமிழ்',
    flag: '🇱🇰',
    sttLocale: 'ta-IN',
    ttsLanguage: 'ta',
    ttsCountry: 'IN',
  ),
  RaabtaLanguage(
    code: 'ml',
    displayName: 'മലയാളം',
    flag: '🇮🇳',
    sttLocale: 'ml-IN',
    ttsLanguage: 'ml',
    ttsCountry: 'IN',
  ),
  RaabtaLanguage(
    code: 'sw',
    displayName: 'Kiswahili',
    flag: '🇰🇪',
    sttLocale: 'sw-KE',
    ttsLanguage: 'sw',
    ttsCountry: 'KE',
  ),
  RaabtaLanguage(
    code: 'ne',
    displayName: 'नेपाली',
    flag: '🇳🇵',
    sttLocale: 'ne-NP',
    ttsLanguage: 'ne',
    ttsCountry: 'NP',
  ),
];

RaabtaLanguage raabtaLanguageByCode(String code) {
  return supportedLanguages.firstWhere(
    (l) => l.code == code,
    orElse: () => supportedLanguages.first,
  );
}

class VoiceService {
  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _sttAvailable = false;
  bool _ttsAvailable = false;
  bool _voiceSupported = false;
  bool isListening = false;
  bool isSpeaking = false;

  bool get isVoiceSupported => _voiceSupported;
  bool get isSttAvailable => _sttAvailable;
  bool get isTtsAvailable => _ttsAvailable;

  Future<bool> initialize() async {
    try {
      await _tts.setSharedInstance(true);

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
          ],
          IosTextToSpeechAudioMode.defaultMode,
        );
      }

      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.setLanguage('en-US');

      _tts.setCompletionHandler(() {
        isSpeaking = false;
      });

      _tts.setErrorHandler((message) {
        debugPrint('⚠️ TTS error: $message');
        isSpeaking = false;
      });

      _ttsAvailable = true;
      debugPrint('✅ TTS initialized successfully');
    } catch (e) {
      debugPrint('⚠️ TTS init failed: $e');
      _ttsAvailable = false;
    }

    try {
      _sttAvailable = await _stt.initialize(
        onError: (error) {
          debugPrint('⚠️ STT error: ${error.errorMsg}');
          isListening = false;
        },
        onStatus: (status) {
          debugPrint('STT status: $status');
          if (status == 'done' || status == 'notListening') {
            isListening = false;
          }
        },
        debugLogging: false,
      );

      if (_sttAvailable) {
        debugPrint('✅ STT initialized successfully');
      } else {
        debugPrint('ℹ️ STT not available on this platform/device');
      }
    } catch (e) {
      debugPrint('⚠️ STT init failed: $e');
      _sttAvailable = false;
    }

    _voiceSupported = _ttsAvailable || _sttAvailable;
    debugPrint(
      '📱 VoiceService ready | TTS: $_ttsAvailable | STT: $_sttAvailable',
    );
    return _voiceSupported;
  }

  Future<void> setLanguage(RaabtaLanguage language) async {
    if (!_ttsAvailable) return;
    try {
      await _tts.setLanguage(language.ttsLocale);
    } catch (e) {
      debugPrint('⚠️ setLanguage error: $e');
    }
  }

  Future<void> startListening({
    required RaabtaLanguage language,
    required void Function(String text) onResult,
    void Function(double level)? onSoundLevel,
  }) async {
    if (!_sttAvailable) {
      debugPrint('ℹ️ STT not available — cannot listen');
      return;
    }
    if (isListening) return;

    try {
      isListening = true;
      final available = await _stt.initialize();
      if (!available) {
        isListening = false;
        return;
      }

      await _stt.listen(
        onResult: (result) {
          if (result.finalResult && result.recognizedWords.isNotEmpty) {
            isListening = false;
            onResult(result.recognizedWords);
          }
        },
        onSoundLevelChange: onSoundLevel,
        listenOptions: SpeechListenOptions(
          localeId: language.sttLocale,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 4),
          partialResults: false,
          cancelOnError: true,
          listenMode: ListenMode.confirmation,
        ),
      );
    } catch (e) {
      debugPrint('⚠️ startListening error: $e');
      isListening = false;
    }
  }

  Future<void> stopListening() async {
    try {
      isListening = false;
      await _stt.stop();
    } catch (e) {
      debugPrint('⚠️ stopListening error: $e');
    }
  }

  Future<void> speak(String text, RaabtaLanguage language) async {
    if (!_ttsAvailable) return;
    try {
      if (isSpeaking) await stopSpeaking();
      await _tts.setLanguage(language.ttsLocale);
      final cleanText = _stripMarkdown(text);
      if (cleanText.isEmpty) return;
      isSpeaking = true;
      await _tts.speak(cleanText);
    } catch (e) {
      debugPrint('⚠️ speak error: $e');
      isSpeaking = false;
    }
  }

  Future<void> stopSpeaking() async {
    try {
      isSpeaking = false;
      await _tts.stop();
    } catch (e) {
      debugPrint('⚠️ stopSpeaking error: $e');
    }
  }

  String _stripMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'\*\*'), '')
        .replaceAll(RegExp(r'\*'), '')
        .replaceAll(RegExp(r'#{1,6}\s'), '')
        .replaceAll(RegExp(r'`{1,3}'), '')
        .replaceAll(RegExp(r'^\s*[-•]\s', multiLine: true), '')
        .replaceAll(RegExp(r'^\s*\d+\.\s', multiLine: true), '')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  void dispose() {
    try {
      _stt.cancel();
      _tts.stop();
    } catch (_) {}
  }
}

final voiceServiceProvider = Provider<VoiceService>((ref) {
  final service = VoiceService();
  ref.onDispose(service.dispose);
  return service;
});
