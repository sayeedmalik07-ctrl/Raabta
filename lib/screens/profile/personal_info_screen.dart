import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/home/widgets/glass_loading_card.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/profile/l10n/profile_strings.dart';
import 'package:raabta/screens/profile/profile_field_persistence.dart';
import 'package:raabta/screens/profile/profile_tab_scaffold.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/services/auth/auth_session_service.dart';
import 'package:raabta/services/firebase_service.dart';

/// Loads Firestore + AI profile once [uid] is confirmed from a resolved auth session.
final personalInfoLoaderProvider =
    FutureProvider.autoDispose.family<PersonalInfoSnapshot, String>((ref, uid) async {
  final user = AuthSessionService.instance.currentUser;
  if (user == null || user.uid != uid) {
    throw StateError('Sign in to view your account details.');
  }

  final aiNotifier = ref.read(userAIProfileProvider.notifier);
  UserAIProfile? aiProfile = ref.read(userAIProfileProvider);
  if (UserProfileOwnership.needsInit(aiProfile, user.uid)) {
    await aiNotifier.initProfile(user.uid);
    aiProfile = ref.read(userAIProfileProvider);
  }
  if (aiProfile == null || aiProfile.uid != user.uid) {
    aiProfile = UserAIProfile.defaultProfile(user.uid);
  }

  Map<String, dynamic> userDoc = {};
  if (FirebaseService.isReady) {
    try {
      final snap =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      userDoc = snap.data() ?? {};
    } catch (_) {
      // Offline or rules — fall back to Auth + AI profile only.
    }
  }

  return PersonalInfoSnapshot.fromSources(
    authUser: user,
    userDoc: userDoc,
    aiProfile: aiProfile,
  );
});

class PersonalInfoSnapshot {
  const PersonalInfoSnapshot({
    required this.uid,
    required this.displayName,
    required this.phone,
    required this.email,
    required this.nationality,
    required this.preferredArea,
    required this.profession,
    required this.language,
    required this.memberSince,
  });

  final String uid;
  final String displayName;
  final String phone;
  final String email;
  final String nationality;
  final String preferredArea;
  final String profession;
  final String language;
  final String memberSince;

  factory PersonalInfoSnapshot.fromSources({
    required User authUser,
    required Map<String, dynamic> userDoc,
    required UserAIProfile aiProfile,
  }) {
    final displayName = authUser.displayName?.trim().isNotEmpty == true
        ? authUser.displayName!.trim()
        : (userDoc['displayName'] as String? ??
                userDoc['name'] as String? ??
                '')
            .trim();

    final phone = authUser.phoneNumber ??
        userDoc['phone'] as String? ??
        userDoc['phoneNumber'] as String? ??
        '';

    final email = authUser.email ?? userDoc['email'] as String? ?? '';

    final nationality = (userDoc['nationality'] as String? ??
            aiProfile.nationality)
        .trim();

    final language = (userDoc['language'] as String? ?? aiProfile.language)
        .trim();

    final createdAt = userDoc['createdAt'];
    String memberSince = '—';
    if (createdAt is Timestamp) {
      final d = createdAt.toDate();
      memberSince = '${_monthName(d.month)} ${d.year}';
    }

    return PersonalInfoSnapshot(
      uid: authUser.uid,
      displayName: displayName.isEmpty ? 'Raabta member' : displayName,
      phone: phone,
      email: email,
      nationality: nationality,
      preferredArea: aiProfile.preferredArea,
      profession: aiProfile.profession,
      language: language.isEmpty ? 'English' : language,
      memberSince: memberSince,
    );
  }

