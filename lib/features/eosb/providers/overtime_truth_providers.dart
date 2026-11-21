import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/eosb/data/eosb_repository.dart';
import 'package:raabta/features/eosb/domain/models/eosb_history_load_outcome.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/domain/services/overtime_salary_storage_policy.dart';
import 'package:raabta/features/eosb/domain/services/overtime_truth_engine.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/providers/auth_scoped_storage_providers.dart';

/// Stable provider error code — UI maps to localized [EosbStrings] keys.
const overtimeCalculationFailedErrorCode = 'overtime_calculation_failed';

/// Local OT history / cache hydration failed (distinct from corrupt storage).
const overtimeHydrationFailedErrorCode = 'ot_history_hydration_failed';

/// Maps [OvertimeTruthState.error] codes to localized [EosbStrings] text.
String overtimeStateErrorMessage(String? errorCode, String locale) =>
    eosbStateErrorMessage(errorCode, locale);

class OvertimeTruthState {
  const OvertimeTruthState({
    required this.record,
    this.input = const OvertimeTruthInput(),
    this.result,
    this.history = const [],
    this.isCalculating = false,
    this.isHydrating = false,
    this.error,
    this.searchQuery = '',
    this.cloudSyncNoticePending = false,
    this.historyStorageCorrupt = false,
    this.historyLoadStatus = EosbHistoryStorageStatus.absent,
  });

  final OvertimeMonthlyRecord record;
  final OvertimeTruthInput input;
  final OvertimeTruthResult? result;
  final List<OvertimeMonthlyRecord> history;
  final bool isCalculating;
  final bool isHydrating;
  final String? error;
  final String searchQuery;
  final bool cloudSyncNoticePending;

  /// On-disk OT history JSON is corrupt; salvaged [history] may still be shown.
  final bool historyStorageCorrupt;

  final EosbHistoryStorageStatus historyLoadStatus;

  List<OvertimeMonthlyRecord> get filteredHistory {
    if (searchQuery.trim().isEmpty) return history;
    final q = searchQuery.toLowerCase();
    return history.where((r) {
      return r.label.toLowerCase().contains(q) ||
          r.profile.companyName.toLowerCase().contains(q) ||
          r.profile.employeeName.toLowerCase().contains(q) ||
          r.profile.project.toLowerCase().contains(q);
    }).toList();
  }

  OvertimeTruthState copyWith({
    OvertimeMonthlyRecord? record,
    OvertimeTruthInput? input,
    OvertimeTruthResult? result,
    List<OvertimeMonthlyRecord>? history,
    bool? isCalculating,
    bool? isHydrating,
    String? error,
    String? searchQuery,
    bool? cloudSyncNoticePending,
    bool? historyStorageCorrupt,
    EosbHistoryStorageStatus? historyLoadStatus,
    bool clearResult = false,
    bool clearError = false,
    bool clearCloudSyncNotice = false,
  }) {
    return OvertimeTruthState(
      record: record ?? this.record,
      input: input ?? this.input,
      result: clearResult ? null : (result ?? this.result),
      history: history ?? this.history,
      isCalculating: isCalculating ?? this.isCalculating,
      isHydrating: isHydrating ?? this.isHydrating,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
      cloudSyncNoticePending: clearCloudSyncNotice
          ? false
          : (cloudSyncNoticePending ?? this.cloudSyncNoticePending),
      historyStorageCorrupt:
          historyStorageCorrupt ?? this.historyStorageCorrupt,
      historyLoadStatus: historyLoadStatus ?? this.historyLoadStatus,
    );
  }
}

class OvertimeTruthNotifier extends StateNotifier<OvertimeTruthState> {
  OvertimeTruthNotifier(this._eosbNotifier, this._ref)
    : super(_initialState(_eosbNotifier));

