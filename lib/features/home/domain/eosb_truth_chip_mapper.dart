import 'package:raabta/features/case_timeline/domain/case_timeline_engine_type.dart';
import 'package:raabta/features/case_timeline/presentation/navigation/case_timeline_navigation.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/domain/services/art_67_input_resolver.dart';
import 'package:raabta/features/eosb/domain/services/eosb_calculation_service.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/domain/truth_chip_urgency_thresholds.dart';
import 'package:raabta/features/home/l10n/truth_chip_eosb_strings.dart';
import 'package:raabta/services/legal_deadline_service.dart';

/// Pure EOSB → [TruthChipStatus] mapper (saved history only).
abstract final class EosbTruthChipMapper {
  EosbTruthChipMapper._();

  static const titleKey = 'tool_eosb_title';
  static const _engineHome = '/eosb';

  static TruthChipStatus map({
    required List<CalculationHistoryEntry> history,
    required DateTime now,
    String locale = 'English',
    EosbCalculationService calculator = const EosbCalculationService(),
  }) {
    if (history.isEmpty) {
      return TruthChipStatus(
        engine: TruthChipEngine.eosb,
        state: TruthChipState.invite,
        tone: TruthChipTone.neutral,
        titleKey: titleKey,
        statusText: TruthChipEosbStrings.t('truth_chip_eosb_invite', locale),
        freshnessText: '',
        deepLink: _engineHome,
      );
    }

    final entry = history.first;
    final freshness =
        TruthChipEosbStrings.t('truth_chip_eosb_freshness', locale);
    final revealed = _revealedEstimate(entry, calculator, locale);
    final deadlines = _legalDeadlines(entry, now);
    final primary = _mostUrgentDeadline(deadlines);

    if (primary != null) {
      final urgency = primary.urgency;
      if (urgency == LegalDeadlineUrgency.expired ||
          urgency == LegalDeadlineUrgency.urgent) {
        return TruthChipStatus(
          engine: TruthChipEngine.eosb,
          state: TruthChipState.urgent,
          tone: TruthChipTone.red,
          titleKey: titleKey,
          statusText: _statusForDeadline(primary, locale, attention: false),
          pillText: TruthChipEosbStrings.t('truth_chip_eosb_pill_action', locale),
          freshnessText: freshness,
          deepLink: _deepLink(entry, primary),
          revealedText: revealed,
        );
      }
      if (urgency == LegalDeadlineUrgency.approaching) {
        return TruthChipStatus(
          engine: TruthChipEngine.eosb,
          state: TruthChipState.attention,
          tone: TruthChipTone.amber,
          titleKey: titleKey,
          statusText: _statusForDeadline(primary, locale, attention: true),
          pillText: '${primary.daysRemaining}d',
          freshnessText: freshness,
          deepLink: _deepLink(entry, primary),
          revealedText: revealed,
        );
      }
    }

    if (TruthChipUrgencyThresholds.isStale(lastSavedAt: entry.savedAt, now: now)) {
      return TruthChipStatus(
        engine: TruthChipEngine.eosb,
        state: TruthChipState.stale,
        tone: TruthChipTone.neutral,
        titleKey: titleKey,
        statusText: TruthChipEosbStrings.t('truth_chip_eosb_stale', locale),
        pillText:
            TruthChipEosbStrings.t('truth_chip_eosb_pill_refresh', locale),
        freshnessText: freshness,
        deepLink: _engineHome,
        revealedText: revealed,
      );
    }

    final tracked = _trackedLine(entry, now, locale);
    return TruthChipStatus(
      engine: TruthChipEngine.eosb,
      state: TruthChipState.tracked,
      tone: TruthChipTone.ok,
      titleKey: titleKey,
      statusText: tracked.line,
      progress: tracked.progress,
      freshnessText: freshness,
      deepLink: _engineHome,
      revealedText: revealed,
    );
  }

  static List<LegalDeadlineResult> _legalDeadlines(
    CalculationHistoryEntry entry,
    DateTime now,
  ) {
    final input = entry.input;
    return [
      LegalDeadlineService.eosbFinalSettlementPaymentDeadline(
        art49NoticeGiven: input.art49NoticeGiven,
        contractTerminationDate: Art67InputResolver.contractTerminationDate(input),
        dateOfLeavingWork: Art67InputResolver.dateOfLeavingWork(input),
        now: now,
      ),
      LegalDeadlineService.eosbLabourClaimDeadline(
        contractExpiryDate: input.lastWorkingDate,
        now: now,
      ),
    ].whereType<LegalDeadlineResult>().toList();
  }

