import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/raabta_orb.dart';
import 'package:raabta/core/widgets/raabta_orb_state.dart';
import 'package:raabta/features/home/widgets/home_primary_brand_fill.dart';
import 'package:raabta/screens/ai_chat/models/ai_chat_message.dart';
import 'package:raabta/screens/ai_chat/utils/ai_chat_error_message.dart';
import 'package:raabta/screens/ai_chat/l10n/ai_chat_strings.dart';
import 'package:raabta/screens/ai_chat/widgets/ai_labour_disclaimer.dart';
import 'package:raabta/screens/ai_chat/widgets/ai_message_actions.dart';
import 'package:raabta/screens/ai_chat/widgets/ai_response_action_bar.dart';
import 'package:raabta/screens/ai_chat/widgets/ai_streaming_cursor.dart';
import 'package:raabta/services/ai/ai_chat_response_parser.dart';

class AiChatBubble extends StatefulWidget {
  const AiChatBubble({
    super.key,
    required this.message,
    required this.isRtl,
    required this.locale,
    this.isSpeaking = false,
    this.onSpeak,
    this.onRetry,
    this.onRegenerate,
    this.onEdit,
    this.onReply,
    this.showLabourDisclaimer = false,
  });

  final AiChatMessage message;
  final bool isRtl;
  final String locale;
  final bool isSpeaking;
  final VoidCallback? onSpeak;
  final VoidCallback? onRetry;
  final VoidCallback? onRegenerate;
  final Future<void> Function(String newText)? onEdit;
  final VoidCallback? onReply;
  final bool showLabourDisclaimer;

  @override
  State<AiChatBubble> createState() => _AiChatBubbleState();
}

