import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/features/home/widgets/home_primary_brand_fill.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/providers/ai_chat_provider.dart';
import 'package:raabta/screens/ai_chat/l10n/ai_chat_strings.dart';

class AiChatComposer extends StatelessWidget {
  const AiChatComposer({
    super.key,
    required this.locale,
    required this.chatState,
    required this.controller,
    required this.onSend,
    required this.onAttach,
    required this.onStopGeneration,
    required this.onStartVoice,
    required this.onStopVoice,
    required     this.onClearAttachment,
    this.bottomInset = AppSpacing.md,
    this.focusNode,
    this.hintText,
  });

  final String locale;
  final AiChatState chatState;
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final VoidCallback onStopGeneration;
  final VoidCallback onStartVoice;
  final VoidCallback onStopVoice;
  final VoidCallback onClearAttachment;
  final double bottomInset;
  final FocusNode? focusNode;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    if (chatState.isListening) {
      return _ListeningBar(
        locale: locale,
        chatState: chatState,
        bottomInset: bottomInset,
        onStopVoice: onStopVoice,
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (chatState.pendingAttachment != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _AttachmentChip(
                locale: locale,
                fileName: chatState.pendingAttachment!.fileName,
                onClear: onClearAttachment,
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: GlassContainer(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xs,
                    AppSpacing.xs,
                    AppSpacing.xs,
                    AppSpacing.xs,
                  ),
                  borderRadius: AppSpacing.radiusFull,
                  glowIntensity: 0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: AppSpacing.aiComposerHeight,
                    ),
                    child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: chatState.isGenerating ||
                                chatState.isProcessingAttachment
                            ? null
                            : onAttach,
                        icon: chatState.isProcessingAttachment
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.add_rounded),
                        tooltip: AiChatStrings.t('ai_attach_document', locale),
                        color: AppColors.textOnGlassMuted,
                      ),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          enabled: !chatState.isGenerating,
                          style: AppTypography.body.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          minLines: 1,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: hintText ??
                                AiChatStrings.t('ai_input_hint', locale),
                            hintStyle: AppTypography.body.copyWith(
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm,
                            ),
                          ),
                          onSubmitted: (_) {
                            if (!chatState.isGenerating) onSend();
                          },
                        ),
                      ),
                      ListenableBuilder(
                        listenable: controller,
                        builder: (context, _) {
                          final canSend = controller.text.trim().isNotEmpty;
                          return _SendStopButton(
                            isGenerating: chatState.isGenerating,
                            canSend: canSend,
                            onSend: onSend,
                            onStop: onStopGeneration,
                          );
                        },
                      ),
                    ],
                  ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _MicButton(
                sttAvailable: chatState.sttAvailable,
                isListening: chatState.isListening,
                isSending: chatState.isSending,
                onStart: onStartVoice,
                onStop: onStopVoice,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SendStopButton extends StatelessWidget {
  const _SendStopButton({
    required this.isGenerating,
    required this.canSend,
    required this.onSend,
    required this.onStop,
  });

  final bool isGenerating;
  final bool canSend;
  final VoidCallback onSend;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final enabled = isGenerating || canSend;
    return GestureDetector(
      onTap: enabled
          ? () {
              if (isGenerating) {
                onStop();
              } else if (canSend) {
                onSend();
              }
            }
          : null,
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.only(right: AppSpacing.xxs),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: canSend || isGenerating
              ? null
              : AppColors.glassSurface,
          gradient: canSend || isGenerating
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isGenerating
                      ? [AppColors.roseGlow, AppColors.roseGlow]
                      : HomePrimaryBrandFill.gradientColors(),
                )
              : null,
          border: Border.all(
            color: canSend || isGenerating
                ? Colors.transparent
                : AppColors.glassBorder,
          ),
        ),
        child: Icon(
          isGenerating ? Icons.stop_rounded : Icons.arrow_upward_rounded,
          color: canSend || isGenerating
              ? Colors.white.withValues(alpha: 0.98)
              : AppColors.textOnGlassMuted,
          size: 20,
        ),
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton({
    required this.sttAvailable,
    required this.isListening,
    required this.isSending,
    required this.onStart,
    required this.onStop,
  });

  final bool sttAvailable;
  final bool isListening;
  final bool isSending;
  final VoidCallback onStart;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSending
          ? null
          : () {
              if (isListening) {
                onStop();
              } else {
                onStart();
              }
            },
      child: GlassContainer(
        borderRadius: AppSpacing.radiusFull,
        padding: EdgeInsets.zero,
        glowIntensity: 0,
        width: AppSpacing.aiComposerHeight,
        height: AppSpacing.aiComposerHeight,
        child: Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isListening
                  ? AppColors.roseGlow.withValues(alpha: 0.85)
                  : Colors.transparent,
            ),
            child: SizedBox(
              width: AppSpacing.aiComposerHeight,
              height: AppSpacing.aiComposerHeight,
              child: Icon(
                !sttAvailable
                    ? Icons.mic_off_rounded
                    : (isListening
                        ? Icons.stop_rounded
                        : Icons.mic_none_rounded),
                color: sttAvailable
                    ? AppColors.textOnGlassSecondary
                    : AppColors.textOnGlassMuted,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  const _AttachmentChip({
    required this.locale,
    required this.fileName,
    required this.onClear,
  });

  final String locale;
  final String fileName;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      borderRadius: AppSpacing.radiusFull,
      child: Row(
        children: [
          const Icon(
            Icons.attach_file_rounded,
            size: 16,
            color: AppColors.cyanGlow,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              '${AiChatStrings.t('ai_attachment_ready', locale)}: $fileName',
              style: AppTypography.caption,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            icon: const Icon(Icons.close_rounded, size: 16),
            onPressed: onClear,
          ),
        ],
      ),
    );
  }
}

class _ListeningBar extends StatelessWidget {
  const _ListeningBar({
    required this.locale,
    required this.chatState,
    required this.bottomInset,
    required this.onStopVoice,
  });

  final String locale;
  final AiChatState chatState;
  final double bottomInset;
  final VoidCallback onStopVoice;

  static const Color _gold = AppColors.accentGold;
  static const Color _purple = AppColors.sharePurple;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        bottomInset,
      ),
      borderRadius: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: chatState.soundLevel / 10,
            backgroundColor: AppColors.glassBorder,
            valueColor: const AlwaysStoppedAnimation<Color>(_gold),
          ),
          const SizedBox(height: AppSpacing.lg),
          AvatarGlow(
            animate: true,
            glowColor: _gold,
            endRadius: 70,
            duration: const Duration(milliseconds: 2000),
            repeat: true,
            child: GestureDetector(
              onTap: onStopVoice,
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _purple,
                ),
                child: const Icon(Icons.mic, color: Colors.white, size: 32),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            chatState.recognizedVoiceText.isEmpty
                ? AiChatStrings.t('ai_listening', locale)
                : chatState.recognizedVoiceText,
            style: TextStyle(
              color: chatState.recognizedVoiceText.isEmpty
                  ? (AppColors.isLight
                      ? AppColors.textOnGlassMuted
                      : Colors.white54)
                  : (AppColors.isLight
                      ? AppColors.textPrimary
                      : Colors.white),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
