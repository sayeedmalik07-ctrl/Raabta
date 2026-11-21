import 'package:flutter/material.dart';

import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

/// Ring treatment for [ProfileAvatar].
enum ProfileAvatarRingStyle {
  standard,
  brandKit,
}

/// Compact circular avatar — photo when available, otherwise gradient initials.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.initials,
    this.photoUrl,
    this.size = AppSpacing.avatarMd,
    this.fontSize,
    this.ringStyle = ProfileAvatarRingStyle.standard,
    this.onSkyline = false,
    this.showGuestProfileIcon = false,
  });

  final String initials;
  final String? photoUrl;
  final double size;
  final double? fontSize;
  final ProfileAvatarRingStyle ringStyle;
  final bool onSkyline;

  /// Signed-out shell avatar — person icon (matches Profile tab), not initials.
  final bool showGuestProfileIcon;

  @override
  Widget build(BuildContext context) {
    final trimmedPhoto = photoUrl?.trim();
    final hasPhoto = trimmedPhoto != null && trimmedPhoto.isNotEmpty;
    const ringWidth = 2.0;
    final innerSize = size - (ringWidth * 2);
    final textSize = fontSize ?? (size * 0.38);

    final ringDecoration = switch (ringStyle) {
      ProfileAvatarRingStyle.standard => const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppColors.cyanGlow, AppColors.purpleGlow],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ProfileAvatarRingStyle.brandKit => BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.brandFamilyMain,
            width: ringWidth,
          ),
        ),
    };

    return Container(
      width: size,
      height: size,
      padding: ringStyle == ProfileAvatarRingStyle.standard
          ? const EdgeInsets.all(2)
          : EdgeInsets.zero,
      decoration: ringDecoration,
      child: ClipOval(
        child: hasPhoto
            ? Image.network(
                trimmedPhoto,
                width: innerSize,
                height: innerSize,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _InitialsFallback(
                  initials: initials,
                  size: innerSize,
                  fontSize: textSize,
                  onSkyline: onSkyline,
                  showGuestProfileIcon: showGuestProfileIcon,
                ),
              )
            : _InitialsFallback(
                initials: initials,
                size: innerSize,
                fontSize: textSize,
                onSkyline: onSkyline,
                showGuestProfileIcon: showGuestProfileIcon,
              ),
      ),
    );
  }
}

class _InitialsFallback extends StatelessWidget {
  const _InitialsFallback({
    required this.initials,
    required this.size,
    required this.fontSize,
    this.onSkyline = false,
    this.showGuestProfileIcon = false,
  });

  final String initials;
  final double size;
  final double fontSize;
  final bool onSkyline;
  final bool showGuestProfileIcon;

  @override
  Widget build(BuildContext context) {
  final iconColor = onSkyline
        ? Colors.white
        : AppColors.isLight
            ? AppColors.textPrimary
            : Colors.white;
    return Container(
      width: size,
      height: size,
      color: onSkyline
          ? Colors.white.withValues(alpha: 0.16)
          : AppColors.surface,
      alignment: Alignment.center,
      child: showGuestProfileIcon
          ? Icon(
              Icons.person_outline_rounded,
              size: fontSize * 1.45,
              color: iconColor,
            )
          : Text(
              initials,
              style: AppTypography.subtitle.copyWith(
                color: iconColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}
