import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:raabta/features/quick_actions/climate_navigator/l10n/climate_strings.dart';
import 'package:raabta/features/quick_actions/climate_navigator/models/qatar_weather.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/climate_status_listen_session.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/climate_status_narration.dart';
import 'package:raabta/features/scam_shield/evidence_listen/evidence_listen_controller.dart';
import 'package:raabta/features/scam_shield/evidence_listen/evidence_tts_availability.dart';
import 'package:share_plus/share_plus.dart';

/// On-device speak + plain-text share for status hero (Parts B/C).
class ClimateStatusMediaActions extends StatefulWidget {
  const ClimateStatusMediaActions({
    super.key,
    required this.weather,
    required this.locale,
  });

  final QatarWeather weather;
  final String locale;

  @override
  State<ClimateStatusMediaActions> createState() =>
      _ClimateStatusMediaActionsState();
}

class _ClimateStatusMediaActionsState extends State<ClimateStatusMediaActions> {
  final _listen = EvidenceListenController();
  var _voiceAvailable = false;
  var _prepared = false;
  var _disposed = false;

  @override
  void initState() {
    super.initState();
    _listen.onStateChanged = () {
      if (!_disposed && mounted) setState(() {});
    };
    ClimateStatusListenSession.register(_listen);
    _prepareVoice();
  }

  Future<void> _prepareVoice() async {
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.windows) {
      if (mounted) {
        setState(() {
          _voiceAvailable = false;
          _prepared = true;
        });
      }
      return;
    }
    await _listen.configureForLocale(widget.locale);
    final ok = await _listen.prepareVoice(
      widget.locale,
      () => EvidenceTtsAvailability.resolveAvailableTag(widget.locale),
    );
    if (mounted) {
      setState(() {
        _voiceAvailable = ok;
        _prepared = true;
      });
    }
  }

  @override
  void dispose() {
    _disposed = true;
    ClimateStatusListenSession.unregister(_listen);
    _listen.stopForDispose();
    super.dispose();
  }

  Future<void> _speak() async {
    if (!_voiceAvailable) return;
    final script = ClimateStatusNarration.buildNarrationScript(
      weather: widget.weather,
      locale: widget.locale,
    );
    await _listen.speak(script, locale: widget.locale);
  }

  Future<void> _share() async {
    final text = ClimateStatusNarration.buildShareText(
      weather: widget.weather,
      locale: widget.locale,
    );
    await Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    if (!_prepared) {
      return const SizedBox(height: 40);
    }

    final showSpeak = _voiceAvailable;
    final speaking = _listen.isSpeaking;

    return Row(
      children: [
        if (showSpeak) ...[
          TextButton.icon(
            onPressed: speaking ? _listen.stop : _speak,
            icon: Icon(speaking ? Icons.stop_circle_outlined : Icons.volume_up_rounded),
            label: Text(
              ClimateStrings.t(
                speaking ? 'status_actions_stop' : 'status_actions_speak',
                widget.locale,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        TextButton.icon(
          onPressed: _share,
          icon: const Icon(Icons.ios_share_outlined),
          label: Text(
            ClimateStrings.t('status_actions_share', widget.locale),
          ),
        ),
      ],
    );
  }
}
