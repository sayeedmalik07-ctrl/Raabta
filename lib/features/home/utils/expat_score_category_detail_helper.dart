import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/features/home/utils/expat_score_profile_helper.dart';
import 'package:raabta/models/intelligence/explanation.dart';
import 'package:raabta/models/intelligence/intelligence_source.dart';
import 'package:raabta/screens/expat_score/l10n/expat_score_strings.dart';
import 'package:raabta/services/ai/expat_score_live_calculator.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

/// Detail-screen category cards derived from live score + category metadata.
class ExpatScoreCategoryDetail {
  const ExpatScoreCategoryDetail({
    required this.emoji,
    required this.title,
    required this.score,
    required this.color,
    required this.completed,
    required this.pending,
    this.insufficientData = false,
    this.detailExplanation,
    this.confidence,
  });

  final String emoji;
  final String title;
  final int score;
  final Color color;
  final List<String> completed;
  final List<String> pending;
  final bool insufficientData;
  final Explanation? detailExplanation;
  final double? confidence;
}

abstract final class ExpatScoreCategoryDetailHelper {
  static bool _hasFlag(UserAIProfile profile, String key) {
    final set = profile.interests.map((e) => e.toLowerCase()).toSet();
    return set.contains(key.toLowerCase()) ||
        set.any((i) => i.startsWith('$key:'));
  }

  static List<ExpatScoreCategoryDetail> buildCategories(
    UserAIProfile profile,
    ExpatLifeScore score,
    String locale,
  ) {
    return [
      _career(profile, score, locale),
      _housing(profile, score, locale),
      _financial(profile, score, locale),
      _community(profile, score, locale),
      _documentation(profile, score, locale),
    ];
  }

  static ExpatScoreCategoryMeta? _meta(
    ExpatLifeScore score,
    String key,
  ) =>
      score.categoryMeta[key];

  static Explanation? _detailExplanation(ExpatScoreCategoryMeta? meta) {
    if (meta == null) return null;
    if (meta.changeExplanation != null) return meta.changeExplanation;
    if (meta.evidenceLines.isEmpty) return null;
    return Explanation(
      why: meta.evidenceLines.join('\n'),
      source: const IntelligenceSource(
        type: 'user',
        reference: 'users/profile',
        verificationStatus: 'verified',
      ),
      confidence: meta.confidence,
      lastUpdated: DateTime.now(),
    );
  }

  static ExpatScoreCategoryDetail _career(
    UserAIProfile profile,
    ExpatLifeScore score,
    String locale,
  ) {
    final categoryMeta = _meta(score, 'career');
    final pct = ExpatScoreProfileHelper.normalizeCategoryPercent(
      score.career,
      'career',
    ).round();
    final completed = <String>[];
    final pending = <String>[];

    if (profile.profession.trim().isNotEmpty) {
      completed.add(ExpatScoreStrings.t('checklist_profession_set', locale));
    } else {
      pending.add(ExpatScoreStrings.t('checklist_add_profession', locale));
    }
    if (profile.skills.length >= 3) {
      completed.add(
        ExpatScoreStrings.format(
          'checklist_skills_listed',
          locale,
          params: {'count': '${profile.skills.length}'},
        ),
      );
    } else {
      pending.add(ExpatScoreStrings.t('checklist_add_skills', locale));
    }
    if (profile.certifications.isNotEmpty) {
      completed.add(ExpatScoreStrings.t('checklist_certs_added', locale));
    } else {
      pending.add(ExpatScoreStrings.t('checklist_add_certs', locale));
    }
    if (profile.viewedJobIds.length >= 5) {
      completed.add(
        ExpatScoreStrings.format(
          'checklist_jobs_explored',
          locale,
          params: {'count': '${profile.viewedJobIds.length}'},
        ),
      );
    } else {
      pending.add(ExpatScoreStrings.t('checklist_view_jobs', locale));
    }
    if (profile.savedJobIds.isNotEmpty) {
      completed.add(
        ExpatScoreStrings.format(
          'checklist_jobs_saved',
          locale,
          params: {'count': '${profile.savedJobIds.length}'},
        ),
      );
    } else {
      pending.add(ExpatScoreStrings.t('checklist_save_jobs', locale));
    }
    if (_hasFlag(profile, 'profile:cv_complete')) {
      completed.add(ExpatScoreStrings.t('checklist_cv_complete', locale));
    } else if (_hasFlag(profile, 'profile:cv_started')) {
      pending.add(ExpatScoreStrings.t('checklist_finish_cv', locale));
    } else {
      pending.add(ExpatScoreStrings.t('checklist_start_cv', locale));
    }

    return ExpatScoreCategoryDetail(
      emoji: '💼',
      title: AppShellStrings.t('score_category_career', locale),
      score: pct,
      color: AppColors.cyanGlow,
      completed: completed,
      pending: pending,
      detailExplanation: _detailExplanation(categoryMeta),
      confidence: categoryMeta?.confidence,
    );
  }

