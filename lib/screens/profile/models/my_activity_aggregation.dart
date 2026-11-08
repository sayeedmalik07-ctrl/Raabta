import 'package:raabta/screens/profile/models/my_activity_item.dart';

/// Read-only My Activity aggregation snapshot across vertical source streams.
class MyActivityAggregation {
  const MyActivityAggregation({
    required this.items,
    this.failedVerticals = const {},
  });

  final List<MyActivityItem> items;
  final Set<MyActivityVertical> failedVerticals;

  bool get hasPartialFailure => failedVerticals.isNotEmpty;

  bool get isFullyLoaded => failedVerticals.isEmpty;

  /// True only when every vertical loaded successfully and returned zero items.
  bool get isConfirmedEmpty => isFullyLoaded && items.isEmpty;
}

/// Tracks per-vertical load outcomes for [MyActivityRepository].
class MyActivityAggregator {
  final Map<MyActivityVertical, List<MyActivityItem>> _items = {};
  final Set<MyActivityVertical> _failed = {};

  void setSuccess(MyActivityVertical vertical, List<MyActivityItem> items) {
    _failed.remove(vertical);
    _items[vertical] = items;
  }

  void setFailure(MyActivityVertical vertical) {
    _failed.add(vertical);
    _items[vertical] = const [];
  }

  MyActivityAggregation snapshot() {
    final merged = _items.values.expand((items) => items).toList()
      ..sort((a, b) => b.sortTime.compareTo(a.sortTime));
    return MyActivityAggregation(
      items: merged,
      failedVerticals: Set.unmodifiable(_failed),
    );
  }
}

/// Merges owner and viewer housing items without collapsing distinct requests.
List<MyActivityItem> mergeHousingActivityItems(
  List<MyActivityItem> ownerItems,
  List<MyActivityItem> viewerItems,
) {
  final seenSourceIds = <String>{};
  final merged = <MyActivityItem>[];

  for (final item in [...ownerItems, ...viewerItems]) {
    final sourceId = item.sourceId;
    if (sourceId != null) {
      if (!seenSourceIds.add(sourceId)) continue;
    }
    merged.add(item);
  }

  return merged;
}
