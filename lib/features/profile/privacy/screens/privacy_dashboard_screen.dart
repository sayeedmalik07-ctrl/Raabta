import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/classifieds_chat_safety_strings.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_settings_tile.dart';
import 'package:raabta/features/profile/privacy/l10n/privacy_strings.dart';
import 'package:raabta/features/profile/privacy/models/privacy_settings.dart';
import 'package:raabta/features/profile/privacy/providers/privacy_providers.dart';
import 'package:raabta/features/profile/privacy/services/vault_lock_service.dart';
import 'package:raabta/models/intelligence/permission_level.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/profile/profile_tab_scaffold.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/services/auth/auth_session_service.dart';
import 'package:raabta/services/intelligence/sensitive_action_audit_service.dart';
import 'package:share_plus/share_plus.dart';

/// Profile → Quick Settings → Privacy — three sections only.
class PrivacyDashboardScreen extends ConsumerStatefulWidget {
  const PrivacyDashboardScreen({super.key});

  @override
  ConsumerState<PrivacyDashboardScreen> createState() =>
      _PrivacyDashboardScreenState();
}

class _PrivacyDashboardScreenState extends ConsumerState<PrivacyDashboardScreen> {
  bool _busy = false;

  String _locale() => AppLocale.normalize(ref.read(userLanguageProvider));

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final user = ref.watch(currentUserProvider);
    final settingsAsync = ref.watch(privacySettingsProvider);
    final summaryAsync = ref.watch(userDataSummaryProvider);
    final permissionsAsync = ref.watch(permissionStatusProvider);
    final vaultLockAsync = ref.watch(vaultLockServiceProvider);

