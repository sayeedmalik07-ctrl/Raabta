import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/screens/ai_chat/l10n/ai_chat_strings.dart';
import 'package:raabta/screens/ai_chat/models/ai_chat_topic.dart';

void showAiChatTopicsSheet(
  BuildContext context, {
  required String locale,
  required ValueChanged<String> onTopicSelected,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundMid,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusLg),
      ),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.glassBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                AiChatStrings.t('ai_browse_topics', locale),
                style: AppTypography.headline2,
              ),
              const SizedBox(height: AppSpacing.sm),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: AiChatTopicsCatalog.topics.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.sm,
                    mainAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 1.15,
                  ),
                  itemBuilder: (context, index) {
                    final topic = AiChatTopicsCatalog.topics[index];
                    return GlassCard(
                      onTap: () {
                        Navigator.pop(ctx);
                        onTopicSelected(
                          AiChatStrings.t(topic.promptKey, locale),
                        );
                      },
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      borderRadius: AppSpacing.radiusSm,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HomeIconBadge(
                            icon: topic.icon,
                            accentColor: AppColors.cyanGlow,
                            size: 36,
                            iconSize: 20,
                          ),
                          const Spacer(),
                          Text(
                            AiChatStrings.t(topic.titleKey, locale),
                            style: AppTypography.subtitle.copyWith(fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            AiChatStrings.t(topic.descriptionKey, locale),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textOnGlassMuted,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
