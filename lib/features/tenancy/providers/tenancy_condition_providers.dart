import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_engine_type.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_entry_type.dart';
import 'package:raabta/features/case_timeline/presentation/navigation/case_timeline_navigation.dart';
import 'package:raabta/features/case_timeline/presentation/providers/case_timeline_providers.dart';
import 'package:raabta/features/tenancy/data/tenancy_condition_repository.dart';
import 'package:raabta/features/tenancy/data/tenancy_firestore_payload.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_condition_models.dart';
import 'package:raabta/features/tenancy/providers/tenancy_providers.dart';
import 'package:raabta/providers/auth_providers.dart';

final tenancyConditionRepositoryProvider =
    FutureProvider<TenancyConditionRepository>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return TenancyConditionRepository(prefs);
});

/// Condition records for the active lease (derived from compliance check).
final tenancyConditionRecordsProvider =
    FutureProvider<List<TenancyConditionRecord>>((ref) async {
  final repo = await ref.watch(tenancyConditionRepositoryProvider.future);
  final result = ref.watch(tenancyProvider).result;
  if (result == null) return [];
  final leaseId = TenancyFirestorePayload.recordIdFor(result);
  return repo.fetchForLease(leaseId);
});

class TenancyConditionCaptureState {
  const TenancyConditionCaptureState({
    this.rooms = const [],
    this.currentRoomLabel = '',
    this.isSaving = false,
    this.pendingRoomIndex,
    this.error,
    this.addToTimeline = true,
  });

  final List<TenancyConditionRoom> rooms;
  final String currentRoomLabel;
  final bool isSaving;
  final int? pendingRoomIndex;
  final String? error;
  final bool addToTimeline;

  TenancyConditionCaptureState copyWith({
    List<TenancyConditionRoom>? rooms,
    String? currentRoomLabel,
    bool? isSaving,
    int? pendingRoomIndex,
    String? error,
    bool? addToTimeline,
    bool clearPending = false,
    bool clearError = false,
  }) {
    return TenancyConditionCaptureState(
      rooms: rooms ?? this.rooms,
      currentRoomLabel: currentRoomLabel ?? this.currentRoomLabel,
      isSaving: isSaving ?? this.isSaving,
      pendingRoomIndex:
          clearPending ? null : (pendingRoomIndex ?? this.pendingRoomIndex),
      error: clearError ? null : (error ?? this.error),
      addToTimeline: addToTimeline ?? this.addToTimeline,
    );
  }
}

