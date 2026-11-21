import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/health_insurance/data/models/claim_dispute_models.dart';
import 'package:raabta/features/health_insurance/data/repository/health_insurance_repository.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_models.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_compliance_models.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_condition_models.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_lease_input.dart';
import 'package:raabta/models/notification_models.dart';
import 'package:raabta/services/notifications/notification_engine.dart';
import 'package:raabta/services/raabta_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kHealthInsuranceRoute = '/health-insurance';
const _kEosbRoute = '/eosb';
const _kSponsorshipTransferRoute = '/sponsorship-transfer';
const _kTenancyRoute = '/tenancy';

/// Which Truth Engine triggered the Job Transition ↔ Health Insurance correlation.
enum LifeEventTriggerEngine {
  eosb,
  sponsorshipTransfer,
}

/// Domains tracked by Life Shock cluster detection (v2 extension).
enum LifeEventShockDomain {
  labour,
  healthInsurance,
  tenancy,
}

/// A single domain with distress activity inside the correlation window.
class LifeEventDomainActivity {
  const LifeEventDomainActivity({
    required this.domain,
    required this.activeDate,
    this.labourEngine,
  });

  final LifeEventShockDomain domain;
  final DateTime activeDate;
  final LifeEventTriggerEngine? labourEngine;
}

/// Two or more domains with correlated distress within [kLifeEventWindowDays].
class LifeEventShockCluster {
  const LifeEventShockCluster({
    required this.activities,
  });

  final Map<LifeEventShockDomain, LifeEventDomainActivity> activities;

  Set<LifeEventShockDomain> get activeDomains => activities.keys.toSet();

  String domainLabels(String locale) {
    final ordered = [
      LifeEventShockDomain.labour,
      LifeEventShockDomain.healthInsurance,
      LifeEventShockDomain.tenancy,
    ].where(activeDomains.contains).map((d) => _domainLabel(d, locale));
    return ordered.join(', ');
  }

  String routeForDomain(LifeEventShockDomain domain) => switch (domain) {
        LifeEventShockDomain.labour =>
          activities[domain]?.labourEngine == LifeEventTriggerEngine.eosb
              ? _kEosbRoute
              : _kSponsorshipTransferRoute,
        LifeEventShockDomain.healthInsurance => _kHealthInsuranceRoute,
        LifeEventShockDomain.tenancy => _kTenancyRoute,
      };

  String ctaLabelForDomain(LifeEventShockDomain domain, String locale) =>
      switch (domain) {
        LifeEventShockDomain.labour =>
          activities[domain]?.labourEngine == LifeEventTriggerEngine.eosb
              ? AppShellStrings.t('life_event_shock_cluster_cta_eosb', locale)
              : AppShellStrings.t(
                  'life_event_shock_cluster_cta_sponsorship',
                  locale,
                ),
        LifeEventShockDomain.healthInsurance => AppShellStrings.t(
            'life_event_shock_cluster_cta_health_insurance',
            locale,
          ),
        LifeEventShockDomain.tenancy =>
          AppShellStrings.t('life_event_shock_cluster_cta_tenancy', locale),
      };

  String notificationDedupKey() => 'life_event_shock_cluster_v1';

  String primaryNotificationRoute() {
    LifeEventShockDomain? latestDomain;
    DateTime? latestDate;
    for (final entry in activities.entries) {
      if (latestDate == null || entry.value.activeDate.isAfter(latestDate)) {
        latestDate = entry.value.activeDate;
        latestDomain = entry.key;
      }
    }
    return routeForDomain(latestDomain ?? activeDomains.first);
  }

  static String _domainLabel(LifeEventShockDomain domain, String locale) =>
      switch (domain) {
        LifeEventShockDomain.labour =>
          AppShellStrings.t('life_event_domain_labour', locale),
        LifeEventShockDomain.healthInsurance => AppShellStrings.t(
            'life_event_domain_health_insurance',
            locale,
          ),
        LifeEventShockDomain.tenancy =>
          AppShellStrings.t('life_event_domain_tenancy', locale),
      };
}

