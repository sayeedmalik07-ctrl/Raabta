import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_text_field.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';

/// Scam Shield hub-standard padding (Money Hub convention).
const scamShieldScreenPadding = EdgeInsets.fromLTRB(
  AppSpacing.xl,
  AppSpacing.lg,
  AppSpacing.xl,
  AppSpacing.xxxl,
);

/// Primary fraud-protection accent — radar / shield cyan.
const scamShieldAccent = AppColors.cyanGlow;

/// Secondary accent for depth gradients.
const scamShieldSecondaryAccent = AppColors.purpleGlow;

void scamShieldSelectionHaptic() => moneyHubSelectionHaptic();

void scamShieldLightHaptic() => moneyHubLightHaptic();

void scamShieldMediumHaptic() => HapticFeedback.mediumImpact();

String scamShieldRelativeUpdated(DateTime updatedAt, String locale) {
  final diff = DateTime.now().difference(updatedAt.toLocal());
  if (diff.inSeconds < 60) {
    return ScamShieldStrings.t('ss_updated_just_now', locale);
  }
  if (diff.inMinutes < 60) {
    return ScamShieldStrings.format('ss_updated_minutes', locale, {
      'minutes': diff.inMinutes.toString(),
    });
  }
  if (diff.inHours < 24) {
    return ScamShieldStrings.format('ss_updated_hours', locale, {
      'hours': diff.inHours.toString(),
    });
  }
  final local = updatedAt.toLocal();
  return ScamShieldStrings.format('ss_updated_date', locale, {
    'day': local.day.toString(),
    'month': local.month.toString(),
    'hour': local.hour.toString().padLeft(2, '0'),
    'minute': local.minute.toString().padLeft(2, '0'),
  });
}

/// Hero card — hub intro; [compact] drops duplicate title and heavy gradient.
class ScamShieldHeroCard extends StatelessWidget {
  const ScamShieldHeroCard({
    super.key,
    required this.locale,
    this.lastScanAt,
    this.aiRemaining,
    this.compact = false,
  });

  final String locale;
  final DateTime? lastScanAt;
  final int? aiRemaining;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (lastScanAt != null) ...[
          ScamShieldLastScanChip(
            locale: locale,
            scannedAt: lastScanAt!,
          ),
          SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
        ],
        if (!compact)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeIconBadge(
                icon: Icons.shield_outlined,
                accentColor: scamShieldAccent,
                size: 48,
                iconSize: 26,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ScamShieldStrings.t('ss_title', locale),
                      style: AppTypography.headline2,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      ScamShieldStrings.t('ss_subtitle', locale),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textOnGlassMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        else
          Text(
            ScamShieldStrings.t('ss_subtitle', locale),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textOnGlassMuted,
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          ScamShieldStrings.t('ss_disclaimer', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
            fontStyle: FontStyle.italic,
          ),
        ),
        if (aiRemaining != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            ScamShieldStrings.format('ss_remaining_ai', locale, {
              'remaining': aiRemaining.toString(),
            }),
            style: AppTypography.caption.copyWith(
              color: scamShieldAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );

    if (compact) {
      return GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        borderRadius: AppSpacing.radiusLg,
        glowColor: scamShieldAccent,
        glowIntensity: 0.05,
        backgroundColor: AppColors.surface.withValues(alpha: 0.65),
        child: content,
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scamShieldAccent.withValues(alpha: 0.22),
            scamShieldSecondaryAccent.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(color: scamShieldAccent.withValues(alpha: 0.35)),
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppSpacing.radiusLg,
        backgroundColor: AppColors.surface.withValues(alpha: 0.72),
        child: content,
      ),
    );
  }
}

/// Pulse chip showing when the last assessment ran.
class ScamShieldLastScanChip extends StatefulWidget {
  const ScamShieldLastScanChip({
    super.key,
    required this.locale,
    required this.scannedAt,
  });

  final String locale;
  final DateTime scannedAt;

  @override
  State<ScamShieldLastScanChip> createState() => _ScamShieldLastScanChipState();
}

