import 'package:flutter/material.dart';
import 'package:raabta/core/design/home_grain_tokens.dart';

/// Tiled film grain on the Home page background only — behind content, not over sky.
///
/// Alpha is baked into the PNG; do not wrap in [Opacity].
class HomePageGrainLayer extends StatelessWidget {
  const HomePageGrainLayer({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (!HomeGrainTokens.shouldShowGrain(
      reduceMotion: reduceMotion,
      mediaQuery: mediaQuery,
    )) {
      return const SizedBox.shrink();
    }

    final brightness = Theme.of(context).brightness;
    final assetPath = HomeGrainTokens.assetPathFor(brightness);
    final scale = mediaQuery.devicePixelRatio * HomeGrainTokens.defaultStrength;
    if (scale <= 0) {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(assetPath),
            repeat: ImageRepeat.repeat,
            scale: scale,
            filterQuality: FilterQuality.none,
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}