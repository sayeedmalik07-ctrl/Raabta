import 'package:raabta/features/tenancy/domain/models/tenancy_condition_models.dart';

/// Matches move-in and move-out rooms by label — no guessing beyond close string match.
abstract final class TenancyConditionRoomMatcher {
  static String normalize(String label) =>
      label.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  static List<TenancyConditionRoomComparison> compare({
    required List<TenancyConditionRoom> moveInRooms,
    required List<TenancyConditionRoom> moveOutRooms,
  }) {
    final comparisons = <TenancyConditionRoomComparison>[];
    final matchedMoveOut = <int>{};

    for (final inRoom in moveInRooms) {
      final matchIndex = _findMatch(inRoom.roomLabel, moveOutRooms, matchedMoveOut);
      TenancyConditionRoom? outRoom;
      if (matchIndex != null) {
        matchedMoveOut.add(matchIndex);
        outRoom = moveOutRooms[matchIndex];
      }
      comparisons.add(
        TenancyConditionRoomComparison(
          displayLabel: inRoom.roomLabel,
          moveInRoom: inRoom,
          moveOutRoom: outRoom,
        ),
      );
    }

    for (var i = 0; i < moveOutRooms.length; i++) {
      if (matchedMoveOut.contains(i)) continue;
      comparisons.add(
        TenancyConditionRoomComparison(
          displayLabel: moveOutRooms[i].roomLabel,
          moveOutRoom: moveOutRooms[i],
          unmatchedMoveOut: true,
        ),
      );
    }

    return comparisons;
  }

  static int? _findMatch(
    String inLabel,
    List<TenancyConditionRoom> moveOutRooms,
    Set<int> alreadyMatched,
  ) {
    final normalizedIn = normalize(inLabel);
    if (normalizedIn.isEmpty) return null;

    for (var i = 0; i < moveOutRooms.length; i++) {
      if (alreadyMatched.contains(i)) continue;
      if (normalize(moveOutRooms[i].roomLabel) == normalizedIn) return i;
    }

    for (var i = 0; i < moveOutRooms.length; i++) {
      if (alreadyMatched.contains(i)) continue;
      final out = normalize(moveOutRooms[i].roomLabel);
      if (out.contains(normalizedIn) || normalizedIn.contains(out)) {
        return i;
      }
    }

    return null;
  }
}
