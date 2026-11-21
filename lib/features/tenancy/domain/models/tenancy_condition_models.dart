/// Move-in or move-out property condition capture session.
enum TenancyConditionRecordType {
  moveIn,
  moveOut,
}

extension TenancyConditionRecordTypeX on TenancyConditionRecordType {
  String get storageValue => name;

  String get labelKey => this == TenancyConditionRecordType.moveIn
      ? 'tenancy_condition_move_in'
      : 'tenancy_condition_move_out';

  static TenancyConditionRecordType fromStorage(String? raw) {
    return raw == 'moveOut'
        ? TenancyConditionRecordType.moveOut
        : TenancyConditionRecordType.moveIn;
  }
}

/// Timestamp provenance for condition photos — not a verification score.
enum TenancyConditionTimestampSource {
  vaultScanDate,
  deviceLinkTime,
}

extension TenancyConditionTimestampSourceX on TenancyConditionTimestampSource {
  String get storageValue => switch (this) {
        TenancyConditionTimestampSource.vaultScanDate => 'vault_scan_date',
        TenancyConditionTimestampSource.deviceLinkTime => 'device_link_time',
      };

  static TenancyConditionTimestampSource fromStorage(String? raw) {
    return raw == 'vault_scan_date'
        ? TenancyConditionTimestampSource.vaultScanDate
        : TenancyConditionTimestampSource.deviceLinkTime;
  }
}

/// Resolves the strongest available timestamp without fabricating capture metadata.
abstract final class TenancyConditionPhotoTimestamp {
  static ({
    DateTime capturedAt,
    TenancyConditionTimestampSource source,
  }) resolve({
    DateTime? vaultScanDate,
    DateTime? deviceFallback,
  }) {
    if (vaultScanDate != null) {
      return (
        capturedAt: vaultScanDate,
        source: TenancyConditionTimestampSource.vaultScanDate,
      );
    }
    return (
      capturedAt: deviceFallback ?? DateTime.now(),
      source: TenancyConditionTimestampSource.deviceLinkTime,
    );
  }
}

/// Single photo linked to Document Vault.
class TenancyConditionPhoto {
  const TenancyConditionPhoto({
    required this.photoRef,
    required this.capturedAt,
    this.note = '',
    this.timestampSource = TenancyConditionTimestampSource.deviceLinkTime,
  });

  final String photoRef;
  final DateTime capturedAt;
  final String note;
  final TenancyConditionTimestampSource timestampSource;

  Map<String, dynamic> toJson() => {
        'photoRef': photoRef,
        'capturedAt': capturedAt.toIso8601String(),
        'note': note,
        'timestampSource': timestampSource.storageValue,
      };

  factory TenancyConditionPhoto.fromJson(Map<String, dynamic> json) {
    return TenancyConditionPhoto(
      photoRef: json['photoRef'] as String? ?? '',
      capturedAt: DateTime.tryParse(json['capturedAt'] as String? ?? '') ??
          DateTime.now(),
      note: json['note'] as String? ?? '',
      timestampSource: TenancyConditionTimestampSourceX.fromStorage(
        json['timestampSource'] as String?,
      ),
    );
  }

  TenancyConditionPhoto copyWith({
    String? photoRef,
    DateTime? capturedAt,
    String? note,
    TenancyConditionTimestampSource? timestampSource,
  }) {
    return TenancyConditionPhoto(
      photoRef: photoRef ?? this.photoRef,
      capturedAt: capturedAt ?? this.capturedAt,
      note: note ?? this.note,
      timestampSource: timestampSource ?? this.timestampSource,
    );
  }
}

/// One room within a condition record session.
class TenancyConditionRoom {
  const TenancyConditionRoom({
    required this.roomLabel,
    this.photos = const [],
  });

  final String roomLabel;
  final List<TenancyConditionPhoto> photos;

  Map<String, dynamic> toJson() => {
        'roomLabel': roomLabel,
        'photos': photos.map((p) => p.toJson()).toList(),
      };

  factory TenancyConditionRoom.fromJson(Map<String, dynamic> json) {
    final photosRaw = json['photos'] as List<dynamic>? ?? [];
    return TenancyConditionRoom(
      roomLabel: json['roomLabel'] as String? ?? '',
      photos: photosRaw
          .map((e) => TenancyConditionPhoto.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList(),
    );
  }

  TenancyConditionRoom copyWith({
    String? roomLabel,
    List<TenancyConditionPhoto>? photos,
  }) {
    return TenancyConditionRoom(
      roomLabel: roomLabel ?? this.roomLabel,
      photos: photos ?? this.photos,
    );
  }
}

/// Full capture session — one document per move-in or move-out.
class TenancyConditionRecord {
  const TenancyConditionRecord({
    required this.recordId,
    required this.userId,
    required this.leaseId,
    required this.recordType,
    required this.rooms,
    required this.createdAt,
    required this.updatedAt,
    this.roomComparisonNotes = const {},
  });

  final String recordId;
  final String userId;
  final String leaseId;
  final TenancyConditionRecordType recordType;
  final List<TenancyConditionRoom> rooms;
  final Map<String, String> roomComparisonNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get totalPhotos =>
      rooms.fold(0, (sum, room) => sum + room.photos.length);

  Map<String, dynamic> toJson() => {
        'recordId': recordId,
        'userId': userId,
        'leaseId': leaseId,
        'recordType': recordType.storageValue,
        'rooms': rooms.map((r) => r.toJson()).toList(),
        'roomComparisonNotes': roomComparisonNotes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory TenancyConditionRecord.fromJson(Map<String, dynamic> json) {
    final roomsRaw = json['rooms'] as List<dynamic>? ?? [];
    final notesRaw = json['roomComparisonNotes'] as Map<String, dynamic>? ?? {};
    return TenancyConditionRecord(
      recordId: json['recordId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      leaseId: json['leaseId'] as String? ?? '',
      recordType: TenancyConditionRecordTypeX.fromStorage(
        json['recordType'] as String?,
      ),
      rooms: roomsRaw
          .map((e) => TenancyConditionRoom.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList(),
      roomComparisonNotes:
          notesRaw.map((k, v) => MapEntry(k.toString(), v.toString())),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  TenancyConditionRecord copyWith({
    String? recordId,
    String? userId,
    String? leaseId,
    TenancyConditionRecordType? recordType,
    List<TenancyConditionRoom>? rooms,
    Map<String, String>? roomComparisonNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TenancyConditionRecord(
      recordId: recordId ?? this.recordId,
      userId: userId ?? this.userId,
      leaseId: leaseId ?? this.leaseId,
      recordType: recordType ?? this.recordType,
      rooms: rooms ?? this.rooms,
      roomComparisonNotes: roomComparisonNotes ?? this.roomComparisonNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Matched room pair for compare UI.
class TenancyConditionRoomComparison {
  const TenancyConditionRoomComparison({
    required this.displayLabel,
    this.moveInRoom,
    this.moveOutRoom,
    this.unmatchedMoveOut = false,
  });

  final String displayLabel;
  final TenancyConditionRoom? moveInRoom;
  final TenancyConditionRoom? moveOutRoom;
  final bool unmatchedMoveOut;
}
