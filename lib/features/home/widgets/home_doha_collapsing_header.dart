import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/design/raabta_solid_surface_tokens.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/home/data/home_doha_skyline_assets.dart';
import 'package:raabta/features/home/domain/home_doha_scene_palette.dart';
import 'package:raabta/features/home/providers/home_doha_day_part_provider.dart';
import 'package:raabta/features/prayer_mosque/providers/prayer_schedule_providers.dart';
import 'package:raabta/features/home/widgets/home_doha_header_collapse_scope.dart';
import 'package:raabta/features/home/widgets/home_doha_header_choreography.dart';
import 'package:raabta/features/home/widgets/home_doha_living_celestial.dart';
import 'package:raabta/features/home/widgets/home_doha_know_qatar_chip.dart';
import 'package:raabta/features/home/widgets/home_doha_skyline_greeting_row.dart';
import 'package:raabta/features/know_qatar/presentation/l10n/know_qatar_strings.dart';
import 'package:raabta/features/know_qatar/presentation/screens/know_qatar_screen.dart';

typedef HomeDohaHeaderConfig = ({
  String locale,
  String greetingLine,
  String profileInitials,
  bool showGuestProfileIcon,
  String? profilePhotoUrl,
  int notificationCount,
  VoidCallback? onProfileTap,
  VoidCallback? onNotificationTap,
  VoidCallback onDiscoverQatar,
  String profileMenuSemanticsLabel,
  String notificationSemanticsLabel,
  Widget searchRow,
});

class HomeDohaCollapsingHeaderDelegate extends SliverPersistentHeaderDelegate {
  HomeDohaCollapsingHeaderDelegate({
    required this.topSafeInset,
    required this.config,
    required this.dayPartSeed,
  });

  final double topSafeInset;
  final HomeDohaHeaderConfig config;
  final Object dayPartSeed;

  @override
  double get minExtent =>
      topSafeInset + HomeDohaTopZoneMetrics.collapsedBodyHeight;

  @override
  double get maxExtent =>
      topSafeInset + HomeDohaTopZoneMetrics.expandedBodyHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final t = HomeDohaTopZoneMetrics.progressFromShrinkOffset(shrinkOffset);
    return HomeDohaTopZone(
      progress: t,
      topSafeInset: topSafeInset,
      config: config,
    );
  }

  @override
  bool shouldRebuild(covariant HomeDohaCollapsingHeaderDelegate oldDelegate) {
    return oldDelegate.topSafeInset != topSafeInset ||
        oldDelegate.dayPartSeed != dayPartSeed ||
        oldDelegate.config.locale != config.locale ||
        oldDelegate.config.greetingLine != config.greetingLine ||
        oldDelegate.config.notificationCount != config.notificationCount ||
        oldDelegate.config.profileInitials != config.profileInitials ||
        oldDelegate.config.showGuestProfileIcon != config.showGuestProfileIcon ||
        oldDelegate.config.profilePhotoUrl != config.profilePhotoUrl ||
        oldDelegate.config.searchRow != config.searchRow;
  }
}

class HomeDohaTopZone extends ConsumerStatefulWidget {
  const HomeDohaTopZone({
    super.key,
    required this.progress,
    required this.topSafeInset,
    required this.config,
  }) : _layersAvailableOverride = null;

  @visibleForTesting
  const HomeDohaTopZone.test({
    required this.progress,
    required this.topSafeInset,
    required this.config,
    bool? layersAvailable,
  })  : _layersAvailableOverride = layersAvailable,
        super(key: const Key('home_doha_top_zone_test'));

  final double progress;
  final double topSafeInset;
  final HomeDohaHeaderConfig config;
  final bool? _layersAvailableOverride;

  @override
  ConsumerState<HomeDohaTopZone> createState() => _HomeDohaTopZoneState();
}

