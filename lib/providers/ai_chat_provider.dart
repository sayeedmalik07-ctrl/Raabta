import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raabta/models/advanced_profile.dart';
import 'package:raabta/features/quick_actions/scanner/services/scanner_ocr_service.dart';
import 'package:raabta/features/profile/privacy/providers/privacy_providers.dart';
import 'package:raabta/core/utils/profile_display_helper.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/ai_chat/models/ai_chat_attachment.dart';
import 'package:raabta/screens/ai_chat/models/ai_chat_context.dart';
import 'package:raabta/screens/ai_chat/models/ai_chat_message.dart';
import 'package:raabta/screens/ai_chat/models/ai_chat_thread.dart';
import 'package:raabta/services/ai/ai_chat_attachment_service.dart';
import 'package:raabta/services/ai/ai_conversation_summarizer.dart';
import 'package:raabta/services/ai/ai_chat_stream_update.dart';
import 'package:raabta/services/ai/ai_thread_repository.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';
import 'package:raabta/services/ai/document_extraction_service.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/services/voice_service.dart';

export 'package:raabta/screens/ai_chat/models/ai_chat_message.dart';

class AiChatState {
  AiChatState({
    this.messages = const [],
    this.threads = const [],
    this.activeThreadId = AiThreadRepository.defaultThreadId,
    this.isSending = false,
    this.isStreaming = false,
    this.isListening = false,
    this.isSpeaking = false,
    this.voiceEnabled = true,
    this.voiceInitialized = false,
    this.sttAvailable = false,
    this.ttsAvailable = false,
    this.soundLevel = 0,
    RaabtaLanguage? selectedLanguage,
    this.recognizedVoiceText = '',
    this.threadLoaded = false,
    this.threadsLoaded = false,
    this.extraContext,
    this.context,
    this.dailyRemaining,
    this.dailyLimit,
    this.isPremium = false,
    this.activeModelTier,
    this.researchMode = false,
    this.pendingAttachment,
    this.isProcessingAttachment = false,
    this.rollingSummary,
  }) : selectedLanguage = selectedLanguage ?? supportedLanguages.first;

  final List<AiChatMessage> messages;
  final List<AiChatThreadSummary> threads;
  final String activeThreadId;
  final bool isSending;
  final bool isStreaming;
  final bool isListening;
  final bool isSpeaking;
  final bool voiceEnabled;
  final bool voiceInitialized;
  final bool sttAvailable;
  final bool ttsAvailable;
  final double soundLevel;
  final RaabtaLanguage selectedLanguage;
  final String recognizedVoiceText;
  final bool threadLoaded;
  final bool threadsLoaded;
  final String? extraContext;
  final AiChatContext? context;
  final int? dailyRemaining;
  final int? dailyLimit;
  final bool isPremium;
  final String? activeModelTier;
  final bool researchMode;
  final AiChatAttachment? pendingAttachment;
  final bool isProcessingAttachment;
  final String? rollingSummary;

  bool get isGenerating => isSending || isStreaming;

  bool get showQuotaWarning =>
      !isPremium &&
      dailyRemaining != null &&
      dailyLimit != null &&
      dailyRemaining! <= 3 &&
      dailyRemaining! > 0;

  AiChatState copyWith({
    List<AiChatMessage>? messages,
    List<AiChatThreadSummary>? threads,
    String? activeThreadId,
    bool? isSending,
    bool? isStreaming,
    bool? isListening,
    bool? isSpeaking,
    bool? voiceEnabled,
    bool? voiceInitialized,
    bool? sttAvailable,
    bool? ttsAvailable,
    double? soundLevel,
    RaabtaLanguage? selectedLanguage,
    String? recognizedVoiceText,
    bool? threadLoaded,
    bool? threadsLoaded,
    String? extraContext,
    AiChatContext? context,
    bool clearContext = false,
    int? dailyRemaining,
    int? dailyLimit,
    bool? isPremium,
    String? activeModelTier,
    bool clearActiveModelTier = false,
    bool? researchMode,
    AiChatAttachment? pendingAttachment,
    bool clearAttachment = false,
    bool? isProcessingAttachment,
    String? rollingSummary,
    bool clearRollingSummary = false,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      threads: threads ?? this.threads,
      activeThreadId: activeThreadId ?? this.activeThreadId,
      isSending: isSending ?? this.isSending,
      isStreaming: isStreaming ?? this.isStreaming,
      isListening: isListening ?? this.isListening,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      voiceInitialized: voiceInitialized ?? this.voiceInitialized,
      sttAvailable: sttAvailable ?? this.sttAvailable,
      ttsAvailable: ttsAvailable ?? this.ttsAvailable,
      soundLevel: soundLevel ?? this.soundLevel,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      recognizedVoiceText: recognizedVoiceText ?? this.recognizedVoiceText,
      threadLoaded: threadLoaded ?? this.threadLoaded,
      threadsLoaded: threadsLoaded ?? this.threadsLoaded,
      extraContext: extraContext ?? this.extraContext,
      context: clearContext ? null : (context ?? this.context),
      dailyRemaining: dailyRemaining ?? this.dailyRemaining,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      isPremium: isPremium ?? this.isPremium,
      activeModelTier: clearActiveModelTier
          ? null
          : (activeModelTier ?? this.activeModelTier),
      researchMode: researchMode ?? this.researchMode,
      pendingAttachment: clearAttachment
          ? null
          : (pendingAttachment ?? this.pendingAttachment),
      isProcessingAttachment:
          isProcessingAttachment ?? this.isProcessingAttachment,
      rollingSummary: clearRollingSummary
          ? null
          : (rollingSummary ?? this.rollingSummary),
    );
  }
}

