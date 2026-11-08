import 'package:flutter/material.dart';
import 'package:raabta/core/widgets/glass_settings_tile.dart';
import 'package:raabta/features/scam_shield/anonymous_signal/scam_anonymous_signal_consent_screen.dart';
import 'package:raabta/features/scam_shield/anonymous_signal/scam_anonymous_signal_prefs.dart';
import 'package:raabta/features/scam_shield/anonymous_signal/scam_anonymous_signal_strings.dart';

class ScamAnonymousSignalSettingsTile extends StatefulWidget {
  const ScamAnonymousSignalSettingsTile({super.key, required this.locale});

  final String locale;

  @override
  State<ScamAnonymousSignalSettingsTile> createState() =>
      _ScamAnonymousSignalSettingsTileState();
}

class _ScamAnonymousSignalSettingsTileState
    extends State<ScamAnonymousSignalSettingsTile> {
  bool? _enabled;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final v = await ScamAnonymousSignalPrefs.isOptedIn();
    if (mounted) setState(() => _enabled = v);
  }

  Future<void> _onChanged(bool value) async {
    if (value) {
      final agreed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) =>
              ScamAnonymousSignalConsentScreen(locale: widget.locale),
        ),
      );
      if (agreed != true) {
        if (mounted) setState(() => _enabled = false);
        return;
      }
    } else {
      await ScamAnonymousSignalPrefs.setOptedIn(false);
    }
    if (mounted) setState(() => _enabled = value);
  }

  @override
  Widget build(BuildContext context) {
    if (_enabled == null) return const SizedBox.shrink();
    return GlassSettingsTile(
      title: ScamAnonymousSignalStrings.t('ss_signal_settings_title', widget.locale),
      subtitle:
          ScamAnonymousSignalStrings.t('ss_signal_settings_sub', widget.locale),
      trailing: Switch.adaptive(
        value: _enabled!,
        onChanged: _onChanged,
      ),
    );
  }
}
