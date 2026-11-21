import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/home/utils/home_ai_assistant_launcher.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/design/raabta_tactile_button_tokens.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/raabta_orb.dart';
import 'package:raabta/core/widgets/raabta_orb_kit_sizes.dart';
import 'package:raabta/core/widgets/raabta_orb_sparkle_glyph.dart';
import 'package:raabta/core/widgets/raabta_orb_state.dart';
import 'package:raabta/features/home/l10n/home_floating_ai_strings.dart';
import 'package:raabta/features/home/utils/home_ai_chip_hint_order.dart';
import 'package:raabta/features/know_qatar/data/models/know_qatar_persona.dart';
import 'package:raabta/features/know_qatar/providers/know_qatar_providers.dart';

/// Inline and sticky Home search-row orbs (separate instances, one layer leader).
class HomeAiSearchOrbs {
  const HomeAiSearchOrbs({this.inline, this.sticky});

  final Widget? inline;
  final Widget? sticky;

  bool get hasOrb => inline != null || sticky != null;
}

/// Hosts the Home AI search-adjacent orb (inline + sticky search rows).
class HomeAiAssistantHost extends ConsumerWidget {
  const HomeAiAssistantHost({
    super.key,
    required this.locale,
    required this.active,
    required this.showProactiveDot,
    required this.child,
    this.orbLayerLink,
    this.linkLeaderOnStickyRow = false,
    this.onAssistantOpening,
  });

  final String locale;
  final bool active;
  final bool showProactiveDot;
  final LayerLink? orbLayerLink;
  /// When true, [orbLayerLink] attaches to the sticky-row orb only.
  final bool linkLeaderOnStickyRow;
  final VoidCallback? onAssistantOpening;
  final Widget Function(BuildContext context, HomeAiSearchOrbs orbs) child;

  /// Design kit v2.1 AI orb (§10 / `.orb`).
  static const aiOrbSize = RaabtaOrbKitSizes.homeSparkle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!active) {
      return child(context, const HomeAiSearchOrbs());
    }

    final persona = ref.watch(knowQatarPersonaProvider);
    final motionEnabled = active &&
        (ModalRoute.of(context)?.isCurrent ?? true) &&
        TickerMode.of(context);
    final attachLinkToSticky =
        orbLayerLink != null && linkLeaderOnStickyRow;
    final attachLinkToInline =
        orbLayerLink != null && !linkLeaderOnStickyRow;

    final orbs = HomeAiSearchOrbs(
      inline: HomeAliveAiOrb(
        key: const ValueKey('home_ai_orb_inline_slot'),
        gestureKey: const Key('home_ai_orb_inline'),
        locale: locale,
        persona: persona,
        showProactiveDot: showProactiveDot,
        animationsEnabled: motionEnabled,
        layerLink: attachLinkToInline ? orbLayerLink : null,
        onAssistantOpening: onAssistantOpening,
      ),
      sticky: HomeAliveAiOrb(
        key: const ValueKey('home_ai_orb_sticky_slot'),
        gestureKey: const Key('home_ai_orb_sticky'),
        locale: locale,
        persona: persona,
        showProactiveDot: showProactiveDot,
        animationsEnabled: motionEnabled,
        layerLink: attachLinkToSticky ? orbLayerLink : null,
        onAssistantOpening: onAssistantOpening,
      ),
    );

    return child(context, orbs);
  }
}

/// Circular Home AI entry — hints rotate for chat prefill only (not shown on orb).
class HomeAliveAiOrb extends StatefulWidget {
  const HomeAliveAiOrb({
    super.key,
    required this.locale,
    required this.persona,
    required this.showProactiveDot,
    required this.animationsEnabled,
    this.gestureKey = const Key('home_floating_ai_orb'),
    this.layerLink,
    this.onAssistantOpening,
  });

  final String locale;
  final KnowQatarPersona persona;
  final bool showProactiveDot;
  final bool animationsEnabled;
  final Key gestureKey;
  final LayerLink? layerLink;
  final VoidCallback? onAssistantOpening;

  @override
  State<HomeAliveAiOrb> createState() => _HomeAliveAiOrbState();
}

class _HomeAliveAiOrbState extends State<HomeAliveAiOrb> {
  static const _hintInterval = Duration(seconds: 4);

