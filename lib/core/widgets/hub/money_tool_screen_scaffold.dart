import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/hub/hub_subscreen_scaffold.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';

/// Money Hub kit tool shell — [HubSubscreenScaffold] + optional hero, status, source line,
/// disclaimer, and pull-to-refresh over scrollable content (subscreen kit + Money UX audit).
class MoneyToolScreenScaffold extends StatelessWidget {
  const MoneyToolScreenScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onBack,
    this.hero,
    this.statusRow,
    this.sourceLine,
    this.disclaimer,
    this.onRefresh,
    this.isRefreshing = false,
    this.headerTrailing,
    this.children = const [],
    this.customBody,
    this.bottomNavigationBar,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;

  /// Primary numeral row (e.g. amount or rate) — use [MoneyAnimatedFigure] at call site.
  final Widget? hero;

  /// Live / stale / indicative row — e.g. [MoneyLiveChip] or [MoneyToolStatusRow].
  final Widget? statusRow;

  /// Dated “Source:” / verification line (kit honesty).
  final Widget? sourceLine;

  /// Fixed compliance band (e.g. [HubNoticeBanner] or feature disclaimer).
  final Widget? disclaimer;

  /// When null, pull-to-refresh and the app-bar refresh control are omitted.
  final Future<void> Function()? onRefresh;
  final bool isRefreshing;

  /// Extra header actions (e.g. report transfer) composed with refresh by the caller.
  final Widget? headerTrailing;

  /// Body content below hero / disclaimer / source (inputs, breakdowns, lists).
  /// Ignored when [customBody] is non-null.
  final List<Widget> children;

  /// Full body under the header (e.g. nested [TabBar] + [TabBarView]). Implies no outer pull-to-refresh.
  final Widget? customBody;

  /// Optional bottom bar (e.g. tool chrome) passed to [HubSubscreenScaffold].
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    assert(
      customBody == null || children.isEmpty,
      'MoneyToolScreenScaffold: pass either customBody or children, not both.',
    );
    final refreshButton = onRefresh == null
        ? null
        : IconButton(
            icon: isRefreshing
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.goldFamilyMain,
                    ),
                  )
                : Icon(Icons.refresh, color: AppColors.goldFamilyMain),
            onPressed: isRefreshing ? null : () => onRefresh!(),
            tooltip:
                MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          );

    final Widget? trailing;
    if (onRefresh == null) {
      trailing = headerTrailing;
    } else if (headerTrailing == null) {
      trailing = refreshButton;
    } else {
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          headerTrailing!,
          refreshButton!,
        ],
      );
    }

    final Widget bodyChild;
    if (customBody != null) {
      bodyChild = customBody!;
    } else {
      final scroll = CustomScrollView(
        physics: onRefresh != null
            ? const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              )
            : const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: moneyHubScreenPadding.copyWith(top: AppSpacing.sm),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Compliance / trust bands first, then hero + inputs (Money Hub kit).
                if (disclaimer != null) ...[
                  disclaimer!,
                  const SizedBox(height: AppSpacing.md),
                ],
                if (hero != null) ...[
                  hero!,
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (statusRow != null) ...[
                  statusRow!,
                  const SizedBox(height: AppSpacing.md),
                ],
                if (sourceLine != null) ...[
                  sourceLine!,
                  const SizedBox(height: AppSpacing.md),
                ],
                ...children,
              ]),
            ),
          ),
        ],
      );

      bodyChild = onRefresh == null
          ? scroll
          : RefreshIndicator(
              color: AppColors.goldFamilyMain,
              backgroundColor: AppColors.surface,
              onRefresh: onRefresh!,
              child: scroll,
            );
    }

    return HubSubscreenScaffold(
      title: title,
      subtitle: subtitle,
      onBack: onBack,
      headerTrailing: trailing,
      bottomNavigationBar: bottomNavigationBar,
      body: bodyChild,
    );
  }
}

/// Semantic status strip for money tools — icon + label + optional detail (tinted text).
class MoneyToolStatusRow extends StatelessWidget {
  const MoneyToolStatusRow({
    super.key,
    required this.label,
    this.detail,
    this.icon = Icons.info_outline,
    this.color,
  });

  final String label;
  final String? detail;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.goldFamilyMain;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: accent),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.caption.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  if (detail != null && detail!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      detail!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textOnGlassMuted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kit-aligned hero numeral for send-amount style tools (tabular, gold accent).
class MoneyToolHeroSendAmount extends StatelessWidget {
  const MoneyToolHeroSendAmount({
    super.key,
    required this.amount,
    required this.caption,
    this.semanticsLabel,
  });

  final double amount;
  final String caption;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel ?? caption,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.goldFamilyMain.withValues(alpha: 0.2),
              AppColors.brandFamilyMain.withValues(alpha: 0.06),
            ],
          ),
          border: Border.all(
            color: AppColors.goldFamilyMain.withValues(alpha: 0.35),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                caption,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textOnGlassMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              MoneyAnimatedFigure(
                value: amount,
                prefix: '',
                suffix: ' QAR',
                decimals: 0,
                style: AppTypography.display.copyWith(
                  fontSize: 40,
                  height: 1.05,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
