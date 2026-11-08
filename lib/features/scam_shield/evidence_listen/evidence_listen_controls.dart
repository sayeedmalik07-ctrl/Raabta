import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/scam_shield/evidence_listen/evidence_listen_controller.dart';
import 'package:raabta/features/scam_shield/evidence_listen/evidence_spoken_script_builder.dart';
import 'package:raabta/features/scam_shield/evidence_listen/evidence_tts_availability.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';

class EvidenceListenControls extends StatefulWidget {
  const EvidenceListenControls({
    super.key,
    required this.locale,
    required this.script,
    this.maskedMessage,
  });

  final String locale;
  final String script;
  final String? maskedMessage;

  @override
  State<EvidenceListenControls> createState() => _EvidenceListenControlsState();
}

class _EvidenceListenControlsState extends State<EvidenceListenControls>
    with WidgetsBindingObserver {
  final _controller = EvidenceListenController();
  bool? _voiceAvailable;
  var _loadingVoice = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.onStateChanged = () {
      if (mounted) setState(() {});
    };
    _initVoice();
  }

  Future<void> _initVoice() async {
    await _controller.configureForLocale(widget.locale);
    final tag = await EvidenceTtsAvailability.resolveAvailableTag(widget.locale);
    final ok = tag != null;
    if (mounted) {
      setState(() {
        _voiceAvailable = ok;
        _loadingVoice = false;
      });
    }
    if (ok) {
      await _controller.prepareVoice(
        widget.locale,
        () async => tag,
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.inactive) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingVoice) return const SizedBox.shrink();
    if (_voiceAvailable != true) return const SizedBox.shrink();

    final speaking = _controller.isSpeaking;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            if (!speaking)
              OutlinedButton.icon(
                onPressed: () => _controller.speak(
                  widget.script,
                  locale: widget.locale,
                ),
                icon: const Icon(Icons.volume_up_outlined, size: 18),
                label: Text(
                  ScamShieldStrings.t('ss_listen_play', widget.locale),
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: _controller.stop,
                icon: const Icon(Icons.stop_circle_outlined, size: 18),
                label: Text(
                  ScamShieldStrings.t('ss_listen_stop', widget.locale),
                ),
              ),
            OutlinedButton(
              onPressed: _controller.isSpeaking ? null : _controller.repeat,
              child: Text(
                ScamShieldStrings.t('ss_listen_repeat', widget.locale),
              ),
            ),
            TextButton(
              onPressed: () {
                _controller.toggleSpeed();
                setState(() {});
              },
              child: Text(
                _controller.slow
                    ? ScamShieldStrings.t('ss_listen_speed_slow', widget.locale)
                    : ScamShieldStrings.t(
                        'ss_listen_speed_normal',
                        widget.locale,
                      ),
              ),
            ),
          ],
        ),
        if (widget.maskedMessage != null &&
            widget.maskedMessage!.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: TextButton.icon(
              onPressed: speaking
                  ? null
                  : () {
                      final script =
                          EvidenceSpokenScriptBuilder.buildReadMessage(
                        widget.locale,
                        widget.maskedMessage!,
                      );
                      _controller.speak(script, locale: widget.locale);
                    },
              icon: const Icon(Icons.record_voice_over_outlined, size: 16),
              label: Text(
                ScamShieldStrings.t('ss_listen_read_message', widget.locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
