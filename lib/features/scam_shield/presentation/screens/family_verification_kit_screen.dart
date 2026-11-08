import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/hub_subscreen_scaffold.dart';
import 'package:raabta/features/scam_shield/family_kit/family_verification_models.dart';
import 'package:raabta/features/scam_shield/family_kit/family_verification_providers.dart';
import 'package:raabta/features/scam_shield/family_kit/family_verification_secure_store.dart';
import 'package:raabta/features/scam_shield/permissions/permission_rationale_flow.dart';
import 'package:raabta/features/scam_shield/permissions/permission_rationale_models.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/family_verification_kit_strings.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';
import 'package:raabta/services/notifications/notification_service.dart';

class FamilyVerificationKitScreen extends ConsumerStatefulWidget {
  const FamilyVerificationKitScreen({super.key});

  @override
  ConsumerState<FamilyVerificationKitScreen> createState() =>
      _FamilyVerificationKitScreenState();
}

class _FamilyVerificationKitScreenState
    extends ConsumerState<FamilyVerificationKitScreen> {
  final _hintController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  List<FamilyKnownContact> _contacts = const [];
  bool _loadingSensitive = true;

  static final _teal = AppColors.tealFamilyMain;

  @override
  void initState() {
    super.initState();
    _loadSensitive();
  }

  Future<void> _loadSensitive() async {
    final hint = await FamilyVerificationSecureStore.readHint();
    final contacts = await FamilyVerificationSecureStore.readContacts();
    if (!mounted) return;
    setState(() {
      _hintController.text = hint ?? '';
      _contacts = contacts;
      _loadingSensitive = false;
    });
  }

  @override
  void dispose() {
    _hintController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _retryPrefsLoad() {
    ref.invalidate(familyVerificationPrefsRepositoryProvider);
    ref.invalidate(familyVerificationPrefsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final prefsAsync = ref.watch(familyVerificationPrefsProvider);

    return HubSubscreenScaffold(
      title: FamilyVerificationKitStrings.t('ss_fvk_title', locale),
      subtitle: FamilyVerificationKitStrings.t('ss_fvk_kit_subtitle', locale),
      onBack: () => context.pop(),
      body: prefsAsync.when(
        loading: () => LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            return Center(
              child: SingleChildScrollView(
                padding: moneyHubScreenPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 140,
                      child: HubLoadingPlaceholder(
                        width: w,
                        height: 140,
                        silhouette: HubLoadingSilhouette.formTool,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: 140,
                      child: HubLoadingPlaceholder(
                        width: w,
                        height: 140,
                        silhouette: HubLoadingSilhouette.formTool,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        error: (_, _) => Center(
          child: SingleChildScrollView(
            padding: moneyHubScreenPadding,
            child: GlassEmptyState(
              icon: Icons.cloud_off_outlined,
              accent: GlassEmptyStateAccent.brand,
              title: FamilyVerificationKitStrings.t(
                'ss_fvk_prefs_load_error_title',
                locale,
              ),
              description: FamilyVerificationKitStrings.t(
                'ss_fvk_prefs_load_error_body',
                locale,
              ),
              actionLabel: FamilyVerificationKitStrings.t(
                'ss_fvk_prefs_retry',
                locale,
              ),
              onAction: _retryPrefsLoad,
            ),
          ),
        ),
        data: (prefs) => ListView(
          padding: moneyHubScreenPadding,
          children: [
            _kitHero(locale),
            const SizedBox(height: AppSpacing.lg),
            _hubSectionHeader(locale, 'ss_fvk_kit_section_steps'),
            _stepCard(
              locale,
              '1',
              'ss_fvk_step1_title',
              'ss_fvk_step1_body',
              Icons.groups_outlined,
            ),
            _stepCard(
              locale,
              '2',
              'ss_fvk_step2_title',
              null,
              Icons.phone_in_talk_outlined,
              extra: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bullet(locale, 'ss_fvk_step2_rule1'),
                  _bullet(locale, 'ss_fvk_step2_rule2'),
                  _bullet(locale, 'ss_fvk_step2_rule3'),
                ],
              ),
            ),
            _stepCard(
              locale,
              '3',
              'ss_fvk_step3_title',
              'ss_fvk_step3_body',
              Icons.record_voice_over_outlined,
            ),
            _stepCard(
              locale,
              '4',
              'ss_fvk_step4_title',
              'ss_fvk_step4_body',
              Icons.event_repeat_outlined,
            ),
            const SizedBox(height: AppSpacing.md),
            _hubSectionHeader(locale, 'ss_fvk_kit_section_device'),
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              glowColor: _teal,
              glowIntensity: 0.05,
              borderRadius: AppSpacing.radiusMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_loadingSensitive) _hintBlock(locale),
                  _contactsBlock(locale, prefs),
                  const Divider(height: AppSpacing.lg),
                  _reminderBlock(locale, prefs),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _hubSectionHeader(locale, 'ss_fvk_kit_section_family_actions'),
            GlassPrimaryButton(
              label: FamilyVerificationKitStrings.t(
                'ss_fvk_share_entry',
                locale,
              ),
              icon: Icons.share_outlined,
              expand: true,
              accentColor: _teal,
              onPressed: () =>
                  context.push('/scam-shield/family-verification/share'),
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassPrimaryButton(
              label: FamilyVerificationKitStrings.t(
                'ss_fvk_practice_entry',
                locale,
              ),
              icon: Icons.psychology_outlined,
              expand: true,
              accentColor: _teal,
              onPressed: () => context.push(
                '/scam-shield/family-verification/practice',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kitHero(String locale) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      glowColor: _teal,
      glowIntensity: 0.09,
      borderRadius: AppSpacing.radiusLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: _teal.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                    color: _teal.withValues(alpha: 0.4),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_outlined, size: 18, color: _teal),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        FamilyVerificationKitStrings.t(
                          'ss_fvk_kit_hero_badge',
                          locale,
                        ),
                        style: AppTypography.caption.copyWith(
                          color: _teal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            FamilyVerificationKitStrings.t('ss_fvk_hub_sub', locale),
            style: AppTypography.subtitle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            FamilyVerificationKitStrings.t('ss_fvk_disclaimer', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _hubSectionHeader(String locale, String titleKey) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.sm,
        top: AppSpacing.xs,
      ),
      child: Text(
        FamilyVerificationKitStrings.t(titleKey, locale),
        style: AppTypography.subtitle.copyWith(
          color: _teal,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _stepCard(
    String locale,
    String number,
    String titleKey,
    String? bodyKey,
    IconData icon, {
    Widget? extra,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        glowColor: _teal,
        glowIntensity: 0.06,
        borderRadius: AppSpacing.radiusMd,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _teal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(
                  color: _teal.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                number,
                style: AppTypography.subtitle.copyWith(
                  color: _teal,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(icon, size: AppSpacing.iconMd, color: _teal),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          FamilyVerificationKitStrings.t(titleKey, locale),
                          style: AppTypography.subtitle.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (bodyKey != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      FamilyVerificationKitStrings.t(bodyKey, locale),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                  if (extra != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    extra,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bullet(String locale, String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: AppTypography.bodySmall.copyWith(color: _teal)),
          Expanded(
            child: Text(
              FamilyVerificationKitStrings.t(key, locale),
              style: AppTypography.bodySmall.copyWith(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hintBlock(String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          FamilyVerificationKitStrings.t('ss_fvk_hint_label', locale),
          style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          FamilyVerificationKitStrings.t('ss_fvk_hint_help', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _hintController,
          decoration: _fvkFieldDecoration(
            context,
            hintText: FamilyVerificationKitStrings.t('ss_fvk_hint_help', locale),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          alignment: WrapAlignment.start,
          children: [
            TextButton(
              onPressed: () async {
                await FamilyVerificationSecureStore.saveHint(
                  _hintController.text,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        FamilyVerificationKitStrings.t(
                          'ss_fvk_hint_save',
                          locale,
                        ),
                      ),
                    ),
                  );
                }
              },
              child: Text(
                FamilyVerificationKitStrings.t('ss_fvk_hint_save', locale),
                style: TextStyle(color: _teal),
              ),
            ),
            TextButton(
              onPressed: () async {
                _hintController.clear();
                await FamilyVerificationSecureStore.clearHint();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        FamilyVerificationKitStrings.t(
                          'ss_fvk_hint_cleared',
                          locale,
                        ),
                      ),
                    ),
                  );
                }
              },
              child: Text(
                FamilyVerificationKitStrings.t('ss_fvk_hint_cleared', locale),
                style: TextStyle(color: _teal),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _contactsBlock(String locale, FamilyVerificationPrefs prefs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            FamilyVerificationKitStrings.t('ss_fvk_contacts_toggle', locale),
            style: AppTypography.body,
          ),
          subtitle: Text(
            FamilyVerificationKitStrings.t('ss_fvk_contacts_help', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          value: prefs.knownNumbersEnabled,
          activeThumbColor: _teal,
          onChanged: (v) async {
            final repo =
                await ref.read(familyVerificationPrefsRepositoryProvider.future);
            await repo.setKnownNumbersEnabled(v);
            if (!v) {
              await FamilyVerificationSecureStore.saveContacts(const []);
              setState(() => _contacts = const []);
            }
            ref.invalidate(familyVerificationPrefsProvider);
          },
        ),
        if (prefs.knownNumbersEnabled) ...[
          for (final c in _contacts)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(c.displayName, style: AppTypography.bodySmall),
              subtitle: Text(
                c.phoneNumber,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          TextField(
            controller: _nameController,
            decoration: _fvkFieldDecoration(
              context,
              labelText: FamilyVerificationKitStrings.t(
                'ss_fvk_contact_name',
                locale,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: _fvkFieldDecoration(
              context,
              labelText: FamilyVerificationKitStrings.t(
                'ss_fvk_contact_phone',
                locale,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                final phone = _phoneController.text.trim();
                if (name.isEmpty || phone.isEmpty) return;
                final updated = [
                  ..._contacts,
                  FamilyKnownContact(displayName: name, phoneNumber: phone),
                ];
                await FamilyVerificationSecureStore.saveContacts(updated);
                _nameController.clear();
                _phoneController.clear();
                setState(() => _contacts = updated);
              },
              child: Text(
                FamilyVerificationKitStrings.t('ss_fvk_contact_add', locale),
                style: TextStyle(color: _teal, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () async {
                await FamilyVerificationSecureStore.saveContacts(const []);
                setState(() => _contacts = const []);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        FamilyVerificationKitStrings.t(
                          'ss_fvk_contacts_delete_all',
                          locale,
                        ),
                      ),
                    ),
                  );
                }
              },
              child: Text(
                FamilyVerificationKitStrings.t(
                  'ss_fvk_contacts_delete_all',
                  locale,
                ),
                style: const TextStyle(color: AppColors.errorBright),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _reminderBlock(String locale, FamilyVerificationPrefs prefs) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        FamilyVerificationKitStrings.t('ss_fvk_reminder_toggle', locale),
        style: AppTypography.body,
      ),
      value: prefs.reminderEnabled,
      activeThumbColor: _teal,
      onChanged: (v) async {
        if (v) {
          final ok = await PermissionRationaleFlow.showThenContinue(
            context,
            kind: PermissionRationaleKind.localNotifications,
            locale: locale,
          );
          if (!ok) return;
          await NotificationService.requestPermission();
        }
        final reminder =
            await ref.read(familyVerificationReminderServiceProvider.future);
        await reminder.setEnabled(enabled: v, locale: locale);
        ref.invalidate(familyVerificationPrefsProvider);
      },
    );
  }
}

/// Hub-style filled fields — Scam Shield teal focus ring.
InputDecoration _fvkFieldDecoration(
  BuildContext context, {
  String? labelText,
  String? hintText,
}) {
  final enabledBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
    borderSide: BorderSide(color: AppColors.glassBorder),
  );
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    labelStyle: AppTypography.caption,
    hintStyle:
        AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
    filled: true,
    fillColor: AppColors.isLight ? AppColors.surface : AppColors.glassSurface,
    border: enabledBorder,
    enabledBorder: enabledBorder,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      borderSide: BorderSide(
        color: AppColors.tealFamilyMain.withValues(alpha: 0.45),
      ),
    ),
  );
}
