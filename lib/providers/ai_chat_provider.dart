import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/services/api_service.dart';
import 'package:raabta/services/voice_service.dart';

class AiChatMessage {
  const AiChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
  });

  final String id;
  final bool isUser;
  final String text;
}

class AiChatState {
  AiChatState({
    this.messages = const [],
    this.isSending = false,
    this.isListening = false,
    this.isSpeaking = false,
    this.voiceEnabled = true,
    this.voiceInitialized = false,
    this.sttAvailable = false,
    this.ttsAvailable = false,
    this.soundLevel = 0,
    RaabtaLanguage? selectedLanguage,
    this.recognizedVoiceText = '',
  }) : selectedLanguage = selectedLanguage ?? supportedLanguages.first;

  final List<AiChatMessage> messages;
  final bool isSending;
  final bool isListening;
  final bool isSpeaking;
  final bool voiceEnabled;
  final bool voiceInitialized;
  final bool sttAvailable;
  final bool ttsAvailable;
  final double soundLevel;
  final RaabtaLanguage selectedLanguage;
  final String recognizedVoiceText;

  AiChatState copyWith({
    List<AiChatMessage>? messages,
    bool? isSending,
    bool? isListening,
    bool? isSpeaking,
    bool? voiceEnabled,
    bool? voiceInitialized,
    bool? sttAvailable,
    bool? ttsAvailable,
    double? soundLevel,
    RaabtaLanguage? selectedLanguage,
    String? recognizedVoiceText,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      isListening: isListening ?? this.isListening,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      voiceInitialized: voiceInitialized ?? this.voiceInitialized,
      sttAvailable: sttAvailable ?? this.sttAvailable,
      ttsAvailable: ttsAvailable ?? this.ttsAvailable,
      soundLevel: soundLevel ?? this.soundLevel,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      recognizedVoiceText: recognizedVoiceText ?? this.recognizedVoiceText,
    );
  }
}

class AiChatNotifier extends StateNotifier<AiChatState> {
  AiChatNotifier(this._voiceService) : super(AiChatState());

  final VoiceService _voiceService;
  int _messageCounter = 0;

  String _nextId() => 'msg_${++_messageCounter}';

  Future<void> initVoice() async {
    try {
      final success = await _voiceService.initialize();
      if (success) {
        await _voiceService.setLanguage(state.selectedLanguage);
      }
      state = state.copyWith(
        voiceInitialized: success,
        sttAvailable: _voiceService.isSttAvailable,
        ttsAvailable: _voiceService.isTtsAvailable,
        voiceEnabled: _voiceService.isTtsAvailable,
      );
    } catch (e) {
      debugPrint('⚠️ initVoice provider error: $e');
      state = state.copyWith(
        voiceInitialized: false,
        sttAvailable: false,
        ttsAvailable: false,
        voiceEnabled: false,
      );
    }
  }

  Future<void> changeLanguage(RaabtaLanguage language) async {
    state = state.copyWith(selectedLanguage: language);
    if (state.ttsAvailable) {
      await _voiceService.setLanguage(language);
    }
  }

  Future<void> startVoiceInput() async {
    if (state.isSending || state.isListening) return;

    if (!state.sttAvailable) {
      debugPrint('ℹ️ STT not available on this platform');
      state = state.copyWith(
        recognizedVoiceText:
            'Voice input not available. Please type your question.',
      );
      return;
    }

    state = state.copyWith(
      isListening: true,
      recognizedVoiceText: '',
      soundLevel: 0,
    );

    await _voiceService.startListening(
      language: state.selectedLanguage,
      onResult: (text) async {
        state = state.copyWith(
          isListening: false,
          recognizedVoiceText: text,
          soundLevel: 0,
        );
        if (text.trim().isNotEmpty) {
          await sendMessage(text.trim());
        }
      },
      onSoundLevel: (level) {
        state = state.copyWith(soundLevel: level.clamp(0.0, 10.0));
      },
    );
  }

  Future<void> stopVoiceInput() async {
    await _voiceService.stopListening();
    state = state.copyWith(
      isListening: false,
      soundLevel: 0,
    );
  }

  Future<void> speakMessage(String text) async {
    if (!state.ttsAvailable) return;

    if (state.isSpeaking) {
      await _voiceService.stopSpeaking();
      state = state.copyWith(isSpeaking: false);
    } else {
      state = state.copyWith(isSpeaking: true);
      await _voiceService.speak(text, state.selectedLanguage);
      state = state.copyWith(isSpeaking: false);
    }
  }

  void toggleVoiceEnabled() {
    if (!state.ttsAvailable) return;

    if (state.voiceEnabled && state.isSpeaking) {
      _voiceService.stopSpeaking();
    }
    state = state.copyWith(
      voiceEnabled: !state.voiceEnabled,
      isSpeaking: false,
    );
    debugPrint(
      '🔊 Voice output: ${state.voiceEnabled ? "ON" : "OFF"}',
    );
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isSending) return;

    final history = state.messages
        .map(
          (message) => {
            'role': message.isUser ? 'user' : 'assistant',
            'content': message.text,
          },
        )
        .toList();

    state = state.copyWith(
      messages: [
        ...state.messages,
        AiChatMessage(id: _nextId(), isUser: true, text: trimmed),
      ],
      isSending: true,
      recognizedVoiceText: '',
    );

    final reply = await ApiService.sendMessage(
      trimmed,
      language: state.selectedLanguage.displayName,
      languageCode: state.selectedLanguage.code,
      conversationHistory: history,
    );

    state = state.copyWith(
      messages: [
        ...state.messages,
        AiChatMessage(id: _nextId(), isUser: false, text: reply),
      ],
      isSending: false,
    );

    if (state.voiceEnabled &&
        state.ttsAvailable &&
        !reply.startsWith('Connection Error:')) {
      await speakMessage(reply);
    }
  }
}

final aiChatProvider =
    StateNotifierProvider<AiChatNotifier, AiChatState>((ref) {
  final voice = ref.watch(voiceServiceProvider);
  return AiChatNotifier(voice);
});
