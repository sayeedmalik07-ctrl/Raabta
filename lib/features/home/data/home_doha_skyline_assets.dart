import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:raabta/features/home/domain/home_doha_scene_palette.dart';

/// Bundled Doha skyline layer paths (white-filled PNGs, tinted via [BlendMode.srcIn]).
abstract final class HomeDohaSkylineAssets {
  HomeDohaSkylineAssets._();

  static const baseDir = 'assets/images/doha';

  static const layerBack = '$baseDir/layer_back.png';
  static const layerMid = '$baseDir/layer_mid.png';
  static const layerWindows = '$baseDir/layer_windows.png';
  static const layerFront = '$baseDir/layer_front.png';
  static const layerDhow = '$baseDir/layer_dhow.png';

  /// Back-to-front paint order (dhow floats above mid per kit).
  static const List<String> layerAssetPaths = [
    layerBack,
    layerMid,
    layerWindows,
    layerFront,
    layerDhow,
  ];

  /// Decode target width in source pixels (1600px masters).
  static const int masterLayerWidth = 1600;
  static const int masterLayerHeight = 560;
  static const int masterDhowWidth = 480;
  static const int masterDhowHeight = 384;
}

/// Per-layer tint configuration for a rendered frame.
@immutable
class DohaSkylineLayerRenderSpec {
  const DohaSkylineLayerRenderSpec({
    required this.assetPath,
    required this.tint,
    this.opacity = 1,
    this.heightFraction = 1,
    this.alignment = Alignment.bottomCenter,
  });

  final String assetPath;
  final Color tint;
  final double opacity;
  final double heightFraction;
  final Alignment alignment;
}

@immutable
class DohaSkylineLayerSpecs {
  const DohaSkylineLayerSpecs({
    required this.specs,
    required this.allAssetsAvailable,
  });

  final List<DohaSkylineLayerRenderSpec> specs;
  final bool allAssetsAvailable;
}

/// Build tint specs from [DohaScenePalette] (Batch C uses these for the stack).
DohaSkylineLayerSpecs dohaSkylineLayerSpecsForPalette(DohaScenePalette palette) {
  final tints = palette.layerTints;
  final windowTint = const Color(0xFFFFD479).withValues(
    alpha: palette.windowLightOpacity.clamp(0, 1),
  );
  return DohaSkylineLayerSpecs(
    allAssetsAvailable: true,
    specs: [
      DohaSkylineLayerRenderSpec(
        assetPath: HomeDohaSkylineAssets.layerBack,
        tint: tints[0],
      ),
      DohaSkylineLayerRenderSpec(
        assetPath: HomeDohaSkylineAssets.layerMid,
        tint: tints[1],
      ),
      DohaSkylineLayerRenderSpec(
        assetPath: HomeDohaSkylineAssets.layerWindows,
        tint: windowTint,
        opacity: palette.windowLightOpacity,
      ),
      DohaSkylineLayerRenderSpec(
        assetPath: HomeDohaSkylineAssets.layerFront,
        tint: tints[2],
      ),
      DohaSkylineLayerRenderSpec(
        assetPath: HomeDohaSkylineAssets.layerDhow,
        tint: tints[2],
        heightFraction: 0.42,
        alignment: Alignment.bottomLeft,
      ),
    ],
  );
}

/// Returns whether every skyline PNG is in the asset bundle.
Future<bool> homeDohaSkylineAssetsAvailable(BuildContext context) async {
  final bundle = DefaultAssetBundle.of(context);
  for (final path in HomeDohaSkylineAssets.layerAssetPaths) {
    try {
      await bundle.load(path);
    } catch (_) {
      return false;
    }
  }
  return true;
}

/// Precaches skyline layers decoded near [displayWidth] logical pixels.
Future<bool> precacheHomeDohaSkylineLayers(
  BuildContext context, {
  required double displayWidth,
}) async {
  final available = await homeDohaSkylineAssetsAvailable(context);
  if (!available) return false;

  final dpr = MediaQuery.devicePixelRatioOf(context);
  final cacheWidth = (displayWidth * dpr).round().clamp(1, 4096);

  for (final path in HomeDohaSkylineAssets.layerAssetPaths) {
    try {
      final image = AssetImage(path);
      await precacheImage(
        ResizeImage(image, width: cacheWidth),
        context,
      );
    } catch (_) {
      return false;
    }
  }
  return true;
}

int skylineDecodeWidthForDisplay(BuildContext context, double displayWidth) {
  final dpr = MediaQuery.devicePixelRatioOf(context);
  return (displayWidth * dpr).round().clamp(1, 4096);
}

/// One tinted skyline layer — never throws; missing assets render empty.
class HomeDohaSkylineTintedLayer extends StatelessWidget {
  const HomeDohaSkylineTintedLayer({
    super.key,
    required this.spec,
    required this.width,
    required this.height,
    this.decodeWidth,
  });

  final DohaSkylineLayerRenderSpec spec;
  final double width;
  final double height;
  final int? decodeWidth;

  @override
  Widget build(BuildContext context) {
    final layerHeight = height * spec.heightFraction;
    Widget child = Image.asset(
      spec.assetPath,
      width: width,
      height: layerHeight,
      alignment: spec.alignment,
      fit: BoxFit.fitWidth,
      cacheWidth: decodeWidth,
      color: spec.tint,
      colorBlendMode: BlendMode.srcIn,
      errorBuilder: (_, __, ___) => SizedBox(width: width, height: layerHeight),
      filterQuality: FilterQuality.medium,
    );
    if (spec.opacity < 1) {
      child = Opacity(opacity: spec.opacity.clamp(0, 1), child: child);
    }

    return SizedBox(
      width: width,
      height: height,
      child: Align(
        alignment: spec.alignment,
        child: child,
      ),
    );
  }
}

/// Sky gradient fallback when layers are unavailable (D2).
class HomeDohaSkyGradientBackdrop extends StatelessWidget {
  const HomeDohaSkyGradientBackdrop({
    super.key,
    required this.palette,
    required this.width,
    required this.height,
  });

  final DohaScenePalette palette;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final stops = palette.skyGradientStops;
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: stops,
          ),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: height * 0.45,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: palette.topScrimOpacity),
                  Colors.black.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Layer stack or gradient-only fallback — safe when assets are missing.
class HomeDohaSkylineStack extends StatelessWidget {
  const HomeDohaSkylineStack({
    super.key,
    required this.palette,
    required this.width,
    required this.height,
    required this.layersAvailable,
    this.layerSpecs,
    this.decodeWidth,
  });

  final DohaScenePalette palette;
  final double width;
  final double height;
  final bool layersAvailable;
  final DohaSkylineLayerSpecs? layerSpecs;
  final int? decodeWidth;

  @override
  Widget build(BuildContext context) {
    final decode = decodeWidth ?? skylineDecodeWidthForDisplay(context, width);

    if (!layersAvailable) {
      return HomeDohaSkyGradientBackdrop(
        palette: palette,
        width: width,
        height: height,
      );
    }

    final specs =
        layerSpecs ?? dohaSkylineLayerSpecsForPalette(palette);
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          HomeDohaSkyGradientBackdrop(
            palette: palette,
            width: width,
            height: height,
          ),
          for (final spec in specs.specs)
            HomeDohaSkylineTintedLayer(
              spec: spec,
              width: width,
              height: height,
              decodeWidth: decode,
            ),
        ],
      ),
    );
  }
}