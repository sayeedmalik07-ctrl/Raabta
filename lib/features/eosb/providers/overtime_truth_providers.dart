import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/eosb/data/eosb_repository.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/domain/services/overtime_truth_engine.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/providers/auth_scoped_storage_providers.dart';

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
  });

  final OvertimeMonthlyRecord record;
  final OvertimeTruthInput input;
  final OvertimeTruthResult? result;
  final List<OvertimeMonthlyRecord> history;
  final bool isCalculating;
  final bool isHydrating;
  final String? error;
  final String searchQuery;

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
    bool clearResult = false,
    bool clearError = false,
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
    );
  }
}

class OvertimeTruthNotifier extends StateNotifier<OvertimeTruthState> {
  OvertimeTruthNotifier(this._eosbNotifier)
      : super(_initialState(_eosbNotifier)) {
    _hydrateFromCache();
  }

  EosbRepository? _repo;
  final EosbNotifier _eosbNotifier;
  bool _hydrated = false;

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

  static OvertimeTruthInput _inputFromRecordStatic(OvertimeMonthlyRecord record) {
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
    if (_hydrated) return;
    _hydrateFromCache(repo: repo);
  }

  Future<void> _hydrateFromCache({EosbRepository? repo}) async {
    if (_hydrated) return;
    final activeRepo = repo ?? _repo;

    try {
      final history = activeRepo?.loadOvertimeHistory() ?? [];
      final cachedResult = activeRepo?.loadCachedOvertimeResult();
      final cachedInput = activeRepo?.loadCachedOvertimeInput();

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

      state = state.copyWith(
        record: record,
        input: cachedInput ?? _inputFromRecord(record),
        result: result,
        history: history,
        isHydrating: false,
      );
      _hydrated = true;
    } catch (_) {
      state = state.copyWith(isHydrating: false);
      _hydrated = true;
    }
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
    final existing =
        state.history.where((r) => r.year == year && r.month == month);
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
    state = state.copyWith(isCalculating: true, clearError: true);
    try {
      final record = state.record.withFullMonthDays();
      final input = _inputFromRecord(record);
      await _repo?.cacheOvertimeInput(input);
      final result = OvertimeTruthEngine.calculateRecord(record);
      state = state.copyWith(
        record: record,
        result: result,
        input: input,
        isCalculating: false,
      );
      await _repo?.saveOvertimeResult(result);
      await _repo?.syncOvertimeCalculation(result);
      return result;
    } catch (e) {
      state = state.copyWith(isCalculating: false, error: e.toString());
      return null;
    }
  }

  Future<OvertimeTruthResult?> calculateLegacy(OvertimeTruthInput input) async {
    state = state.copyWith(input: input, isCalculating: true, clearError: true);
    try {
      await _repo?.cacheOvertimeInput(input);
      final result = OvertimeTruthEngine.calculate(input);
      final record = result.record.withFullMonthDays();
      state = state.copyWith(
        result: result,
        record: record,
        isCalculating: false,
      );
      await _repo?.saveOvertimeResult(result);
      await _repo?.syncOvertimeCalculation(result);
      return result;
    } catch (e) {
      state = state.copyWith(isCalculating: false, error: e.toString());
      return null;
    }
  }

  Future<void> saveCurrentToHistory() async {
    final stamped = state.record.copyWith(updatedAt: DateTime.now());
    final history = List<OvertimeMonthlyRecord>.from(state.history);
    history.removeWhere((r) => r.id == stamped.id);
    history.insert(0, stamped);
    state = state.copyWith(record: stamped, history: history);
    await _repo?.saveOvertimeHistory(history);
    final result = state.result;
    if (result != null && result.record.id == stamped.id) {
      await _repo?.syncOvertimeCalculation(result);
    }
  }

  Future<void> duplicateCurrentMonth() async {
    final record = state.record;
    final copy = record.copyWith(
      id: '${record.year}_${record.month}_dup_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final history = [copy, ...state.history];
    state = state.copyWith(record: copy, history: history);
    await _repo?.saveOvertimeHistory(history);
  }

  Future<void> deleteFromHistory(String id) async {
    final history =
        state.history.where((r) => r.id != id).toList(growable: false);
    state = state.copyWith(history: history);
    await _repo?.saveOvertimeHistory(history);
  }

  Future<void> toggleFavorite(String id) async {
    final history = state.history.map((r) {
      if (r.id == id) return r.copyWith(isFavorite: !r.isFavorite);
      return r;
    }).toList();
    state = state.copyWith(history: history);
    await _repo?.saveOvertimeHistory(history);
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
  final notifier = OvertimeTruthNotifier(eosbNotifier);

  ref.listen<AsyncValue<EosbRepository>>(eosbRepositoryProvider, (prev, next) {
    next.whenData(notifier.attachRepository);
  }, fireImmediately: true);

  return notifier;
});