  static ExpatScoreCategoryDetail _housing(
    UserAIProfile profile,
    ExpatLifeScore score,
    String locale,
  ) {
    final categoryMeta = _meta(score, 'housing');
    final insufficient = categoryMeta?.insufficientData == true;
    final pct = insufficient
        ? 0
        : ExpatScoreProfileHelper.normalizeCategoryPercent(
            score.housing,
            'housing',
          ).round();
    final completed = <String>[];
    final pending = <String>[];

    if (insufficient) {
      pending.add(
        categoryMeta?.evidenceLines.first ??
            ExpatScoreStrings.t('checklist_housing_insufficient', locale),
      );
    } else {
      if (profile.preferredArea.trim().isNotEmpty) {
        completed.add(
          ExpatScoreStrings.format(
            'checklist_preferred_area',
            locale,
            params: {'area': profile.preferredArea},
          ),
        );
      } else {
        pending.add(ExpatScoreStrings.t('checklist_set_area', locale));
      }
      if (profile.savedHousingIds.isNotEmpty ||
          _hasFlag(profile, 'profile:housing_confirmed')) {
        completed.add(ExpatScoreStrings.t('checklist_housing_active', locale));
      } else {
        pending.add(ExpatScoreStrings.t('checklist_browse_housing', locale));
      }
      if (profile.viewedHousingIds.length >= 3) {
        completed.add(
          ExpatScoreStrings.format(
            'checklist_housing_viewed',
            locale,
            params: {'count': '${profile.viewedHousingIds.length}'},
          ),
        );
      } else {
        pending.add(ExpatScoreStrings.t('checklist_view_housing', locale));
      }
      if (_hasFlag(profile, 'profile:housing_review')) {
        completed.add(ExpatScoreStrings.t('checklist_housing_review', locale));
      } else {
        pending.add(ExpatScoreStrings.t('checklist_add_housing_review', locale));
      }
    }

    return ExpatScoreCategoryDetail(
      emoji: '🏠',
      title: AppShellStrings.t('score_category_housing', locale),
      score: pct,
      color: AppColors.blueGlow,
      completed: completed,
      pending: pending,
      insufficientData: insufficient,
      detailExplanation: _detailExplanation(categoryMeta),
      confidence: categoryMeta?.confidence,
    );
  }

  static ExpatScoreCategoryDetail _financial(
    UserAIProfile profile,
    ExpatLifeScore score,
    String locale,
  ) {
    final categoryMeta = _meta(score, 'financial');
    final pct = ExpatScoreProfileHelper.normalizeCategoryPercent(
      score.financial,
      'financial',
    ).round();
    final completed = <String>[];
    final pending = <String>[];

    final budgetMin = profile.budgetRange['min'] ?? 0;
    if (budgetMin > 0) {
      completed.add(ExpatScoreStrings.t('checklist_budget_set', locale));
    } else {
      pending.add(ExpatScoreStrings.t('checklist_set_budget', locale));
    }
    if (_hasFlag(profile, 'profile:money_transfer')) {
      completed.add(ExpatScoreStrings.t('checklist_transfer_tracked', locale));
    } else {
      pending.add(ExpatScoreStrings.t('checklist_set_transfer', locale));
    }
    if (_hasFlag(profile, 'profile:exchange_alerts')) {
      completed.add(ExpatScoreStrings.t('checklist_exchange_alerts', locale));
    } else {
      pending.add(ExpatScoreStrings.t('checklist_enable_exchange', locale));
    }
    if (_hasFlag(profile, 'profile:eosb_calculation')) {
      completed.add(ExpatScoreStrings.t('checklist_eosb_done', locale));
    } else {
      pending.add(ExpatScoreStrings.t('checklist_run_eosb', locale));
    }
    if (_hasFlag(profile, 'profile:bill_tracker')) {
      completed.add(ExpatScoreStrings.t('checklist_bills_tracked', locale));
    } else {
      pending.add(ExpatScoreStrings.t('checklist_add_bills', locale));
    }

    for (final line in categoryMeta?.evidenceLines ?? const <String>[]) {
      if (line.startsWith('Risk:') || line.startsWith('Data mismatch:')) {
        pending.add(line);
      }
    }

    return ExpatScoreCategoryDetail(
      emoji: '💰',
      title: AppShellStrings.t('score_category_financial', locale),
      score: pct,
      color: AppColors.amberGlow,
      completed: completed,
      pending: pending,
      detailExplanation: _detailExplanation(categoryMeta),
      confidence: categoryMeta?.confidence,
    );
  }