  Timer? _hintTimer;
  int _hintIndex = 0;
  List<String> _hintKeys = HomeAiChipHintKeys.all;
  bool _pressing = false;
  final _launchBoundsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _hintKeys = HomeAiChipHintOrder.forPersona(widget.persona);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncHintTimer();
  }

  @override
  void didUpdateWidget(covariant HomeAliveAiOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.persona != widget.persona ||
        oldWidget.locale != widget.locale) {
      _hintKeys = HomeAiChipHintOrder.forPersona(widget.persona);
      _hintIndex = 0;
    }
    if (oldWidget.animationsEnabled != widget.animationsEnabled) {
      _syncHintTimer();
    }
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    super.dispose();
  }

  bool get _reduceMotion =>
      MediaQuery.disableAnimationsOf(context) || !widget.animationsEnabled;

  void _syncHintTimer() {
    _hintTimer?.cancel();
    if (_reduceMotion) return;
    _hintTimer = Timer.periodic(_hintInterval, (_) {
      if (!mounted || _reduceMotion) return;
      setState(() {
        _hintIndex = (_hintIndex + 1) % _hintKeys.length;
      });
    });
  }

  String get _currentHint =>
      HomeFloatingAiStrings.t(_hintKeys[_hintIndex], widget.locale);

  void _onTapDown(TapDownDetails _) {
    setState(() => _pressing = true);
  }

  void _onTapUp(TapUpDetails _) {
    _openAssistant();
  }

  void _onTapCancel() {
    if (_pressing) setState(() => _pressing = false);
  }

  void _openAssistant() {
    if (!mounted) return;
    setState(() => _pressing = false);
    widget.onAssistantOpening?.call();
    Rect? sourceRect;
    final boundsBox = _launchBoundsKey.currentContext?.findRenderObject();
    if (boundsBox is RenderBox && boundsBox.hasSize) {
      final topLeft = boundsBox.localToGlobal(Offset.zero);
      sourceRect = topLeft & boundsBox.size;
    }
    final launched = HomeAiAssistantLauncher.open(
      context,
      query: _currentHint,
      autoSendInitialMessage: false,
      entranceSourceRect: sourceRect,
    );
    if (!launched && mounted) setState(() => _pressing = false);
  }

  @override
  Widget build(BuildContext context) {
    final semanticsLabel =
        HomeFloatingAiStrings.t('ask_raabta', widget.locale);
    final longPressTooltip = HomeFloatingAiStrings.t(
      'ai_orb_long_press_tooltip',
      widget.locale,
    );
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final scale = reduceMotion
        ? 1.0
        : RaabtaTactileButtonTokens.pressScale(_pressing);
    final pressOffset = RaabtaTactileButtonTokens.pressTranslation(
      _pressing,
      reduceMotion: reduceMotion,
    );
    final brightness = Theme.of(context).brightness;
    final pressDuration =
        _pressing ? Duration.zero : AppSpacing.tapAnimation;
    final pressCurve =
        _pressing ? Curves.linear : Curves.easeOutBack;

    final orb = RepaintBoundary(
      child: SizedBox(
        key: _launchBoundsKey,
        width: HomeAiAssistantHost.aiOrbSize,
        height: HomeAiAssistantHost.aiOrbSize,
        child: GestureDetector(
          key: widget.gestureKey,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          behavior: HitTestBehavior.opaque,
          child: OverflowBox(
            minWidth: HomeAiAssistantHost.aiOrbSize,
            maxWidth: HomeAiAssistantHost.aiOrbSize * 1.26,
            minHeight: HomeAiAssistantHost.aiOrbSize,
            maxHeight: HomeAiAssistantHost.aiOrbSize * 1.26,
            child: Transform.translate(
              offset: pressOffset,
              child: AnimatedScale(
                scale: scale,
                duration: pressDuration,
                curve: pressCurve,
                child: DecoratedBox(
                  decoration: RaabtaTactileButtonTokens.circleDecoration(
                    brightness: brightness,
                  ),
                  child: SizedBox(
                    width: HomeAiAssistantHost.aiOrbSize,
                    height: HomeAiAssistantHost.aiOrbSize,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        RaabtaOrb(
                          state: RaabtaOrbState.idle,
                          size: HomeAiAssistantHost.aiOrbSize,
                          animationsEnabled: widget.animationsEnabled,
                          idleVisualsOnly: false,
                          tactileMateriality: true,
                        ),
                        IgnorePointer(
                          child: RaabtaOrbSparkleGlyph(
                            size: HomeAiAssistantHost.aiOrbSize * 0.42,
                          ),
                        ),
                        if (widget.showProactiveDot)
                          Positioned(
                            top: 2,
                            right: 2,
                            child: Container(
                              key: const Key('home_ai_proactive_badge'),
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.warning,
                                border: Border.all(
                                  color: AppColors.background,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.warning.withValues(alpha: 0.45),
                                    blurRadius: 4,
                                  ),
                                ],
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
        ),
      ),
    );

    final linkedOrb = widget.layerLink != null
        ? CompositedTransformTarget(
            link: widget.layerLink!,
            child: orb,
          )
        : orb;

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Tooltip(
        triggerMode: TooltipTriggerMode.longPress,
        message: longPressTooltip,
        child: linkedOrb,
      ),
    );
  }
}

/// @deprecated Use [HomeAliveAiOrb] — kept for tests importing the old name.
typedef HomeAliveAiChip = HomeAliveAiOrb;
