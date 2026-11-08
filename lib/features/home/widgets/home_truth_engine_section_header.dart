import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/l10n/home_truth_engine_section_strings.dart';
import 'package:raabta/features/home/providers/home_truth_engine_reveal_provider.dart';
/// Truth Engine section header — eyebrow, title, attention badge, eye reveal.
class HomeTruthEngineSectionHeader extends ConsumerWidget {
  const HomeTruthEngineSectionHeader({
    super.key,
    required this.overline,
    required this.title,
    required this.locale,
    this.subtitle,
    this.compact = true,
  });

  final String overline;
  final String title;
  final String? subtitle;
  final String locale;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attentionCount = ref.watch(homeTruthEngineAttentionCountProvider);
    final revealed = ref.watch(homeTruthEngineDetailsRevealedProvider);
    final controller = ref.read(homeTruthEngineRevealControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatOverline(overline, context),
          style: AppTypography.overline.copyWith(
            color: AppColors.textOnGlassSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTypography.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (attentionCount > 0) ...[
              const SizedBox(width: AppSpacing.sm),
              _AttentionBadge(count: attentionCount, locale: locale),
            ],
            const SizedBox(width: AppSpacing.xs),
            _RevealEyeButton(
              revealed: revealed,
              locale: locale,
              onPressed: controller.toggle,
            ),
          ],
        ),
        if (subtitle != null && !compact) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle!,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textOnGlassMuted,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  static String _formatOverline(String text, BuildContext context) {
    if (Directionality.of(context) == TextDirection.rtl) return text;
    return text.toUpperCase();
  }
}

class _AttentionBadge extends StatelessWidget {
  const _AttentionBadge({
    required this.count,
    required this.locale,
  });

  final int count;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final label = HomeTruthEngineSectionStrings.format(
      'home_truth_attention_count',
      locale,
      params: {'count': '$count'},
    );
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: AppColors.warning,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _RevealEyeButton extends StatelessWidget {
  const _RevealEyeButton({
    required this.revealed,
    required this.locale,
    required this.onPressed,
  });

  final bool revealed;
  final String locale;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final semanticsLabel = revealed
        ? HomeTruthEngineSectionStrings.t('home_truth_eye_hide', locale)
        : HomeTruthEngineSectionStrings.t('home_truth_eye_show', locale);

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: revealed
                  ? AppColors.goldFamilyMain.withValues(alpha: 0.12)
                  : AppColors.glassSurface,
              border: Border.all(
                color: revealed
                    ? AppColors.goldFamilyMain.withValues(alpha: 0.5)
                    : AppColors.glassBorder,
              ),
            ),
            child: Icon(
              revealed ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 20,
              color: revealed
                  ? AppColors.goldFamilyMain
                  : AppColors.textOnGlassSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