  EosbRepository? _repo;
  final EosbNotifier _eosbNotifier;
  final Ref _ref;
  bool _hydrated = false;
  String? _hydratedUid;
  Future<void>? _activeHydration;
  int _hydrationGeneration = 0;

  /// Tests await this barrier before hydration applies state (auth race simulation).
  @visibleForTesting
  Future<void> debugHydrationBarrier = Future<void>.value();

  String? get _authUid => _ref.read(currentAuthUidProvider);

  bool _isHydrationStale(int generation, String? uid) =>
      generation != _hydrationGeneration || _authUid != uid;

  bool _needsHydrationForCurrentUid() {
    final uid = _authUid;
    if (_hydrated && _hydratedUid == uid) return false;
    if (!state.isHydrating && state.error == overtimeHydrationFailedErrorCode) {
      return false;
    }
    return true;
  }

  void _resetHydrationScopedHistoryState({bool isHydrating = true}) {
    state = state.copyWith(
      isHydrating: isHydrating,
      history: const [],
      historyStorageCorrupt: false,
      historyLoadStatus: EosbHistoryStorageStatus.absent,
      clearError: true,
    );
  }

  Future<bool> _persistHistory(List<OvertimeMonthlyRecord> history) async {
    final repo = _repo;
    if (repo == null) return false;
    final outcome = await repo.saveOvertimeHistory(history, uid: _authUid);
    return outcome.saved;
  }

  void clearCloudSyncNotice() {
    if (!state.cloudSyncNoticePending) return;
    state = state.copyWith(clearCloudSyncNotice: true);
  }

  void _noteCloudSyncOutcome(EosbCloudSyncOutcome outcome) {
    if (outcome == EosbCloudSyncOutcome.failed) {
      state = state.copyWith(cloudSyncNoticePending: true);
    }
  }

  void _setHistorySaveFailed() {
    state = state.copyWith(error: eosbHistoryPersistenceFailedErrorCode);
  }

  static OvertimeTruthState _initialState(EosbNotifier eosbNotifier) {
    final now = DateTime.now();
    final record = _prefillRecordStatic(
      OvertimeMonthlyRecord.emptyForMonth(now.year, now.month),
      eosbNotifier,
    );
    return OvertimeTruthState(
      record: record,
      input: _inputFromRecordStatic(record),
      isHydrating: true,
    );
  }

  static OvertimeMonthlyRecord _prefillRecordStatic(
    OvertimeMonthlyRecord record,
    EosbNotifier eosbNotifier,
  ) {
    final eosb = eosbNotifier.state.input;
    if (eosb.basicSalary <= 0) return record;
    return record.copyWith(
      profile: record.profile.copyWith(
        companyName: eosb.companyName,
        normalizedEmployerKey: eosb.effectiveNormalizedEmployerKey,
        basicSalary: eosb.basicSalary,
        totalSalary: eosb.totalSalary > 0 ? eosb.totalSalary : eosb.basicSalary,
        joiningDate: eosb.joiningDate,
      ),
    );
  }

  static OvertimeTruthInput _inputFromRecordStatic(
    OvertimeMonthlyRecord record,
  ) {
    return OvertimeTruthInput(
      companyName: record.profile.companyName,
      basicSalary: record.profile.basicSalary,
      periodStart: record.periodStart,
      periodEnd: record.periodEnd,
      workingDaysPerWeek: record.profile.workingDaysPerWeek,
      standardHoursPerDay: record.profile.workingHoursPerDay,
      isRamadanPeriod: record.profile.isRamadanPeriod,
      inputMode: OvertimeInputMode.calendar,
      employerPaidOvertime: record.employerPaidOvertime,
      employerReportedOvertimeHours: record.employerReportedHours,
      record: record,
    );
  }

  void attachRepository(EosbRepository repo) {
    _repo = repo;
    _scheduleHydrationIfNeeded();
  }

  @visibleForTesting
  void replaceRepositoryForTests(EosbRepository repo) {
    _repo = repo;
  }