/// Active correlation eligible for Today-zone card + notification.
class LifeEventHealthCoverageCorrelation {
  const LifeEventHealthCoverageCorrelation({
    required this.engine,
    required this.caseActiveDate,
  });

  final LifeEventTriggerEngine engine;
  final DateTime caseActiveDate;

  String engineLabel(String locale) => switch (engine) {
        LifeEventTriggerEngine.eosb =>
          AppShellStrings.t('life_event_engine_eosb', locale),
        LifeEventTriggerEngine.sponsorshipTransfer => AppShellStrings.t(
            'life_event_engine_sponsorship_transfer',
            locale,
          ),
      };

  String notificationDedupKey() => switch (engine) {
        LifeEventTriggerEngine.eosb =>
          'life_event_health_coverage_eosb',
        LifeEventTriggerEngine.sponsorshipTransfer =>
          'life_event_health_coverage_sponsorship_transfer',
      };
}

/// Deterministic Job Transition ↔ Health Insurance gap detector (Life Events v1).
class LifeEventsCorrelationService {
  LifeEventsCorrelationService({
    SharedPreferences? prefs,
    FirebaseFirestore? firestore,
  })  : _prefs = prefs,
        _firestore = firestore ?? FirebaseFirestore.instance;

  static const kLifeEventWindowDays = 30;
  static const healthInsuranceRoute = _kHealthInsuranceRoute;
  static const eosbRoute = _kEosbRoute;
  static const sponsorshipTransferRoute = _kSponsorshipTransferRoute;
  static const tenancyRoute = _kTenancyRoute;

  static const shockClusterPromptAtPrefsKey =
      'life_event_shock_cluster_prompt_at_v1';
  static const shockClusterFirestorePromptField =
      'lastShockClusterPromptAt';

  /// Per-engine prompt timestamps (v1).
  static const eosbPromptAtPrefsKey =
      'life_event_health_coverage_eosb_prompt_at_v1';
  static const sponsorshipPromptAtPrefsKey =
      'life_event_health_coverage_sponsorship_transfer_prompt_at_v1';

  /// Legacy global key — read as EOSB fallback only so existing users are not
  /// re-prompted for EOSB; ST uses per-engine keys only (see [_readLastPromptAtForEngine]).
  static const legacyPromptAtPrefsKey =
      'life_event_health_coverage_prompt_at_v1';

  /// Deprecated alias kept for tests referencing the old global key name.
  static const promptAtPrefsKey = legacyPromptAtPrefsKey;

  static String promptAtPrefsKeyFor(LifeEventTriggerEngine engine) =>
      switch (engine) {
        LifeEventTriggerEngine.eosb => eosbPromptAtPrefsKey,
        LifeEventTriggerEngine.sponsorshipTransfer => sponsorshipPromptAtPrefsKey,
      };

  static String firestorePromptFieldFor(LifeEventTriggerEngine engine) =>
      switch (engine) {
        LifeEventTriggerEngine.eosb => 'lastHealthCoveragePromptAtEosb',
        LifeEventTriggerEngine.sponsorshipTransfer =>
          'lastHealthCoveragePromptAtSponsorshipTransfer',
      };

  final SharedPreferences? _prefs;
  final FirebaseFirestore _firestore;

