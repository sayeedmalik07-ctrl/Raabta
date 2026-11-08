import 'dart:async';

import 'package:flutter/material.dart';

/// Lightweight chip entrance — implicit animation, no per-chip [AnimationController].
class HomeChipEntrance extends StatefulWidget {
  const HomeChipEntrance({
    super.key,
    required this.child,
    this.delayMs = 0,
    this.enabled = true,
  });

  final Widget child;
  final int delayMs;
  final bool enabled;

  static const _duration = Duration(milliseconds: 320);

  @override
  State<HomeChipEntrance> createState() => _HomeChipEntranceState();
}

class _HomeChipEntranceState extends State<HomeChipEntrance> {
  bool _visible = false;
  bool _configured = false;
  Timer? _delayTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_configured) return;
    _configured = true;

    if (!widget.enabled || MediaQuery.disableAnimationsOf(context)) {
      _visible = true;
      return;
    }

    _delayTimer = Timer(Duration(milliseconds: widget.delayMs), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || MediaQuery.disableAnimationsOf(context)) {
      return widget.child;
    }

    return AnimatedOpacity(
      duration: HomeChipEntrance._duration,
      curve: Curves.easeOutCubic,
      opacity: _visible ? 1 : 0,
      child: AnimatedSlide(
        duration: HomeChipEntrance._duration,
        curve: Curves.easeOutCubic,
        offset: _visible ? Offset.zero : const Offset(0, 0.04),
        child: widget.child,
      ),
    );
  }
}
