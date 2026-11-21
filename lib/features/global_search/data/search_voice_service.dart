import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:raabta/features/global_search/domain/search_voice_error.dart';
import 'package:raabta/features/global_search/domain/search_voice_stt_locale.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Platform speech engine adapter for Global Search voice input (S11).
abstract class SearchVoiceSpeechEngine {
  Future<bool> initialize({
    void Function(Object error)? onError,
    void Function(String status)? onStatus,
  });

  bool get isAvailable;

  Future<void> listen({
    required String localeId,
    required void Function(SpeechRecognitionResult result) onResult,
    Duration listenFor = const Duration(seconds: 30),
    Duration pauseFor = const Duration(seconds: 4),
    bool partialResults = true,
  });

  Future<void> stop();
  Future<void> cancel();
}

class DefaultSearchVoiceSpeechEngine implements SearchVoiceSpeechEngine {
  DefaultSearchVoiceSpeechEngine({SpeechToText? speech})
      : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;
  var _initialized = false;

  @override
  bool get isAvailable => _initialized;

  @override
  Future<bool> initialize({
    void Function(Object error)? onError,
    void Function(String status)? onStatus,
  }) async {
    if (_initialized) return true;
    try {
      _initialized = await _speech.initialize(
        onError: (error) => onError?.call(error),
        onStatus: onStatus,
        debugLogging: false,
      );
      return _initialized;
    } catch (_) {
      _initialized = false;
      return false;
    }
  }

  @override
  Future<void> listen({
    required String localeId,
    required void Function(SpeechRecognitionResult result) onResult,
    Duration listenFor = const Duration(seconds: 30),
    Duration pauseFor = const Duration(seconds: 4),
    bool partialResults = true,
  }) {
    return _speech.listen(
      onResult: onResult,
      listenFor: listenFor,
      pauseFor: pauseFor,
      listenOptions: SpeechListenOptions(
        localeId: localeId,
        partialResults: partialResults,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      ),
    );
  }

  @override
  Future<void> stop() => _speech.stop();

  @override
  Future<void> cancel() => _speech.cancel();
}

/// Microphone permission gateway (testable).
abstract class SearchVoicePermissionGateway {
  Future<PermissionStatus> requestMicrophone();
}

class DefaultSearchVoicePermissionGateway implements SearchVoicePermissionGateway {
  @override
  Future<PermissionStatus> requestMicrophone() {
    return Permission.microphone.request();
  }
}

/// Voice recognition service — transcript only, no search logic (S11).
class SearchVoiceService {
  SearchVoiceService({
    SearchVoiceSpeechEngine? engine,
    SearchVoicePermissionGateway? permissions,
    @visibleForTesting this.platformSupportedOverride,
  })  : _engine = engine ?? DefaultSearchVoiceSpeechEngine(),
        _permissions = permissions ?? DefaultSearchVoicePermissionGateway();

  final SearchVoiceSpeechEngine _engine;
  final SearchVoicePermissionGateway _permissions;

  /// When set (tests), bypasses [Platform] checks.
  @visibleForTesting
  final bool? platformSupportedOverride;

  var _listenSessionActive = false;
  var _finalDelivered = false;
  Timer? _timeoutTimer;

  static const listenTimeout = Duration(seconds: 30);

  bool get isListenSessionActive => _listenSessionActive;