  static ExpatScoreCategoryDetail _community(
    UserAIProfile profile,
    ExpatLifeScore score,
    String locale,
  ) {
    final categoryMeta = _meta(score, 'community');
    final insufficient = categoryMeta?.insufficientData == true;
    final pct = insufficient
        ? 0
        : ExpatScoreProfileHelper.normalizeCategoryPercent(
            score.community,
            'community',
          ).round();
    final completed = <String>[];
    final pending = <String>[];

    if (insufficient) {
      pending.add(
        categoryMeta?.evidenceLines.first ??
            ExpatScoreStrings.t('checklist_community_insufficient', locale),
      );
    } else {
      if (profile.communityGroups.isNotEmpty) {
        completed.add(
          ExpatScoreStrings.format(
            'checklist_groups_joined',
            locale,
            params: {'count': '${profile.communityGroups.length}'},
          ),
        );
      } else {
        pending.add(ExpatScoreStrings.t('checklist_join_group', locale));
      }
      if (_hasFlag(profile, 'profile:community_posts')) {
        completed.add(ExpatScoreStrings.t('checklist_posts_published', locale));
      } else {
        pending.add(ExpatScoreStrings.t('checklist_post_community', locale));
      }
      if (_hasFlag(profile, 'profile:questions_answered')) {
        completed.add(
          ExpatScoreStrings.t('checklist_questions_answered', locale),
        );
      } else {
        pending.add(ExpatScoreStrings.t('checklist_answer_questions', locale));
      }
      if (_hasFlag(profile, 'profile:events_attended')) {
        completed.add(ExpatScoreStrings.t('checklist_events_attended', locale));
      } else {
        pending.add(ExpatScoreStrings.t('checklist_attend_event', locale));
      }
    }

    return ExpatScoreCategoryDetail(
      emoji: '👥',
      title: AppShellStrings.t('score_category_community', locale),
      score: pct,
      color: AppColors.purpleGlow,
      completed: completed,
      pending: pending,
      insufficientData: insufficient,
      detailExplanation: _detailExplanation(categoryMeta),
      confidence: categoryMeta?.confidence,
    );
  }

  static ExpatScoreCategoryDetail _documentation(
    UserAIProfile profile,
    ExpatLifeScore score,
    String locale,
  ) {
    final categoryMeta = _meta(score, 'documentation');
    final pct = ExpatScoreProfileHelper.normalizeCategoryPercent(
      score.documentation,
      'documentation',
    ).round();
    final completed = <String>[];
    final pending = <String>[];

    if (_hasFlag(profile, 'profile:iqama_expiry') ||
        _hasFlag(profile, 'profile:vault_visa')) {
      completed.add(ExpatScoreStrings.t('checklist_iqama_tracked', locale));
    } else {
      pending.add(ExpatScoreStrings.t('checklist_set_iqama', locale));
    }
    if (_hasFlag(profile, 'profile:passport_expiry') ||
        _hasFlag(profile, 'profile:vault_passport')) {
      completed.add(ExpatScoreStrings.t('checklist_passport_tracked', locale));
    } else {
      pending.add(ExpatScoreStrings.t('checklist_add_passport', locale));
    }
    if (_hasFlag(profile, 'profile:qid_info') ||
        _hasFlag(profile, 'profile:vault_qid')) {
      completed.add(ExpatScoreStrings.t('checklist_qid_added', locale));
    } else {
      pending.add(ExpatScoreStrings.t('checklist_add_qid', locale));
    }
    if (_hasFlag(profile, 'profile:work_permit') ||
        _hasFlag(profile, 'profile:vault_driving')) {
      completed.add(ExpatScoreStrings.t('checklist_permit_tracked', locale));
    } else {
      pending.add(ExpatScoreStrings.t('checklist_add_permit', locale));
    }

    for (final line in categoryMeta?.evidenceLines ?? const <String>[]) {
      if (line.startsWith('Risk:')) {
        pending.add(line);
      }
    }

    return ExpatScoreCategoryDetail(
      emoji: '📋',
      title: AppShellStrings.t('score_category_documentation', locale),
      score: pct,
      color: AppColors.emeraldGlow,
      completed: completed,
      pending: pending,
      detailExplanation: _detailExplanation(categoryMeta),
      confidence: categoryMeta?.confidence,
    );
  }
}
