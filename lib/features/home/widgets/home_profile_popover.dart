import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:raabta/config/monetization_state.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/navigation/shell_nav_config.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/features/home/l10n/home_profile_strings.dart';
import 'package:raabta/features/home/widgets/home_brand_primary_button.dart';
import 'package:raabta/features/home/widgets/home_header_tactile_control.dart';
import 'package:raabta/features/home/utils/home_directional_icons.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/profile/l10n/profile_strings.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/utils/profile_display_helper.dart';
import 'package:raabta/core/widgets/glass_settings_tile.dart';
import 'package:raabta/features/home/utils/home_time_greeting.dart';
import 'package:raabta/features/home/widgets/glass_status_header.dart';
import 'package:raabta/features/home/widgets/profile_avatar.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/services/auth/auth_session_service.dart';

/// Paytm/Blinkit-style account launcher — lightweight summary + shortcuts.
enum HomeProfileShortcut {
  myProfile,
  documentVault,
  notifications,
  signOut,
}

abstract final class HomeProfilePopover {
  HomeProfilePopover._();

  static Future<void> show(BuildContext context, WidgetRef ref) {
    final locale = ref.read(userLanguageProvider);
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: HomeProfileStrings.t('menu_dismiss', locale),
      barrierColor: Colors.black.withValues(alpha: 0.42),
      transitionDuration: AppSpacing.contentAnimation,
      pageBuilder: (dialogContext, _, _) {
        return SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.screenHorizontalPadding,
                top: AppSpacing.sm,
              ),
              child: _HomeProfilePopoverPanel(
                onClose: () => Navigator.of(dialogContext).pop(),
                onShortcut: (shortcut) {
                  Navigator.of(dialogContext).pop();
                  _handleShortcut(context, ref, shortcut);
                },
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, animation, _, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curve,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curve),
            alignment: Alignment.topLeft,
            child: child,
          ),
        );
      },
    );
  }

  static Future<void> _handleShortcut(
    BuildContext context,
    WidgetRef ref,
    HomeProfileShortcut shortcut,
  ) async {
    if (!context.mounted) return;

    switch (shortcut) {
      case HomeProfileShortcut.myProfile:
        context.go(
          '/home?tab=${ShellNavConfig.legacyQueryIndexFor(ShellTab.profile)}',
        );
      case HomeProfileShortcut.documentVault:
        context.push('/document-vault');
      case HomeProfileShortcut.notifications:
        context.push('/profile/notifications');
      case HomeProfileShortcut.signOut:
        await _confirmSignOut(context, ref);
    }
  }

  static Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final locale = ref.read(userLanguageProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ProfileStrings.t('dialog_sign_out_title', locale)),
        content: Text(ProfileStrings.t('dialog_sign_out_body', locale)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(CommonActionStrings.t('action_cancel', locale)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ProfileStrings.t('action_sign_out', locale)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await AuthSessionService.instance.signOutExplicit();
    if (!context.mounted) return;
    context.go('/login');
  }

  /// Test hook for navigation assertions.
  @visibleForTesting
  static Future<void> handleShortcutForTest(
    BuildContext context,
    WidgetRef ref,
    HomeProfileShortcut shortcut,
  ) =>
      _handleShortcut(context, ref, shortcut);
}

class _HomeProfilePopoverPanel extends ConsumerWidget {
  const _HomeProfilePopoverPanel({
    required this.onClose,
    required this.onShortcut,
  });

  final VoidCallback onClose;
  final ValueChanged<HomeProfileShortcut> onShortcut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final user = ref.watch(currentUserProvider);
    final profile = ref.watch(userAIProfileProvider);
    final premiumAsync = ref.watch(isPremiumUserProvider);