  /// Pure date-math evaluation — no I/O, no AI.
  ///
  /// Dedupe is checked per [lastEosbPromptAt] / [lastSponsorshipPromptAt] after
  /// the winning engine is selected.
  static LifeEventHealthCoverageCorrelation? evaluateHealthCoverageCorrelation({
    required DateTime now,
    DateTime? eosbCaseDate,
    DateTime? sponsorshipCaseDate,
    DateTime? healthInsuranceLastReviewedAt,
    DateTime? lastEosbPromptAt,
    DateTime? lastSponsorshipPromptAt,
  }) {
    final windowStart = now.subtract(const Duration(days: kLifeEventWindowDays));
    final eosbInWindow =
        eosbCaseDate != null && !eosbCaseDate.isBefore(windowStart);
    final sponsorshipInWindow = sponsorshipCaseDate != null &&
        !sponsorshipCaseDate.isBefore(windowStart);

    LifeEventTriggerEngine? engine;
    DateTime? caseDate;

    if (eosbInWindow && sponsorshipInWindow) {
      if (eosbCaseDate.isAfter(sponsorshipCaseDate)) {
        engine = LifeEventTriggerEngine.eosb;
        caseDate = eosbCaseDate;
      } else {
        engine = LifeEventTriggerEngine.sponsorshipTransfer;
        caseDate = sponsorshipCaseDate;
      }
    } else if (eosbInWindow) {
      engine = LifeEventTriggerEngine.eosb;
      caseDate = eosbCaseDate;
    } else if (sponsorshipInWindow) {
      engine = LifeEventTriggerEngine.sponsorshipTransfer;
      caseDate = sponsorshipCaseDate;
    }

    if (engine == null || caseDate == null) return null;

    final lastPromptForEngine = switch (engine) {
      LifeEventTriggerEngine.eosb => lastEosbPromptAt,
      LifeEventTriggerEngine.sponsorshipTransfer => lastSponsorshipPromptAt,
    };
    if (_wasPromptedRecently(lastPromptForEngine, now)) return null;

    if (_healthInsuranceRecentlyReviewed(
      lastReviewedAt: healthInsuranceLastReviewedAt,
      caseActiveDate: caseDate,
      now: now,
    )) {
      return null;
    }

    return LifeEventHealthCoverageCorrelation(
      engine: engine,
      caseActiveDate: caseDate,
    );
  }

  static bool _wasPromptedRecently(DateTime? lastPromptAt, DateTime now) {
    if (lastPromptAt == null) return false;
    return !lastPromptAt
        .isBefore(now.subtract(const Duration(days: kLifeEventWindowDays)));
  }

  static bool _healthInsuranceRecentlyReviewed({
    required DateTime? lastReviewedAt,
    required DateTime caseActiveDate,
    required DateTime now,
  }) {
    if (lastReviewedAt == null) return false;

    final windowStart = now.subtract(const Duration(days: kLifeEventWindowDays));
    final reviewedInWindow = !lastReviewedAt.isBefore(windowStart);
    final reviewedAfterCaseStart = !lastReviewedAt.isBefore(caseActiveDate);

    return reviewedInWindow && reviewedAfterCaseStart;
  }

  /// Labour / Sponsorship activity within the correlation window.
  static LifeEventDomainActivity? evaluateLabourDistress({
    required DateTime now,
    DateTime? eosbCaseDate,
    DateTime? sponsorshipCaseDate,
  }) {
    final windowStart =
        now.subtract(const Duration(days: kLifeEventWindowDays));
    final eosbInWindow =
        eosbCaseDate != null && !eosbCaseDate.isBefore(windowStart);
    final sponsorshipInWindow = sponsorshipCaseDate != null &&
        !sponsorshipCaseDate.isBefore(windowStart);

    LifeEventTriggerEngine? engine;
    DateTime? caseDate;

    if (eosbInWindow && sponsorshipInWindow) {
      if (eosbCaseDate.isAfter(sponsorshipCaseDate)) {
        engine = LifeEventTriggerEngine.eosb;
        caseDate = eosbCaseDate;
      } else {
        engine = LifeEventTriggerEngine.sponsorshipTransfer;
        caseDate = sponsorshipCaseDate;
      }
    } else if (eosbInWindow) {
      engine = LifeEventTriggerEngine.eosb;
      caseDate = eosbCaseDate;
    } else if (sponsorshipInWindow) {
      engine = LifeEventTriggerEngine.sponsorshipTransfer;
      caseDate = sponsorshipCaseDate;
    }

    if (engine == null || caseDate == null) return null;

    return LifeEventDomainActivity(
      domain: LifeEventShockDomain.labour,
      activeDate: caseDate,
      labourEngine: engine,
    );
  }