  bool get supportsPlatform {
    if (platformSupportedOverride != null) {
      return platformSupportedOverride!;
    }
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  Future<bool> ensureInitialized({
    void Function(Object error)? onError,
    void Function(String status)? onStatus,
  }) async {
    if (!supportsPlatform) return false;
    return _engine.initialize(onError: onError, onStatus: onStatus);
  }

  Future<SearchVoiceErrorCode?> requestPermission() async {
    if (!supportsPlatform) return SearchVoiceErrorCode.notAvailable;

    final status = await _permissions.requestMicrophone();
    if (status.isGranted) return null;
    if (status.isPermanentlyDenied) {
      return SearchVoiceErrorCode.permissionPermanentlyDenied;
    }
    return SearchVoiceErrorCode.permissionDenied;
  }

  Future<SearchVoiceErrorCode?> startListening({
    required String appLocale,
    required void Function(String partial) onPartial,
    required void Function(String finalText) onFinal,
    required void Function(SearchVoiceErrorCode code) onError,
  }) async {
    if (!supportsPlatform) {
      onError(SearchVoiceErrorCode.notAvailable);
      return SearchVoiceErrorCode.notAvailable;
    }
    if (_listenSessionActive) {
      onError(SearchVoiceErrorCode.recognitionFailed);
      return SearchVoiceErrorCode.recognitionFailed;
    }

    final permissionError = await requestPermission();
    if (permissionError != null) {
      onError(permissionError);
      return permissionError;
    }

    final ready = await ensureInitialized(
      onError: (_) {
        if (!_finalDelivered) {
          onError(SearchVoiceErrorCode.recognitionFailed);
        }
      },
      onStatus: (status) {
        if ((status == 'done' || status == 'notListening') &&
            _listenSessionActive &&
            !_finalDelivered) {
          _completeListen(onFinal: onFinal, onError: onError);
        }
      },
    );

    if (!ready) {
      onError(SearchVoiceErrorCode.initializationFailed);
      return SearchVoiceErrorCode.initializationFailed;
    }

    _listenSessionActive = true;
    _finalDelivered = false;
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(listenTimeout, () {
      if (_listenSessionActive && !_finalDelivered) {
        unawaited(_engine.stop());
        onError(SearchVoiceErrorCode.timeout);
        _listenSessionActive = false;
      }
    });

    final localeId = SearchVoiceSttLocale.resolve(appLocale);

    try {
      await _engine.listen(
        localeId: localeId,
        onResult: (result) {
          final words = result.recognizedWords.trim();
          if (words.isEmpty) {
            if (result.finalResult) {
              _deliverFinal(
                '',
                onFinal: onFinal,
                onError: onError,
              );
            }
            return;
          }

          if (result.finalResult) {
            _deliverFinal(words, onFinal: onFinal, onError: onError);
          } else {
            onPartial(words);
          }
        },
      );
      return null;
    } catch (_) {
      _listenSessionActive = false;
      _timeoutTimer?.cancel();
      onError(SearchVoiceErrorCode.recognitionFailed);
      return SearchVoiceErrorCode.recognitionFailed;
    }
  }

  void _completeListen({
    required void Function(String finalText) onFinal,
    required void Function(SearchVoiceErrorCode code) onError,
  }) {
    if (_finalDelivered) return;
    _listenSessionActive = false;
    _timeoutTimer?.cancel();
    onError(SearchVoiceErrorCode.emptyTranscript);
  }

  void _deliverFinal(
    String words, {
    required void Function(String finalText) onFinal,
    required void Function(SearchVoiceErrorCode code) onError,
  }) {
    if (_finalDelivered) return;
    _finalDelivered = true;
    _listenSessionActive = false;
    _timeoutTimer?.cancel();

    final trimmed = words.trim();
    if (trimmed.isEmpty) {
      onError(SearchVoiceErrorCode.emptyTranscript);
      return;
    }
    onFinal(trimmed);
  }

  Future<void> stopListening() async {
    _listenSessionActive = false;
    _timeoutTimer?.cancel();
    try {
      await _engine.stop();
    } catch (_) {}
  }

  Future<void> cancelListening() async {
    _listenSessionActive = false;
    _finalDelivered = true;
    _timeoutTimer?.cancel();
    try {
      await _engine.cancel();
    } catch (_) {}
  }

  void dispose() {
    _timeoutTimer?.cancel();
    unawaited(_engine.cancel());
  }

  /// Test-only reset.
  void resetForTests() {
    _listenSessionActive = false;
    _finalDelivered = false;
    _timeoutTimer?.cancel();
  }
}

Future<void> openSearchVoicePermissionSettings() => openAppSettings();
