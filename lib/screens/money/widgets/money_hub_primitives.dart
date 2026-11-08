import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/background/animated_aurora_background.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';
import 'package:raabta/core/widgets/hub/hub_landing_header.dart';
import 'package:raabta/core/widgets/hub/hub_search_decoration.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/features/home/widgets/glass_loading_card.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/money/l10n/money_hub_strings.dart';

/// Hub-standard horizontal padding (Marketplace / Jobs / Housing).
const moneyHubScreenPadding = EdgeInsets.fromLTRB(
  AppSpacing.xl,
  AppSpacing.lg,
  AppSpacing.xl,
  AppSpacing.xxxl,
);

/// Money Hub category accent — rates, refresh, live chips (kit: gold vertical).
Color get moneyHubAccent => AppColors.goldFamilyMain;

/// Shared Money Hub interaction feedback.
void moneyHubSelectionHaptic() => HapticFeedback.selectionClick();

void moneyHubLightHaptic() => HapticFeedback.lightImpact();

/// Large monetary / numeric value with tabular figures and count-up motion.
class MoneyAnimatedFigure extends StatelessWidget {
  const MoneyAnimatedFigure({
    super.key,
    required this.value,
    required this.style,
    this.prefix = '',
    this.suffix = '',
    this.decimals,
    this.duration = const Duration(milliseconds: 420),
  });

  final double value;
  final TextStyle style;
  final String prefix;
  final String suffix;
  final int? decimals;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    if (!value.isFinite) {
      return Text(
        '${prefix}—$suffix',
        style: AppTypography.tabular(style),
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) {
        if (!animated.isFinite) {
          return Text(
            '${prefix}—$suffix',
            style: AppTypography.tabular(style),
          );
        }
        final fractionDigits = decimals ??
            (animated == animated.roundToDouble() ? 0 : 2);
        final formatted = animated.toStringAsFixed(fractionDigits);
        return Text(
          '$prefix$formatted$suffix',
          style: AppTypography.tabular(style),
        );
      },
    );
  }
}