  /// Awaits in-flight or pending repository-backed hydration (tests only).
  @visibleForTesting
  Future<void> flushHydration() async {
    final repo = _repo;
    if (repo == null) return;
    await _ensureHydration(repo);
  }

  /// Re-loads UID-scoped caches when auth changes (in-flight hydrations are ignored).
  void handleAuthUidChange() {
    final uid = _authUid;
    if (_hydrated && _hydratedUid == uid) return;
    _hydrationGeneration++;
    _hydrated = false;
    _hydratedUid = null;
    _resetHydrationScopedHistoryState();
    _scheduleHydrationIfNeeded();
  }

  /// Re-attempt cache hydration after a prior failure ([overtimeHydrationFailedErrorCode]).
  Future<void> retryHydration() async {
    final repo = _repo;
    if (repo == null) return;
    _hydrated = false;
    _hydratedUid = null;
    _hydrationGeneration++;
    _resetHydrationScopedHistoryState();
    await _ensureHydration(repo);
  }

  void _scheduleHydrationIfNeeded() {
    final repo = _repo;
    if (repo == null) return;

    final uid = _authUid;
    if (_hydrated && _hydratedUid == uid) return;

    if (_hydrated && _hydratedUid != uid) {
      _hydrationGeneration++;
      _hydrated = false;
      _hydratedUid = null;
      _resetHydrationScopedHistoryState();
    }

    unawaited(_ensureHydration(repo));
  }

  Future<void> _ensureHydration(EosbRepository repo) async {
    while (_needsHydrationForCurrentUid()) {
      if (_activeHydration != null) {
        await _activeHydration;
        continue;
      }

      final uid = _authUid;
      final owned = _hydrateFromCache(repo: repo, uid: uid);
      _activeHydration = owned;
      try {
        await owned;
      } finally {
        if (identical(_activeHydration, owned)) {
          _activeHydration = null;
        }
      }
    }
  }

  Future<void> _hydrateFromCache({
    required EosbRepository repo,
    required String? uid,
  }) async {
    final generation = _hydrationGeneration;

    try {
      final historyOutcome = repo.loadOvertimeHistoryOutcome(uid: uid);
      final history = historyOutcome.records;
      final cachedResult = repo.loadCachedOvertimeResult(uid: uid);
      final cachedInput = repo.loadCachedOvertimeInput(uid: uid);

      OvertimeMonthlyRecord record = state.record;
      OvertimeTruthResult? result = cachedResult;

      if (cachedResult != null) {
        record = cachedResult.record.withFullMonthDays();
      } else if (cachedInput?.record != null) {
        record = cachedInput!.record!.withFullMonthDays();
        record = _prefillRecord(record);
      } else {
        record = _prefillRecord(state.record.withFullMonthDays());
      }

      if (result != null) {
        result = OvertimeTruthEngine.calculateRecord(record);
      }

      await debugHydrationBarrier;
      if (_isHydrationStale(generation, uid)) return;

      state = state.copyWith(
        record: record,
        input: cachedInput ?? _inputFromRecord(record),
        result: result,
        history: history,
        historyStorageCorrupt: historyOutcome.isStorageCorrupt,
        historyLoadStatus: historyOutcome.status,
        isHydrating: false,
        clearError: true,
      );
      _hydrated = true;
      _hydratedUid = uid;
    } catch (_) {
      await debugHydrationBarrier;
      if (_isHydrationStale(generation, uid)) return;
      _applyHydrationFailure();
    }
  }

  void _applyHydrationFailure() {
    state = state.copyWith(
      isHydrating: false,
      history: const [],
      historyStorageCorrupt: false,
      historyLoadStatus: EosbHistoryStorageStatus.absent,
      error: overtimeHydrationFailedErrorCode,
    );
  }

  OvertimeMonthlyRecord _prefillRecord(OvertimeMonthlyRecord record) {
    return _prefillRecordStatic(record, _eosbNotifier);
  }

