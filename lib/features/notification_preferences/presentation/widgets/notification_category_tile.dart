import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_settings_tile.dart';
import 'package:raabta/features/notification_preferences/l10n/notification_prefs_strings.dart';
import 'package:raabta/services/notifications/notification_type.dart';

class NotificationCategoryTile extends StatelessWidget {
  const NotificationCategoryTile({
    super.key,
    required this.meta,
    required this.enabled,
    required this.onChanged,
    this.locale = 'English',
    this.canToggle = true,
    this.subtitle,
  });

  final NotificationTypeMeta meta;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final String locale;
  final bool canToggle;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final hint = subtitle;
    final showHint = hint != null && hint.isNotEmpty && hint != '${meta.l10nKey}_hint';
    return GlassSettingsTile(
      title: NotificationPrefsStrings.t(meta.l10nKey, locale),
      subtitle: showHint ? hint : null,
      trailing: Switch.adaptive(
        value: enabled,
        onChanged: canToggle ? onChanged : null,
        activeThumbColor: AppColors.sharePurple,
        activeTrackColor: AppColors.sharePurple.withValues(alpha: 0.4),
      ),
    );
  }
}

class NotificationCategoryGroupHeader extends StatelessWidget {
  const NotificationCategoryGroupHeader({
    super.key,
    required this.group,
    this.locale = 'English',
  });

  final NotificationCategoryGroup group;
  final String locale;

  String get _label {
    switch (group) {
      case NotificationCategoryGroup.billsAndWarranty:
        return NotificationPrefsStrings.t('group_bills', locale);
      case NotificationCategoryGroup.eosb:
        return NotificationPrefsStrings.t('group_eosb', locale);
      case NotificationCategoryGroup.scamShield:
        return NotificationPrefsStrings.t('group_scam_shield', locale);
      case NotificationCategoryGroup.community:
        return NotificationPrefsStrings.t('group_community', locale);
      case NotificationCategoryGroup.jobsAndHousing:
        return NotificationPrefsStrings.t('group_jobs', locale);
      case NotificationCategoryGroup.groups:
        return NotificationPrefsStrings.t('group_groups', locale);
      case NotificationCategoryGroup.admin:
        return NotificationPrefsStrings.t('group_admin', locale);
      case NotificationCategoryGroup.system:
        return 'System';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text(
        _label.toUpperCase(),
        style: AppTypography.caption.copyWith(
          color: AppColors.accentGold,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
