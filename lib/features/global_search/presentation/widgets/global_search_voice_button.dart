import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/features/global_search/data/search_voice_service.dart';
import 'package:raabta/features/global_search/domain/search_voice_error.dart';
import 'package:raabta/features/global_search/domain/search_voice_state.dart';
import 'package:raabta/features/global_search/presentation/search_voice_controller.dart';

/// Microphone control for Global Search voice input (S11).
class GlobalSearchVoiceButton extends ConsumerWidget {
  const GlobalSearchVoiceButton({
    super.key,
    required this.locale,
    required this.onPartialTranscript,
    required this.onSubmitFinal,
    this.enabled = true,
  });

  final String locale;
  final ValueChanged<String> onPartialTranscript;
  final ValueChanged<String> onSubmitFinal;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(searchVoiceControllerProvider);
    final controller = ref.read(searchVoiceControllerProvider.notifier);
    final service = ref.read(searchVoiceServiceProvider);

    ref.listen<SearchVoiceState>(searchVoiceControllerProvider, (prev, next) {
      if (next.status == SearchVoiceStatus.error && next.errorCode != null) {
        final code = next.errorCode!;
        if (code == SearchVoiceErrorCode.cancelled) return;
        final message = AppShellStrings.t(code.messageKey, locale);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            action: code == SearchVoiceErrorCode.permissionPermanentlyDenied
                ? SnackBarAction(
                    label: AppShellStrings.t(
                      'global_search_voice_permission_settings',
                      locale,
                    ),
                    onPressed: openSearchVoicePermissionSettings,
                  )
                : null,
          ),
        );
        controller.clearError();
      }
    });

    if (!service.supportsPlatform ||
        voiceState.status == SearchVoiceStatus.unavailable) {
      return Semantics(
        label: AppShellStrings.t('global_search_voice_unavailable', locale),
        child: const SizedBox(
          width: 44,
          height: 44,
        ),
      );
    }

    final isListening = voiceState.status == SearchVoiceStatus.listening;
    final isBusy = voiceState.status == SearchVoiceStatus.initializing ||
        voiceState.status == SearchVoiceStatus.processing;

    final semanticLabel = isListening
        ? AppShellStrings.t('global_search_voice_stop', locale)
        : AppShellStrings.t('global_search_voice_search', locale);

    return Semantics(
      button: true,
      label: semanticLabel,
      child: SizedBox(
        width: 44,
        height: 44,
        child: IconButton(
          onPressed: !enabled || isBusy
              ? null
              : () => controller.toggleListening(
                    appLocale: locale,
                    onSubmitFinal: onSubmitFinal,
                    onPartialTranscript: onPartialTranscript,
                  ),
          icon: isBusy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                  color: isListening ? AppColors.cyanGlow : null,
                ),
          tooltip: semanticLabel,
        ),
      ),
    );
  }
}