class TenancyConditionCaptureNotifier
    extends StateNotifier<TenancyConditionCaptureState> {
  TenancyConditionCaptureNotifier(this._ref)
      : super(const TenancyConditionCaptureState());

  final Ref _ref;

  void setRoomLabel(String label) {
    state = state.copyWith(currentRoomLabel: label);
  }

  void setAddToTimeline(bool value) {
    state = state.copyWith(addToTimeline: value);
  }

  void addRoom() {
    final label = state.currentRoomLabel.trim();
    if (label.isEmpty) return;
    state = state.copyWith(
      rooms: [...state.rooms, TenancyConditionRoom(roomLabel: label)],
      currentRoomLabel: '',
      clearError: true,
    );
  }

  void removeRoom(int index) {
    final next = List<TenancyConditionRoom>.from(state.rooms)..removeAt(index);
    state = state.copyWith(rooms: next);
  }

  void setPendingPhoto(int roomIndex) {
    state = state.copyWith(pendingRoomIndex: roomIndex);
  }

  Future<void> attachPendingPhoto(
    String vaultDocId,
    DateTime capturedAt, {
    TenancyConditionTimestampSource timestampSource =
        TenancyConditionTimestampSource.deviceLinkTime,
  }) async {
    final index = state.pendingRoomIndex;
    if (index == null || index < 0 || index >= state.rooms.length) return;

    final room = state.rooms[index];
    final updated = room.copyWith(
      photos: [
        ...room.photos,
        TenancyConditionPhoto(
          photoRef: vaultDocId,
          capturedAt: capturedAt,
          timestampSource: timestampSource,
        ),
      ],
    );
    final next = List<TenancyConditionRoom>.from(state.rooms);
    next[index] = updated;
    state = state.copyWith(rooms: next, clearPending: true);
  }

  void updatePhotoNote(int roomIndex, int photoIndex, String note) {
    if (roomIndex < 0 || roomIndex >= state.rooms.length) return;
    final room = state.rooms[roomIndex];
    if (photoIndex < 0 || photoIndex >= room.photos.length) return;
    final photos = List<TenancyConditionPhoto>.from(room.photos);
    photos[photoIndex] = photos[photoIndex].copyWith(note: note);
    final next = List<TenancyConditionRoom>.from(state.rooms);
    next[roomIndex] = room.copyWith(photos: photos);
    state = state.copyWith(rooms: next);
  }

  Future<TenancyConditionRecord?> saveSession({
    required TenancyConditionRecordType recordType,
  }) async {
    if (state.rooms.isEmpty) return null;

    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final repo = await _ref.read(tenancyConditionRepositoryProvider.future);
      final tenancy = _ref.read(tenancyProvider);
      final result = tenancy.result;
      final uid = _ref.read(currentUserProvider)?.uid ?? '';
      if (result == null || uid.isEmpty) {
        state = state.copyWith(isSaving: false, error: 'Lease required');
        return null;
      }

      final leaseId = TenancyFirestorePayload.recordIdFor(result);
      final existing = repo.findByType(
        await repo.fetchForLease(leaseId),
        recordType,
      );

      final record = TenancyConditionRecord(
        recordId: existing?.recordId ?? '',
        userId: uid,
        leaseId: leaseId,
        recordType: recordType,
        rooms: state.rooms,
        roomComparisonNotes: existing?.roomComparisonNotes ?? const {},
        createdAt: existing?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saved = await repo.upsert(record);

      if (state.addToTimeline) {
        await _addTimelineMilestone(saved, recordType);
      }

      _ref.invalidate(tenancyConditionRecordsProvider);

      if (recordType == TenancyConditionRecordType.moveIn ||
          recordType == TenancyConditionRecordType.moveOut) {
        await _ref
            .read(tenancyProvider.notifier)
            .toggleChecklistItem('property_condition_record', true);
      }

      state = const TenancyConditionCaptureState();
      return saved;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return null;
    }
  }

  Future<void> _addTimelineMilestone(
    TenancyConditionRecord record,
    TenancyConditionRecordType type,
  ) async {
    final uid = _ref.read(currentUserProvider)?.uid;
    final checkedAt = _ref.read(tenancyProvider).result?.checkedAt;
    if (uid == null || checkedAt == null) return;

    final caseId =
        CaseTimelineNavigation.tenancyCaseIdFromCheckedAt(checkedAt);
    final title = type == TenancyConditionRecordType.moveIn
        ? 'Move-in condition record saved'
        : 'Move-out condition record saved';

    await _ref.read(caseTimelineServiceProvider).addEntry(
          userId: uid,
          engineType: CaseTimelineEngineType.tenancy,
          caseId: caseId,
          entryDate: DateTime.now(),
          entryType: CaseTimelineEntryType.photo,
          title: title,
          checklistItemId: 'property_condition_record',
          description: '${record.totalPhotos} photos across ${record.rooms.length} rooms',
        );
  }

  void reset() {
    state = const TenancyConditionCaptureState();
  }
}

final tenancyConditionCaptureProvider = StateNotifierProvider<
    TenancyConditionCaptureNotifier, TenancyConditionCaptureState>((ref) {
  return TenancyConditionCaptureNotifier(ref);
});

/// Whether lease end is within 60 days (move-out prompt).
bool tenancyLeaseEndApproaching(DateTime? leaseEndDate) {
  if (leaseEndDate == null) return false;
  final days = leaseEndDate.difference(DateTime.now()).inDays;
  return days >= 0 && days <= 60;
}
