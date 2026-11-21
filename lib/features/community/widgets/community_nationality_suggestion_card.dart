import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/ai_suggestion_card.dart';
import 'package:raabta/features/community/models/community_nationality_suggestion.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';
import 'package:raabta/features/community/services/community_nationality_suggestion_service.dart';

class CommunityNationalitySuggestionCard extends StatelessWidget {
  const CommunityNationalitySuggestionCard({
    super.key,
    required this.view,
    required this.locale,
    required this.onJoinGroup,
    required this.onAskQatar,
    required this.onDismiss,
  });

  final CommunityNationalitySuggestionView view;
  final String locale;
  final VoidCallback onJoinGroup;
  final VoidCallback onAskQatar;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    if (view.kind == CommunityNationalitySuggestionKind.hidden) {
      return const SizedBox.shrink();
    }

    final nationality = view.nationalityLabel ?? '';
    final countryId = view.countryId ?? '';

    if (view.kind == CommunityNationalitySuggestionKind.joinGroup &&
        view.group != null) {
      final group = view.group!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AISuggestionCard(
            title: CommunityStrings.format(
              'community_nat_suggestion_join_title',
              locale,
              params: {'nationality': nationality},
            ),
            description: CommunityStrings.format(
              'community_nat_suggestion_join_body',
              locale,
              params: {'groupName': '${group.emoji} ${group.name}'},
            ),
            icon: Icons.public_outlined,
            accentColor: AppColors.brandFamilyMain,
            actionLabel: CommunityStrings.t(
              'community_nat_suggestion_join_action',
              locale,
            ),
            onTap: onJoinGroup,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () async {
                await CommunityNationalitySuggestionService.dismiss(countryId);
                onDismiss();
              },
              child: Text(
                CommunityStrings.t('community_nat_suggestion_dismiss', locale),
                style: AppTypography.caption,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          borderRadius: AppSpacing.radiusLg,
          glowColor: AppColors.brandFamilyMain,
          glowIntensity: 0.08,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                CommunityStrings.format(
                  'community_nat_suggestion_no_group_title',
                  locale,
                  params: {'nationality': nationality},
                ),
                style: AppTypography.title.copyWith(fontSize: 15),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                CommunityStrings.t(
                  'community_nat_suggestion_no_group_body',
                  locale,
                ),
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: onAskQatar,
                child: Text(
                  CommunityStrings.t(
                    'community_nat_suggestion_ask_action',
                    locale,
                  ),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () async {
              await CommunityNationalitySuggestionService.dismiss(countryId);
              onDismiss();
            },
            child: Text(
              CommunityStrings.t('community_nat_suggestion_dismiss', locale),
              style: AppTypography.caption,
            ),
          ),
        ),
      ],
    );
  }
}