class _AiChatBubbleState extends State<AiChatBubble> {
  Future<void> _promptEdit(BuildContext context) async {
    if (widget.onEdit == null) return;
    final controller = TextEditingController(text: widget.message.text);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: Text(AiChatStrings.t('ai_edit_message', widget.locale)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 4,
          minLines: 1,
          decoration: InputDecoration(
            hintText: AiChatStrings.t('ai_input_hint', widget.locale),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AiChatStrings.t('ai_dismiss', widget.locale)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(AiChatStrings.t('ai_save', widget.locale)),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await widget.onEdit!(result);
    }
  }

  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AiChatStrings.t('ai_copied', widget.locale)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.surfaceElevated,
      ),
    );
  }

  void _showActions({
    required String text,
    String? parsedDisplayText,
  }) {
    showAiMessageActionSheet(
      context,
      locale: widget.locale,
      text: text,
      onReply: widget.onReply,
      onCopy: () => _copyText(parsedDisplayText ?? text),
      onEdit: widget.onEdit != null ? () => _promptEdit(context) : null,
      onRegenerate: widget.onRegenerate,
      onSpeak: widget.onSpeak,
    );
  }

  Widget _wrapInteractions({
    required Widget child,
    required VoidCallback onLongPress,
    bool swipeToReply = false,
  }) {
    Widget wrapped = GestureDetector(
      onLongPress: onLongPress,
      child: child,
    );
    if (swipeToReply && widget.onReply != null) {
      wrapped = AiSwipeToReply(
        enabled: true,
        isRtl: widget.isRtl,
        locale: widget.locale,
        messageId: widget.message.id,
        onReply: widget.onReply!,
        child: wrapped,
      );
    }
    return wrapped;
  }

  bool get _isError => AiChatErrorMessage.isErrorText(widget.message.text);

  RaabtaOrbState get _avatarOrbState {
    if (_isError) return RaabtaOrbState.error;
    if (widget.message.isStreaming) {
      return widget.message.text.trim().isEmpty
          ? RaabtaOrbState.processing
          : RaabtaOrbState.responding;
    }
    return RaabtaOrbState.idle;
  }

  Widget _orbAvatar() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: AppSpacing.xxs,
        end: AppSpacing.xs,
      ),
      child: RaabtaOrb(state: _avatarOrbState, size: 22),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.message.isUser) {
      return Align(
        alignment: widget.isRtl ? Alignment.centerLeft : Alignment.centerRight,
        child: _wrapInteractions(
          onLongPress: () => _showActions(text: widget.message.text),
          child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.78,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: HomePrimaryBrandFill.gradientColors(),
            ),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(AppSpacing.radiusSm),
              topRight: const Radius.circular(AppSpacing.radiusSm),
              bottomLeft: Radius.circular(widget.isRtl ? 4 : AppSpacing.radiusSm),
              bottomRight: Radius.circular(widget.isRtl ? AppSpacing.radiusSm : 4),
            ),
          ),
          child: Directionality(
            textDirection:
                widget.isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: Text(
              widget.message.text,
              style: AppTypography.body.copyWith(color: Colors.white),
            ),
          ),
        ),
        ),
      );
    }

    if (_isError) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _orbAvatar(),
            Expanded(
              child: GlassContainer(
                padding: const EdgeInsets.all(AppSpacing.md),
                borderRadius: AppSpacing.radiusSm,
                glowColor: AppColors.goldFamilyMain,
                glowIntensity: 0.12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: AppSpacing.iconSm,
                          color: AppColors.goldFamilyMain,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          AiChatStrings.t('ai_error_title', widget.locale),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.goldFamilyMain,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      AiChatStrings.t('ai_error_body', widget.locale),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (widget.onRetry != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      TextButton.icon(
                        onPressed: widget.onRetry,
                        icon: Icon(
                          Icons.refresh_rounded,
                          size: 18,
                          color: AppColors.brandFamilyMain,
                        ),
                        label: Text(
                          AiChatStrings.t('ai_retry', widget.locale),
                          style: AppTypography.link.copyWith(
                            color: AppColors.brandFamilyMain,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (widget.message.isStreaming && widget.message.text.trim().isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _orbAvatar(),
            Expanded(
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                borderRadius: AppSpacing.radiusSm,
                glowColor: AppColors.purpleGlow,
                glowIntensity: 0.08,
                child: const SizedBox(height: AppSpacing.lg),
              ),
            ),
          ],
        ),
      );
    }

    final parsed = AiChatResponseParser.parse(widget.message.text);
    final displayText = parsed.displayText.isEmpty && widget.message.isStreaming
        ? '…'
        : parsed.displayText;

    return Column(
      crossAxisAlignment:
          widget.isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        _wrapInteractions(
          swipeToReply: !widget.message.isStreaming,
          onLongPress: () => _showActions(
            text: widget.message.text,
            parsedDisplayText: parsed.displayText,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _orbAvatar(),
              Expanded(
                child: Align(
                  alignment: widget.isRtl
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: GlassContainer(
                    margin: const EdgeInsets.only(bottom: AppSpacing.xxs),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.sm,
                      AppSpacing.sm,
                    ),
                    borderRadius: AppSpacing.radiusSm,
                    glowColor: AppColors.purpleGlow,
                    glowIntensity: 0.1,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.72,
                      ),
                      child: Column(
                        crossAxisAlignment: widget.isRtl
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Directionality(
                                  textDirection: widget.isRtl
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  child: MarkdownBody(
                                    data: displayText,
                                    styleSheet: MarkdownStyleSheet(
                                      p: AppTypography.body.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                      listBullet: AppTypography.body.copyWith(
                                        color: AppColors.cyanGlow,
                                      ),
                                      strong: AppTypography.body.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                      code: AppTypography.caption.copyWith(
                                        fontFamily: 'monospace',
                                        color: AppColors.cyanGlow,
                                      ),
                                    ),
                                    shrinkWrap: true,
                                  ),
                                ),
                              ),
                              if (widget.message.isStreaming)
                                const AiStreamingCursor(),
                            ],
                          ),
                          if (!widget.message.isStreaming &&
                              displayText.isNotEmpty)
                            AiResponseActionBar(
                              actions: parsed.actions,
                              citations: parsed.citations,
                            ),
                          if (!widget.message.isStreaming &&
                              displayText.isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (widget.onRegenerate != null)
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(
                                      Icons.refresh_rounded,
                                      size: 16,
                                    ),
                                    color: AppColors.textSecondary,
                                    tooltip: AiChatStrings.t(
                                      'ai_regenerate',
                                      widget.locale,
                                    ),
                                    onPressed: widget.onRegenerate,
                                  ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(Icons.copy_rounded, size: 16),
                                  color: AppColors.textSecondary,
                                  tooltip:
                                      AiChatStrings.t('ai_copy', widget.locale),
                                  onPressed: () => _copyText(parsed.displayText),
                                ),
                                if (widget.onSpeak != null)
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: Icon(
                                      widget.isSpeaking
                                          ? Icons.stop_circle_outlined
                                          : Icons.volume_up_rounded,
                                      size: 18,
                                    ),
                                    color: AppColors.cyanGlow,
                                    onPressed: widget.onSpeak,
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.showLabourDisclaimer && !widget.message.isStreaming)
          AiLabourDisclaimer(locale: widget.locale),
      ],
    );
  }
}
