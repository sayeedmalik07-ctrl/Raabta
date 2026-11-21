import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:raabta/core/design/raabta_tactile_button_tokens.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

/// Primary solid CTA — materiality tactile recipe (Today hero, profile popover).
class HomeBrandPrimaryButton extends StatefulWidget {
  const HomeBrandPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  State<HomeBrandPrimaryButton> createState() => _HomeBrandPrimaryButtonState();
}

class _HomeBrandPrimaryButtonState extends State<HomeBrandPrimaryButton> {
  bool _pressed = false;

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  void _onTapDown(TapDownDetails _) {
    HapticFeedback.lightImpact();
    setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    widget.onPressed();
    setState(() => _pressed = false);
  }

  void _onTapCancel() {
    if (_pressed) setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final radius = AppSpacing.radiusFull;
    final decoration = RaabtaTactileButtonTokens.shapeDecoration(
      brightness: brightness,
      radius: radius,
    );

    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: RaabtaTactileButtonTokens.pressScale(
            _pressed,
            reduceMotion: _reduceMotion,
          ),
          duration: _pressed ? Duration.zero : const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: Transform.translate(
            offset: RaabtaTactileButtonTokens.pressTranslation(
              _pressed,
              reduceMotion: _reduceMotion,
            ),
            child: DecoratedBox(
              decoration: decoration,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Text(
                      widget.label,
                      style: AppTypography.button.copyWith(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}