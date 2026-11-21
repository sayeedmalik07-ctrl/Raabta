import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/glass_settings_tile.dart';
import 'package:raabta/features/home/widgets/glass_loading_card.dart';
import 'package:raabta/features/notification_preferences/domain/notification_preferences_model.dart';
import 'package:raabta/features/notification_preferences/l10n/notification_prefs_strings.dart';
import 'package:raabta/features/notification_preferences/presentation/widgets/notification_category_tile.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_alert_config.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_monthly_tip_scheduler.dart';
import 'package:raabta/models/notification_models.dart';
import 'package:raabta/providers/notification_providers.dart';
import 'package:raabta/services/notifications/notification_preferences_service.dart';
import 'package:raabta/services/notifications/notification_type.dart';
import 'package:permission_handler/permission_handler.dart';

final notificationPreferencesServiceProvider =
    FutureProvider<NotificationPreferencesService>((ref) async {
  return createNotificationPreferencesService();
});

class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends ConsumerState<NotificationPreferencesScreen> {
  NotificationPreferencesModel? _model;
  bool _loading = true;
  bool _notificationsBlocked = false;

  static const _scamSecurityPushTypes = {
    NotificationType.scamAdvisoryAlert,
    NotificationType.securityTip,
  };

  @override
  void initState() {
    super.initState();
    _load();
    _refreshOsPermission();
  }

  Future<void> _refreshOsPermission() async {
    final status = await Permission.notification.status;
    if (mounted) {
      setState(() => _notificationsBlocked = status.isDenied || status.isPermanentlyDenied);
    }
  }

  Future<void> _load() async {
    final service =
        await ref.read(notificationPreferencesServiceProvider.future);
    final settings = await service.getSettings();
    if (mounted) {
      setState(() {
        _model = NotificationPreferencesModel(settings: settings);
        _loading = false;
      });
    }
  }

  Future<void> _save(NotificationSettings settings) async {
    setState(() {
      _model = _model?.copyWith(settings: settings) ??
          NotificationPreferencesModel(settings: settings);
    });
    final service =
        await ref.read(notificationPreferencesServiceProvider.future);
    await service.saveSettings(settings);
    ref.invalidate(notificationSettingsProvider);
    final locale = settings.notificationLanguage;
    await SecurityMonthlyTipScheduler.reconcile(locale: locale);
  }

  Future<void> _turnAllScamSecurityOff() async {
    final s = _model!.settings;
    await _save(
      s.copyWith(
        scamAdvisoryAlert: false,
        securityTip: false,
        securityTodayCards: false,
      ),
    );
  }