class AiChatNotifier extends StateNotifier<AiChatState> {
  AiChatNotifier(
    this._ref,
    this._voiceService,
    this._ai,
    this._threads,
    this._attachmentService,
    this._summarizer,
  ) : super(AiChatState());

  final Ref _ref;
  final VoiceService _voiceService;
  final ClaudeAIService _ai;
  final AiThreadRepository _threads;
  final AiChatAttachmentService _attachmentService;
  final AiConversationSummarizer _summarizer;

  int _messageCounter = 0;
  int _authGeneration = 0;
  StreamSubscription<AiChatStreamUpdate>? _streamSub;
  bool _persistScheduled = false;

  @visibleForTesting
  int get authGeneration => _authGeneration;

  String _nextId() => 'msg_${++_messageCounter}';

  String? get _uid => _ref.read(currentUserProvider)?.uid;

  /// Clears in-memory chat state on authenticated UID change or logout.
  void resetForAuthChange() {
    _authGeneration++;
    _streamSub?.cancel();
    _streamSub = null;
    _ai.cancelActiveStream();
    _messageCounter = 0;
    _persistScheduled = false;
    state = AiChatState();
  }

  bool _isCurrentAuthSession(int generation, String? requestUid) {
    return generation == _authGeneration &&
        requestUid != null &&
        requestUid == _uid;
  }

  String get _mergedExtraContext {
    final parts = <String>[];
    if (state.context != null) {
      parts.add(state.context!.combinedExtraContext);
    }
    if (state.pendingAttachment != null) {
      parts.add(state.pendingAttachment!.contextBlock);
    }
    if (state.extraContext != null && state.extraContext!.trim().isNotEmpty) {
      parts.add(state.extraContext!.trim());
    }
    final advHint = _advancedProfileExtraContext();
    if (advHint != null) {
      parts.add(advHint);
    }
    if (parts.isEmpty) return '';
    return parts.join('\n\n');
  }

  void setExtraContext(String? context) {
    state = state.copyWith(extraContext: context);
  }

  void setContext(AiChatContext? context) {
    state = state.copyWith(
      context: context,
      clearContext: context == null,
    );
  }

  void clearContext() {
    state = state.copyWith(clearContext: true);
  }

  void toggleResearchMode() {
    if (!state.isPremium) return;
    state = state.copyWith(researchMode: !state.researchMode);
  }

  void clearPendingAttachment() {
    state = state.copyWith(clearAttachment: true);
  }

  Future<void> attachFromGallery() async {
    if (state.isProcessingAttachment || state.isGenerating) return;
    state = state.copyWith(isProcessingAttachment: true);
    try {
      final attachment = await _attachmentService.pickAndProcess();
      if (attachment != null) {
        state = state.copyWith(pendingAttachment: attachment);
      }
    } catch (e) {
      debugPrint('attachFromGallery: $e');
    } finally {
      state = state.copyWith(isProcessingAttachment: false);
    }
  }

  Future<void> attachFromCamera() async {
    if (state.isProcessingAttachment || state.isGenerating) return;
    state = state.copyWith(isProcessingAttachment: true);
    try {
      final attachment = await _attachmentService.pickAndProcess(
        source: ImageSource.camera,
      );
      if (attachment != null) {
        state = state.copyWith(pendingAttachment: attachment);
      }
    } catch (e) {
      debugPrint('attachFromCamera: $e');
    } finally {
      state = state.copyWith(isProcessingAttachment: false);
    }
  }

