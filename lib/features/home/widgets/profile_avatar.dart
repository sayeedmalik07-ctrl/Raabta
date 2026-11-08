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
  });

  final String initials;
  final String? photoUrl;
  final double size;
  final double? fontSize;
  final ProfileAvatarRingStyle ringStyle;

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
                ),
              )
            : _InitialsFallback(
                initials: initials,
                size: innerSize,
                fontSize: textSize,
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
  });

  final String initials;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: AppColors.surface,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTypography.subtitle.copyWith(
          color: AppColors.isLight
              ? AppColors.textPrimary
              : Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
