import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/router/ai_chat_entrance_orb.dart';

/// Full-screen `/ai-chat` entrance from the Home sparkle orb (scrim, no blur).
CustomTransitionPage<void> buildAiChatLivingEntrancePage({
  required GoRouterState state,
  required Widget child,
  Rect? entranceOrbRect,
}) {
  const enterDuration = Duration(milliseconds: 380);
  const exitDuration = Duration(milliseconds: 280);

  return CustomTransitionPage<void>(
    key: state.pageKey,
    opaque: false,
    barrierColor: Colors.transparent,
    transitionDuration: enterDuration,
    reverseTransitionDuration: exitDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final reduceMotion = MediaQuery.disableAnimationsOf(context);
      final curved = CurvedAnimation(
        parent: animation,
        curve: reduceMotion ? Curves.easeOut : Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      );

      final scrimOpacity = Tween<double>(begin: 0, end: 0.75).animate(curved);

      final content = reduceMotion
          ? FadeTransition(opacity: curved, child: child)
          : SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(curved),
              child: FadeTransition(opacity: curved, child: child),
            );

      return Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: scrimOpacity,
            builder: (context, _) {
              return ColoredBox(
                color: AppColors.background.withValues(
                  alpha: scrimOpacity.value,
                ),
              );
            },
          ),
          if (!reduceMotion)
            AnimatedBuilder(
              animation: curved,
              builder: (context, _) {
                final t = curved.value;
                return IgnorePointer(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(0.88, -0.78),
                            radius: 0.95,
                            colors: [
                              AppColors.purpleGlow.withValues(
                                alpha: 0.22 * t,
                              ),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(-0.9, 0.92),
                            radius: 0.85,
                            colors: [
                              AppColors.blueGlow.withValues(alpha: 0.1 * t),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      CustomPaint(
                        painter: _EntranceRipplePainter(
                          progress: t,
                          origin: entranceOrbRect?.center ??
                              AiChatFlyingEntranceOrb.defaultSourceCenter(
                                MediaQuery.sizeOf(context),
                              ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          if (!reduceMotion)
            LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedBuilder(
                  animation: curved,
                  builder: (context, _) {
                    return AiChatFlyingEntranceOrb(
                      progress: curved.value,
                      screenSize: constraints.biggest,
                      sourceRect: entranceOrbRect,
                    );
                  },
                );
              },
            ),
          content,
        ],
      );
    },
    child: child,
  );
}

class _EntranceRipplePainter extends CustomPainter {
  _EntranceRipplePainter({
    required this.progress,
    required this.origin,
  });

  final double progress;
  final Offset origin;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    for (var i = 0; i < 4; i++) {
      final ringT = (progress - i * 0.08).clamp(0.0, 1.0);
      if (ringT <= 0) continue;
      final radius = size.width * (0.12 + ringT * 0.38);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColors.purpleGlow.withValues(
          alpha: (1 - ringT) * 0.35,
        );
      canvas.drawCircle(origin, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EntranceRipplePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.origin != origin;
  }
}

/// Staggered fade/slide for AI chat empty-state sections (40 to 60 ms steps).
class AiChatLivingEntranceStagger extends StatelessWidget {
  const AiChatLivingEntranceStagger({
    super.key,
    required this.index,
    required this.progress,
    required this.child,
  });

  final int index;
  final Animation<double> progress;
  final Widget child;

  static const _staggerMs = 50;
  static const _fadeWindowMs = 220;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      return FadeTransition(
        opacity: progress,
        child: child,
      );
    }

    final delayMs = index == 0 ? 280 : index * _staggerMs;
    final delay = delayMs / 420.0;
    final fadeStart = delay;
    final fadeEnd = delay + (_fadeWindowMs / 420.0);

    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final t = progress.value;
        final opacity = ((t - fadeStart) / (fadeEnd - fadeStart)).clamp(0.0, 1.0);
        final slide = (1 - opacity) * 12;
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, slide),
            child: child,
          ),
        );
      },
    );
  }
}

/// Drives staggered empty-state reveal after living entrance.
class AiChatLivingEntranceHost extends StatefulWidget {
  const AiChatLivingEntranceHost({
    super.key,
    required this.enabled,
    required this.builder,
  });

  final bool enabled;
  final Widget Function(BuildContext context, Animation<double> progress) builder;

  @override
  State<AiChatLivingEntranceHost> createState() =>
      _AiChatLivingEntranceHostState();
}

class _AiChatLivingEntranceHostState extends State<AiChatLivingEntranceHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    if (widget.enabled) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant AiChatLivingEntranceHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && _controller.value < 1) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.builder(context, const AlwaysStoppedAnimation<double>(1));
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => widget.builder(context, _controller),
    );
  }
}