  Future<void> loadThreadsIfNeeded() async {
    if (state.threadsLoaded) return;
    final uid = _uid;
    if (uid == null) {
      state = state.copyWith(threadsLoaded: true);
      return;
    }
    try {
      final threads = await _threads.listThreads(uid);
      state = state.copyWith(threads: threads, threadsLoaded: true);
    } catch (e) {
      debugPrint('AiChat loadThreads: $e');
      state = state.copyWith(threadsLoaded: true);
    }
  }

  Future<void> loadThreadIfNeeded({String? threadId}) async {
    final targetId = threadId ?? state.activeThreadId;
    if (state.threadLoaded && state.activeThreadId == targetId) return;

    final uid = _uid;
    if (uid == null) {
      state = state.copyWith(threadLoaded: true, activeThreadId: targetId);
      return;
    }
    try {
      final messages = await _threads.loadMessages(uid, threadId: targetId);
      final summary = await _threads.loadRollingSummary(uid, threadId: targetId);
      state = state.copyWith(
        messages: messages,
        threadLoaded: true,
        activeThreadId: targetId,
        rollingSummary: summary,
        clearActiveModelTier: true,
      );
    } catch (e) {
      debugPrint('AiChat loadThread: $e');
      state = state.copyWith(threadLoaded: true, activeThreadId: targetId);
    }
  }

  Future<void> switchThread(String threadId) async {
    if (threadId == state.activeThreadId && state.threadLoaded) return;
    stopGeneration();
    state = state.copyWith(
      threadLoaded: false,
      messages: const [],
      activeThreadId: threadId,
      clearActiveModelTier: true,
    );
    await loadThreadIfNeeded(threadId: threadId);
  }

  Future<void> createNewThread({AiChatContext? context}) async {
    stopGeneration();
    final uid = _uid;
    if (uid == null) {
      state = state.copyWith(
        messages: const [],
        threadLoaded: true,
        context: context,
        clearContext: context == null,
        clearActiveModelTier: true,
      );
      return;
    }

    await _persistThread();
    final id = await _threads.createThread(
      uid,
      title: context?.label ?? 'New chat',
      contextSource: context?.source.routeValue,
      locale: state.selectedLanguage.displayName,
    );
    await loadThreadsIfNeeded();
    final threads = await _threads.listThreads(uid);
    state = state.copyWith(
      activeThreadId: id,
      messages: const [],
      threads: threads,
      threadLoaded: true,
      context: context,
      clearContext: context == null,
      clearActiveModelTier: true,
    );
  }

  Future<void> renameThread(String threadId, String title) async {
    final uid = _uid;
    if (uid == null) return;
    await _threads.renameThread(uid, threadId, title);
    final threads = await _threads.listThreads(uid);
    state = state.copyWith(threads: threads);
  }

  Future<void> deleteThread(String threadId) async {
    final uid = _uid;
    if (uid == null) return;
    await _threads.deleteThread(uid, threadId);
    final threads = await _threads.listThreads(uid);
    if (state.activeThreadId == threadId) {
      final fallback = threads.isNotEmpty
          ? threads.first.id
          : AiThreadRepository.defaultThreadId;
      state = state.copyWith(
        threads: threads,
        activeThreadId: fallback,
        threadLoaded: false,
        messages: const [],
      );
      await loadThreadIfNeeded(threadId: fallback);
    } else {
      state = state.copyWith(threads: threads);
    }
  }

