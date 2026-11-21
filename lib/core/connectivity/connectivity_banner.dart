import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/connectivity/connectivity_provider.dart';
import 'package:raabta/core/connectivity/connectivity_status.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

/// App-wide connectivity banner — mounted once at the root shell.
class ConnectivityBanner extends ConsumerStatefulWidget {
  const ConnectivityBanner({super.key});

  static const _animationDuration = Duration(milliseconds: 220);

  @override
  ConsumerState<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends ConsumerState<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathController;
  late final Animation<double> _breathScale;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _breathScale = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(connectivityStatusProvider);
    final dismissed = ref.watch(connectivityBannerDismissedProvider);
    final topPadding = MediaQuery.paddingOf(context).top;

    if (status == ConnectivityStatus.online) {
      return const SizedBox.shrink();
    }

    if (status == ConnectivityStatus.slow) {
      return _SlowIndicator(topPadding: topPadding);
    }

    if (dismissed) {
      return const SizedBox.shrink();
    }

    final copy = _copyFor(status);

    return AnimatedSize(
      duration: ConnectivityBanner._animationDuration,
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: topPadding),
          Dismissible(
            key: ValueKey(
              'connectivity_banner_${ref.watch(connectivityBannerInstanceProvider)}',
            ),
            direction: DismissDirection.up,
            onDismissed: (_) {
              ref
                  .read(connectivityStatusProvider.notifier)
                  .dismissCurrentBanner();
            },
            child: _FullBanner(
              primaryLine: copy.primary,
              secondaryLine: copy.secondary,
              breathScale: _breathScale,
            ),
          ),
        ],
      ),
    );
  }

  _BannerCopy _copyFor(ConnectivityStatus status) {
    return switch (status) {
      ConnectivityStatus.offline => const _BannerCopy(
          primary: "You're offline — Raabta is still here",
          secondary:
              "Showing saved data. We'll sync when you're back.",
        ),
      ConnectivityStatus.reconnecting => const _BannerCopy(
          primary: 'Back online — syncing…',
          secondary: null,
        ),
      _ => const _BannerCopy(primary: '', secondary: null),
    };
  }
}

class _BannerCopy {
  const _BannerCopy({required this.primary, this.secondary});

  final String primary;
  final String? secondary;
}

class _FullBanner extends StatefulWidget {
  const _FullBanner({
    required this.primaryLine,
    required this.secondaryLine,
    required this.breathScale,
  });

  final String primaryLine;
  final String? secondaryLine;
  final Animation<double> breathScale;

  static const _expandAnimationDuration = Duration(milliseconds: 180);
  static const _autoCollapseDelay = Duration(milliseconds: 4500);
  static const _minTapHeight = 32.0;
  static const _collapsedIconSize = 14.0;
  static const _collapsedVerticalInset = 5.0;

  @override
  State<_FullBanner> createState() => _FullBannerState();
}

class _FullBannerState extends State<_FullBanner> {
  bool _expanded = false;
  Timer? _autoCollapseTimer;

  bool get _expandable => widget.secondaryLine != null;

  @override
  void dispose() {
    _autoCollapseTimer?.cancel();
    super.dispose();
  }

  void _collapse() {
    _autoCollapseTimer?.cancel();
    if (!_expanded) return;
    setState(() => _expanded = false);
  }

  void _toggleExpanded() {
    if (!_expandable) return;

    if (_expanded) {
      _collapse();
      return;
    }

    setState(() => _expanded = true);
    _autoCollapseTimer?.cancel();
    _autoCollapseTimer = Timer(_FullBanner._autoCollapseDelay, () {
      if (mounted) _collapse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryStyle = AppTypography.chipLabel.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
      height: 1.15,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        0,
        AppSpacing.sm,
        AppSpacing.xxs,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _expandable ? _toggleExpanded : null,
          splashColor: AppColors.sharePurple.withValues(alpha: 0.08),
          highlightColor: AppColors.sharePurple.withValues(alpha: 0.04),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: _FullBanner._minTapHeight,
            ),
            child: Align(
              alignment: Alignment.center,
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: _FullBanner._collapsedVerticalInset,
                ),
                borderRadius: AppSpacing.radiusMd,
                glowColor: AppColors.sharePurple,
                glowIntensity: 0.25,
                backgroundColor: AppColors.glassSurface,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: widget.breathScale,
                      child: Icon(
                        Icons.wifi_off_rounded,
                        color: AppColors.accentGold,
                        size: _FullBanner._collapsedIconSize,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.primaryLine,
                            style: primaryStyle,
                            maxLines: _expanded ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_expandable)
                            AnimatedSize(
                              duration: _FullBanner._expandAnimationDuration,
                              curve: Curves.easeOutCubic,
                              alignment: Alignment.topLeft,
                              child: AnimatedOpacity(
                                duration: _FullBanner._expandAnimationDuration,
                                opacity: _expanded ? 1 : 0,
                                child: _expanded
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          widget.secondaryLine!,
                                          style: AppTypography.chipLabel.copyWith(
                                            color: AppColors.textSecondary
                                                .withValues(alpha: 0.85),
                                            fontWeight: FontWeight.w500,
                                            height: 1.25,
                                          ),
                                        ),
                                      )
                                    : const SizedBox(width: double.infinity),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_expandable) ...[
                      const SizedBox(width: AppSpacing.xxs),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: _FullBanner._expandAnimationDuration,
                        curve: Curves.easeOutCubic,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: AppSpacing.iconSm,
                          color: AppColors.textSecondary.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
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

class _SlowIndicator extends StatefulWidget {
  const _SlowIndicator({required this.topPadding});

  final double topPadding;

  @override
  State<_SlowIndicator> createState() => _SlowIndicatorState();
}

class _SlowIndicatorState extends State<_SlowIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: ConnectivityBanner._animationDuration,
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: widget.topPadding),
          SizedBox(
            height: 20,
            child: Center(
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.45, end: 1).animate(_pulse),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.warning,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.warning.withValues(alpha: 0.45),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Root wrapper — keeps the provider alive and reflows content below the banner.
class ConnectivityScope extends ConsumerWidget {
  const ConnectivityScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(connectivityStatusProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ConnectivityBanner(),
        Expanded(child: child),
      ],
    );
  }
}
