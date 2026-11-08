import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../colors/app_colors.dart';

/// Trailing edge fade for horizontal lists — signals more content off-screen.
class HorizontalScrollFade extends StatefulWidget {
  const HorizontalScrollFade({
    super.key,
    required this.height,
    required this.builder,
    this.fadeWidth = 28,
    this.playScrollHintOnce = false,
    this.scrollHintPrefsKey,
  });

  final double height;
  final double fadeWidth;
  final bool playScrollHintOnce;
  final String? scrollHintPrefsKey;
  final Widget Function(ScrollController controller) builder;

  @override
  State<HorizontalScrollFade> createState() => _HorizontalScrollFadeState();
}

class _HorizontalScrollFadeState extends State<HorizontalScrollFade> {
  late final ScrollController _controller;
  bool _showEndFade = false;
  bool _hintScheduled = false;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()..addListener(_syncFade);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncFade();
      _maybePlayScrollHint();
    });
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_syncFade)
      ..dispose();
    super.dispose();
  }

  void _syncFade() {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    final canScroll = position.maxScrollExtent > 0;
    final show = canScroll && _controller.offset < position.maxScrollExtent - 4;
    if (show != _showEndFade && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || show == _showEndFade) return;
        setState(() => _showEndFade = show);
      });
    }
  }

  Future<void> _maybePlayScrollHint() async {
    if (!mounted) return;
    if (MediaQuery.disableAnimationsOf(context)) return;

    if (!widget.playScrollHintOnce ||
        widget.scrollHintPrefsKey == null ||
        _hintScheduled ||
        !_controller.hasClients) {
      return;
    }
    if (_controller.position.maxScrollExtent <= 0) return;

    _hintScheduled = true;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(widget.scrollHintPrefsKey!) ?? false) return;
    if (!mounted) return;

    await _controller.animateTo(
      28,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
    if (!mounted) return;
    await _controller.animateTo(
      0,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInCubic,
    );
    await prefs.setBool(widget.scrollHintPrefsKey!, true);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.builder(_controller),
          if (_showEndFade)
            PositionedDirectional(
              end: 0,
              top: 0,
              bottom: 0,
              child: SizedBox(
                width: widget.fadeWidth,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: AlignmentDirectional.centerStart,
                        end: AlignmentDirectional.centerEnd,
                        colors: [
                          AppColors.background.withValues(alpha: 0),
                          AppColors.background.withValues(alpha: 0.92),
                        ],
                      ),
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