  /// Health Insurance distress: unresolved compliance violation or active claim
  /// denial tracking within the window.
  static LifeEventDomainActivity? evaluateHealthInsuranceDistress({
    required DateTime now,
    DateTime? complianceCheckedAt,
    bool hasUnresolvedViolation = false,
    DateTime? claimDisputeUpdatedAt,
    DateTime? claimDisputeDenialDate,
  }) {
    final windowStart =
        now.subtract(const Duration(days: kLifeEventWindowDays));
    DateTime? distressDate;

    if (hasUnresolvedViolation &&
        complianceCheckedAt != null &&
        !complianceCheckedAt.isBefore(windowStart)) {
      distressDate = _latestDate([distressDate, complianceCheckedAt]);
    }

    for (final candidate in [claimDisputeUpdatedAt, claimDisputeDenialDate]) {
      if (candidate != null && !candidate.isBefore(windowStart)) {
        distressDate = _latestDate([distressDate, candidate]);
      }
    }

    if (distressDate == null) return null;

    return LifeEventDomainActivity(
      domain: LifeEventShockDomain.healthInsurance,
      activeDate: distressDate,
    );
  }

  /// Tenancy distress: compliance flags, dispute packet, or move-out condition
  /// record within the window.
  static LifeEventDomainActivity? evaluateTenancyDistress({
    required DateTime now,
    DateTime? latestCheckedAt,
    bool hasCriticalIssue = false,
    bool hasViolation = false,
    bool depositOverCap = false,
    DateTime? latestPacketGeneratedAt,
    DateTime? latestMoveOutRecordAt,
  }) {
    final windowStart =
        now.subtract(const Duration(days: kLifeEventWindowDays));
    DateTime? distressDate;

    if (latestCheckedAt != null && !latestCheckedAt.isBefore(windowStart)) {
      if (hasCriticalIssue || hasViolation || depositOverCap) {
        distressDate = _latestDate([distressDate, latestCheckedAt]);
      }
    }

    if (latestPacketGeneratedAt != null &&
        !latestPacketGeneratedAt.isBefore(windowStart)) {
      distressDate = _latestDate([distressDate, latestPacketGeneratedAt]);
    }

    if (latestMoveOutRecordAt != null &&
        !latestMoveOutRecordAt.isBefore(windowStart)) {
      distressDate = _latestDate([distressDate, latestMoveOutRecordAt]);
    }

    if (distressDate == null) return null;

    return LifeEventDomainActivity(
      domain: LifeEventShockDomain.tenancy,
      activeDate: distressDate,
    );
  }

  /// Pure evaluation — fires when ≥2 domains show distress in the window.
  static LifeEventShockCluster? evaluateShockCluster({
    required DateTime now,
    LifeEventDomainActivity? labour,
    LifeEventDomainActivity? healthInsurance,
    LifeEventDomainActivity? tenancy,
    DateTime? lastClusterPromptAt,
  }) {
    if (_wasPromptedRecently(lastClusterPromptAt, now)) return null;

    final activities = <LifeEventShockDomain, LifeEventDomainActivity>{};
    for (final activity in [labour, healthInsurance, tenancy]) {
      if (activity == null) continue;
      activities[activity.domain] = activity;
    }

    if (activities.length < 2) return null;

    return LifeEventShockCluster(activities: activities);
  }

  static DateTime? latestMoveOutRecordAt(
    List<TenancyConditionRecord> records,
  ) {
    DateTime? latest;
    for (final record in records) {
      if (record.recordType != TenancyConditionRecordType.moveOut) continue;
      latest = _latestDate([latest, record.createdAt]);
    }
    return latest;
  }

