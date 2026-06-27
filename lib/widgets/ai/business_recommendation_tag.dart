import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/design/app_colors.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_text_styles.dart';
import 'package:raabta/services/ai/business_recommendation_service.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/widgets/ai/ai_loading_skeleton.dart';

class BusinessRecommendationTag extends ConsumerStatefulWidget {
  const BusinessRecommendationTag({
    super.key,
    required this.businessData,
  });

  final Map<String, dynamic> businessData;

  @override
  ConsumerState<BusinessRecommendationTag> createState() =>
      _BusinessRecommendationTagState();
}

class _BusinessRecommendationTagState
    extends ConsumerState<BusinessRecommendationTag> {
  BusinessRecommendation? _result;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  Future<void> _calculate() async {
    try {
      final profile =
          ref.read(userProfileAIServiceProvider).getCachedProfile() ??
              ref.read(userAIProfileProvider);

      if (profile == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final service = ref.read(businessRecommendationServiceProvider);
      final recommendation = service.recommendBusiness(
        widget.businessData,
        profile,
        isPersonalized: true,
      );

      if (mounted) {
        setState(() {
          _result = recommendation;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AILoadingSkeleton(width: 180, height: 20, borderRadius: 20);
    }

    if (_result == null) return const SizedBox.shrink();

    String? label;
    Color? color;

    if (_result!.isPersonalized && _result!.recommendationScore >= 65) {
      label = '🤖 Recommended for you';
      color = AppColors.secondary;
    } else if (_result!.isTrending) {
      label = '🔥 Trending this week';
      color = AppColors.warning;
    } else if (_result!.isNearby) {
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
          if (_result!.recommendationReason.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              _result!.recommendationReason,
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