class _ScamShieldLastScanChipState extends State<ScamShieldLastScanChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: scamShieldAccent.withValues(alpha: 0.1),
            border: Border.all(color: scamShieldAccent.withValues(alpha: 0.35)),
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
                    color: AppColors.success,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.55),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                ScamShieldStrings.t('ss_last_scan_label', widget.locale),
                style: AppTypography.caption.copyWith(
                  color: scamShieldAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          scamShieldRelativeUpdated(widget.scannedAt, widget.locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

/// Unified verdict surface for trust, risk, and incident outcomes.
class ScamShieldVerdictCard extends StatelessWidget {
  const ScamShieldVerdictCard({
    super.key,
    required this.overline,
    required this.headline,
    required this.accentColor,
    this.subtitle,
    this.details = const [],
    this.leadingIcon,
  });

  final String overline;
  final String headline;
  final Color accentColor;
  final String? subtitle;
  final List<Widget> details;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: accentColor.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            overline,
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, color: accentColor, size: 28),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Text(
                  headline,
                  style: AppTypography.tabular(
                    AppTypography.headline2.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: AppTypography.caption,
            ),
          ],
          ...details,
        ],
      ),
    );
  }
}

/// Shortcut tile — matches Money Hub feature tile grammar.
class ScamShieldFeatureTile extends StatelessWidget {
  const ScamShieldFeatureTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
    this.glowIntensity = 0.14,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;
  final double glowIntensity;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () {
        scamShieldSelectionHaptic();
        onTap();
      },
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppSpacing.radiusLg,
      glowColor: accentColor,
      glowIntensity: glowIntensity,
      child: Row(
        children: [
          HomeIconBadge(
            icon: icon,
            accentColor: accentColor,
            size: 40,
            iconSize: 22,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.subtitle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textOnGlassMuted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: accentColor.withValues(alpha: 0.8)),
        ],
      ),
    );
  }
}

/// Glass-styled single-select chip row (replaces Material ChoiceChip).
class ScamShieldOptionChips<T> extends StatelessWidget {
  const ScamShieldOptionChips({
    super.key,
    required this.options,
    required this.selected,
    required this.labelFor,
    required this.onSelected,
    this.accentColor = scamShieldAccent,
  });

  final List<T> options;
  final T selected;
  final String Function(T option) labelFor;
  final ValueChanged<T> onSelected;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = option == selected;
        return GestureDetector(
          onTap: () {
            scamShieldSelectionHaptic();
            onSelected(option);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected
                    ? accentColor.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              labelFor(option),
              style: AppTypography.caption.copyWith(
                color: isSelected ? accentColor : AppColors.textTertiary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Branded assess / OCR waiting state.
class ScamShieldAssessLoading extends StatefulWidget {
  const ScamShieldAssessLoading({
    super.key,
    required this.message,
  });

  final String message;

  @override
  State<ScamShieldAssessLoading> createState() => _ScamShieldAssessLoadingState();
}

class _ScamShieldAssessLoadingState extends State<ScamShieldAssessLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: scamShieldAccent,
      glowIntensity: 0.12,
      child: Row(
        children: [
          ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.05).animate(
              CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
            ),
            child: Icon(Icons.radar, color: scamShieldAccent, size: 28),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              widget.message,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textOnGlassMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Staggered fade + slide entrance for results and share bootstrap.
class ScamShieldEntranceReveal extends StatefulWidget {
  const ScamShieldEntranceReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  State<ScamShieldEntranceReveal> createState() =>
      _ScamShieldEntranceRevealState();
}

class _ScamShieldEntranceRevealState extends State<ScamShieldEntranceReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

/// Shared scan input block for hub and share-review screens.
class ScamShieldScanInputBlock extends StatelessWidget {
  const ScamShieldScanInputBlock({
    super.key,
    required this.locale,
    required this.controller,
    required this.hintText,
    required this.charCount,
    required this.maxChars,
    required this.onChanged,
    this.directoryAction,
    this.footer,
    this.inputFormatters,
  });

  final String locale;
  final TextEditingController controller;
  final String hintText;
  final int charCount;
  final int maxChars;
  final ValueChanged<String> onChanged;
  final VoidCallback? directoryAction;
  final Widget? footer;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeSectionHeader(
          overline: ScamShieldStrings.t('ss_scan_overline', locale),
          title: ScamShieldStrings.t('ss_paste_label', locale),
          actionText: directoryAction != null
              ? ScamShieldStrings.t('ss_directory_link', locale)
              : null,
          onActionTap: directoryAction,
          leadingIcon: Icons.radar_outlined,
        ),
        const SizedBox(height: AppSpacing.sm),
        GlassTextField(
          controller: controller,
          hint: hintText,
          maxLines: 8,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          ScamShieldStrings.format('ss_char_count', locale, {
            'count': charCount.toString(),
            'max': maxChars.toString(),
          }),
          style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
        ),
        if (footer != null) ...[
          const SizedBox(height: AppSpacing.sm),
          footer!,
        ],
      ],
    );
  }
}