  static ({
    DateTime? latestCheckedAt,
    bool hasCriticalIssue,
    bool hasViolation,
    bool depositOverCap,
    DateTime? latestPacketGeneratedAt,
  }) tenancyDistressSnapshot({
    TenancyComplianceResult? cachedResult,
    TenancyLeaseInput? cachedInput,
    DateTime? summaryCheckedAt,
    bool? summaryHasCriticalIssue,
    bool? summaryHasViolation,
    DateTime? summaryPacketGeneratedAt,
  }) {
    final result = cachedResult;
    final input = cachedInput;
    return (
      latestCheckedAt: _latestDate([
        result?.checkedAt,
        summaryCheckedAt,
      ]),
      hasCriticalIssue:
          result?.hasCriticalIssue ?? summaryHasCriticalIssue ?? false,
      hasViolation: result?.hasViolation ?? summaryHasViolation ?? false,
      depositOverCap: input?.isDepositOverCap ?? false,
      latestPacketGeneratedAt: summaryPacketGeneratedAt,
    );
  }

  static ({
    DateTime? complianceCheckedAt,
    bool hasUnresolvedViolation,
    DateTime? claimDisputeUpdatedAt,
    DateTime? claimDisputeDenialDate,
  }) healthInsuranceDistressSnapshot({
    HealthInsuranceRepository? healthInsuranceRepository,
    HealthInsuranceClaimDispute? claimDispute,
  }) {
    final repo = healthInsuranceRepository;
    final result = repo?.loadCachedResult();
    final dispute = claimDispute;
    return (
      complianceCheckedAt: result?.checkedAt,
      hasUnresolvedViolation: repo?.hasUnresolvedViolation() ?? false,
      claimDisputeUpdatedAt: dispute?.updatedAt,
      claimDisputeDenialDate: dispute?.denialDate,
    );
  }

  Future<LifeEventHealthCoverageCorrelation?> loadHealthCoverageCorrelation({
    required String userId,
    List<CalculationHistoryEntry> eosbHistory = const [],
    TransferReadinessResult? sponsorshipCachedResult,
    HealthInsuranceRepository? healthInsuranceRepository,
    DateTime? now,
    bool includePromptDedupe = true,
  }) async {
    final clock = now ?? DateTime.now();
    final prefs = _prefs ?? await SharedPreferences.getInstance();

    final eosbDate = _latestDate([
      _parseIso(
        await _readUserSummaryField(userId, 'eosbSummary', 'latestCalculatedAt'),
      ),
      if (eosbHistory.isNotEmpty) eosbHistory.first.savedAt,
      if (eosbHistory.isNotEmpty) eosbHistory.first.result.calculatedAt,
    ]);

    final sponsorshipDate = _latestDate([
      _parseIso(await _readUserSummaryField(
        userId,
        'sponsorshipTransferSummary',
        'latestCheckedAt',
      )),
      sponsorshipCachedResult?.checkedAt,
    ]);

    final healthReviewedAt = healthInsuranceRepository?.lastReviewedAt();
    final lastEosbPromptAt = includePromptDedupe
        ? await _readLastPromptAtForEngine(
            LifeEventTriggerEngine.eosb,
            userId,
            prefs,
          )
        : null;
    final lastSponsorshipPromptAt = includePromptDedupe
        ? await _readLastPromptAtForEngine(
            LifeEventTriggerEngine.sponsorshipTransfer,
            userId,
            prefs,
          )
        : null;

    return evaluateHealthCoverageCorrelation(
      now: clock,
      eosbCaseDate: eosbDate,
      sponsorshipCaseDate: sponsorshipDate,
      healthInsuranceLastReviewedAt: healthReviewedAt,
      lastEosbPromptAt: lastEosbPromptAt,
      lastSponsorshipPromptAt: lastSponsorshipPromptAt,
    );
  }

