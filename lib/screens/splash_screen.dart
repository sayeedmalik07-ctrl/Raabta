import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raabta/core/background/animated_aurora_background.dart';
import 'package:raabta/core/router/app_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/admin/services/app_startup_guard.dart';
import 'package:raabta/services/auth/auth_session_service.dart';
import 'package:raabta/services/auth/splash_navigation.dart';
import 'package:raabta/screens/language_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// When true, splash branding renders without startup navigation (tests only).
  @visibleForTesting
  static bool skipNavigationForTests = false;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _sequenceController;
  late final AnimationController _glowController;
  late final AnimationController _orbController;
  late final AnimationController _shimmerController;

  late final Animation<double> _backdropOpacity;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _glowPulse;
  late final Animation<double> _glowOpacity;

  double _initProgress = 0;
  double _screenOpacity = 1;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    if (!SplashScreen.skipNavigationForTests) {
      _navigateAfterDelay();
    }
  }

  void _initAnimations() {
    _sequenceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _backdropOpacity = CurvedAnimation(
      parent: _sequenceController,
      curve: const Interval(0, 0.2, curve: Curves.easeOut),
    );

    _logoOpacity = CurvedAnimation(
      parent: _sequenceController,
      curve: const Interval(0.15, 0.55, curve: Curves.easeOutCubic),
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _sequenceController,
        curve: const Interval(0.15, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _taglineOpacity = CurvedAnimation(
      parent: _sequenceController,
      curve: const Interval(0.45, 0.75, curve: Curves.easeOut),
    );

    _glowPulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _glowOpacity = Tween<double>(begin: 0.15, end: 0.25).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _sequenceController.forward();
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _shimmerController.forward();
    });
  }

  void _setInitProgress(double value) {
    if (!mounted) return;
    setState(() => _initProgress = value.clamp(0, 1));
  }

  Future<void> _fadeOutAndGo(String nextLocation) async {
    if (!mounted) return;
    appRouter.go(nextLocation);
  }

  Future<void> _navigateAfterDelay() async {
    _setInitProgress(0.08);
    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    _setInitProgress(0.45);
    // Wait for Firebase to restore persisted auth before startup checks.
    await AuthSessionService.instance.waitForInitialAuthState();
    if (!mounted) return;

    final startup = await AppStartupGuard.check();
    if (!mounted) return;

    _setInitProgress(0.72);

    switch (startup) {
      case StartupResult.maintenance:
        _setInitProgress(1);
        await _fadeOutAndGo('/maintenance');
        return;
      case StartupResult.forceUpdate:
        _setInitProgress(1);
        await _fadeOutAndGo('/force-update');
        return;
      case StartupResult.suspended:
        _setInitProgress(1);
        await _fadeOutAndGo('/suspended');
        return;
      case StartupResult.ok:
        break;
    }

    var nextLocation = resolvePostSplashRoute(languageSaved: false);

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(LanguageScreen.languageKey);
      if (savedLanguage != null) {
        nextLocation = resolvePostSplashRoute(languageSaved: true);
      }
    } catch (e) {
      debugPrint('SharedPreferences unavailable, going to LanguageScreen: $e');
    }

    _setInitProgress(1);
    await _fadeOutAndGo(nextLocation);
  }

  @override
  void dispose() {
    _sequenceController.dispose();
    _glowController.dispose();
    _orbController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.sizeOf(context).height * 0.28;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: AnimatedOpacity(
        opacity: _screenOpacity,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        child: AnimatedAuroraBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              fit: StackFit.expand,
              children: [
                FadeTransition(
                  opacity: _backdropOpacity,
                  child: RepaintBoundary(
                    child: _DriftingOrbs(animation: _orbController),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      const Spacer(flex: 3),
                      _buildLogoCluster(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildWordmark(),
                      const SizedBox(height: AppSpacing.sm),
                      FadeTransition(
                        opacity: _taglineOpacity,
                        child: Text(
                          'Your Qatar Connection',
                          style: AppTypography.subtitle.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const Spacer(flex: 2),
                      Padding(
                        padding: EdgeInsets.only(bottom: bottomInset),
                        child: _GradientProgressBar(progress: _initProgress),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoCluster() {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowController, _sequenceController]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _logoOpacity,
          child: Transform.scale(
            scale: _logoScale.value,
            child: SizedBox(
              width: 132,
              height: 132,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    scale: _glowPulse.value,
                    child: Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.accentGold
                                .withValues(alpha: _glowOpacity.value),
                            AppColors.accentGold.withValues(alpha: 0),
                          ],
                          stops: const [0.2, 1],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.sharePurple.withValues(alpha: 0.35),
                          AppColors.cyanGlow.withValues(alpha: 0.2),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.glassBorderBright,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyanGlow.withValues(alpha: 0.18),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🌙', style: TextStyle(fontSize: 42)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWordmark() {
    return FadeTransition(
      opacity: _logoOpacity,
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          final shimmer = _shimmerController.value;
          return Column(
            children: [
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment(-1.2 + (shimmer * 2.4), -0.4),
                    end: Alignment(-0.2 + (shimmer * 2.4), 0.4),
                    colors: [
                      AppColors.textPrimary,
                      AppColors.accentGold,
                      AppColors.textPrimary,
                    ],
                    stops: const [0.35, 0.5, 0.65],
                  ).createShader(bounds);
                },
                child: Text(
                  'Raabta',
                  style: AppTypography.display.copyWith(fontSize: 48),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'رابطہ',
                style: AppTypography.subtitle.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 2,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DriftingOrbs extends StatelessWidget {
  const _DriftingOrbs({required this.animation});

  final Animation<double> animation;

  static const _orbSpecs = [
    _OrbSpec(
      color: AppColors.cyanGlow,
      size: 56,
      start: Offset(0.12, 0.18),
      delta: Offset(0.04, 0.06),
      opacity: 0.08,
    ),
    _OrbSpec(
      color: AppColors.sharePurple,
      size: 72,
      start: Offset(0.78, 0.14),
      delta: Offset(-0.05, 0.04),
      opacity: 0.07,
    ),
    _OrbSpec(
      color: AppColors.purpleGlow,
      size: 48,
      start: Offset(0.22, 0.72),
      delta: Offset(0.03, -0.05),
      opacity: 0.06,
    ),
    _OrbSpec(
      color: AppColors.iceCyanGlow,
      size: 40,
      start: Offset(0.84, 0.68),
      delta: Offset(-0.04, -0.03),
      opacity: 0.07,
    ),
    _OrbSpec(
      color: AppColors.cyanGlow,
      size: 32,
      start: Offset(0.5, 0.32),
      delta: Offset(0.02, 0.04),
      opacity: 0.05,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        return LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                for (final spec in _orbSpecs)
                  Positioned(
                    left: constraints.maxWidth *
                        (spec.start.dx +
                            spec.delta.dx * _wave(t, spec.start.dx)),
                    top: constraints.maxHeight *
                        (spec.start.dy +
                            spec.delta.dy * _wave(t, spec.start.dy)),
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        width: spec.size,
                        height: spec.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: spec.color.withValues(alpha: spec.opacity),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  double _wave(double t, double seed) {
    return (t + seed).remainder(1) * 2 - 1;
  }
}

class _OrbSpec {
  const _OrbSpec({
    required this.color,
    required this.size,
    required this.start,
    required this.delta,
    required this.opacity,
  });

  final Color color;
  final double size;
  final Offset start;
  final Offset delta;
  final double opacity;
}

class _GradientProgressBar extends StatelessWidget {
  const _GradientProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox(
              height: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: AppColors.glassSurface),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.clamp(0.04, 1),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.cyanGlow,
                            AppColors.accentGold,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cyanGlow.withValues(alpha: 0.35),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