  OvertimeTruthInput _inputFromRecord(OvertimeMonthlyRecord record) {
    return _inputFromRecordStatic(record);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Strips salary-bearing fields from in-memory OT state after consent off.
  void applySalaryConsentRevocation() {
    final redactedRecord = OvertimeSalaryStoragePolicy.redactRecord(
      state.record,
    );
    final redactedInput = OvertimeSalaryStoragePolicy.redactInput(state.input);
    state = state.copyWith(
      record: redactedRecord,
      input: redactedInput,
      clearResult: true,
      clearError: true,
    );
  }

  void updateInput(OvertimeTruthInput input) {
    state = state.copyWith(input: input, clearError: true);
  }

  void updateRecord(OvertimeMonthlyRecord record) {
    final full = record.withFullMonthDays();
    state = state.copyWith(
      record: full,
      input: _inputFromRecord(full),
      clearError: true,
    );
  }

  void updateProfile(OvertimeEmployeeProfile profile) {
    updateRecord(
      state.record.copyWith(profile: profile, updatedAt: DateTime.now()),
    );
  }

  void updateDay(int index, OvertimeDayEntry day) {
    final record = state.record;
    if (index < 0 || index >= record.days.length) return;
    final days = List<OvertimeDayEntry>.from(record.days);
    days[index] = day;
    updateRecord(record.copyWith(days: days, updatedAt: DateTime.now()));
    _recalculateLive();
  }

  void setEmployerComparison({double? paid, double? hours}) {
    final record = state.record;
    updateRecord(
      record.copyWith(
        employerPaidOvertime: paid ?? record.employerPaidOvertime,
        employerReportedHours: hours ?? record.employerReportedHours,
        updatedAt: DateTime.now(),
      ),
    );
    _recalculateLive();
  }

  void loadMonth(int year, int month) {
    final existing = state.history.where(
      (r) => r.year == year && r.month == month,
    );
    if (existing.isNotEmpty) {
      updateRecord(existing.first);
      calculate();
      return;
    }
    updateRecord(
      _prefillRecord(OvertimeMonthlyRecord.emptyForMonth(year, month)),
    );
    _recalculateLive();
  }

  void _recalculateLive() {
    final result = OvertimeTruthEngine.calculateRecord(state.record);
    state = state.copyWith(result: result);
  }

  Future<OvertimeTruthResult?> calculate() async {
    state = state.copyWith(
      isCalculating: true,
      clearError: true,
      clearCloudSyncNotice: true,
    );
    try {
      final record = state.record.withFullMonthDays();
      final input = _inputFromRecord(record);
      await _repo?.cacheOvertimeInput(input, uid: _authUid);
      final result = OvertimeTruthEngine.calculateRecord(record);
      state = state.copyWith(
        record: record,
        result: result,
        input: input,
        isCalculating: false,
      );
      await _repo?.saveOvertimeResult(result, uid: _authUid);
      final sync =
          await _repo?.syncOvertimeCalculation(result, uid: _authUid) ??
          EosbCloudSyncOutcome.skipped;
      _noteCloudSyncOutcome(sync);
      return result;
    } catch (_) {
      state = state.copyWith(
        isCalculating: false,
        error: overtimeCalculationFailedErrorCode,
      );
      return null;
    }
  }

  Future<OvertimeTruthResult?> calculateLegacy(OvertimeTruthInput input) async {
    state = state.copyWith(
      input: input,
      isCalculating: true,
      clearError: true,
      clearCloudSyncNotice: true,
    );
    try {
      await _repo?.cacheOvertimeInput(input, uid: _authUid);
      final result = OvertimeTruthEngine.calculate(input);
      final record = result.record.withFullMonthDays();
      state = state.copyWith(
        result: result,
        record: record,
        isCalculating: false,
      );
      await _repo?.saveOvertimeResult(result, uid: _authUid);
      final sync =
          await _repo?.syncOvertimeCalculation(result, uid: _authUid) ??
          EosbCloudSyncOutcome.skipped;
      _noteCloudSyncOutcome(sync);
      return result;
    } catch (_) {
      state = state.copyWith(
        isCalculating: false,
        error: overtimeCalculationFailedErrorCode,
      );
      return null;
    }
  }

  Future<bool> saveCurrentToHistory() async {
    final stamped = state.record.copyWith(updatedAt: DateTime.now());
    final history = List<OvertimeMonthlyRecord>.from(state.history);
    history.removeWhere((r) => r.id == stamped.id);
    history.insert(0, stamped);

    if (!await _persistHistory(history)) {
      _setHistorySaveFailed();
      return false;
    }

    state = state.copyWith(record: stamped, history: history, clearError: true);
    final result = state.result;
    if (result != null && result.record.id == stamped.id) {
      final sync =
          await _repo?.syncOvertimeCalculation(result, uid: _authUid) ??
          EosbCloudSyncOutcome.skipped;
      _noteCloudSyncOutcome(sync);
    }
    return true;
  }

  Future<void> duplicateHistoryRecord(OvertimeMonthlyRecord source) async {
    final copy = source.copyWith(
      id: '${source.year}_${source.month}_dup_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final history = [copy, ...state.history];

    if (!await _persistHistory(history)) {
      _setHistorySaveFailed();
      return;
    }

    state = state.copyWith(record: copy, history: history, clearError: true);
  }

  Future<void> deleteFromHistory(String id) async {
    final history = state.history
        .where((r) => r.id != id)
        .toList(growable: false);

    if (!await _persistHistory(history)) {
      _setHistorySaveFailed();
      return;
    }

    state = state.copyWith(history: history, clearError: true);
  }

  Future<void> toggleFavorite(String id) async {
    final history = state.history.map((r) {
      if (r.id == id) return r.copyWith(isFavorite: !r.isFavorite);
      return r;
    }).toList();

    if (!await _persistHistory(history)) {
      _setHistorySaveFailed();
      return;
    }

    state = state.copyWith(history: history, clearError: true);
  }

  void applyToEosb() {
    final result = state.result;
    if (result == null) return;

    final eosbInput = _eosbNotifier.state.input;
    _eosbNotifier.updateInput(
      eosbInput.copyWith(
        overtimeHours: result.totalOvertimeHours,
        pendingSalary: eosbInput.pendingSalary + result.comparison.unpaidGap,
        companyName: result.record.profile.companyName.isNotEmpty
            ? result.record.profile.companyName
            : eosbInput.companyName,
        basicSalary: result.record.profile.basicSalary > 0
            ? result.record.profile.basicSalary
            : eosbInput.basicSalary,
      ),
    );
  }
}

final overtimeTruthProvider =
    StateNotifierProvider<OvertimeTruthNotifier, OvertimeTruthState>((ref) {
      ref.watch(currentAuthUidProvider);
      final eosbNotifier = ref.watch(eosbProvider.notifier);
      final notifier = OvertimeTruthNotifier(eosbNotifier, ref);

      ref.listen<AsyncValue<EosbRepository>>(eosbRepositoryProvider, (
        prev,
        next,
      ) {
        next.whenData(notifier.attachRepository);
      }, fireImmediately: true);

      ref.listen(currentAuthUidProvider, (previous, next) {
        if (previous != next) {
          notifier.handleAuthUidChange();
        }
      });

      return notifier;
    });

final overtimeHistoryStorageCorruptProvider = Provider<bool>((ref) {
  return ref.watch(overtimeTruthProvider).historyStorageCorrupt;
});

final overtimeHistoryLoadStatusProvider = Provider<EosbHistoryStorageStatus>(
  (ref) => ref.watch(overtimeTruthProvider).historyLoadStatus,
);
