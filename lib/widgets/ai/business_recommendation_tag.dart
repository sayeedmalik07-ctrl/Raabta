import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/design/app_colors.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_text_styles.dart';
import 'package:raabta/services/ai/business_recommendation_service.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

class BusinessRecommendationTag extends ConsumerWidget {
  const BusinessRecommendationTag({
    super.key,
    required this.businessData,
  });

  final Map<String, dynamic> businessData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userAIProfileProvider);
    if (profile == null) return const SizedBox.shrink();

    final service = ref.read(businessRecommendationServiceProvider);
    final result = service.recommendBusiness(
      businessData,
      profile,
      isPersonalized: true,
    );

    String? label;
    Color? color;

    if (result.isPersonalized && result.recommendationScore >= 65) {
      label = '🤖 Recommended for you';
      color = AppColors.secondary;
    } else if (result.isTrending) {
      label = '🔥 Trending this week';
      color = AppColors.warning;
    } else if (result.isNearby) {
      label = '📍 Near you';
      color = AppColors.primary;
    }

    if (label == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color!.withValues(alpha: 0.1),
              border: Border.all(color: color.withValues(alpha: 0.35)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (result.recommendationReason.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              result.recommendationReason,
              style: AppTextStyles.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
