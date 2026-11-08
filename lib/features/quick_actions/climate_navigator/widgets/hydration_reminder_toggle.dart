import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/quick_actions/climate_navigator/l10n/climate_strings.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/hydration_reminder_preferences.dart';
import 'package:raabta/services/notifications/notification_service.dart';

/// Opt-in rest/hydration break reminders (local notifications only).
class HydrationReminderToggle extends StatefulWidget {
  const HydrationReminderToggle({
    super.key,
    required this.locale,
  });

  final String locale;

  @override
  State<HydrationReminderToggle> createState() =>
      _HydrationReminderToggleState();
}

class _HydrationReminderToggleState extends State<HydrationReminderToggle> {
  bool? _enabled;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await HydrationReminderPreferences.isEnabled();
    if (mounted) setState(() => _enabled = enabled);
  }

  Future<void> _onChanged(bool value) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _enabled = value;
    });

    await HydrationReminderPreferences.setEnabled(value);
    await NotificationService.setHydrationRemindersEnabled(
      enabled: value,
      title: ClimateStrings.t('hydration_reminder_title', widget.locale),
      body: ClimateStrings.t('hydration_reminder_body', widget.locale),
    );

    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _enabled;

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        ClimateStrings.t('hydration_reminder_toggle_label', widget.locale),
        style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        ClimateStrings.t('hydration_reminder_toggle_subtitle', widget.locale),
        style: AppTypography.caption.copyWith(
          color: AppColors.textSecondary,
          height: 1.35,
        ),
      ),
      value: enabled ?? false,
      onChanged: enabled == null || _busy ? null : _onChanged,
      activeThumbColor: AppColors.successBright,
    );
  }
}
