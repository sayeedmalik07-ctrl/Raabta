import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/utils/home_header_context_line.dart';
import 'package:raabta/features/home/widgets/home_header_tactile_control.dart';
import 'package:raabta/features/home/widgets/profile_avatar.dart';

/// Premium glass welcome header — presentation only.
class GlassStatusHeader extends StatelessWidget {
  const GlassStatusHeader({
    super.key,
    this.userName,
    this.greeting,
    this.place,
    this.notificationCount = 0,
    this.onNotificationTap,
    this.onSearchTap,
    this.onProfileTap,
    this.profileInitials,
    this.profilePhotoUrl,
    this.languageToggle,
    this.aiAssistantToggle,
    this.profileMenuSemanticsLabel,
    this.searchSemanticsLabel,
    this.notificationSemanticsLabel,
    this.locale = 'English',
  });

  final String? userName;
  final String? greeting;
  final HomeHeaderPlaceParts? place;
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onProfileTap;
  final String? profileInitials;
  final String? profilePhotoUrl;
  final Widget? languageToggle;
  final Widget? aiAssistantToggle;
  final String? profileMenuSemanticsLabel;
  final String? searchSemanticsLabel;
  final String? notificationSemanticsLabel;
  final String locale;

  String? get _trimmedUserName {
    final name = userName?.trim();
    if (name == null || name.isEmpty) return null;
    return name;
  }

  static String badgeLabelForCount(int count) {
    if (count <= 0) return '';
    if (count > 9) return '9+';
    return '$count';
  }

  /// Design kit v2.1 header controls (§10 / `.hdr`).
  static const double kitAvatarSize = 44;
  static const double kitControlSize = 44;

