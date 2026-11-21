import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/ai_suggestion_card.dart';
import 'package:raabta/features/know_qatar/data/models/know_qatar_models.dart';
import 'package:raabta/features/know_qatar/presentation/l10n/know_qatar_strings.dart';
import 'package:raabta/features/quick_actions/quick_actions_hub.dart';

class KnowQatarActionCards extends StatelessWidget {
  const KnowQatarActionCards({
    super.key,
    required this.links,
    required this.locale,
  });

  final List<KnowQatarActionLink> links;
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
          child: Text(
            KnowQatarStrings.t('kq_action_links_heading', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 0.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...links.map((link) {
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: AISuggestionCard(
            title: KnowQatarStrings.t(link.labelKey, locale),
            description: KnowQatarStrings.t('kq_action_card_hint', locale),
            icon: link.icon,
            accentColor: AppColors.cyanGlow,
            actionLabel: KnowQatarStrings.t('kq_action_open', locale),
            onTap: () => QuickActionsHub.navigateTo(context, link.route),
          ),
        );
      }),
      ],
    );
  }
}

class KnowQatarCultureChips extends StatelessWidget {
  const KnowQatarCultureChips({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        ActionChip(
          avatar: Icon(Icons.translate_rounded, size: 18, color: AppColors.cyanGlow),
          label: Text(KnowQatarStrings.t('kq_chip_arabic_phrases', locale)),
          labelStyle: AppTypography.caption,
          backgroundColor: AppColors.surfaceElevated.withValues(alpha: 0.55),
          side: BorderSide(color: AppColors.glassBorderBright.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          onPressed: () => context.push('/arabic-companion'),
        ),
        ActionChip(
          avatar: Icon(Icons.mosque_outlined, size: 18, color: AppColors.cyanGlow),
          label: Text(KnowQatarStrings.t('kq_chip_nearby_mosques', locale)),
          labelStyle: AppTypography.caption,
          backgroundColor: AppColors.surfaceElevated.withValues(alpha: 0.55),
          side: BorderSide(color: AppColors.glassBorderBright.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          onPressed: () => context.push('/prayer-mosque/mosques'),
        ),
      ],
    );
  }
}

class KnowQatarAiFooterLink extends StatelessWidget {
  const KnowQatarAiFooterLink({
    super.key,
    required this.promptKey,
    required this.sectionTitleKey,
    required this.sectionTeaserKey,
    required this.locale,
  });

  final String promptKey;
  final String sectionTitleKey;
  final String sectionTeaserKey;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.cyanGlow,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
        ),
        onPressed: () {
          context.push(
            '/ai-chat',
            extra: {
              'query': KnowQatarStrings.t(promptKey, locale),
              'contextSubtitle': KnowQatarStrings.t(sectionTitleKey, locale),
              'contextSource': 'general',
              'contextBody': KnowQatarStrings.t(sectionTeaserKey, locale),
            },
          );
        },
        icon: const Icon(Icons.auto_awesome_outlined, size: 18),
        label: Text(
          KnowQatarStrings.t('kq_ask_ai', locale),
          style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
