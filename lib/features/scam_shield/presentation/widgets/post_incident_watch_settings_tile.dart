import 'package:flutter/material.dart';
import 'package:raabta/core/widgets/glass_settings_tile.dart';
import 'package:raabta/features/scam_shield/post_incident_watch/post_incident_watch_prefs.dart';
import 'package:raabta/features/scam_shield/post_incident_watch/post_incident_watch_providers.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostIncidentWatchSettingsTile extends ConsumerStatefulWidget {
  const PostIncidentWatchSettingsTile({super.key, required this.locale});

  final String locale;

  @override
  ConsumerState<PostIncidentWatchSettingsTile> createState() =>
      _PostIncidentWatchSettingsTileState();
}

class _PostIncidentWatchSettingsTileState
    extends ConsumerState<PostIncidentWatchSettingsTile> {
  bool? _enabled;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final v = await PostIncidentWatchPrefs.isReminderEnabled();
    if (mounted) setState(() => _enabled = v);
  }

  @override
  Widget build(BuildContext context) {
    if (_enabled == null) return const SizedBox.shrink();
    return GlassSettingsTile(
      title: ScamShieldStrings.t('ss_post_incident_settings_title', widget.locale),
      subtitle: ScamShieldStrings.t('ss_post_incident_settings_sub', widget.locale),
      trailing: Switch.adaptive(
        value: _enabled!,
        onChanged: (v) async {
          await PostIncidentWatchPrefs.setReminderEnabled(v);
          setState(() => _enabled = v);
          ref.invalidate(postIncidentWatchActiveProvider);
        },
      ),
    );
  }
}