  String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour % 12 == 0 ? 12 : hour % 12;
    return '$h:00 $period';
  }

  Future<void> _pickHour({
    required int current,
    required ValueChanged<int> onPicked,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.sharePurple,
                  secondary: AppColors.accentGold,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onPicked(picked.hour);
  }

  @override
  Widget build(BuildContext context) {
    final locale = _model?.settings.notificationLanguage ?? 'English';
    final isRtl = locale == 'Arabic' || locale == 'Urdu';

    if (_loading || _model == null) {
      return GlassScreenScaffold(
        title: NotificationPrefsStrings.t('prefs_title', locale),
        leading: GlassIconButton(
          icon: Icons.arrow_back,
          tooltip: 'Back',
          onPressed: () => context.pop(),
        ),
        body: const Center(child: GlassLoadingCard(height: 120, width: 240)),
      );
    }

    final s = _model!.settings;
    final grouped = <NotificationCategoryGroup, List<NotificationTypeMeta>>{};
    for (final meta in NotificationTypeRegistry.all) {
      if (_scamSecurityPushTypes.contains(meta.type)) continue;
      grouped.putIfAbsent(meta.group, () => []).add(meta);
    }

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: GlassScreenScaffold(
        title: NotificationPrefsStrings.t('prefs_title', locale),
        leading: GlassIconButton(
          icon: Icons.arrow_back,
          tooltip: 'Back',
          onPressed: () => context.pop(),
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              NotificationPrefsStrings.t('prefs_subtitle', locale),
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
            if (_notificationsBlocked) ...[
              const SizedBox(height: AppSpacing.md),
              GlassContainer(
                child: ListTile(
                  title: Text(
                    NotificationPrefsStrings.t('prefs_os_blocked_title', locale),
                    style: AppTypography.subtitle,
                  ),
                  subtitle: Text(
                    NotificationPrefsStrings.t('prefs_os_blocked_body', locale),
                    style: AppTypography.bodySmall,
                  ),
                  trailing: TextButton(
                    onPressed: openAppSettings,
                    child: Text(
                      NotificationPrefsStrings.t('prefs_open_settings', locale),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            _ScamSecurityAlertsSection(
              locale: locale,
              settings: s,
              onSave: _save,
              onTurnAllOff: _turnAllScamSecurityOff,
            ),
            const SizedBox(height: AppSpacing.lg),
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      NotificationPrefsStrings.t('quiet_hours', locale),
                      style: AppTypography.subtitle.copyWith(
                        color: AppColors.cyanGlow,
                      ),
                    ),
                  ),
                  GlassSettingsTile(
                    title: NotificationPrefsStrings.t('quiet_hours', locale),
                    subtitle: NotificationPrefsStrings.t('quiet_hours_hint', locale),
                    trailing: Switch.adaptive(
                      value: s.quietHoursEnabled,
                      onChanged: (v) =>
                          _save(s.copyWith(quietHoursEnabled: v)),
                      activeThumbColor: AppColors.sharePurple,
                    ),
                  ),
                  if (s.quietHoursEnabled) ...[
                    GlassSettingsTile(
                      title: NotificationPrefsStrings.t('start_time', locale),
                      trailing: Text(
                        _formatHour(s.quietHoursStart),
                        style: AppTypography.body.copyWith(
                          color: AppColors.accentGold,
                        ),
                      ),
                      onTap: () => _pickHour(
                        current: s.quietHoursStart,
                        onPicked: (h) => _save(s.copyWith(quietHoursStart: h)),
                      ),
                    ),
                    GlassSettingsTile(
                      title: NotificationPrefsStrings.t('end_time', locale),
                      trailing: Text(
                        _formatHour(s.quietHoursEnd),
                        style: AppTypography.body.copyWith(
                          color: AppColors.accentGold,
                        ),
                      ),
                      onTap: () => _pickHour(
                        current: s.quietHoursEnd,
                        onPicked: (h) => _save(s.copyWith(quietHoursEnd: h)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            for (final entry in grouped.entries) ...[
              NotificationCategoryGroupHeader(
                group: entry.key,
                locale: locale,
              ),
              GlassContainer(
                child: Column(
                  children: [
                    for (final meta in entry.value)
                      NotificationCategoryTile(
                        meta: meta,
                        locale: locale,
                        enabled: _model!.isEnabled(meta.type),
                        canToggle: meta.userCanDisable,
                        subtitle: NotificationPrefsStrings.t(
                          '${meta.l10nKey}_hint',
                          locale,
                        ),
                        onChanged: (v) => _save(
                          _model!.toggleType(meta.type, v).settings,
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}

class _ScamSecurityAlertsSection extends StatelessWidget {
  const _ScamSecurityAlertsSection({
    required this.locale,
    required this.settings,
    required this.onSave,
    required this.onTurnAllOff,
  });

  final String locale;
  final NotificationSettings settings;
  final ValueChanged<NotificationSettings> onSave;
  final VoidCallback onTurnAllOff;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Text(
            NotificationPrefsStrings.t('group_scam_security_alerts', locale)
                .toUpperCase(),
            style: AppTypography.caption.copyWith(
              color: AppColors.accentGold,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        GlassContainer(
          child: Column(
            children: [
              GlassSettingsTile(
                title: NotificationPrefsStrings.t(
                  'notif_scam_advisory_alert',
                  locale,
                ),
                subtitle: NotificationPrefsStrings.t(
                  'notif_scam_advisory_alert_hint',
                  locale,
                ),
                trailing: Switch.adaptive(
                  value: settings.scamAdvisoryAlert,
                  onChanged: (v) =>
                      onSave(settings.copyWith(scamAdvisoryAlert: v)),
                  activeThumbColor: AppColors.sharePurple,
                ),
              ),
              GlassSettingsTile(
                title: NotificationPrefsStrings.t('notif_security_tip', locale),
                subtitle: NotificationPrefsStrings.t(
                  'notif_security_tip_hint',
                  locale,
                ),
                trailing: Switch.adaptive(
                  value: settings.securityTip,
                  onChanged: (v) => onSave(settings.copyWith(securityTip: v)),
                  activeThumbColor: AppColors.sharePurple,
                ),
              ),
              if (!SecurityAlertConfig.kSecurityTipDefaultEnabled)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text(
                    NotificationPrefsStrings.t(
                      'notif_security_tip_flag_review',
                      locale,
                    ),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              GlassSettingsTile(
                title: NotificationPrefsStrings.t(
                  'notif_security_today_cards',
                  locale,
                ),
                subtitle: NotificationPrefsStrings.t(
                  'notif_security_today_cards_hint',
                  locale,
                ),
                trailing: Switch.adaptive(
                  value: settings.securityTodayCards,
                  onChanged: (v) =>
                      onSave(settings.copyWith(securityTodayCards: v)),
                  activeThumbColor: AppColors.sharePurple,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onTurnAllOff,
                  child: Text(
                    NotificationPrefsStrings.t(
                      'scam_security_turn_all_off',
                      locale,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
