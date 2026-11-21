import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/glass_settings_tile.dart';
import 'package:raabta/features/home/widgets/glass_loading_card.dart';
import 'package:raabta/models/notification_models.dart';
import 'package:raabta/providers/notification_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/notifications/l10n/notification_settings_strings.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  NotificationSettings? _settings;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = await ref.read(notificationRepositoryProvider.future);
    final settings = await repo.getSettings();
    if (mounted) {
      setState(() {
        _settings = settings;
        _loading = false;
      });
    }
  }

  Future<void> _save(NotificationSettings settings) async {
    setState(() => _settings = settings);
    final repo = await ref.read(notificationRepositoryProvider.future);
    await repo.saveSettings(settings);
    ref.invalidate(notificationSettingsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));

    if (_loading || _settings == null) {
      return GlassScreenScaffold(
        title: NotificationSettingsStrings.t('settings_title', locale),
        leading: GlassIconButton(
          icon: Icons.arrow_back,
          tooltip: CommonActionStrings.t('action_back', locale),
          onPressed: () => context.pop(),
        ),
        body: const Center(
          child: GlassLoadingCard(height: 120, width: 240),
        ),
      );
    }

    final s = _settings!;

    return GlassScreenScaffold(
      title: NotificationSettingsStrings.t('settings_title', locale),
      leading: GlassIconButton(
        icon: Icons.arrow_back,
        tooltip: CommonActionStrings.t('action_back', locale),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          Text(
            NotificationSettingsStrings.t('notification_language', locale),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            NotificationSettingsStrings.t('notification_language_hint', locale),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            borderRadius: AppSpacing.radiusLg,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: s.notificationLanguage,
                isExpanded: true,
                dropdownColor: AppColors.surface,
                style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                items: NotificationSettingsStrings.notificationLanguageKeys
                    .map(
                      (lang) => DropdownMenuItem(
                        value: lang,
                        child: Text(
                          NotificationSettingsStrings.languageLabel(lang, locale),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    _save(s.copyWith(notificationLanguage: value));
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            NotificationSettingsStrings.t('notification_types', locale),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.md),
          _ToggleTile(
            title: NotificationSettingsStrings.t('type_iqama_title', locale),
            subtitle: NotificationSettingsStrings.t('type_iqama_subtitle', locale),
            value: s.iqamaExpiry,
            onChanged: (v) => _save(s.copyWith(iqamaExpiry: v)),
          ),
          _ToggleTile(
            title: NotificationSettingsStrings.t('type_housing_title', locale),
            subtitle:
                NotificationSettingsStrings.t('type_housing_subtitle', locale),
            value: s.housingMatch,
            onChanged: (v) => _save(s.copyWith(housingMatch: v)),
          ),
          _ToggleTile(
            title: NotificationSettingsStrings.t('type_rate_title', locale),
            subtitle: NotificationSettingsStrings.t('type_rate_subtitle', locale),
            value: s.rateAlert,
            onChanged: (v) => _save(s.copyWith(rateAlert: v)),
          ),
          _ToggleTile(
            title:
                NotificationSettingsStrings.t('type_community_reply_title', locale),
            subtitle: NotificationSettingsStrings.t(
              'type_community_reply_subtitle',
              locale,
            ),
            value: s.communityReply,
            onChanged: (v) => _save(s.copyWith(communityReply: v)),
          ),
          _ToggleTile(
            title: NotificationSettingsStrings.t('type_job_title', locale),
            subtitle: NotificationSettingsStrings.t('type_job_subtitle', locale),
            value: s.jobMatch,
            onChanged: (v) => _save(s.copyWith(jobMatch: v)),
          ),
          _ToggleTile(
            title:
                NotificationSettingsStrings.t('type_weekly_digest_title', locale),
            subtitle: NotificationSettingsStrings.t(
              'type_weekly_digest_subtitle',
              locale,
            ),
            value: s.weeklyDigest,
            onChanged: (v) => _save(s.copyWith(weeklyDigest: v)),
          ),
          _ToggleTile(
            title: NotificationSettingsStrings.t('type_admin_title', locale),
            subtitle: NotificationSettingsStrings.t('type_admin_subtitle', locale),
            value: s.adminAnnouncement,
            onChanged: (v) => _save(s.copyWith(adminAnnouncement: v)),
          ),
          _ToggleTile(
            title: NotificationSettingsStrings.t('type_bill_title', locale),
            subtitle: NotificationSettingsStrings.t('type_bill_subtitle', locale),
            value: s.billDue,
            onChanged: (v) => _save(s.copyWith(billDue: v)),
          ),
          _ToggleTile(
            title: NotificationSettingsStrings.t('type_warranty_title', locale),
            subtitle:
                NotificationSettingsStrings.t('type_warranty_subtitle', locale),
            value: s.warrantyExpiring,
            onChanged: (v) => _save(s.copyWith(warrantyExpiring: v)),
          ),
          _ToggleTile(
            title: NotificationSettingsStrings.t('type_events_title', locale),
            subtitle: NotificationSettingsStrings.t('type_events_subtitle', locale),
            value: s.communityEvents,
            onChanged: (v) => _save(s.copyWith(communityEvents: v)),
          ),
          _ToggleTile(
            title:
                NotificationSettingsStrings.t('type_lost_found_title', locale),
            subtitle: NotificationSettingsStrings.t(
              'type_lost_found_subtitle',
              locale,
            ),
            value: s.communityLostFound,
            onChanged: (v) => _save(s.copyWith(communityLostFound: v)),
          ),
          _ToggleTile(
            title:
                NotificationSettingsStrings.t('type_breaking_news_title', locale),
            subtitle: NotificationSettingsStrings.t(
              'type_breaking_news_subtitle',
              locale,
            ),
            value: s.breakingNews,
            onChanged: (v) => _save(s.copyWith(breakingNews: v)),
          ),
          _ToggleTile(
            title:
                NotificationSettingsStrings.t('type_group_activity_title', locale),
            subtitle: NotificationSettingsStrings.t(
              'type_group_activity_subtitle',
              locale,
            ),
            value: s.groupActivity,
            onChanged: (v) => _save(s.copyWith(groupActivity: v)),
          ),
          _ToggleTile(
            title: NotificationSettingsStrings.t('type_emergency_title', locale),
            subtitle:
                NotificationSettingsStrings.t('type_emergency_subtitle', locale),
            value: s.emergency,
            onChanged: (v) => _save(s.copyWith(emergency: v)),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            NotificationSettingsStrings.t('quiet_hours', locale),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            NotificationSettingsStrings.t('quiet_hours_hint', locale),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          _ToggleTile(
            title: NotificationSettingsStrings.t('quiet_hours_enable', locale),
            subtitle:
                '${NotificationSettingsStrings.formatHour(s.quietHoursStart, locale)} – ${NotificationSettingsStrings.formatHour(s.quietHoursEnd, locale)}',
            value: s.quietHoursEnabled,
            onChanged: (v) => _save(s.copyWith(quietHoursEnabled: v)),
          ),
          if (s.quietHoursEnabled) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _HourPicker(
                    label: NotificationSettingsStrings.t('start_time', locale),
                    hour: s.quietHoursStart,
                    locale: locale,
                    onChanged: (h) => _save(s.copyWith(quietHoursStart: h)),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _HourPicker(
                    label: NotificationSettingsStrings.t('end_time', locale),
                    hour: s.quietHoursEnd,
                    locale: locale,
                    onChanged: (h) => _save(s.copyWith(quietHoursEnd: h)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassSwitchTile(
        title: title,
        subtitle: subtitle,
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _HourPicker extends StatelessWidget {
  const _HourPicker({
    required this.label,
    required this.hour,
    required this.locale,
    required this.onChanged,
  });

  final String label;
  final int hour;
  final String locale;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: AppSpacing.radiusLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.bodySmall),
          DropdownButton<int>(
            value: hour,
            isExpanded: true,
            dropdownColor: AppColors.surface,
            style: AppTypography.body.copyWith(color: AppColors.textPrimary),
            items: List.generate(
              24,
              (h) => DropdownMenuItem(
                value: h,
                child: Text(
                  NotificationSettingsStrings.formatHourOption(h, locale),
                ),
              ),
            ),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}
