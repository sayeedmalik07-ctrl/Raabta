import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_risk_banner.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_alert_config.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_alert_delivery.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_alert_state_repository.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_awareness_models.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_guidance_catalog.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_guidance_strings.dart';
import 'package:raabta/models/intelligence/intelligence_insight.dart';
import 'package:raabta/models/intelligence/intelligence_source.dart';
import 'package:raabta/models/notification_models.dart';
import 'package:raabta/services/intelligence/attention_scorer.dart';

/// Resolves time-limited security campaigns for Home Today (Phase 30).
class SecurityAwarenessService {
  SecurityAwarenessService({
    SecurityAlertStateRepository? repository,
    DateTime Function()? clock,
  })  : _repository = repository ?? SecurityAlertStateRepository(),
        _clock = clock;

  final SecurityAlertStateRepository _repository;
  final DateTime Function()? _clock;

  DateTime get _now => _clock?.call() ?? DateTime.now();

  static const insightType = 'security_awareness';

  Future<SecurityAwarenessCampaign?> resolve({
    required NotificationSettings settings,
    required String locale,
    String userId = 'local',
  }) async {
    if (!settings.securityTodayCards) return null;

    final now = _now;
    final post = await _resolvePostIncident(now, locale);
    if (post != null) return post;

    final advisory = await _resolveAdvisory(now, locale);
    if (advisory != null) return advisory;

    return _resolveMonthlyTip(now, locale, userId: userId);
  }

  Future<SecurityAwarenessCampaign?> _resolvePostIncident(
    DateTime now,
    String locale,
  ) async {
    final untilRaw = await _repository.read(
      SecurityAlertStateRepository.postIncidentUntilKey,
    );
    final until = _parse(untilRaw);
    if (until == null || !until.isAfter(now)) return null;
    if (await _isDismissed('post_incident')) return null;

    final shared = await SecurityGuidanceCatalog.loadSharedSomething();
    if (shared == null) return null;

    final steps = [
      for (final key in shared.stepKeys.take(3))
        SecurityGuidanceStrings.t(key, locale),
    ];

    return SecurityAwarenessCampaign(
      id: 'post_incident',
      kind: SecurityAwarenessCampaignKind.postIncident,
      headline: SecurityGuidanceStrings.t(shared.headlineKey, locale),
      steps: steps,
      sourceLabel: SecurityGuidanceStrings.t('ss_sec_source_pattern', locale),
      ctaLabel: SecurityGuidanceStrings.t('ss_sec_shared_call_bank', locale),
      ctaRoute: 'shared_something_sheet',
      secondaryCtaLabel: SecurityGuidanceStrings.t('ss_sec_today_learn_steps', locale),
      secondaryCtaRoute: 'shared_something_sheet',
      expiresAt: until,
      elevatedVisual: true,
      attentionComposite: _boundedComposite(
        id: 'post_incident',
        userId: 'local',
        now: now,
        expiresAt: until,
      ),
    );
  }

  Future<SecurityAwarenessCampaign?> _resolveAdvisory(
    DateTime now,
    String locale,
  ) async {
    final advisoryId = await _repository.read(
      SecurityAlertStateRepository.activeAdvisoryIdKey,
    );
    if (advisoryId == null || advisoryId.isEmpty) return null;
    if (await _isDismissed('advisory_$advisoryId')) return null;

    final startedRaw = await _repository.read(
      SecurityAlertStateRepository.activeAdvisoryStartedKey,
    );
    final started = _parse(startedRaw) ?? now;
    final expiresAt = started.add(
      const Duration(days: SecurityAlertConfig.advisoryCampaignDays),
    );
    if (!expiresAt.isAfter(now)) return null;

    final topics = await SecurityAlertDelivery.verifiedTopics();
    final topic = topics.isNotEmpty ? topics.first : null;
    final variantKey = topic != null
        ? _variantForDay(topic.variantKeys, started, now)
        : 'ss_sec_push_advisory_body';
    final body = topic != null
        ? SecurityGuidanceStrings.t(variantKey, locale)
        : SecurityGuidanceStrings.t('ss_sec_push_advisory_body', locale);

    return SecurityAwarenessCampaign(
      id: 'advisory_$advisoryId',
      kind: SecurityAwarenessCampaignKind.elevatedAdvisory,
      headline: SecurityGuidanceStrings.t('ss_sec_advisory_card_headline', locale),
      steps: _stepsFromVariant(body),
      sourceLabel: SecurityGuidanceStrings.t('ss_sec_source_pattern', locale),
      ctaLabel: SecurityGuidanceStrings.t('ss_sec_today_view_advisory', locale),
      ctaRoute: '/scam-shield/advisories/$advisoryId',
      expiresAt: expiresAt,
      elevatedVisual: true,
      attentionComposite: _boundedComposite(
        id: 'advisory_$advisoryId',
        userId: 'local',
        now: now,
        expiresAt: expiresAt,
      ),
      advisoryId: advisoryId,
    );
  }