    final isLoadingUser = user == null && ref.watch(resolvedAuthUserForProfileProvider).isLoading;
    final heroName =
        user != null ? ProfileDisplayHelper.profileHeroName(user) : null;
    final isSignedOut = user == null;

    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.88,
          minWidth: 280,
        ),
        child: GlassContainer(
          borderRadius: AppSpacing.radiusLg,
          padding: EdgeInsets.zero,
          glowColor: AppColors.brandFamilyMain,
          glowIntensity: AppColors.isLight ? 0.06 : 0.04,
          backgroundColor: _profilePopoverSurfaceColor(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLoadingUser)
                      const SizedBox(
                        width: GlassStatusHeader.kitAvatarSize,
                        height: GlassStatusHeader.kitAvatarSize,
                        child: Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    else
                      ProfileAvatar(
                        initials: ProfileDisplayHelper.initials(user),
                        photoUrl: user?.photoURL,
                        size: GlassStatusHeader.kitAvatarSize,
                        ringStyle: ProfileAvatarRingStyle.brandKit,
                      ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: isLoadingUser
                          ? Padding(
                              padding: const EdgeInsets.only(top: AppSpacing.sm),
                              child: Text(
                                HomeProfileStrings.t('loading_account', locale),
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textOnGlassSecondary,
                                ),
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isSignedOut) ...[
                                  Text(
                                    homeTimeGreetingForLocale(locale),
                                    style: AppTypography.greeting.copyWith(
                                      color: AppColors.textOnGlassSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xxs),
                                  Text(
                                    AppShellStrings.t(
                                      'home_hero_guest_title',
                                      locale,
                                    ),
                                    style: AppTypography.subtitle.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: AppSpacing.xxs),
                                  Text(
                                    AppShellStrings.t(
                                      'home_hero_guest_body',
                                      locale,
                                    ),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textOnGlassMuted,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ] else if (heroName != null) ...[
                                  Text(
                                    heroName,
                                    style: AppTypography.subtitle.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ] else ...[
                                  Text(
                                    homeTimeGreetingForLocale(locale),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textOnGlassSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xxs),
                                  Text(
                                    ProfileStrings.t(
                                      'profile_hero_complete_name_prompt',
                                      locale,
                                    ),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textOnGlassMuted,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                if (!isSignedOut &&
                                    MonetizationState.showPremiumTierUi) ...[
                                  const SizedBox(height: AppSpacing.xxs),
                                  _TierBadge(
                                    isPremium: premiumAsync.value ?? false,
                                    locale: locale,
                                  ),
                                ],
                                if (!isSignedOut && heroName != null) ...[
                                  const SizedBox(height: AppSpacing.xxs),
                                  Text(
                                    ProfileDisplayHelper.profileSubtitle(
                                      profile,
                                    ),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textOnGlassMuted,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                    ),
                    HomeHeaderTactileControl(
                      width: GlassStatusHeader.kitControlSize,
                      height: GlassStatusHeader.kitControlSize,
                      circular: true,
                      semanticsLabel:
                          HomeProfileStrings.t('tooltip_close', locale),
                      onTap: onClose,
                      child: Icon(
                        Icons.close_rounded,
                        size: AppSpacing.iconMd,
                        color: AppColors.textOnGlassSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: AppColors.isLight
                    ? AppColors.glassBorder
                    : Colors.white12,
              ),
              GlassSettingsTile(
                title: HomeProfileStrings.t('menu_my_profile', locale),
                leading: _MenuLeadingIcon(Icons.person_outline_rounded),
                trailing: Icon(
                  HomeDirectionalIcons.forwardChevron(context),
                  size: 20,
                  color: AppColors.textOnGlassMuted,
                ),
                onTap: () => onShortcut(HomeProfileShortcut.myProfile),
              ),
              GlassSettingsTile(
                title: HomeProfileStrings.t('menu_document_vault', locale),
                leading: _MenuLeadingIcon(Icons.folder_copy_outlined),
                trailing: Icon(
                  HomeDirectionalIcons.forwardChevron(context),
                  size: 20,
                  color: AppColors.textOnGlassMuted,
                ),
                onTap: () => onShortcut(HomeProfileShortcut.documentVault),
              ),
              GlassSettingsTile(
                title: HomeProfileStrings.t('menu_notifications', locale),
                subtitle: HomeProfileStrings.t('menu_notifications_sub', locale),
                leading: _MenuLeadingIcon(Icons.notifications_outlined),
                trailing: Icon(
                  HomeDirectionalIcons.forwardChevron(context),
                  size: 20,
                  color: AppColors.textOnGlassMuted,
                ),
                onTap: () => onShortcut(HomeProfileShortcut.notifications),
              ),
              if (!isSignedOut) ...[
                Divider(
                  height: 1,
                  color: AppColors.isLight
                      ? AppColors.glassBorder
                      : Colors.white12,
                ),
                GlassSettingsTile(
                  title: ProfileStrings.t('action_sign_out', locale),
                  titleColor: AppColors.roseGlow,
                  leading: Icon(
                    Icons.logout_rounded,
                    size: 20,
                    color: AppColors.roseGlow,
                  ),
                  onTap: () => onShortcut(HomeProfileShortcut.signOut),
                ),
              ],
              if (isSignedOut)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: HomeBrandPrimaryButton(
                    label: AppShellStrings.t('home_hero_guest_sign_in', locale),
                    onPressed: () {
                      onClose();
                      context.go('/login');
                    },
                  ),
                )
              else
                const SizedBox(height: AppSpacing.xs),
            ],
          ),
        ),
      ),
    );
  }
}

Color _profilePopoverSurfaceColor() {
  return AppColors.isLight
      ? Color.lerp(AppColors.surface, Colors.white, 0.45)!
      : Color.lerp(AppColors.surface, AppColors.background, 0.42)!;
}

class _MenuLeadingIcon extends StatelessWidget {
  const _MenuLeadingIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: 20,
      color: AppColors.brandFamilyMain.withValues(alpha: 0.92),
    );
  }
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.isPremium, required this.locale});

  final bool isPremium;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final label = isPremium
        ? HomeProfileStrings.t('tier_premium', locale)
        : HomeProfileStrings.t('tier_free', locale);
    final color = isPremium ? AppColors.accentGold : AppColors.textOnGlassMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: AppTypography.chipLabel.copyWith(color: color),
      ),
    );
  }
}

/// Test hook — panel without dialog wrapper.
@visibleForTesting
Widget buildHomeProfilePopoverPanelForTest({
  required VoidCallback onClose,
  required ValueChanged<HomeProfileShortcut> onShortcut,
}) {
  return _HomeProfilePopoverPanel(
    onClose: onClose,
    onShortcut: onShortcut,
  );
}
