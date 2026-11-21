import 'package:flutter/material.dart';

/// Defers building below-fold Home content until after the first frame so
/// identity, search, today, and score paint without waiting on lower sections.
class HomeLazySection extends StatefulWidget {
  const HomeLazySection({
    super.key,
    required this.builder,
    this.frameDelay = Duration.zero,
  });

  final WidgetBuilder builder;
  final Duration frameDelay;

  @override
  State<HomeLazySection> createState() => _HomeLazySectionState();
}

class _HomeLazySectionState extends State<HomeLazySection> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    if (widget.frameDelay == Duration.zero) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _ready = true);
      });
    } else {
      Future<void>.delayed(widget.frameDelay, () {
        if (mounted) setState(() => _ready = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const SizedBox.shrink();
    return RepaintBoundary(child: widget.builder(context));
  }
}
