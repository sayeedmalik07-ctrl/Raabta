import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/widgets/glass_status_header.dart';
import 'package:raabta/features/home/widgets/home_header_tactile_control.dart';
import 'package:raabta/features/home/widgets/home_language_toggle_chip.dart';
import 'package:raabta/features/home/widgets/profile_avatar.dart';

/// Greeting controls over the Doha skyline (no glass card shell — D8).
class HomeDohaSkylineGreetingRow extends StatelessWidget {
  const HomeDohaSkylineGreetingRow({
    super.key,
    required this.locale,
    required this.greetingLine,
    required this.profileInitials,
    this.showGuestProfileIcon = false,
    this.profilePhotoUrl,
    this.notificationCount = 0,
    this.onProfileTap,
    this.onNotificationTap,
    this.profileMenuSemanticsLabel,
    this.notificationSemanticsLabel,
  });

  final String locale;
  final String greetingLine;
  final String profileInitials;
  final bool showGuestProfileIcon;
  final String? profilePhotoUrl;
  final int notificationCount;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final String? profileMenuSemanticsLabel;
  final String? notificationSemanticsLabel;

  @override
  Widget build(BuildContext context) {
    final badge = GlassStatusHeader.badgeLabelForCount(notificationCount);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontalPadding,
      ),
      child: Row(
        children: [
          if (onProfileTap != null) ...[
            HomeHeaderTactileControl(
              width: GlassStatusHeader.kitAvatarSize,
              height: GlassStatusHeader.kitAvatarSize,
              borderRadius: GlassStatusHeader.kitAvatarSize / 2,
              circular: true,
              overSkyline: true,
              onTap: onProfileTap,
              semanticsLabel: profileMenuSemanticsLabel,
              child: ProfileAvatar(
                initials: profileInitials,
                photoUrl: profilePhotoUrl,
                size: GlassStatusHeader.kitAvatarSize - 4,
                ringStyle: ProfileAvatarRingStyle.brandKit,
                onSkyline: true,
                showGuestProfileIcon: showGuestProfileIcon,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Text(
              greetingLine,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.title.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                shadows: const [
                  Shadow(
                    color: Color(0x59000000),
                    blurRadius: 8,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
          const HomeLanguageToggleChip(overSkyline: true),
          const SizedBox(width: AppSpacing.xs),
          _SkylineNotificationBell(
            badgeLabel: badge,
            onTap: onNotificationTap,
            semanticsLabel: notificationSemanticsLabel,
          ),
        ],
      ),
    );
  }
}

class _SkylineNotificationBell extends StatelessWidget {
  const _SkylineNotificationBell({
    required this.badgeLabel,
    this.onTap,
    this.semanticsLabel,
  });

  final String badgeLabel;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: HomeHeaderTactileControl(
        width: GlassStatusHeader.kitControlSize,
        height: GlassStatusHeader.kitControlSize,
        borderRadius: GlassStatusHeader.kitControlSize / 2,
        overSkyline: true,
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            const Icon(Icons.notifications_none_rounded, color: Colors.white),
            if (badgeLabel.isNotEmpty)
              Positioned(
                top: 6,
                right: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.brandFamilyMain,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    child: Text(
                      badgeLabel,
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}