/// Shortcut tile — full card (legacy) or compact hub kit tile (Money tools grid).
class MoneyHubFeatureTile extends StatelessWidget {
  const MoneyHubFeatureTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  /// Hub kit `MoneyTool` tiles: rounded-square, gold chip, centered labels (2 lines).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return GlassCard(
        onTap: () {
          moneyHubSelectionHaptic();
          onTap();
        },
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
        borderRadius: AppSpacing.radiusMd,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            HomeIconBadge(
              icon: icon,
              accentColor: accentColor,
              variant: HomeIconBadgeVariant.goldBrand,
              size: 40,
              iconSize: 22,
              chipBorderRadius: HomeCardTier.coreServiceIconChipRadius,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.25,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return GlassCard(
      onTap: () {
        moneyHubSelectionHaptic();
        onTap();
      },
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppSpacing.radiusLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeIconBadge(
            icon: icon,
            accentColor: accentColor,
            size: 36,
            iconSize: 20,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: AppTypography.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textOnGlassMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Segmented control for Markets tab (Trend vs Compare).
class MoneyHubSegmentedControl extends StatelessWidget {
  const MoneyHubSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.accentColor,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.goldFamilyMain;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.isLight
            ? AppColors.glassSurface
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.isLight
              ? AppColors.glassBorder
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  moneyHubSelectionHaptic();
                  onChanged(i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selectedIndex == i
                        ? accent.withValues(alpha: 0.22)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: selectedIndex == i
                        ? Border.all(color: accent.withValues(alpha: 0.45))
                        : null,
                  ),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(
                      color: selectedIndex == i
                          ? accent
                          : AppColors.textTertiary,
                      fontWeight: selectedIndex == i
                          ? FontWeight.w700
                          : FontWeight.w500,
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

/// Live-data pill with optional pulse — used near rates, gold, CPI feeds.
class MoneyLiveChip extends ConsumerStatefulWidget {
  const MoneyLiveChip({
    super.key,
    required this.label,
    this.updatedAt,
    this.isLive = true,
    this.accentColor,
    this.warningLabel,
  });

  final String label;
  final DateTime? updatedAt;
  final bool isLive;
  final Color? accentColor;
  final String? warningLabel;

  @override
  ConsumerState<MoneyLiveChip> createState() => _MoneyLiveChipState();
}

class _MoneyLiveChipState extends ConsumerState<MoneyLiveChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.isLive) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(MoneyLiveChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLive && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.isLive) {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final accent = widget.accentColor ?? AppColors.goldFamilyMain;
    final dotColor = widget.warningLabel != null
        ? AppColors.warning
        : widget.isLive
            ? AppColors.success
            : accent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: accent.withValues(alpha: 0.1),
            border: Border.all(
              color: accent.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(
                opacity: Tween<double>(begin: 0.45, end: 1).animate(
                  CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
                ),
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                    boxShadow: widget.isLive
                        ? [
                            BoxShadow(
                              color: dotColor.withValues(alpha: 0.55),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  widget.warningLabel ?? widget.label,
                  style: AppTypography.caption.copyWith(
                    color: widget.warningLabel != null
                        ? AppColors.warning
                        : accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.updatedAt != null) ...[
          const SizedBox(height: 4),
          Text(
            moneyHubRelativeUpdatedLabel(locale, widget.updatedAt!),
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}

/// Localized relative freshness under [MoneyLiveChip] — same thresholds as legacy English helper.
@visibleForTesting
String moneyHubRelativeUpdatedLabel(
  String locale,
  DateTime updatedAt, {
  DateTime? clock,
}) {
  final now = (clock ?? DateTime.now()).toLocal();
  final localUpdated = updatedAt.toLocal();
  final diff = now.difference(localUpdated);
  if (diff.inSeconds < 60) {
    return MoneyHubStrings.t('live_chip_updated_just_now', locale);
  }
  if (diff.inMinutes < 60) {
    return MoneyHubStrings.format(
      'live_chip_updated_minutes',
      locale,
      params: {'minutes': '${diff.inMinutes}'},
    );
  }
  if (diff.inHours < 24) {
    return MoneyHubStrings.format(
      'live_chip_updated_hours',
      locale,
      params: {'hours': '${diff.inHours}'},
    );
  }
  return MoneyHubStrings.format(
    'live_chip_updated_datetime',
    locale,
    params: {
      'day': '${localUpdated.day}',
      'month': '${localUpdated.month}',
      'hour': localUpdated.hour.toString().padLeft(2, '0'),
      'minute': localUpdated.minute.toString().padLeft(2, '0'),
    },
  );
}

/// Money Hub empty state — gold icon chip + glass card (kit §2; not cyan [GlassEmptyState]).
class MoneyHubEmptyState extends StatelessWidget {
  const MoneyHubEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      borderRadius: AppSpacing.radiusMd,
      glowColor: moneyHubAccent,
      glowIntensity: 0.1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HomeIconBadge(
            icon: icon,
            accentColor: moneyHubAccent,
            variant: HomeIconBadgeVariant.goldBrand,
            size: 52,
            iconSize: 28,
            chipBorderRadius: HomeCardTier.coreServiceIconChipRadius,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTypography.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textOnGlassMuted,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: moneyHubAccent,
                  foregroundColor: AppColors.background,
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Skeleton stack for full-screen Money Hub feature loads.
class MoneyHubScreenLoading extends StatelessWidget {
  const MoneyHubScreenLoading({
    super.key,
    this.cardCount = 3,
    this.cardHeight = 128,
  });

  final int cardCount;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < cardCount; i++) ...[
          GlassLoadingCard(height: cardHeight),
          if (i < cardCount - 1) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

/// Tabbed Money Hub shell — hub kit header + search row + aurora + tab content.
///
/// Chrome (header, search + filter, hub tabs) stays **pinned**; [body] scrolls underneath.
/// A token-border scrim fades in after ~8px of vertical scroll (Hub kit §3.1 / §7).
class MoneyHubShell extends StatefulWidget {
  const MoneyHubShell({
    super.key,
    required this.shellTitle,
    required this.shellSubtitle,
    required this.searchHint,
    required this.tabLabels,
    required this.searchController,
    required this.tabController,
    required this.body,
    required this.onRefresh,
    required this.isRefreshing,
    this.canPop = false,
    this.onPop,
  });

  final String shellTitle;
  final String shellSubtitle;
  final String searchHint;
  final List<String> tabLabels;
  final TextEditingController searchController;
  final TabController tabController;
  final Widget body;
  final Future<void> Function() onRefresh;
  final bool isRefreshing;
  final bool canPop;
  final VoidCallback? onPop;

  @override
  State<MoneyHubShell> createState() => _MoneyHubShellState();
}

class _MoneyHubShellState extends State<MoneyHubShell> {
  final GlobalKey _chromeKey = GlobalKey();
  static const double _scrimFadePx = 8;
  /// Until first layout, avoid body painting under unpinned chrome.
  static const double _fallbackChromeHeight = 200;

  double _chromeHeight = 0;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(_onTabChanged);
  }

  @override
  void didUpdateWidget(MoneyHubShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabController != widget.tabController) {
      oldWidget.tabController.removeListener(_onTabChanged);
      widget.tabController.addListener(_onTabChanged);
    }
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (widget.tabController.indexIsChanging) return;
    _scrollOffset = 0;
    setState(() {});
  }

  void _measureChrome() {
    final box = _chromeKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final h = box.size.height;
    if ((h - _chromeHeight).abs() > 0.5) {
      setState(() => _chromeHeight = h);
    }
  }

  bool _onScrollNotification(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    final px = n.metrics.pixels;
    if (px != _scrollOffset) {
      setState(() => _scrollOffset = px.clamp(0.0, double.infinity));
    }
    return false;
  }

  double get _scrimProgress =>
      (_scrollOffset / _scrimFadePx).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    assert(
      widget.tabLabels.length == widget.tabController.length,
      'tabLabels must match TabController length',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _measureChrome());

    final refreshButton = IconButton(
      icon: widget.isRefreshing
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: moneyHubAccent,
              ),
            )
          : Icon(Icons.refresh, color: moneyHubAccent),
      onPressed: widget.isRefreshing ? null : () => widget.onRefresh(),
      tooltip: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    );

    final scrimBorderAlpha = 0.45 * _scrimProgress;
    final chromeFillAlpha = 0.88 * _scrimProgress;

    return AnimatedAuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: _chromeHeight > 0 ? _chromeHeight : _fallbackChromeHeight,
                  ),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: _onScrollNotification,
                    child: widget.body,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: RepaintBoundary(
                  key: _chromeKey,
                  child: AnimatedContainer(
                    duration: Duration.zero,
                    decoration: BoxDecoration(
                      color: AppColors.background
                          .withValues(alpha: chromeFillAlpha),
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.glassBorderBright
                              .withValues(alpha: scrimBorderAlpha),
                          width: _scrimProgress > 0.02 ? 1 : 0,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            AppSpacing.md,
                            AppSpacing.xs,
                            AppSpacing.md,
                            0,
                          ),
                          child: HubLandingHeader(
                            title: widget.shellTitle,
                            subtitle: widget.shellSubtitle,
                            onBack: widget.onPop ?? () => context.pop(),
                            showBack: widget.canPop,
                            trailing: refreshButton,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            AppSpacing.xl,
                            AppSpacing.sm,
                            AppSpacing.xl,
                            AppSpacing.sm,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: widget.searchController,
                                  decoration: hubSearchInputDecoration(
                                    hintText: widget.searchHint,
                                  ),
                                  textInputAction: TextInputAction.search,
                                  autocorrect: false,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              SizedBox(
                                width: HubLayoutTokens.filterControlSize,
                                height: HubLayoutTokens.filterControlSize,
                                child: Material(
                                  color: AppColors.brandFamilyMain
                                      .withValues(alpha: 0.2),
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    onTap: () => moneyHubLightHaptic(),
                                    customBorder: const CircleBorder(),
                                    child: Icon(
                                      Icons.tune_rounded,
                                      color: AppColors.brandFamilyMain,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TabBar(
                          controller: widget.tabController,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            color: AppColors.brandFamilyMain.withValues(
                              alpha: AppColors.isLight ? 0.14 : 0.22,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          indicatorPadding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 2,
                          ),
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          dividerColor: Colors.transparent,
                          labelColor: AppColors.brandFamilyText,
                          unselectedLabelColor: AppColors.textTertiary,
                          labelStyle: AppTypography.subtitle.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          unselectedLabelStyle:
                              AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textTertiary,
                          ),
                          tabs: [
                            for (final label in widget.tabLabels)
                              Tab(text: label),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section header — delegates to shared [HomeSectionHeader] for hub consistency.
class MoneyHubSectionHeader extends StatelessWidget {
  const MoneyHubSectionHeader({
    super.key,
    this.overline,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailing,
    this.compact = false,
  });

  final String? overline;
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? trailing;

  /// Tighter hub kit headers (title-focused, optional hidden subtitle).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: HomeSectionHeader(
            overline: overline,
            title: title,
            subtitle: subtitle,
            leadingIcon: leadingIcon,
            compact: compact,
          ),
        ),
        ?trailing,
      ],
    );
  }
}
