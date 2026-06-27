import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/design/app_colors.dart';
import 'package:raabta/core/design/app_text_styles.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/services/ai/ai_feed_engine.dart';

class AIFeedCardWidget extends StatelessWidget {
  final AIFeedCard card;
  final VoidCallback? onTap;

  const AIFeedCardWidget({
    super.key,
    required this.card,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _handleTap(context),
      child: Container(
        width: 300,
        height: 140,
        margin: const EdgeInsets.only(right: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border(
            left: BorderSide(color: card.borderColor, width: 4),
            top: BorderSide(color: AppColors.glassBorder, width: 1),
            right: BorderSide(color: AppColors.glassBorder, width: 1),
            bottom: BorderSide(color: AppColors.glassBorder, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: card.borderColor.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(card.icon, style: const TextStyle(fontSize: 22)),
                  if (card.isSponsored)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.12),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.4),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '📢 SPONSORED',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                card.title,
                style: AppTextStyles.h3,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Expanded(
                child: Text(
                  card.subtitle,
                  style: AppTextStyles.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: card.borderColor.withValues(alpha: 0.12),
                  border: Border.all(
                    color: card.borderColor.withValues(alpha: 0.4),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  card.ctaText,
                  style: TextStyle(
                    color: card.borderColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    if (card.ctaRoute.isNotEmpty) {
      try {
        context.push(card.ctaRoute);
        return;
      } catch (_) {
        _navigateByType(context);
      }
    } else {
      _navigateByType(context);
    }
  }

  void _navigateByType(BuildContext context) {
    switch (card.type) {
      case FeedCardType.jobRecommendation:
        context.push('/jobs');
      case FeedCardType.housingRecommendation:
        context.push('/housing');
      case FeedCardType.exchangeRate:
        context.push('/money');
      case FeedCardType.visaUpdate:
        context.push('/visa');
      case FeedCardType.communityEvent:
        context.push('/community');
      case FeedCardType.businessOffer:
        context.push('/businesses');
      case FeedCardType.scoreSuggestion:
        context.push('/expat-score');
      case FeedCardType.sponsored:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(card.sponsorLabel ?? 'Sponsored content'),
            backgroundColor: AppColors.surface,
            behavior: SnackBarBehavior.floating,
          ),
        );
      default:
        context.push('/ai-chat');
    }
  }
}
