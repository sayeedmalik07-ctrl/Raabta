import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/saved_search/domain/saved_search_criteria.dart';
import 'package:raabta/features/saved_search/domain/saved_search_vertical.dart';

class SavedSearch {
  const SavedSearch({
    required this.id,
    required this.userId,
    required this.vertical,
    required this.name,
    required this.criteria,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final SavedSearchVertical vertical;
  final String name;
  final SavedSearchCriteria criteria;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory SavedSearch.fromFirestore(String id, Map<String, dynamic> data) {
    final vertical = SavedSearchVertical.fromStorage(data['vertical'] as String?) ??
        SavedSearchVertical.housing;
    return SavedSearch(
      id: id,
      userId: data['userId'] as String? ?? '',
      vertical: vertical,
      name: data['name'] as String? ?? '',
      criteria: SavedSearchCriteria.fromJson(
        (data['criteria'] as Map?)?.cast<String, dynamic>(),
      ),
      active: data['active'] as bool? ?? true,
      createdAt: _readTimestamp(data['createdAt']),
      updatedAt: _readTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'vertical': vertical.storageValue,
      'name': name,
      'criteria': criteria.toJson(),
      'active': active,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  SavedSearch copyWith({
    String? name,
    bool? active,
    SavedSearchCriteria? criteria,
    DateTime? updatedAt,
  }) {
    return SavedSearch(
      id: id,
      userId: userId,
      vertical: vertical,
      name: name ?? this.name,
      criteria: criteria ?? this.criteria,
      active: active ?? this.active,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime _readTimestamp(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