class _HomeDohaTopZoneState extends ConsumerState<HomeDohaTopZone> {
  bool? _layersAvailable;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _warmAssets());
  }

  Future<void> _warmAssets() async {
    if (!mounted) return;
    final width = MediaQuery.sizeOf(context).width;
    final available = await homeDohaSkylineAssetsAvailable(context);
    if (!mounted) return;
    setState(() => _layersAvailable = available);
    if (available) {
      await precacheHomeDohaSkylineLayers(context, displayWidth: width);
    }
  }

  bool get _layersReady =>
      widget._layersAvailableOverride ?? _layersAvailable ?? true;

  @override
  Widget build(BuildContext context) {
    final dayPartState = ref.watch(homeDohaDayPartProvider);
    final palette = DohaScenePalette.forPart(dayPartState.part);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final t = widget.progress;
    final bodyHeight = HomeDohaTopZoneMetrics.expandedBodyHeight;
    final width = MediaQuery.sizeOf(context).width;

    final greetingOpacity = HomeDohaTopZoneMetrics.greetingOpacity(t);
    final greetingSlide = HomeDohaTopZoneMetrics.greetingSlideY(
      t,
      reduceMotion: reduceMotion,
    );
    final searchTop = widget.topSafeInset +
        HomeDohaTopZoneMetrics.searchRowTopY(t, reduceMotion: reduceMotion);
    final skylineOpacity = HomeDohaTopZoneMetrics.skylineOpacity(t);
    final chipOpacity = HomeDohaTopZoneMetrics.chipOpacity(t);
    final glassOpacity = HomeDohaTopZoneMetrics.glassBarOpacity(t);
    final celestialOpacity = HomeDohaTopZoneMetrics.celestialOpacity(t);

    final layerSpecs = dohaSkylineLayerSpecsForPalette(palette);
    final decodeWidth = skylineDecodeWidthForDisplay(context, width);
    final prayerAnchors = homeDohaPrayerAnchorsFromSchedule(
      ref.read(prayerScheduleStripProvider).schedule,
    );
    final celestialAnchor = HomeDohaTopZoneMetrics.celestialAnchorBesideHomeOrb(
      width: width,
      collapseProgress: t,
      part: dayPartState.part,
      qatarLocalNow: dayPartState.resolvedAt,
      prayerTimes: prayerAnchors,
      topSafeInset: widget.topSafeInset,
    );

    return SizedBox(
      height: widget.topSafeInset + bodyHeight,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        fit: StackFit.expand,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: widget.topSafeInset,
            height: bodyHeight,
            child: RepaintBoundary(
              child: Opacity(
                opacity: skylineOpacity,
                child: Semantics(
                  button: true,
                  label: KnowQatarStrings.t(
                    'kq_screen_title',
                    widget.config.locale,
                  ),
                  child: GestureDetector(
                    onTap: widget.config.onDiscoverQatar,
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      fit: StackFit.expand,
                      children: [
                      HomeDohaSkyGradientBackdrop(
                        palette: palette,
                        width: width,
                        height: bodyHeight,
                      ),
                      if (palette.starOpacity > 0)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: bodyHeight *
                              HomeDohaTopZoneMetrics.starfieldSkyBandFraction,
                          child: Opacity(
                            opacity: palette.starOpacity * skylineOpacity,
                            child: const _DohaStarfield(),
                          ),
                        ),
                      if (_layersReady)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
                            height: bodyHeight * 0.49,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                for (var i = 0; i < layerSpecs.specs.length; i++)
                                  Transform.translate(
                                    offset: Offset(
                                      0,
                                      HomeDohaTopZoneMetrics.layerParallaxY(
                                        t,
                                        switch (i) {
                                          0 =>
                                            HomeDohaTopZoneMetrics.parallaxBackPx,
                                          1 =>
                                            HomeDohaTopZoneMetrics.parallaxMidPx,
                                          2 || 3 =>
                                            HomeDohaTopZoneMetrics.parallaxMidPx,
                                          _ =>
                                            HomeDohaTopZoneMetrics.parallaxFrontPx,
                                        },
                                        reduceMotion: reduceMotion,
                                      ),
                                    ),
                                    child: HomeDohaSkylineTintedLayer(
                                      spec: layerSpecs.specs[i],
                                      width: width,
                                      height: bodyHeight * 0.49,
                                      decodeWidth: decodeWidth,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      Positioned(
                        left: celestialAnchor.dx,
                        top: celestialAnchor.dy,
                        child: Opacity(
                          opacity: celestialOpacity,
                          child: IgnorePointer(
                            child: HomeDohaLivingCelestial(
                              palette: palette,
                              part: dayPartState.part,
                              animationsEnabled: !reduceMotion,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: HomeDohaTopZoneMetrics.skylineHorizonFadeHeight,
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  palette.skyGradientStops.last
                                      .withValues(alpha: 0),
                                  palette.skyGradientStops.last
                                      .withValues(alpha: 0.92),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: widget.topSafeInset + bodyHeight,
            child: IgnorePointer(
              ignoring: glassOpacity <= 0.01,
              child: Opacity(
                opacity: glassOpacity,
                child: _CollapsedGlassBar(
                  useSolidFill: _useSolidBarFill(context),
                  topInset: widget.topSafeInset,
                ),
              ),
            ),
          ),
          if (greetingOpacity > 0)
            Positioned(
              left: 0,
              right: 0,
              top: widget.topSafeInset + HomeDohaTopZoneMetrics.greetingRowTop,
              child: IgnorePointer(
                ignoring: greetingOpacity < 0.05,
                child: Opacity(
                  opacity: greetingOpacity,
                  child: Transform.translate(
                    offset: Offset(0, greetingSlide),
                    child: HomeDohaSkylineGreetingRow(
                      locale: widget.config.locale,
                      greetingLine: widget.config.greetingLine,
                      profileInitials: widget.config.profileInitials,
                      showGuestProfileIcon: widget.config.showGuestProfileIcon,
                      profilePhotoUrl: widget.config.profilePhotoUrl,
                      notificationCount: widget.config.notificationCount,
                      onProfileTap: widget.config.onProfileTap,
                      onNotificationTap: widget.config.onNotificationTap,
                      profileMenuSemanticsLabel:
                          widget.config.profileMenuSemanticsLabel,
                      notificationSemanticsLabel:
                          widget.config.notificationSemanticsLabel,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: AppSpacing.screenHorizontalPadding,
            right: AppSpacing.screenHorizontalPadding,
            top: searchTop,
            child: HomeDohaHeaderCollapseScope(
              progress: t,
              child: widget.config.searchRow,
            ),
          ),
          if (chipOpacity > 0)
            Positioned(
              left: AppSpacing.screenHorizontalPadding,
              bottom: 14,
              child: IgnorePointer(
                ignoring: chipOpacity < 0.05,
                child: Opacity(
                  opacity: chipOpacity,
                  child: HomeDohaKnowQatarChip(
                    locale: widget.config.locale,
                    onTap: widget.config.onDiscoverQatar,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static bool _useSolidBarFill(BuildContext context) {
    if (AppColors.isLight) return true;
    if (MediaQuery.disableAnimationsOf(context)) return true;
    if (!kIsWeb) {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
        case TargetPlatform.macOS:
        case TargetPlatform.windows:
        case TargetPlatform.linux:
          return true;
        default:
          break;
      }
    }
    return false;
  }
}

class _CollapsedGlassBar extends StatelessWidget {
  const _CollapsedGlassBar({
    required this.useSolidFill,
    required this.topInset,
  });

  final bool useSolidFill;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    final themeBrightness = Theme.of(context).brightness;
    final neutral =
        RaabtaSolidSurfaceTokens.fill(RaabtaSolidSurfaceFamily.neutral, themeBrightness);
    final surface = neutral.withValues(
      alpha: HomeDohaTopZoneMetrics.glassBarSurfaceAlpha,
    );
    final bar = DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.glassBorder.withValues(alpha: 0.65),
          ),
        ),
      ),
    );

    if (useSolidFill) {
      return Padding(
        padding: EdgeInsets.only(top: topInset),
        child: bar,
      );
    }

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: HomeDohaTopZoneMetrics.glassBarBlurSigma,
          sigmaY: HomeDohaTopZoneMetrics.glassBarBlurSigma,
        ),
        child: Padding(
          padding: EdgeInsets.only(top: topInset),
          child: bar,
        ),
      ),
    );
  }
}

class _DohaStarfield extends StatelessWidget {
  const _DohaStarfield();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      painter: _StarfieldPainter(),
      size: Size.infinite,
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  const _StarfieldPainter();

  static const _points = <Offset>[
    Offset(0.12, 0.14),
    Offset(0.28, 0.22),
    Offset(0.48, 0.12),
    Offset(0.66, 0.20),
    Offset(0.36, 0.30),
    Offset(0.18, 0.32),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (final p in _points) {
      canvas.drawCircle(
        Offset(p.dx * size.width, p.dy * size.height),
        1.1,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Navigates to Know Qatar from skyline / chip.
void homeDohaOpenKnowQatar(BuildContext context) {
  context.push(KnowQatarScreen.route());
}