  Future<LifeEventShockCluster?> loadShockCluster({
    required String userId,
    List<CalculationHistoryEntry> eosbHistory = const [],
    TransferReadinessResult? sponsorshipCachedResult,
    HealthInsuranceRepository? healthInsuranceRepository,
    HealthInsuranceClaimDispute? claimDispute,
    TenancyComplianceResult? tenancyCachedResult,
    TenancyLeaseInput? tenancyCachedInput,
    List<TenancyConditionRecord> tenancyConditionRecords = const [],
    DateTime? now,
    bool includePromptDedupe = true,
  }) async {
    final clock = now ?? DateTime.now();
    final prefs = _prefs ?? await SharedPreferences.getInstance();

    final eosbDate = _latestDate([
      _parseIso(
        await _readUserSummaryField(userId, 'eosbSummary', 'latestCalculatedAt'),
      ),
      if (eosbHistory.isNotEmpty) eosbHistory.first.savedAt,
      if (eosbHistory.isNotEmpty) eosbHistory.first.result.calculatedAt,
    ]);

    final sponsorshipDate = _latestDate([
      _parseIso(await _readUserSummaryField(
        userId,
        'sponsorshipTransferSummary',
        'latestCheckedAt',
      )),
      sponsorshipCachedResult?.checkedAt,
    ]);

    final tenancySummary = await _readUserSummaryMap(userId, 'tenancySummary');
    final tenancySnapshot = tenancyDistressSnapshot(
      cachedResult: tenancyCachedResult,
      cachedInput: tenancyCachedInput,
      summaryCheckedAt: _parseIso(tenancySummary?['latestCheckedAt']?.toString()),
      summaryHasCriticalIssue: tenancySummary?['hasCriticalIssue'] == true,
      summaryHasViolation: tenancySummary?['hasViolation'] == true,
      summaryPacketGeneratedAt:
          _parseIso(tenancySummary?['latestPacketGeneratedAt']?.toString()),
    );

    final hiSnapshot = healthInsuranceDistressSnapshot(
      healthInsuranceRepository: healthInsuranceRepository,
      claimDispute: claimDispute,
    );

    final lastClusterPromptAt = includePromptDedupe
        ? await _readLastShockClusterPromptAt(userId, prefs)
        : null;

    return evaluateShockCluster(
      now: clock,
      labour: evaluateLabourDistress(
        now: clock,
        eosbCaseDate: eosbDate,
        sponsorshipCaseDate: sponsorshipDate,
      ),
      healthInsurance: evaluateHealthInsuranceDistress(
        now: clock,
        complianceCheckedAt: hiSnapshot.complianceCheckedAt,
        hasUnresolvedViolation: hiSnapshot.hasUnresolvedViolation,
        claimDisputeUpdatedAt: hiSnapshot.claimDisputeUpdatedAt,
        claimDisputeDenialDate: hiSnapshot.claimDisputeDenialDate,
      ),
      tenancy: evaluateTenancyDistress(
        now: clock,
        latestCheckedAt: tenancySnapshot.latestCheckedAt,
        hasCriticalIssue: tenancySnapshot.hasCriticalIssue,
        hasViolation: tenancySnapshot.hasViolation,
        depositOverCap: tenancySnapshot.depositOverCap,
        latestPacketGeneratedAt: tenancySnapshot.latestPacketGeneratedAt,
        latestMoveOutRecordAt: latestMoveOutRecordAt(tenancyConditionRecords),
      ),
      lastClusterPromptAt: lastClusterPromptAt,
    );
  }

  Future<DateTime?> _readLastShockClusterPromptAt(
    String userId,
    SharedPreferences prefs,
  ) async {
    final local =
        _parseIso(prefs.getString(shockClusterPromptAtPrefsKey));
    final remote = _parseIso(await _readUserSummaryField(
      userId,
      'lifeEventsSummary',
      shockClusterFirestorePromptField,
    ));
    return _latestDate([local, remote]);
  }

  Future<void> maybeNotifyShockCluster({
    required LifeEventShockCluster cluster,
    required String locale,
  }) async {
    final title =
        AppShellStrings.t('life_event_shock_cluster_notif_title', locale);
    final body = AppShellStrings.format(
      'life_event_shock_cluster_notif_body',
      locale,
      params: {'domains': cluster.domainLabels(locale)},
    );

    await RaabtaNotificationService.instance.sendSmartNotification(
      SmartNotificationRequest(
        type: NotificationType.lifeEventCorrelation,
        title: title,
        body: body,
        route: cluster.primaryNotificationRoute(),
        dedupKey: cluster.notificationDedupKey(),
        dedupWindow: const Duration(days: kLifeEventWindowDays),
      ),
    );
  }