  static String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[(month - 1).clamp(0, 11)];
  }
}

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _nationalityCtrl;
  late final TextEditingController _areaCtrl;
  late final TextEditingController _professionCtrl;

  bool _hydrated = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _nationalityCtrl = TextEditingController();
    _areaCtrl = TextEditingController();
    _professionCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nationalityCtrl.dispose();
    _areaCtrl.dispose();
    _professionCtrl.dispose();
    super.dispose();
  }

  void _retryAuth() {
    ref.invalidate(resolvedAuthUserForProfileProvider);
    ref.invalidate(authSessionReadyProvider);
  }

  void _retryLoad(String uid) {
    _retryAuth();
    ref.invalidate(personalInfoLoaderProvider(uid));
  }

  void _hydrateForm(PersonalInfoSnapshot data) {
    if (_hydrated) return;
    _nameCtrl.text = data.displayName;
    _nationalityCtrl.text = data.nationality;
    _areaCtrl.text = data.preferredArea;
    _professionCtrl.text = data.profession;
    _hydrated = true;
  }

  Future<void> _save(PersonalInfoSnapshot snapshot) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final name = _nameCtrl.text.trim();
      final nationality = _nationalityCtrl.text.trim();
      final area = _areaCtrl.text.trim();
      final profession = _professionCtrl.text.trim();

      final user = ref.read(currentUserProvider);
      if (user != null && name.isNotEmpty && name != user.displayName) {
        await user.updateDisplayName(name);
      }

      if (FirebaseService.isReady) {
        await FirebaseFirestore.instance.collection('users').doc(snapshot.uid).set(
          {
            if (name.isNotEmpty) 'displayName': name,
            'lastActive': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      if (profession.isNotEmpty) {
        await ProfileFieldPersistence.saveProfession(
          ref,
          uid: snapshot.uid,
          value: profession,
        );
      }
      if (nationality.isNotEmpty) {
        await ProfileFieldPersistence.saveNationality(
          ref,
          uid: snapshot.uid,
          value: nationality,
        );
      }
      if (area.isNotEmpty) {
        await ProfileFieldPersistence.savePreferredArea(
          ref,
          uid: snapshot.uid,
          value: area,
        );
      }

      ref.invalidate(personalInfoLoaderProvider(snapshot.uid));
      if (!mounted) return;
      final locale = AppLocale.normalize(ref.read(userLanguageProvider));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ProfileStrings.t('snack_profile_updated', locale)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceElevated,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final locale = AppLocale.normalize(ref.read(userLanguageProvider));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ProfileStrings.format(
              'error_save_failed',
              locale,
              params: {'error': e.toString()},
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final authUserAsync = ref.watch(resolvedAuthUserForProfileProvider);

    return ProfileTabScaffold(
      child: authUserAsync.when(
        loading: () => _loadingScaffold(locale),
        error: (error, _) => _messageScaffold(
          locale: locale,
          icon: Icons.error_outline,
          message: ProfileStrings.t('error_session_verify', locale),
          detail: error.toString(),
          onRetry: _retryAuth,
        ),
        data: (user) {
          if (user == null) {
            return _messageScaffold(
              locale: locale,
              icon: Icons.login_outlined,
              message: ProfileStrings.t('error_sign_in_required', locale),
              onRetry: _retryAuth,
              secondaryAction: TextButton(
                onPressed: () => context.go('/login'),
                child: Text(ProfileStrings.t('action_go_to_sign_in', locale)),
              ),
            );
          }

          final asyncInfo = ref.watch(personalInfoLoaderProvider(user.uid));
          return asyncInfo.when(
            loading: () => _loadingScaffold(locale),
            error: (error, _) => _messageScaffold(
              locale: locale,
              icon: Icons.error_outline,
              message: error is StateError
                  ? error.message
                  : ProfileStrings.t('error_load_profile', locale),
              detail: error is StateError ? null : error.toString(),
              onRetry: () => _retryLoad(user.uid),
            ),
            data: (info) {
              _hydrateForm(info);
              return GlassScreenScaffold(
                title: ProfileStrings.t('personal_info_title', locale),
                leading: GlassIconButton(
                  icon: Icons.arrow_back_ios_rounded,
                  tooltip: CommonActionStrings.t('action_back', locale),
                  onPressed: () => context.pop(),
                ),
                padding: const EdgeInsets.all(AppSpacing.lg),
                body: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Text(
                        ProfileStrings.t('personal_info_intro', locale),
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _ReadOnlyField(
                        label: ProfileStrings.t('field_phone', locale),
                        value: info.phone.isEmpty ? '—' : info.phone,
                      ),
                      if (info.email.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        _ReadOnlyField(
                          label: ProfileStrings.t('field_email', locale),
                          value: info.email,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      _ReadOnlyField(
                        label: ProfileStrings.t('field_member_since', locale),
                        value: info.memberSince,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _ReadOnlyField(
                        label: ProfileStrings.t('field_app_language', locale),
                        value: info.language,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            _EditableField(
                              label: ProfileStrings.t('field_display_name', locale),
                              controller: _nameCtrl,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? ProfileStrings.t('validation_required', locale)
                                  : null,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _EditableField(
                              label: ProfileStrings.t('field_nationality', locale),
                              controller: _nationalityCtrl,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _EditableField(
                              label: ProfileStrings.t('field_preferred_area', locale),
                              controller: _areaCtrl,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _EditableField(
                              label: ProfileStrings.t('field_profession', locale),
                              controller: _professionCtrl,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      GlassPrimaryButton(
                        label: _saving
                            ? ProfileStrings.t('action_saving', locale)
                            : ProfileStrings.t('action_save_changes', locale),
                        onPressed: _saving ? null : () => _save(info),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _loadingScaffold(String locale) {
    return GlassScreenScaffold(
      title: ProfileStrings.t('personal_info_title', locale),
      leading: GlassIconButton(
        icon: Icons.arrow_back_ios_rounded,
        tooltip: CommonActionStrings.t('action_back', locale),
        onPressed: () => context.pop(),
      ),
      body: const Center(child: GlassLoadingCard(height: 120, width: 240)),
    );
  }

  Widget _messageScaffold({
    required String locale,
    required IconData icon,
    required String message,
    String? detail,
    required VoidCallback onRetry,
    Widget? secondaryAction,
  }) {
    return GlassScreenScaffold(
      title: ProfileStrings.t('personal_info_title', locale),
      leading: GlassIconButton(
        icon: Icons.arrow_back_ios_rounded,
        tooltip: CommonActionStrings.t('action_back', locale),
        onPressed: () => context.pop(),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.error, size: 40),
              const SizedBox(height: AppSpacing.md),
              Text(message, textAlign: TextAlign.center, style: AppTypography.body),
              if (detail != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  detail,
                  textAlign: TextAlign.center,
                  style: AppTypography.caption,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              GlassPrimaryButton(
                label: CommonActionStrings.t('action_retry', locale),
                onPressed: onRetry,
              ),
              if (secondaryAction != null) ...[
                const SizedBox(height: AppSpacing.sm),
                secondaryAction,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: AppTypography.subtitle),
      ],
    );
  }
}

class _EditableField extends StatelessWidget {
  const _EditableField({
    required this.label,
    required this.controller,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: AppTypography.subtitle,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.bodySmall,
        filled: true,
        fillColor: AppColors.surface.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
      ),
    );
  }
}
