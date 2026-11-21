import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';

/// Blinking block cursor shown while assistant text streams in.
class AiStreamingCursor extends StatefulWidget {
  const AiStreamingCursor({super.key});

  @override
  State<AiStreamingCursor> createState() => _AiStreamingCursorState();
}

class _AiStreamingCursorState extends State<AiStreamingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 8,
        height: 16,
        margin: const EdgeInsets.only(left: 2),
        decoration: BoxDecoration(
          color: AppColors.cyanGlow,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