  Future<void> recordShockClusterPromptShown({
    String? userId,
    DateTime? when,
  }) async {
    final timestamp = when ?? DateTime.now();
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(
      shockClusterPromptAtPrefsKey,
      timestamp.toIso8601String(),
    );

    if (userId != null && userId.isNotEmpty) {
      try {
        await _firestore.collection('users').doc(userId).set({
          'lifeEventsSummary': {
            shockClusterFirestorePromptField: timestamp.toIso8601String(),
          },
        }, SetOptions(merge: true));
      } catch (_) {}
    }
  }

  Future<DateTime?> _readLastPromptAtForEngine(
    LifeEventTriggerEngine engine,
    String userId,
    SharedPreferences prefs,
  ) async {
    final perEngineLocal = _parseIso(prefs.getString(promptAtPrefsKeyFor(engine)));
    final perEngineRemote = _parseIso(await _readUserSummaryField(
      userId,
      'lifeEventsSummary',
      firestorePromptFieldFor(engine),
    ));

    if (engine == LifeEventTriggerEngine.sponsorshipTransfer) {
      return _latestDate([perEngineLocal, perEngineRemote]);
    }

    // EOSB: also honour legacy global timestamp so pre-migration users are not
    // re-prompted for EOSB within the original 30-day window.
    final legacyLocal = _parseIso(prefs.getString(legacyPromptAtPrefsKey));
    final legacyRemote = _parseIso(await _readUserSummaryField(
      userId,
      'lifeEventsSummary',
      'lastHealthCoveragePromptAt',
    ));
    return _latestDate([
      perEngineLocal,
      perEngineRemote,
      legacyLocal,
      legacyRemote,
    ]);
  }

  Future<void> maybeNotifyHealthCoverageCorrelation({
    required LifeEventHealthCoverageCorrelation correlation,
    required String locale,
  }) async {
    final title =
        AppShellStrings.t('life_event_health_coverage_notif_title', locale);
    final body =
        AppShellStrings.t('life_event_health_coverage_notif_body', locale);

    await RaabtaNotificationService.instance.sendSmartNotification(
      SmartNotificationRequest(
        type: NotificationType.lifeEventCorrelation,
        title: title,
        body: body,
        route: healthInsuranceRoute,
        dedupKey: correlation.notificationDedupKey(),
        dedupWindow: const Duration(days: kLifeEventWindowDays),
      ),
    );
  }

  Future<void> recordHealthCoveragePromptShown({
    required LifeEventTriggerEngine engine,
    String? userId,
    DateTime? when,
  }) async {
    final timestamp = when ?? DateTime.now();
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(
      promptAtPrefsKeyFor(engine),
      timestamp.toIso8601String(),
    );

    if (userId != null && userId.isNotEmpty) {
      await _mirrorPromptToFirestore(userId, engine, timestamp);
    }
  }

  Future<void> _mirrorPromptToFirestore(
    String userId,
    LifeEventTriggerEngine engine,
    DateTime when,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'lifeEventsSummary': {
          firestorePromptFieldFor(engine): when.toIso8601String(),
        },
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<String?> _readUserSummaryField(
    String userId,
    String summaryKey,
    String fieldKey,
  ) async {
    final summary = await _readUserSummaryMap(userId, summaryKey);
    if (summary == null) return null;
    return summary[fieldKey]?.toString();
  }

  Future<Map<String, dynamic>?> _readUserSummaryMap(
    String userId,
    String summaryKey,
  ) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      final summary = doc.data()?[summaryKey];
      if (summary is! Map) return null;
      return Map<String, dynamic>.from(summary);
    } catch (_) {
      return null;
    }
  }

  static DateTime? _parseIso(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  static DateTime? _latestDate(List<DateTime?> candidates) {
    DateTime? latest;
    for (final candidate in candidates) {
      if (candidate == null) continue;
      if (latest == null || candidate.isAfter(latest)) {
        latest = candidate;
      }
    }
    return latest;
  }
}
