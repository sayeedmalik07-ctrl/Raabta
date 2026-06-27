import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/data/qatar_labour_law_kb.dart';
import 'package:raabta/providers/ai_chat_provider.dart';
import 'package:raabta/services/voice_service.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({
    super.key,
    this.onBack,
    this.initialMessage,
    this.contextSubtitle,
    this.autoSendInitialMessage = true,
  });

  final VoidCallback? onBack;
  final String? initialMessage;
  final String? contextSubtitle;

  final bool autoSendInitialMessage;

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  static const Color _backgroundColor = Color(0xFF0F0F0F);
  static const Color _surfaceColor = Color(0xFF1A1A2E);
  static const Color _purple = Color(0xFF6C3FC5);
  static const Color _gold = Color(0xFFFFB627);
  static const Color _subtitleColor = Color(0xFF8A9BB0);

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _pendingInitialSend = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialMessage?.trim();
    if (initial != null && initial.isNotEmpty) {
      _messageController.text = initial;
      if (widget.autoSendInitialMessage) {
        _pendingInitialSend = true;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiChatProvider.notifier).initVoice();
      if (_pendingInitialSend) {
        _pendingInitialSend = false;
        ref.read(aiChatProvider.notifier).sendMessage(initial!);
        _messageController.clear();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendFromField() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    await ref.read(aiChatProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  bool _isRtl(String code) => code == 'ar' || code == 'ur';

  @override
  Widget build(BuildContext context) {
    ref.listen<AiChatState>(aiChatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length ||
          previous?.isSending != next.isSending) {
        _scrollToBottom();
      }
    });

    final chatState = ref.watch(aiChatProvider);
    final showEmptyState =
        chatState.messages.isEmpty && !chatState.isSending;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _surfaceColor,
        elevation: 0,
        leading: IconButton(
          onPressed: _handleBack,
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Raabta AI',
              style: TextStyle(
                color: _gold,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.contextSubtitle ?? 'Qatar Labour Rights + General Help',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final ttsAvailable = ref.watch(aiChatProvider).ttsAvailable;
              final voiceEnabled = ref.watch(aiChatProvider).voiceEnabled;
              return IconButton(
                icon: Icon(
                  ttsAvailable
                      ? (voiceEnabled
                          ? Icons.record_voice_over_rounded
                          : Icons.voice_over_off_rounded)
                      : Icons.speaker_notes_off_rounded,
                  color: ttsAvailable
                      ? (voiceEnabled ? _gold : Colors.white38)
                      : Colors.white24,
                ),
                onPressed: ttsAvailable
                    ? () => ref
                        .read(aiChatProvider.notifier)
                        .toggleVoiceEnabled()
                    : null,
                tooltip: ttsAvailable
                    ? 'Toggle voice responses'
                    : 'Voice not available',
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildLanguageSelector(chatState),
            const SizedBox(height: 8),
            if (showEmptyState) ...[
              _buildQuickTopicChips(),
              const SizedBox(height: 8),
            ],
            Expanded(
              child: showEmptyState
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🤖', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 16),
                            const Text(
                              'Ask Raabta AI',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Visa, housing, labour rights — ask in your language',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _subtitleColor.withValues(alpha: 0.9),
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      itemCount:
                          chatState.messages.length +
                          (chatState.isSending ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (chatState.isSending &&
                            index == chatState.messages.length) {
                          return const _LoadingBubble();
                        }
                        final message = chatState.messages[index];
                        return _ChatBubble(
                          message: message,
                          isRtl: _isRtl(chatState.selectedLanguage.code),
                          isSpeaking:
                              chatState.isSpeaking && !message.isUser,
                          onSpeak: message.isUser
                              ? null
                              : () => ref
                                  .read(aiChatProvider.notifier)
                                  .speakMessage(message.text),
                        );
                      },
                    ),
            ),
            _buildInputBar(chatState),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(AiChatState chatState) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: supportedLanguages.length,
        separatorBuilder: (context, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final lang = supportedLanguages[index];
          final isSelected = lang.code == chatState.selectedLanguage.code;
          return GestureDetector(
            onTap: () =>
                ref.read(aiChatProvider.notifier).changeLanguage(lang),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? _purple : _surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? _gold : Colors.white24,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                '${lang.flag} ${lang.displayName}',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickTopicChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            '⚖️ Qatar Labour Rights — Quick Help',
            style: TextStyle(
              color: _gold,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: 86,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: QatarLabourLawKB.quickTopics.length,
            separatorBuilder: (context, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final topic = QatarLabourLawKB.quickTopics[index];
              return GestureDetector(
                onTap: () => ref
                    .read(aiChatProvider.notifier)
                    .sendMessage(topic['question']!),
                child: Container(
                  width: 88,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _purple),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        topic['icon']!,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        topic['label']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInputBar(AiChatState chatState) {
    if (chatState.isListening) {
      return Container(
        color: _backgroundColor,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: chatState.soundLevel / 10,
              backgroundColor: _surfaceColor,
              valueColor: const AlwaysStoppedAnimation<Color>(_gold),
            ),
            const SizedBox(height: 20),
            AvatarGlow(
              animate: true,
              glowColor: _gold,
              endRadius: 70,
              duration: const Duration(milliseconds: 2000),
              repeat: true,
              child: GestureDetector(
                onTap: () =>
                    ref.read(aiChatProvider.notifier).stopVoiceInput(),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: _purple,
                  ),
                  child: const Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              chatState.recognizedVoiceText.isEmpty
                  ? 'Listening... tap mic to stop'
                  : chatState.recognizedVoiceText,
              style: TextStyle(
                color: chatState.recognizedVoiceText.isEmpty
                    ? Colors.white54
                    : Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    }

    return Container(
      color: _backgroundColor,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      enabled: !chatState.isSending,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Ask about your rights in Qatar...',
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendFromField(),
                    ),
                  ),
                  Consumer(
                    builder: (context, ref, _) {
                      final ttsAvailable =
                          ref.watch(aiChatProvider).ttsAvailable;
                      final voiceEnabled =
                          ref.watch(aiChatProvider).voiceEnabled;

                      return IconButton(
                        onPressed: ttsAvailable
                            ? () => ref
                                .read(aiChatProvider.notifier)
                                .toggleVoiceEnabled()
                            : null,
                        icon: Icon(
                          voiceEnabled
                              ? Icons.volume_up_rounded
                              : Icons.volume_off_rounded,
                          color: ttsAvailable
                              ? (voiceEnabled ? _gold : Colors.white54)
                              : Colors.white24,
                          size: 20,
                        ),
                        tooltip: ttsAvailable
                            ? (voiceEnabled
                                ? 'Turn off voice responses'
                                : 'Turn on voice responses')
                            : 'Speaker not available',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: chatState.isSending ? null : _sendFromField,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: chatState.isSending ? Colors.white24 : _purple,
              ),
              child: chatState.isSending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Consumer(
            builder: (context, ref, _) {
              final sttAvailable = ref.watch(aiChatProvider).sttAvailable;
              final isListening = ref.watch(aiChatProvider).isListening;
              final isSending = ref.watch(aiChatProvider).isSending;

              return GestureDetector(
                onTap: isSending
                    ? null
                    : () {
                        if (!sttAvailable) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                '🎤 Voice input requires iOS or Android device.\n'
                                'Please type your question instead.',
                              ),
                              backgroundColor: _purple,
                              duration: const Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                          return;
                        }
                        if (isListening) {
                          ref.read(aiChatProvider.notifier).stopVoiceInput();
                        } else {
                          ref.read(aiChatProvider.notifier).startVoiceInput();
                        }
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: sttAvailable && !isListening
                        ? const LinearGradient(
                            colors: [Color(0xFFFFB627), Color(0xFFFF8C00)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isListening
                        ? const Color(0xFFFF4444)
                        : (!sttAvailable ? Colors.white12 : null),
                    boxShadow: sttAvailable
                        ? [
                            BoxShadow(
                              color: (isListening
                                      ? const Color(0xFFFF4444)
                                      : _gold)
                                  .withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    isListening
                        ? Icons.stop_rounded
                        : (sttAvailable
                            ? Icons.mic_rounded
                            : Icons.mic_off_rounded),
                    color: sttAvailable ? Colors.white : Colors.white38,
                    size: 26,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LoadingBubble extends StatelessWidget {
  const _LoadingBubble();

  static const Color _surfaceColor = Color(0xFF1A1A2E);
  static const Color _purple = Color(0xFF6C3FC5);
  static const Color _subtitleColor = Color(0xFF8A9BB0);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: const Border(
            left: BorderSide(color: _purple, width: 3),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _purple,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Raabta AI is thinking...',
              style: TextStyle(
                color: _subtitleColor,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.isRtl,
    required this.isSpeaking,
    this.onSpeak,
  });

  final AiChatMessage message;
  final bool isRtl;
  final bool isSpeaking;
  final VoidCallback? onSpeak;

  static const Color _surfaceColor = Color(0xFF1A1A2E);
  static const Color _purple = Color(0xFF6C3FC5);
  static const Color _gold = Color(0xFFFFB627);
  static const Color _errorColor = Color(0xFFF87171);

  bool get _isError =>
      message.text.startsWith('Connection Error:') ||
      message.text.startsWith('Error:');

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return Align(
        alignment: isRtl ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _purple,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isRtl ? 4 : 16),
              bottomRight: Radius.circular(isRtl ? 16 : 4),
            ),
          ),
          child: Directionality(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: Text(
              message.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isRtl ? 16 : 4),
            topRight: Radius.circular(isRtl ? 4 : 16),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          ),
          border: Border(
            left: BorderSide(
              color: _isError ? _errorColor : _purple,
              width: 3,
            ),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Column(
          crossAxisAlignment:
              isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Directionality(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: Text(
                message.text,
                style: TextStyle(
                  color: _isError ? _errorColor : Colors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
            if (onSpeak != null && !_isError) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onSpeak,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _purple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _gold.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Icon(
                    isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded,
                    color: _gold,
                    size: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