  Future<void> _persistThread() async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _threads.saveMessages(
        uid,
        state.messages,
        threadId: state.activeThreadId,
        locale: state.selectedLanguage.displayName,
        contextSource: state.context?.source.routeValue,
        rollingSummary: state.rollingSummary,
      );
    } catch (e) {
      debugPrint('AiChat persist: $e');
    }
  }

  void _schedulePersist() {
    if (_persistScheduled) return;
    _persistScheduled = true;
    final generation = _authGeneration;
    Future<void>.delayed(const Duration(milliseconds: 400), () async {
      _persistScheduled = false;
      if (generation != _authGeneration) return;
      await _persistThread();
      if (generation != _authGeneration) return;
      await loadThreadsIfNeeded();
      final uid = _uid;
      if (uid != null) {
        final threads = await _threads.listThreads(uid);
        if (generation != _authGeneration) return;
        state = state.copyWith(threads: threads);
      }
    });
  }

  Map<String, dynamic> _userProfilePayload() {
    final settings = _ref.read(privacySettingsProvider).valueOrNull;
    if (settings != null && !settings.aiPersonalizationEnabled) {
      return const {};
    }
    final profile = _ref.read(userAIProfileProvider);
    final uid = _uid;
    if (profile == null || uid == null || profile.uid != uid) return const {};
    return {
      'profession': profile.profession,
      'nationality': profile.nationality,
      'preferredArea': profile.preferredArea,
      'language': profile.language,
      'yearsExperience': profile.yearsExperience,
      ...AdvancedProfileSignals.bucketedMap(
        profile: profile.advancedProfile,
        consentGiven: profile.advancedProfileConsentGiven,
      ),
    };
  }

  String? _advancedProfileExtraContext() {
    final profile = _ref.read(userAIProfileProvider);
    final uid = _uid;
    if (profile == null || uid == null || profile.uid != uid) return null;
    return AdvancedProfileSignals.personalizationHint(
      profile: profile.advancedProfile,
      consentGiven: profile.advancedProfileConsentGiven,
    );
  }

  Future<void> initVoice() async {
    try {
      final success = await _voiceService.initialize();
      if (success) {
        await _voiceService.setLanguage(state.selectedLanguage);
      }
      final premium = await _ref.read(isPremiumUserProvider.future);
      state = state.copyWith(
        voiceInitialized: success,
        sttAvailable: _voiceService.isSttAvailable,
        ttsAvailable: _voiceService.isTtsAvailable,
        voiceEnabled: _voiceService.isTtsAvailable,
        isPremium: premium,
      );
    } catch (e) {
      debugPrint('initVoice provider error: $e');
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
    if (state.isGenerating || state.isListening) return;

    if (!state.sttAvailable) {
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
    state = state.copyWith(isListening: false, soundLevel: 0);
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
  }

  void stopGeneration() {
    _streamSub?.cancel();
    _streamSub = null;
    _ai.cancelActiveStream();

    final updated = [...state.messages];
    if (updated.isNotEmpty &&
        !updated.last.isUser &&
        updated.last.isStreaming) {
      if (updated.last.text.trim().isEmpty) {
        updated.removeLast();
      } else {
        updated[updated.length - 1] =
            updated.last.copyWith(isStreaming: false);
      }
    }

    state = state.copyWith(
      messages: updated,
      isSending: false,
      isStreaming: false,
    );
    _schedulePersist();
  }

  List<Map<String, String>> _historyBeforeSend() {
    return state.messages
        .where((m) => !m.isStreaming && m.text.isNotEmpty)
        .map(
          (message) => {
            'role': message.isUser ? 'user' : 'assistant',
            'content': message.text,
          },
        )
        .toList();
  }

  Future<void> sendMessage(String text) async {
    await _sendInternal(text);
  }

  Future<void> regenerateLastResponse() async {
    final messages = [...state.messages];
    while (messages.isNotEmpty && !messages.last.isUser) {
      messages.removeLast();
    }
    if (messages.isEmpty || !messages.last.isUser) return;
    final lastUserText = messages.last.text;
    messages.removeLast();
    state = state.copyWith(messages: messages);
    await _sendInternal(lastUserText);
  }

  Future<void> editUserMessage(String messageId, String newText) async {
    final trimmed = newText.trim();
    if (trimmed.isEmpty) return;

    final idx = state.messages.indexWhere((m) => m.id == messageId);
    if (idx < 0 || !state.messages[idx].isUser) return;

    final kept = state.messages.sublist(0, idx);
    state = state.copyWith(messages: kept);
    await _sendInternal(trimmed);
  }

  Future<void> _maybeSummarizeThread() async {
    if (state.messages.length < 16) return;
    final generation = _authGeneration;
    final uid = _uid;
    final summary = await _summarizer.summarize(
      messages: state.messages,
      language: state.selectedLanguage.displayName,
    );
    if (summary == null || generation != _authGeneration || uid != _uid) return;
    state = state.copyWith(rollingSummary: summary);
    if (uid != null) {
      await _threads.saveMessages(
        uid,
        state.messages,
        threadId: state.activeThreadId,
        locale: state.selectedLanguage.displayName,
        contextSource: state.context?.source.routeValue,
        rollingSummary: summary,
      );
    }
  }

  Future<void> _sendInternal(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isGenerating) return;

    await _maybeSummarizeThread();

    final history = _historyBeforeSend();
    final extra = _mergedExtraContext;
    final hadAttachment = state.pendingAttachment != null;
    final userMsg = AiChatMessage(
      id: _nextId(),
      isUser: true,
      text: trimmed,
      createdAt: DateTime.now(),
    );
    final assistantId = _nextId();
    final assistantPlaceholder = AiChatMessage(
      id: assistantId,
      isUser: false,
      text: '',
      isStreaming: true,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg, assistantPlaceholder],
      isSending: true,
      isStreaming: true,
      recognizedVoiceText: '',
      clearActiveModelTier: true,
      clearAttachment: hadAttachment,
    );

    final user = _ref.read(currentUserProvider);
    final greetingName = ProfileDisplayHelper.greetingName(user);
    final isFirstAssistantTurn =
        !history.any((turn) => turn['role'] == 'assistant');

    final request = _ai.buildMainChatRequest(
      message: trimmed,
      language: state.selectedLanguage.displayName,
      languageCode: state.selectedLanguage.code,
      conversationHistory: history,
      userProfile: _userProfilePayload(),
      userId: _uid,
      extraContext: extra.isEmpty ? null : extra,
      rollingSummary: state.rollingSummary,
      researchMode: state.researchMode && state.isPremium,
      userGreetingName: greetingName.isEmpty ? null : greetingName,
      isFirstAssistantTurn: isFirstAssistantTurn,
    );

    var fullReply = StringBuffer();
    final streamGeneration = _authGeneration;
    final requestUid = _uid;

    _streamSub?.cancel();
    _streamSub = _ai.streamMainChat(request).listen(
      (update) {
        if (!_isCurrentAuthSession(streamGeneration, requestUid)) return;
        if (update.isMeta && update.meta != null) {
          state = state.copyWith(
            dailyRemaining: update.meta!.dailyRemaining,
            dailyLimit: update.meta!.dailyLimit,
            isPremium: update.meta!.isPremium,
            activeModelTier: update.meta!.modelTier,
          );
          return;
        }
        if (update.isError) {
          final updated = [...state.messages];
          final idx = updated.indexWhere((m) => m.id == assistantId);
          if (idx >= 0) {
            updated[idx] = updated[idx].copyWith(
              text: update.error!,
              isStreaming: false,
            );
          }
          state = state.copyWith(
            messages: updated,
            isSending: false,
            isStreaming: false,
          );
          return;
        }
        if (!update.isText) return;
        fullReply.write(update.textDelta);
        final updated = [...state.messages];
        final idx = updated.indexWhere((m) => m.id == assistantId);
        if (idx >= 0) {
          updated[idx] = updated[idx].copyWith(text: fullReply.toString());
          state = state.copyWith(messages: updated);
        }
      },
      onDone: () async {
        if (!_isCurrentAuthSession(streamGeneration, requestUid)) return;
        final reply = fullReply.toString();
        final updated = [...state.messages];
        final idx = updated.indexWhere((m) => m.id == assistantId);
        if (idx >= 0) {
          updated[idx] = updated[idx].copyWith(
            text: reply,
            isStreaming: false,
          );
        }
        state = state.copyWith(
          messages: updated,
          isSending: false,
          isStreaming: false,
        );
        _schedulePersist();

        if (state.voiceEnabled &&
            state.ttsAvailable &&
            reply.isNotEmpty &&
            !reply.startsWith('Connection Error:')) {
          await speakMessage(reply);
        }
      },
      onError: (_) {
        if (!_isCurrentAuthSession(streamGeneration, requestUid)) return;
        stopGeneration();
      },
      cancelOnError: true,
    );
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    _ai.cancelActiveStream();
    super.dispose();
  }
}

final aiThreadRepositoryProvider = Provider<AiThreadRepository>(
  (ref) => AiThreadRepository(),
);

final aiChatAttachmentServiceProvider = Provider<AiChatAttachmentService>((ref) {
  return AiChatAttachmentService(
    ref.watch(scannerOcrServiceProvider),
    ref.watch(documentExtractionServiceProvider),
  );
});

final aiConversationSummarizerProvider =
    Provider<AiConversationSummarizer>((ref) => AiConversationSummarizer());

final aiChatProvider =
    StateNotifierProvider<AiChatNotifier, AiChatState>((ref) {
  final voice = ref.watch(voiceServiceProvider);
  final ai = ref.watch(claudeAIServiceProvider);
  final threads = ref.watch(aiThreadRepositoryProvider);
  final attachments = ref.watch(aiChatAttachmentServiceProvider);
  final summarizer = ref.watch(aiConversationSummarizerProvider);
  return AiChatNotifier(ref, voice, ai, threads, attachments, summarizer);
});