  static LegalDeadlineResult? _mostUrgentDeadline(
    List<LegalDeadlineResult> deadlines,
  ) {
    if (deadlines.isEmpty) return null;
    deadlines.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
    return deadlines.first;
  }

  static String _statusForDeadline(
    LegalDeadlineResult deadline,
    String locale, {
    required bool attention,
  }) {
    final isSettlement =
        deadline.kind == LegalDeadlineKind.eosbFinalSettlementPayment;
    if (attention) {
      final key = isSettlement
          ? 'truth_chip_eosb_attention_settlement'
          : 'truth_chip_eosb_attention_claim';
      return TruthChipEosbStrings.format(
        key,
        locale,
        params: {'days': '${deadline.daysRemaining}'},
      );
    }
    final key = isSettlement
        ? 'truth_chip_eosb_urgent_settlement'
        : 'truth_chip_eosb_urgent_claim';
    return TruthChipEosbStrings.t(key, locale);
  }

  static String _deepLink(
    CalculationHistoryEntry entry,
    LegalDeadlineResult deadline,
  ) {
    if (deadline.kind == LegalDeadlineKind.eosbLabourClaim ||
        deadline.kind == LegalDeadlineKind.eosbFinalSettlementPayment) {
      final caseId = CaseTimelineNavigation.eosbCaseIdFromCalculatedAt(
        entry.result.calculatedAt,
      );
      return CaseTimelineNavigation.routePath(
        engine: CaseTimelineEngineType.eosb,
        caseId: caseId,
      );
    }
    return _engineHome;
  }

  static ({String line, double? progress}) _trackedLine(
    CalculationHistoryEntry entry,
    DateTime now,
    String locale,
  ) {
    final joining = entry.input.joiningDate;
    if (joining == null) {
      return (
        line: TruthChipEosbStrings.t('truth_chip_eosb_tracked_saved', locale),
        progress: null,
      );
    }

    final end = entry.input.lastWorkingDate ?? now;
    final serviceYear = _serviceYearNumber(joining: joining, onDate: end);
    final line = TruthChipEosbStrings.format(
      'truth_chip_eosb_tracked_year',
      locale,
      params: {'year': '$serviceYear'},
    );

    if (entry.input.lastWorkingDate != null) {
      return (line: line, progress: null);
    }

    return (
      line: line,
      progress: _progressInCurrentServiceYear(joining: joining, now: now),
    );
  }

  static int _serviceYearNumber({
    required DateTime joining,
    required DateTime onDate,
  }) {
    var years = onDate.year - joining.year;
    if (!_isOnOrAfterAnniversary(onDate, joining)) {
      years--;
    }
    return years + 1;
  }

  static bool _isOnOrAfterAnniversary(DateTime date, DateTime joining) {
    if (date.month > joining.month) return true;
    if (date.month < joining.month) return false;
    return date.day >= joining.day;
  }

  static double _progressInCurrentServiceYear({
    required DateTime joining,
    required DateTime now,
  }) {
    var anniversary = DateTime(now.year, joining.month, joining.day);
    if (now.isBefore(anniversary)) {
      anniversary = DateTime(now.year - 1, joining.month, joining.day);
    }
    final next = DateTime(
      anniversary.year + 1,
      joining.month,
      joining.day,
    );
    final totalDays = next.difference(anniversary).inDays;
    if (totalDays <= 0) return 0;
    final elapsed = now.difference(anniversary).inDays;
    return (elapsed / totalDays).clamp(0.0, 1.0);
  }

  static String? _revealedEstimate(
    CalculationHistoryEntry entry,
    EosbCalculationService calculator,
    String locale,
  ) {
    final total = calculator.calculate(entry.input).totalEntitlement;
    if (total <= 0) return null;
    final amount = _formatQarAmount(total);
    return TruthChipEosbStrings.format(
      'truth_chip_eosb_revealed_estimate',
      locale,
      params: {'amount': amount},
    );
  }

  static String _formatQarAmount(double amount) {
    final rounded = amount.round();
    final raw = rounded.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      if (i > 0 && (raw.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(raw[i]);
    }
    return buffer.toString();
  }
}
