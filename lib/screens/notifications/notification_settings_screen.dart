import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/design/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_text_styles.dart';
import 'package:raabta/models/notification_models.dart';
import 'package:raabta/providers/notification_providers.dart';

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

  static const _languages = [
    'English',
    'Urdu',
    'Hindi',
    'Arabic',
    'Filipino',
    'Bengali',
  ];

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

  String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour % 12 == 0 ? 12 : hour % 12;
    return '$h:00 $period';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _settings == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
          title: Text('Notification Settings', style: AppTextStyles.h2),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final s = _settings!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Notification Settings', style: AppTextStyles.h2),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Notification language', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Separate from app language — alerts will arrive in this language',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: s.notificationLanguage,
                isExpanded: true,
                dropdownColor: AppColors.surface,
                items: _languages
                    .map(
                      (lang) => DropdownMenuItem(
                        value: lang,
                        child: Text(lang, style: AppTextStyles.bodyMedium),
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
          Text('Notification types', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.md),
          _ToggleTile(
            title: '📋 Iqama expiry warnings',
            subtitle: '90, 60, 30, 14, 7, 3, 1 days before expiry',
            value: s.iqamaExpiry,
            onChanged: (v) => _save(s.copyWith(iqamaExpiry: v)),
          ),
          _ToggleTile(
            title: '🏠 Housing matches',
            subtitle: 'New listings matching your saved search',
            value: s.housingMatch,
            onChanged: (v) => _save(s.copyWith(housingMatch: v)),
          ),
          _ToggleTile(
            title: '💰 Exchange rate alerts',
            subtitle: 'When your target rate is reached',
            value: s.rateAlert,
            onChanged: (v) => _save(s.copyWith(rateAlert: v)),
          ),
          _ToggleTile(
            title: '💬 Community replies',
            subtitle: 'When someone answers your question',
            value: s.communityReply,
            onChanged: (v) => _save(s.copyWith(communityReply: v)),
          ),
          _ToggleTile(
            title: '💼 Job matches',
            subtitle: 'New jobs matching your profile',
            value: s.jobMatch,
            onChanged: (v) => _save(s.copyWith(jobMatch: v)),
          ),
          _ToggleTile(
            title: '📰 Weekly digest',
            subtitle: 'Top housing + jobs in your area every Sunday',
            value: s.weeklyDigest,
            onChanged: (v) => _save(s.copyWith(weeklyDigest: v)),
          ),
          _ToggleTile(
            title: '📢 Admin announcements',
            subtitle: 'Qatar law changes, holidays, important updates',
            value: s.adminAnnouncement,
            onChanged: (v) => _save(s.copyWith(adminAnnouncement: v)),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Quiet hours', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No push notifications during these hours (Qatar time)',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          _ToggleTile(
            title: '🌙 Enable quiet hours',
            subtitle:
                '${_formatHour(s.quietHoursStart)} – ${_formatHour(s.quietHoursEnd)}',
            value: s.quietHoursEnabled,
            onChanged: (v) => _save(s.copyWith(quietHoursEnabled: v)),
          ),
          if (s.quietHoursEnabled) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _HourPicker(
                    label: 'Start',
                    hour: s.quietHoursStart,
                    onChanged: (h) => _save(s.copyWith(quietHoursStart: h)),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _HourPicker(
                    label: 'End',
                    hour: s.quietHoursEnd,
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
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: SwitchListTile(
        title: Text(title, style: AppTextStyles.bodyMedium),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
        value: value,
        activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
        activeThumbColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }
}

class _HourPicker extends StatelessWidget {
  const _HourPicker({
    required this.label,
    required this.hour,
    required this.onChanged,
  });

  final String label;
  final int hour;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          DropdownButton<int>(
            value: hour,
            isExpanded: true,
            dropdownColor: AppColors.surface,
            items: List.generate(
              24,
              (h) => DropdownMenuItem(
                value: h,
                child: Text(
                  h == 0
                      ? '12 AM'
                      : h < 12
                          ? '$h AM'
                          : h == 12
                              ? '12 PM'
                              : '${h - 12} PM',
                  style: AppTextStyles.bodyMedium,
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