  Future<SecurityAwarenessCampaign?> _resolveMonthlyTip(
    DateTime now,
    String locale, {
    required String userId,
  }) async {
    final untilRaw = await _repository.read(
      SecurityAlertStateRepository.monthlyCampaignUntilKey,
    );
    final until = _parse(untilRaw);
    if (until == null || !until.isAfter(now)) return null;
    if (await _isDismissed('monthly_tip')) return null;

    final topics = await SecurityAlertDelivery.verifiedTopics();
    if (topics.isEmpty) return null;

    final topicId = await _repository.read(
      SecurityAlertStateRepository.lastTopicIdKey,
    );
    final topic = topics.firstWhere(
      (t) => t.id == topicId,
      orElse: () => topics.first,
    );
    final campaignStart = until.subtract(
      const Duration(days: SecurityAlertConfig.monthlyTipCampaignDays),
    );
    final variantKey = _variantForDay(topic.variantKeys, campaignStart, now);
    final body = SecurityGuidanceStrings.t(variantKey, locale);

    return SecurityAwarenessCampaign(
      id: 'monthly_tip',
      kind: SecurityAwarenessCampaignKind.monthlyTip,
      headline: SecurityGuidanceStrings.t(topic.titleKey, locale),
      steps: _stepsFromVariant(body),
      sourceLabel: SecurityGuidanceStrings.t(topic.sourceLabelKey, locale),
      ctaLabel: SecurityGuidanceStrings.t('ss_sec_today_open_tip', locale),
      ctaRoute: '/scam-shield/security-tip?topic=${topic.id}',
      expiresAt: until,
      elevatedVisual: false,
      attentionComposite: _boundedComposite(
        id: 'monthly_tip',
        userId: userId,
        now: now,
        expiresAt: until,
      ),
      topicId: topic.id,
    );
  }

  Future<void> dismissCampaign(String campaignId) async {
    await _repository.write('campaign_dismiss_$campaignId', 'true');
    await SecurityAlertDelivery.recordTipOpened();
  }

  Future<bool> _isDismissed(String campaignId) async {
    return await _repository.read('campaign_dismiss_$campaignId') == 'true';
  }

  static List<String> _stepsFromVariant(String variant) {
    final parts = variant.split('—').map((s) => s.trim()).where((s) => s.isNotEmpty);
    final list = parts.toList();
    if (list.length >= 2) return list.take(3).toList();
    return [variant];
  }

  static String _variantForDay(
    List<String> variantKeys,
    DateTime campaignStart,
    DateTime now,
  ) =>
      variantForDayForTest(variantKeys, campaignStart, now);

  @visibleForTesting
  static String variantForDayForTest(
    List<String> variantKeys,
    DateTime campaignStart,
    DateTime now,
  ) {
    if (variantKeys.isEmpty) return '';
    final dayIndex = now.difference(campaignStart).inDays.abs();
    return variantKeys[dayIndex % variantKeys.length];
  }

  static double _boundedComposite({
    required String id,
    required String userId,
    required DateTime now,
    required DateTime expiresAt,
  }) {
    final insight = IntelligenceInsight(
      id: id,
      userId: userId,
      type: insightType,
      summary: 'security',
      confidence: 0.85,
      source: const IntelligenceSource(
        type: 'official',
        verificationStatus: 'verified',
      ),
      createdAt: now,
      expiresAt: expiresAt,
    );
    final scorer = AttentionScorer(
      typeSeverity: {insightType: 0.9},
      now: now,
    );
    final composite = scorer.compositeScore(insight);
    return composite.clamp(0.0, SecurityAlertConfig.todayCardMaxComposite);
  }

  static DateTime? _parse(String? raw) =>
      raw == null ? null : DateTime.tryParse(raw);

  /// Accent for elevated advisories — uses ScamShield tokens.
  static Color accentForCampaign(SecurityAwarenessCampaign campaign) {
    if (campaign.elevatedVisual) {
      return scamShieldRiskColor(ScamShieldRiskLevel.high);
    }
    return scamShieldRiskColor(ScamShieldRiskLevel.low);
  }
}
