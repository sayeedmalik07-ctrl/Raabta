import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/design/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_text_styles.dart';
import 'package:raabta/features/jobs/cv_maker/data/cv_repository.dart';
import 'package:raabta/features/jobs/cv_maker/domain/models/cv_document.dart';
import 'package:raabta/features/jobs/esco_match/presentation/l10n/esco_match_strings.dart';
import 'package:raabta/features/jobs/esco_match/presentation/widgets/esco_match_breakdown.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/ai/job_match_service.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/widgets/ai/ai_loading_skeleton.dart';
import 'package:raabta/widgets/ai/ai_match_indicator.dart';

class JobMatchBadge extends ConsumerStatefulWidget {
  const JobMatchBadge({
    super.key,
    required this.jobData,
    this.compact = false,
    this.enrichFromCv = false,
  });

  final Map<String, dynamic> jobData;
  final bool compact;

  /// When true, merges the user's saved CV skills into the match (detail sheet only).
  final bool enrichFromCv;

  @override
  ConsumerState<JobMatchBadge> createState() => _JobMatchBadgeState();
}

class _JobMatchBadgeState extends ConsumerState<JobMatchBadge> {
  JobMatchResult? _result;
  bool _loading = true;

  Color get _matchColor {
    final score = _result?.matchScore ?? 0;
    if (score >= 90) return AppColors.success;
    if (score >= 75) return AppColors.primary;
    if (score >= 60) return AppColors.info;
    if (score >= 45) return AppColors.warning;
    return AppColors.textMuted;
  }

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void didUpdateWidget(covariant JobMatchBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.jobData != widget.jobData ||
        oldWidget.enrichFromCv != widget.enrichFromCv) {
      _calculate();
    }
  }

  Future<void> _calculate() async {
    setState(() => _loading = true);

    try {
      final profile =
          ref.read(userProfileAIServiceProvider).getCachedProfile() ??
              ref.read(userAIProfileProvider);

      if (profile == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final locale = ref.read(userLanguageProvider);
      CvDocument? cv;
      if (widget.enrichFromCv) {
        cv = await ref.read(cvRepositoryProvider).loadLatest();
      }

      final cvContext = cv != null ? _cvMatchTokens(cv) : null;
      final matchService = ref.read(jobMatchServiceProvider);
      final result = matchService.evaluateMatch(
        widget.jobData,
        profile,
        extraSkillTokens: cvContext?.skills ?? const [],
        extraCertTokens: cvContext?.certs ?? const [],
        jobTitleTokens: cvContext?.jobTitles ?? const [],
        locale: locale,
      );

      if (mounted) {
        setState(() {
          _result = result;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  ({List<String> skills, List<String> certs, List<String> jobTitles})
      _cvMatchTokens(CvDocument cv) {
    return (
      skills: [
        ...cv.skills.hardSkills,
        ...cv.skills.toolsSoftware,
        ...cv.skills.softSkills,
      ],
      certs: cv.certifications
          .map((c) => c.name)
          .where((n) => n.trim().isNotEmpty)
          .toList(growable: false),
      jobTitles: cv.experience
          .map((e) => e.jobTitle)
          .where((t) => t.trim().isNotEmpty)
          .toList(growable: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);

    if (_loading) {
      return widget.compact
          ? const AILoadingSkeleton(width: 80, height: 24, borderRadius: 20)
          : const AILoadingSkeleton(
              width: double.infinity,
              height: 64,
              borderRadius: AppRadius.md,
            );
    }

    if (_result == null) return const SizedBox.shrink();
    if (_result!.matchScore < 45) return const SizedBox.shrink();

    return widget.compact ? _buildCompact(locale) : _buildFull(locale);
  }

  Widget _buildCompact(String locale) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _matchColor.withValues(alpha: 0.12),
        border: Border.all(color: _matchColor.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hub_outlined, size: 10, color: _matchColor),
          const SizedBox(width: 3),
          Text(
            EscoMatchStrings.tf(
              'esco_match_compact',
              locale,
              {'score': '${_result!.matchScore}'},
            ),
            style: TextStyle(
              color: _matchColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFull(String locale) {
    final esco = _result!.escoDetail;
    final levelLabel =
        EscoMatchStrings.matchLevelLabel(_result!.matchLevel, locale);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _matchColor.withValues(alpha: 0.06),
        border: Border(left: BorderSide(color: _matchColor, width: 3)),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(AppRadius.md),
          bottomRight: Radius.circular(AppRadius.md),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AIMatchIndicator(matchScore: _result!.matchScore, size: 48),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      EscoMatchStrings.t('esco_match_header', locale),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: _matchColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        levelLabel,
                        style: TextStyle(
                          color: _matchColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  EscoMatchStrings.t('esco_match_subtitle', locale),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  EscoMatchStrings.tf(
                    'esco_match_score',
                    locale,
                    {'score': '${_result!.matchScore}'},
                  ),
                  style: AppTextStyles.h3.copyWith(color: _matchColor),
                ),
                if (_result!.explanation.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _result!.explanation,
                    style: AppTextStyles.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (esco != null) ...[
                  const SizedBox(height: 8),
                  EscoMatchBreakdown(
                    matchedSkills: esco.matchedSkills,
                    missingSkills: esco.missingRequiredSkills,
                    blockedQualifications: esco.blockedQualifications,
                    overlapPercent: esco.overlapPercent,
                    locale: locale,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