  @override
  Widget build(BuildContext context) {
    final shell = GlassContainer(
      borderRadius: AppSpacing.radiusLg,
      padding: EdgeInsets.zero,
      glowColor: AppColors.brandFamilyMain,
      glowIntensity: AppColors.isLight ? 0.06 : 0.03,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontalPadding,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (onProfileTap != null) ...[
                _ProfileAvatarButton(
                  initials: profileInitials ?? 'R',
                  photoUrl: profilePhotoUrl,
                  onTap: onProfileTap,
                  semanticsLabel: profileMenuSemanticsLabel,
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (greeting != null && greeting!.trim().isNotEmpty)
                      Text(
                        greeting!.trim(),
                        style: AppTypography.greeting.copyWith(
                          color: AppColors.textOnGlassSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (_trimmedUserName != null) ...[
                      if (greeting != null && greeting!.trim().isNotEmpty)
                        const SizedBox(height: AppSpacing.xxs),
                      Text(
                        _trimmedUserName!,
                        style: AppTypography.title.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (place != null && place!.hasContent) ...[
                      const SizedBox(height: AppSpacing.xs),
                      _PlaceLine(parts: place!, locale: locale),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (aiAssistantToggle != null) ...[
                aiAssistantToggle!,
                const SizedBox(width: AppSpacing.xs),
              ],
              if (languageToggle != null) ...[
                languageToggle!,
                const SizedBox(width: AppSpacing.xs),
              ],
              if (onSearchTap != null) ...[
                _SearchButton(
                  onTap: onSearchTap,
                  semanticsLabel: searchSemanticsLabel,
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              _HeaderNotificationBell(
                notificationCount: notificationCount,
                badgeLabel: badgeLabelForCount(notificationCount),
                onTap: onNotificationTap,
                semanticsLabel: notificationSemanticsLabel,
              ),
            ],
          ),
        ),
      ),
    );

    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: AppColors.isLight
              ? Border.all(
                  color: AppColors.brandFamilyMain.withValues(alpha: 0.22),
                )
              : null,
          boxShadow: AppColors.isLight
              ? [
                  BoxShadow(
                    color: AppColors.brandFamilyMain.withValues(alpha: 0.14),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: shell,
      ),
    );
  }
}

class _PlaceLine extends StatelessWidget {
  const _PlaceLine({required this.parts, required this.locale});

  final HomeHeaderPlaceParts parts;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final segments = parts.visibleSegments(locale: locale);
    if (segments.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        Icon(
          Icons.place_outlined,
          size: 14,
          color: AppColors.textOnGlassMuted,
        ),
        const SizedBox(width: AppSpacing.xxs),
        Expanded(
          child: Text(
            segments.join(' · '),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textOnGlassMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatarButton extends StatelessWidget {
  const _ProfileAvatarButton({
    required this.initials,
    this.photoUrl,
    this.onTap,
    this.semanticsLabel,
  });

  final String initials;
  final String? photoUrl;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  static const double _tapTarget = 48;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel ?? 'Open profile menu',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('home_profile_avatar_button'),
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: _tapTarget,
            height: _tapTarget,
            child: Center(
              child: ProfileAvatar(
                initials: initials,
                photoUrl: photoUrl,
                size: GlassStatusHeader.kitAvatarSize,
                ringStyle: ProfileAvatarRingStyle.brandKit,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchButton extends StatelessWidget {
  const _SearchButton({
    this.onTap,
    this.semanticsLabel,
  });

  final VoidCallback? onTap;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return HomeHeaderTactileControl(
      width: kitControlSize,
      height: GlassStatusHeader.kitControlSize,
      circular: true,
      semanticsLabel: semanticsLabel ?? 'Search',
      onTap: onTap,
      child: Icon(
        Icons.search_outlined,
        size: AppSpacing.iconLg,
        color: AppColors.brandFamilyMain.withValues(alpha: 0.9),
      ),
    );
  }

  static const kitControlSize = GlassStatusHeader.kitControlSize;
}

class _HeaderNotificationBell extends StatefulWidget {
  const _HeaderNotificationBell({
    required this.notificationCount,
    required this.badgeLabel,
    this.onTap,
    this.semanticsLabel,
  });

  final int notificationCount;
  final String badgeLabel;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  @override
  State<_HeaderNotificationBell> createState() =>
      _HeaderNotificationBellState();
}

class _HeaderNotificationBellState extends State<_HeaderNotificationBell>
    with TickerProviderStateMixin {
  int? _lastCount;
  late final AnimationController _tiltController;
  late final AnimationController _badgePopController;
  late final Animation<double> _tilt;
  late final Animation<double> _badgeScale;

  @override
  void initState() {
    super.initState();
    _lastCount = widget.notificationCount;
    _tiltController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _badgePopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _tilt = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 14 * math.pi / 180),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 14 * math.pi / 180, end: 0.0),
        weight: 60,
      ),
    ]).animate(
      CurvedAnimation(parent: _tiltController, curve: Curves.easeInOut),
    );
    _badgeScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 55),
    ]).animate(
      CurvedAnimation(parent: _badgePopController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant _HeaderNotificationBell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final prev = _lastCount;
    final next = widget.notificationCount;
    if (prev != null && next > prev) {
      _playNewNotificationCue();
    }
    _lastCount = next;
  }

  @override
  void dispose() {
    _tiltController.dispose();
    _badgePopController.dispose();
    super.dispose();
  }

  void _playNewNotificationCue() {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    _badgePopController.forward(from: 0);
    if (!reduceMotion) {
      _tiltController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return HomeHeaderTactileControl(
      controlKey: const Key('home_notification_bell_button'),
      width: GlassStatusHeader.kitControlSize,
      height: GlassStatusHeader.kitControlSize,
      circular: true,
      semanticsLabel: widget.semanticsLabel ?? 'Notifications',
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_tiltController, _badgePopController]),
        builder: (context, child) {
          final tilt = reduceMotion ? 0.0 : _tilt.value;
          final badgeScale =
              _badgePopController.isAnimating ? _badgeScale.value : 1.0;

          return Transform.rotate(
            angle: tilt,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  size: 20,
                  color: AppColors.brandFamilyText.withValues(alpha: 0.88),
                ),
                if (widget.notificationCount > 0)
                  PositionedDirectional(
                    top: 2,
                    end: 2,
                    child: Transform.scale(
                      scale: badgeScale,
                      child: _HeaderNotificationBadge(label: widget.badgeLabel),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Semantic red unread count — matches inbox/header design kit.
@visibleForTesting
Widget buildHeaderNotificationBadgeForTest(String label) {
  return _HeaderNotificationBadge(label: label);
}

@visibleForTesting
String headerNotificationBadgeLabelForTest(int count) =>
    GlassStatusHeader.badgeLabelForCount(count);

class _HeaderNotificationBadge extends StatelessWidget {
  const _HeaderNotificationBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final wide = label.length > 1;
    final ringColor =
        AppColors.isLight ? AppColors.surface : AppColors.background;

    return Container(
      key: Key('home_notification_badge_$label'),
      constraints: BoxConstraints(
        minWidth: wide ? 18 : 16,
        minHeight: 16,
      ),
      padding: wide
          ? const EdgeInsets.symmetric(horizontal: 4)
          : EdgeInsets.zero,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: ringColor,
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: Colors.white,
          fontSize: wide ? 9 : 10,
          height: 1,
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
