import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_text_styles.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/housing/l10n/housing_strings.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';
import 'package:raabta/services/ai/housing_match_service.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/widgets/ai/ai_loading_skeleton.dart';

class HousingMatchWidget extends ConsumerStatefulWidget {
  const HousingMatchWidget({
    super.key,
    required this.listingData,
    this.compact = true,
  });

  final Map<String, dynamic> listingData;
  final bool compact;

  @override
  ConsumerState<HousingMatchWidget> createState() => _HousingMatchWidgetState();
}

class _HousingMatchWidgetState extends ConsumerState<HousingMatchWidget> {
  HousingMatchResult? _result;
  String? _aiExplanation;
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

      final matchService = ref.read(housingMatchServiceProvider);
      final result = matchService.calculateMatch(widget.listingData, profile);

      String? explanation;
      if (!widget.compact && result.matchScore >= 60) {
        final claudeService = ref.read(claudeAIServiceProvider);
        final aiResponse = await claudeService.generateHousingExplanation(
          listing: widget.listingData,
          matchScore: result.matchScore,
          profile: profile,
        );
        if (aiResponse.success) explanation = aiResponse.reply;
      }

      if (mounted) {
        setState(() {
          _result = result;
          _aiExplanation = explanation;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _tagColor(String tag) {
    if (tag.contains('Budget')) return AppColors.success;
    if (tag.contains('Best Value')) return AppColors.goldFamilyMain;
    if (tag.contains('Just Listed')) return AppColors.warning;
    if (tag.contains('Near')) return AppColors.brandFamilyMain;
    if (tag.contains('Family')) return AppColors.textSecondary;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(userAIProfileProvider);
    final locale = ref.watch(userLanguageProvider);

    ref.listen(userAIProfileProvider, (previous, next) {
      if (previous != next) {
        setState(() {
          _loading = true;
          _result = null;
          _aiExplanation = null;
        });
        _calculate();
      }
    });

    ref.listen(userLanguageProvider, (previous, next) {
      if (previous != next && mounted) {
        setState(() {});
      }
    });

    if (_loading) {
      return widget.compact
          ? const AILoadingSkeleton(width: 200, height: 24, borderRadius: 20)
          : const AILoadingSkeleton(
              width: double.infinity,
              height: 70,
              borderRadius: AppRadius.md,
            );
    }

    if (_result == null || _result!.matchScore < 60) {
      return const SizedBox.shrink();
    }

    return widget.compact ? _buildCompact() : _buildFull(locale);
  }

  Widget _buildCompact() {
    if (_result!.tags.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: _result!.tags.take(3).map((tag) {
          final color = _tagColor(tag);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              border: Border.all(color: color.withValues(alpha: 0.35)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              tag,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFull(String locale) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.brandFamilyMain.withValues(alpha: 0.05),
        border: Border(
          left: BorderSide(color: AppColors.brandFamilyMain, width: 3),
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(AppRadius.md),
          bottomRight: Radius.circular(AppRadius.md),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                HousingStrings.t('housing_match_title', locale),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.brandFamilyMain,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.brandFamilyMain.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _result!.matchLabel,
                  style: TextStyle(
                    color: AppColors.brandFamilyMain,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '${_result!.matchScore}% Housing Match',
            style: AppTextStyles.h3.copyWith(color: AppColors.brandFamilyMain),
          ),
          const SizedBox(height: 5),
          Wrap(
            spacing: 5,
            runSpacing: 4,
            children: _result!.tags.map((tag) {
              final color = _tagColor(tag);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  border: Border.all(color: color.withValues(alpha: 0.35)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }).toList(),
          ),
          if (_aiExplanation != null) ...[
            const SizedBox(height: 6),
            Text(
              _aiExplanation!,
              style: AppTextStyles.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
