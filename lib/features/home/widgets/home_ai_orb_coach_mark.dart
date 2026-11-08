import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/data/home_ai_orb_coach_mark_prefs.dart';
import 'package:raabta/features/home/l10n/home_floating_ai_strings.dart';

/// One time glass coach bubble anchored under the Home AI orb.
class HomeAiOrbCoachMark extends StatefulWidget {
  const HomeAiOrbCoachMark({
    super.key,
    required this.link,
    required this.locale,
    required this.visible,
    this.onDismissed,
  });

  final LayerLink link;
  final String locale;
  final bool visible;
  final VoidCallback? onDismissed;

  @visibleForTesting
  static const autoDismissDuration = Duration(seconds: 5);

  @override
  State<HomeAiOrbCoachMark> createState() => _HomeAiOrbCoachMarkState();
}

class _HomeAiOrbCoachMarkState extends State<HomeAiOrbCoachMark> {
  Timer? _autoDismiss;
  bool _showing = false;
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    _scheduleShow();
  }

  @override
  void didUpdateWidget(covariant HomeAiOrbCoachMark oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.visible && widget.visible) {
      _scheduleShow();
    }
    if (oldWidget.visible && !widget.visible) {
      _hide(immediate: true);
    }
  }

  @override
  void dispose() {
    _autoDismiss?.cancel();
    super.dispose();
  }

  Future<void> _scheduleShow() async {
    if (!widget.visible || _showing) return;
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted || !widget.visible) return;
    if (await HomeAiOrbCoachMarkPrefs.isDismissed()) return;
    if (!mounted) return;

    _autoDismiss?.cancel();
    _autoDismiss = Timer(HomeAiOrbCoachMark.autoDismissDuration, () {
      if (mounted) unawaited(_dismiss());
    });

    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    setState(() {
      _showing = true;
      _opacity = reduceMotion ? 1 : 0;
    });

    if (reduceMotion) return;

    await Future<void>.delayed(Duration.zero);
    if (!mounted || !_showing) return;
    setState(() => _opacity = 1);
  }

  Future<void> _dismiss() async {
    if (!_showing) return;
    _autoDismiss?.cancel();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    if (!reduceMotion && mounted) {
      setState(() => _opacity = 0);
      await Future<void>.delayed(const Duration(milliseconds: 180));
    }

    if (!mounted) return;
    await HomeAiOrbCoachMarkPrefs.dismiss();
    widget.onDismissed?.call();
    setState(() {
      _showing = false;
      _opacity = 0;
    });
  }

  void _hide({required bool immediate}) {
    _autoDismiss?.cancel();
    if (!mounted) return;
    setState(() {
      _showing = false;
      _opacity = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_showing || !widget.visible) return const SizedBox.shrink();

    final title = HomeFloatingAiStrings.t('ai_coach_mark_title', widget.locale);
    final subtitle =
        HomeFloatingAiStrings.t('ai_coach_mark_subtitle', widget.locale);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration =
        reduceMotion ? Duration.zero : const Duration(milliseconds: 220);

    return CompositedTransformFollower(
      link: widget.link,
      showWhenUnlinked: false,
      targetAnchor: Alignment.bottomCenter,
      followerAnchor: Alignment.topRight,
      offset: const Offset(-4, 8),
      child: AnimatedOpacity(
        duration: duration,
        opacity: _opacity,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () => unawaited(_dismiss()),
            behavior: HitTestBehavior.opaque,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: GlassContainer(
                key: const Key('home_ai_orb_coach_mark'),
                borderRadius: AppSpacing.radiusSm,
                glowColor: AppColors.brandFamilyMain,
                glowIntensity: 0.12,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.brandFamilyText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textOnGlassSecondary,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
