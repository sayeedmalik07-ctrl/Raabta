import 'package:flutter/material.dart';

import 'package:raabta/core/background/animated_aurora_background.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

/// Standard premium screen shell with aurora background and optional app bar.
class GlassScreenScaffold extends StatelessWidget {
  const GlassScreenScaffold({
    super.key,
    required this.body,
    this.title,
    this.leading,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.padding,
    this.extendBodyBehindAppBar = false,
    this.safeArea = true,
    this.enableBackgroundAnimation = true,
    this.titleStyle,
  });

  final Widget body;
  final String? title;
  final TextStyle? titleStyle;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final EdgeInsetsGeometry? padding;
  final bool extendBodyBehindAppBar;
  final bool safeArea;
  final bool enableBackgroundAnimation;

  @override
  Widget build(BuildContext context) {
    final content = padding == null
        ? body
        : Padding(padding: padding!, child: body);

    return AnimatedAuroraBackground(
      enableAnimation: enableBackgroundAnimation,
      ignoreSafeArea: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        appBar: title == null
            ? null
            : AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: leading,
                actions: actions,
                title: Text(
                  title!,
                  style: titleStyle ?? AppTypography.headline2,
                ),
                centerTitle: false,
              ),
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
        body: safeArea ? SafeArea(child: content) : content,
      ),
    );
  }
}

/// Glass-styled top bar action button (back, close, etc.).
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: GlassContainer(
        onTap: onPressed,
        borderRadius: AppSpacing.radiusSm,
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Icon(icon, size: AppSpacing.iconSm, color: AppColors.textSecondary),
      ),
    );
  }
}

/// Kit 40×40 glass control with 14 dp corner radius (AI chat header).
class GlassBarControl extends StatelessWidget {
  const GlassBarControl({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  static const double size = 40;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: SizedBox(
        width: size,
        height: size,
        child: GlassContainer(
          onTap: onPressed,
          borderRadius: AppSpacing.radiusBarControl,
          padding: EdgeInsets.zero,
          child: Center(
            child: Icon(
              icon,
              size: AppSpacing.iconMd,
              color: AppColors.textOnGlassSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