    return ProfileTabScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            PrivacyStrings.t('privacy_title', locale),
            style: AppTypography.headline2,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.xxxl,
          ),
          children: [
            _SectionHeader(
              title: PrivacyStrings.t('section_account_security', locale),
            ),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    GlassSettingsTile(
                      title: PrivacyStrings.t('phone_verification', locale),
                      subtitle: _phoneStatus(user, locale),
                      leading: Icon(
                        user?.phoneNumber != null
                            ? Icons.verified_outlined
                            : Icons.phone_iphone_outlined,
                        color: AppColors.cyanGlow,
                      ),
                    ),
                    const Divider(height: 1, indent: 52),
                    vaultLockAsync.when(
                      loading: () => ListTile(
                        title: Text(
                          PrivacyStrings.t('vault_pin_lock_loading', locale),
                        ),
                        subtitle: Text(PrivacyStrings.t('loading', locale)),
                      ),
                      error: (_, _) => const SizedBox.shrink(),
                      data: (lock) => SwitchListTile(
                        secondary: const Icon(Icons.lock_outline),
                        title: Text(
                          PrivacyStrings.t('vault_pin_lock', locale),
                        ),
                        subtitle: Text(
                          PrivacyStrings.t('vault_pin_lock_subtitle', locale),
                        ),
                        value: lock.isEnabled,
                        onChanged: _busy
                            ? null
                            : (value) => _toggleVaultLock(lock, value),
                      ),
                    ),
                    const Divider(height: 1, indent: 52),
                    permissionsAsync.when(
                      loading: () => ListTile(
                        title: Text(
                          PrivacyStrings.t('app_permissions', locale),
                        ),
                        subtitle: Text(PrivacyStrings.t('checking', locale)),
                      ),
                      error: (_, _) => GlassSettingsTile(
                        title: PrivacyStrings.t('app_permissions', locale),
                        subtitle: PrivacyStrings.t(
                          'perm_status_read_error',
                          locale,
                        ),
                        leading: const Icon(Icons.security_outlined),
                        onTap: openPhonePermissionSettings,
                      ),
                      data: (statuses) => Column(
                        children: [
                          for (final entry in statuses.entries) ...[
                            GlassSettingsTile(
                              title: _permissionName(entry.key, locale),
                              subtitle: _permissionStatusLabel(
                                entry.value,
                                locale,
                              ),
                              leading: Icon(_permissionIcon(entry.key)),
                            ),
                            if (entry.key != statuses.keys.last)
                              const Divider(height: 1, indent: 52),
                          ],
                          const Divider(height: 1, indent: 52),
                          GlassSettingsTile(
                            title: PrivacyStrings.t(
                              'manage_phone_settings',
                              locale,
                            ),
                            subtitle: PrivacyStrings.t(
                              'manage_phone_settings_sub',
                              locale,
                            ),
                            leading: const Icon(Icons.settings_outlined),
                            onTap: openPhonePermissionSettings,
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, indent: 52),
                    GlassSettingsTile(
                      title: ClassifiedsChatSafetyStrings.t(
                        'blocked_users_title',
                        locale,
                      ),
                      leading: const Icon(Icons.block_outlined),
                      onTap: () => context.push('/profile/blocked-users'),
                    ),
                    const Divider(height: 1, indent: 52),
                    GlassSettingsTile(
                      title: PrivacyStrings.t('sign_out', locale),
                      titleColor: AppColors.error,
                      leading: const Icon(Icons.logout, color: AppColors.error),
                      onTap: _signOut,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _SectionHeader(
              title: PrivacyStrings.t('section_privacy', locale),
            ),
            settingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Text(
                PrivacyStrings.t('privacy_settings_load_error', locale),
                style: AppTypography.body,
              ),
              data: (settings) => GlassCard(
                padding: EdgeInsets.zero,
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      summaryAsync.when(
                        loading: () => ListTile(
                          title: Text(
                            PrivacyStrings.t('ai_history', locale),
                          ),
                          subtitle: Text(PrivacyStrings.t('loading', locale)),
                        ),
                        error: (_, _) => ListTile(
                          title: Text(
                            PrivacyStrings.t('ai_history', locale),
                          ),
                          subtitle: Text(
                            PrivacyStrings.t('ai_history_count_error', locale),
                          ),
                        ),
                        data: (summary) => ListTile(
                          title: Text(
                            PrivacyStrings.t('ai_history', locale),
                          ),
                          subtitle: Text(
                            summary.aiConversationCount == 0
                                ? PrivacyStrings.t('ai_history_none', locale)
                                : PrivacyStrings.format(
                                    'ai_history_summary',
                                    locale,
                                    params: {
                                      'count':
                                          '${summary.aiConversationCount}',
                                      'msgCount':
                                          '${summary.aiMessageCount}',
                                    },
                                  ),
                          ),
                          trailing: summary.aiConversationCount > 0
                              ? TextButton(
                                  onPressed:
                                      _busy ? null : _deleteAiHistory,
                                  child: Text(
                                    PrivacyStrings.t('action_delete', locale),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const Divider(height: 1, indent: 52),
                      SwitchListTile(
                        secondary: const Icon(Icons.auto_awesome_outlined),
                        title: Text(
                          PrivacyStrings.t('ai_personalization', locale),
                        ),
                        subtitle: Text(
                          PrivacyStrings.t('ai_personalization_sub', locale),
                        ),
                        value: settings.aiPersonalizationEnabled,
                        onChanged: _busy
                            ? null
                            : (v) => _updateSettings(
                                  settings.copyWith(
                                    aiPersonalizationEnabled: v,
                                  ),
                                ),
                      ),
                      const Divider(height: 1, indent: 52),
                      SwitchListTile(
                        secondary: const Icon(Icons.visibility_outlined),
                        title: Text(
                          PrivacyStrings.t('public_profile_visibility', locale),
                        ),
                        subtitle: Text(
                          PrivacyStrings.t(
                            'public_profile_visibility_sub',
                            locale,
                          ),
                        ),
                        value: settings.profileVisibilityPublic,
                        onChanged: _busy
                            ? null
                            : (v) => _updateSettings(
                                  settings.copyWith(
                                    profileVisibilityPublic: v,
                                  ),
                                ),
                      ),
                      SwitchListTile(
                        secondary: const Icon(Icons.mail_outline),
                        title: Text(
                          PrivacyStrings.t('allow_contact', locale),
                        ),
                        subtitle: Text(
                          PrivacyStrings.t('allow_contact_sub', locale),
                        ),
                        value: settings.allowContactFromOthers,
                        onChanged: _busy
                            ? null
                            : (v) => _updateSettings(
                                  settings.copyWith(
                                    allowContactFromOthers: v,
                                  ),
                                ),
                      ),
                      const Divider(height: 1, indent: 52),
                      GlassSettingsTile(
                        title: PrivacyStrings.t('sensitive_ai_notice', locale),
                        subtitle: settings.sensitiveAiDisclaimerAcknowledged
                            ? PrivacyStrings.t(
                                'sensitive_ai_acknowledged',
                                locale,
                              )
                            : PrivacyStrings.t(
                                'sensitive_ai_read_before',
                                locale,
                              ),
                        leading: const Icon(Icons.info_outline),
                        onTap: () => _showSensitiveAiNotice(settings),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _SectionHeader(
              title: PrivacyStrings.t('section_your_data', locale),
            ),
            summaryAsync.when(
              loading: () => GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    PrivacyStrings.t('data_summary_loading', locale),
                  ),
                ),
              ),
              error: (_, _) => GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    PrivacyStrings.t('data_summary_error', locale),
                    style: AppTypography.body,
                  ),
                ),
              ),
              data: (summary) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          PrivacyStrings.t('what_raabta_stores', locale),
                          style: AppTypography.subtitle,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _DataRow(
                          label: PrivacyStrings.t('data_profile', locale),
                          value: summary.profileStored
                              ? PrivacyStrings.t('data_stored', locale)
                              : PrivacyStrings.t('data_not_stored', locale),
                        ),
                        _DataRow(
                          label: PrivacyStrings.t('data_documents', locale),
                          value: summary.documentCount == 0
                              ? PrivacyStrings.t('data_none', locale)
                              : PrivacyStrings.format(
                                  'data_documents_count',
                                  locale,
                                  params: {
                                    'count': '${summary.documentCount}',
                                  },
                                ),
                        ),
                        _DataRow(
                          label: PrivacyStrings.t(
                            'data_ai_conversations',
                            locale,
                          ),
                          value: summary.aiConversationCount == 0
                              ? PrivacyStrings.t('data_none', locale)
                              : PrivacyStrings.format(
                                  'data_ai_threads',
                                  locale,
                                  params: {
                                    'count': '${summary.aiConversationCount}',
                                  },
                                ),
                        ),
                        _DataRow(
                          label: PrivacyStrings.t('data_eosb_device', locale),
                          value: summary.eosbHistoryCount +
                                      summary.overtimeHistoryCount ==
                                  0
                              ? PrivacyStrings.t('data_none', locale)
                              : PrivacyStrings.format(
                                  'data_eosb_summary',
                                  locale,
                                  params: {
                                    'eosbCount':
                                        '${summary.eosbHistoryCount}',
                                    'overtimeCount':
                                        '${summary.overtimeHistoryCount}',
                                  },
                                ),
                        ),
                        _DataRow(
                          label: PrivacyStrings.t(
                            'data_advanced_profile',
                            locale,
                          ),
                          value: summary.advancedProfileFieldCount == 0
                              ? PrivacyStrings.t('data_none', locale)
                              : PrivacyStrings.format(
                                  'data_advanced_fields_count',
                                  locale,
                                  params: {
                                    'count':
                                        '${summary.advancedProfileFieldCount}',
                                  },
                                ),
                        ),
                        if (!summary.hasAnyData) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            PrivacyStrings.t('data_no_personal', locale),
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        GlassSettingsTile(
                          title: PrivacyStrings.t('view_my_data', locale),
                          subtitle: PrivacyStrings.t(
                            'view_my_data_sub',
                            locale,
                          ),
                          leading: const Icon(Icons.open_in_new_outlined),
                          onTap: _showViewDataSheet,
                        ),
                        const Divider(height: 1, indent: 52),
                        GlassSettingsTile(
                          title: PrivacyStrings.t('download_my_data', locale),
                          subtitle: PrivacyStrings.t(
                            'download_my_data_sub',
                            locale,
                          ),
                          leading: const Icon(Icons.download_outlined),
                          onTap: _busy ? null : _exportData,
                        ),
                        const Divider(height: 1, indent: 52),
                        GlassSettingsTile(
                          title: PrivacyStrings.t(
                            'delete_selected_data',
                            locale,
                          ),
                          subtitle: PrivacyStrings.t(
                            'delete_selected_data_sub',
                            locale,
                          ),
                          leading: const Icon(Icons.delete_outline),
                          onTap: _busy ? null : _showDeleteDataSheet,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  GlassPrimaryButton(
                    label: PrivacyStrings.t('delete_my_account', locale),
                    expand: true,
                    accentColor: AppColors.error,
                    onPressed: _busy ? null : _confirmDeleteAccount,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    PrivacyStrings.t('delete_account_warning', locale),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _phoneStatus(User? user, String locale) {
    final phone = user?.phoneNumber;
    if (phone == null || phone.isEmpty) {
      return PrivacyStrings.t('phone_not_verified', locale);
    }
    return PrivacyStrings.format(
      'phone_verified',
      locale,
      params: {'phone': phone},
    );
  }

  String _permissionName(Permission permission, String locale) {
    return switch (permission) {
      Permission.camera => PrivacyStrings.t('perm_camera', locale),
      Permission.location => PrivacyStrings.t('perm_location', locale),
      Permission.notification =>
        PrivacyStrings.t('perm_notifications', locale),
      _ => permission.toString(),
    };
  }

  String _permissionStatusLabel(PermissionStatus status, String locale) {
    return switch (status) {
      PermissionStatus.granted =>
        PrivacyStrings.t('perm_allowed', locale),
      PermissionStatus.denied => PrivacyStrings.t('perm_denied', locale),
      PermissionStatus.restricted =>
        PrivacyStrings.t('perm_restricted', locale),
      PermissionStatus.limited => PrivacyStrings.t('perm_limited', locale),
      PermissionStatus.permanentlyDenied =>
        PrivacyStrings.t('perm_blocked', locale),
      PermissionStatus.provisional =>
        PrivacyStrings.t('perm_provisional', locale),
    };
  }

  IconData _permissionIcon(Permission permission) {
    return switch (permission) {
      Permission.camera => Icons.photo_camera_outlined,
      Permission.location => Icons.location_on_outlined,
      Permission.notification => Icons.notifications_outlined,
      _ => Icons.shield_outlined,
    };
  }

  Future<void> _toggleVaultLock(VaultLockService lock, bool enable) async {
    final locale = _locale();
    if (enable) {
      final pin = await _promptPinSetup();
      if (pin == null) return;
      setState(() => _busy = true);
      try {
        await lock.enableWithPin(pin);
        ref.invalidate(vaultLockServiceProvider);
        _snack(PrivacyStrings.t('snack_vault_enabled', locale));
      } catch (e) {
        _snack(e.toString());
      } finally {
        if (mounted) setState(() => _busy = false);
      }
    } else {
      final pin = await _promptPinVerify();
      if (pin == null) return;
      setState(() => _busy = true);
      try {
        await lock.disable(pin: pin);
        ref.invalidate(vaultLockServiceProvider);
        _snack(PrivacyStrings.t('snack_vault_disabled', locale));
      } catch (e) {
        _snack(PrivacyStrings.t('snack_vault_disable_error', locale));
      } finally {
        if (mounted) setState(() => _busy = false);
      }
    }
  }

  Future<String?> _promptPinSetup() async {
    final locale = _locale();
    final controller = TextEditingController();
    final confirm = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(PrivacyStrings.t('pin_setup_title', locale)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: InputDecoration(
                labelText: PrivacyStrings.t('pin_digit_label', locale),
              ),
            ),
            TextField(
              controller: confirm,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: InputDecoration(
                labelText: PrivacyStrings.t('pin_confirm_label', locale),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(CommonActionStrings.t('action_cancel', locale)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().length < 4 ||
                  controller.text != confirm.text) {
                return;
              }
              Navigator.pop(ctx, controller.text.trim());
            },
            child: Text(CommonActionStrings.t('action_save', locale)),
          ),
        ],
      ),
    );
  }

  Future<String?> _promptPinVerify() async {
    final locale = _locale();
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(PrivacyStrings.t('pin_enter_title', locale)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          obscureText: true,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(CommonActionStrings.t('action_cancel', locale)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(PrivacyStrings.t('action_confirm', locale)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateSettings(PrivacySettings settings) async {
    final uid = ref.read(privacyUserIdProvider);
    if (uid == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(privacySettingsServiceProvider).save(uid, settings);
      ref.invalidate(privacySettingsProvider);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteAiHistory() async {
    final locale = _locale();
    final uid = ref.read(privacyUserIdProvider);
    if (uid == null) return;
    final ok = await _confirm(
      PrivacyStrings.t('confirm_delete_ai', locale),
    );
    if (!ok) return;
    setState(() => _busy = true);
    try {
      await ref.read(userDataServiceProvider).deleteAiHistory(uid);
      ref.invalidate(userDataSummaryProvider);
      _snack(PrivacyStrings.t('snack_ai_deleted', locale));
    } catch (e) {
      _snack(PrivacyStrings.t('snack_delete_failed', locale));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportData() async {
    final locale = _locale();
    final uid = ref.read(privacyUserIdProvider);
    if (uid == null) return;
    setState(() => _busy = true);
    try {
      final payload =
          await ref.read(userDataServiceProvider).exportUserData(uid);
      final json = const JsonEncoder.withIndent('  ').convert(payload);
      await Share.share(
        json,
        subject: PrivacyStrings.t('export_subject', locale),
      );
    } catch (e) {
      _snack(PrivacyStrings.t('snack_export_failed', locale));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showViewDataSheet() {
    final locale = _locale();
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(PrivacyStrings.t('sheet_profile', locale)),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/profile/personal-info');
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: Text(PrivacyStrings.t('sheet_document_vault', locale)),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/document-vault');
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome_outlined),
              title: Text(PrivacyStrings.t('sheet_ai_assistant', locale)),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/ai-chat');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDataSheet() {
    final locale = _locale();
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.auto_awesome_outlined),
              title: Text(PrivacyStrings.t('sheet_delete_ai', locale)),
              onTap: () {
                Navigator.pop(ctx);
                _deleteAiHistory();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(PrivacyStrings.t('sheet_delete_documents', locale)),
              onTap: () {
                Navigator.pop(ctx);
                _deleteDocuments();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate_outlined),
              title: Text(PrivacyStrings.t('sheet_delete_eosb', locale)),
              onTap: () {
                Navigator.pop(ctx);
                _deleteEosbLocal();
              },
            ),
            ListTile(
              leading: const Icon(Icons.work_outline),
              title: Text(
                PrivacyStrings.t('sheet_delete_advanced_profile', locale),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _deleteAdvancedProfile();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteDocuments() async {
    final locale = _locale();
    final uid = ref.read(privacyUserIdProvider);
    if (uid == null) return;
    if (!await _confirm(
      PrivacyStrings.t('confirm_delete_documents', locale),
    )) {
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(userDataServiceProvider).deleteAllDocuments(uid);
      ref.invalidate(userDataSummaryProvider);
      _snack(PrivacyStrings.t('snack_documents_deleted', locale));
    } catch (_) {
      _snack(PrivacyStrings.t('snack_delete_failed', locale));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteEosbLocal() async {
    final locale = _locale();
    if (!await _confirm(
      PrivacyStrings.t('confirm_delete_eosb', locale),
    )) {
      return;
    }
    setState(() => _busy = true);
    try {
      final uid = ref.read(privacyUserIdProvider);
      if (uid == null) return;
      await ref.read(userDataServiceProvider).deleteEosbLocalData(uid);
      ref.invalidate(userDataSummaryProvider);
      _snack(PrivacyStrings.t('snack_eosb_deleted', locale));
    } catch (_) {
      _snack(PrivacyStrings.t('snack_delete_failed', locale));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteAdvancedProfile() async {
    final locale = _locale();
    final uid = ref.read(privacyUserIdProvider);
    if (uid == null) return;
    if (!await _confirm(
      PrivacyStrings.t('confirm_delete_advanced_profile', locale),
    )) {
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(userDataServiceProvider).deleteAdvancedProfile(uid);
      await ref.read(userAIProfileProvider.notifier).revokeAdvancedProfileConsent();
      ref.invalidate(userDataSummaryProvider);
      _snack(PrivacyStrings.t('snack_advanced_profile_deleted', locale));
    } catch (_) {
      _snack(PrivacyStrings.t('snack_delete_failed', locale));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final locale = _locale();
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final phoneController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(PrivacyStrings.t('delete_account_title', locale)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(PrivacyStrings.t('delete_account_body', locale)),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: PrivacyStrings.t('phone_number_label', locale),
                hintText: PrivacyStrings.t('phone_hint', locale),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(CommonActionStrings.t('action_cancel', locale)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              PrivacyStrings.t('delete_forever', locale),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await SensitiveActionAuditService.log(
      actionId: SensitiveActionIds.deleteAccount,
      level: PermissionLevel.execute,
      referenceId: user.uid,
    );

    setState(() => _busy = true);
    try {
      await ref.read(userDataServiceProvider).deleteAccount(
            uid: user.uid,
            phoneConfirmation: phoneController.text.trim(),
          );
      if (!mounted) return;
      await AuthSessionService.instance.signOutExplicit();
      if (!mounted) return;
      context.go('/login');
    } catch (e) {
      _snack(PrivacyStrings.t('snack_account_delete_failed', locale));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showSensitiveAiNotice(PrivacySettings settings) async {
    final locale = _locale();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(PrivacyStrings.t('sensitive_ai_title', locale)),
        content: Text(PrivacyStrings.t('sensitive_ai_body', locale)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(PrivacyStrings.t('action_close', locale)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _updateSettings(
                settings.copyWith(sensitiveAiDisclaimerAcknowledged: true),
              );
            },
            child: Text(PrivacyStrings.t('action_understand', locale)),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    final locale = _locale();
    final ok = await _confirm(PrivacyStrings.t('confirm_sign_out', locale));
    if (!ok || !mounted) return;
    await AuthSessionService.instance.signOutExplicit();
    if (!mounted) return;
    context.go('/login');
  }

  Future<bool> _confirm(String message) async {
    final locale = _locale();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(CommonActionStrings.t('action_cancel', locale)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(PrivacyStrings.t('action_confirm', locale)),
          ),
        ],
      ),
    );
    return result == true;
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.body)),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
