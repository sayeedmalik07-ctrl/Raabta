import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/quick_actions/climate_navigator/l10n/climate_strings.dart';
import 'package:raabta/features/quick_actions/climate_navigator/models/qatar_weather.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/climate_heat_reminder_scheduler.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/hydration_reminder_preferences.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/heat_illness_guide_panel.dart';
import 'package:raabta/services/notifications/notification_service.dart';

/// Opt-in heat-triggered local reminders (Climate Navigator).
class HydrationReminderToggle extends StatefulWidget {
  const HydrationReminderToggle({
    super.key,
    required this.locale,
    this.weather,
  });

  final String locale;
  final QatarWeather? weather;

  @override
  State<HydrationReminderToggle> createState() =>
      _HydrationReminderToggleState();
}

class _HydrationReminderToggleState extends State<HydrationReminderToggle> {
  ClimateHeatReminderPreferences? _prefs;
  bool _busy = false;
  String? _permissionMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant HydrationReminderToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weather != widget.weather && widget.weather != null) {
      _rescheduleIfEnabled();
    }
  }

  Future<void> _load() async {
    final prefs = await ClimateHeatReminderPreferences.load();
    if (mounted) setState(() => _prefs = prefs);
    await _rescheduleIfEnabled();
  }

  Future<void> _rescheduleIfEnabled() async {
    final prefs = _prefs;
    final weather = widget.weather;
    if (prefs == null || !prefs.enabled || weather == null) return;
    await ClimateHeatReminderScheduler.syncFromWeather(
      weather: weather,
      locale: widget.locale,
    );
  }

  Future<void> _persist(ClimateHeatReminderPreferences next) async {
    setState(() {
      _busy = true;
      _prefs = next;
    });
    await ClimateHeatReminderPreferences.save(next);
    if (next.enabled && widget.weather != null) {
      await ClimateHeatReminderScheduler.syncFromWeather(
        weather: widget.weather!,
        locale: widget.locale,
      );
    } else if (widget.weather != null) {
      await ClimateHeatReminderScheduler.syncFromWeather(
        weather: widget.weather!,
        locale: widget.locale,
      );
    } else {
      await NotificationService.cancelHeatSafetyAlert();
      await NotificationService.cancelClimateHeatReminders();
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _onMainToggle(bool value) async {
    if (_busy) return;
    if (!value) {
      await _persist(_prefs!.copyWith(enabled: false));
      setState(() => _permissionMessage = null);
      return;
    }

    setState(() => _busy = true);
    final granted = await NotificationService.requestPermission();
    if (!granted) {
      await ClimateHeatReminderPreferences.setEnabled(false);
      if (mounted) {
        setState(() {
          _prefs = _prefs?.copyWith(enabled: false);
          _busy = false;
          _permissionMessage =
              ClimateStrings.t('heat_reminder_permission_denied', widget.locale);
        });
      }
      return;
    }

    await _persist(_prefs!.copyWith(enabled: true));
    if (mounted) {
      setState(() {
        _busy = false;
        _permissionMessage = null;
      });
    }
  }

  Future<void> _pickTime({
    required TimeOfDay initial,
    required void Function(TimeOfDay) onPicked,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) onPicked(picked);
  }

  String _formatTime(TimeOfDay t) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, t.hour, t.minute);
    return DateFormat.Hm().format(dt);
  }

  String? _forecastBasisLabel() {
    final weather = widget.weather;
    if (weather == null) return null;
    final time = DateFormat.Hm().format(weather.fetchedAt.toLocal());
    if (weather.isFallback) {
      return ClimateStrings.t('weather_estimated', widget.locale);
    }
    return ClimateStrings.format(
      'heat_reminder_forecast_basis',
      widget.locale,
      params: {'time': time},
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = _prefs;
    if (prefs == null) {
      return const SizedBox(
        height: 48,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final basis = _forecastBasisLabel();

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              ClimateStrings.t('hydration_reminder_toggle_label', widget.locale),
              style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              ClimateStrings.t(
                'hydration_reminder_toggle_subtitle',
                widget.locale,
              ),
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
            value: prefs.enabled,
            onChanged: _busy ? null : _onMainToggle,
            activeThumbColor: AppColors.successBright,
          ),
          if (_permissionMessage != null) ...[
            Text(
              _permissionMessage!,
              style: AppTypography.caption.copyWith(color: AppColors.error),
            ),
            TextButton(
              onPressed: openAppSettings,
              child: Text(
                ClimateStrings.t(
                  'heat_reminder_open_settings',
                  widget.locale,
                ),
              ),
            ),
          ],
          if (prefs.enabled) ...[
            if (basis != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  basis,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
            _TimeRow(
              label: ClimateStrings.t(
                'heat_reminder_active_start',
                widget.locale,
              ),
              value: _formatTime(prefs.activeStart),
              onTap: _busy
                  ? null
                  : () => _pickTime(
                        initial: prefs.activeStart,
                        onPicked: (t) => _persist(prefs.copyWith(activeStart: t)),
                      ),
            ),
            _TimeRow(
              label: ClimateStrings.t('heat_reminder_active_end', widget.locale),
              value: _formatTime(prefs.activeEnd),
              onTap: _busy
                  ? null
                  : () => _pickTime(
                        initial: prefs.activeEnd,
                        onPicked: (t) => _persist(prefs.copyWith(activeEnd: t)),
                      ),
            ),
            _TimeRow(
              label: ClimateStrings.t(
                'heat_reminder_quiet_start',
                widget.locale,
              ),
              value: _formatTime(prefs.quietStart),
              onTap: _busy
                  ? null
                  : () => _pickTime(
                        initial: prefs.quietStart,
                        onPicked: (t) => _persist(prefs.copyWith(quietStart: t)),
                      ),
            ),
            _TimeRow(
              label: ClimateStrings.t('heat_reminder_quiet_end', widget.locale),
              value: _formatTime(prefs.quietEnd),
              onTap: _busy
                  ? null
                  : () => _pickTime(
                        initial: prefs.quietEnd,
                        onPicked: (t) => _persist(prefs.copyWith(quietEnd: t)),
                      ),
            ),
            if (prefs.hasActiveWindow)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  ClimateStrings.t(
                    'heat_reminder_before_shift_label',
                    widget.locale,
                  ),
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                value: prefs.beforeShiftEnabled,
                onChanged: _busy
                    ? null
                    : (v) => _persist(prefs.copyWith(beforeShiftEnabled: v)),
                activeThumbColor: AppColors.successBright,
              ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: () =>
                    HeatIllnessGuidePanel.showSheet(context, widget.locale),
                child: Text(
                  ClimateStrings.t('open_guide', widget.locale),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(label, style: AppTypography.caption),
      trailing: TextButton(onPressed: onTap, child: Text(value)),
    );
  }
}
