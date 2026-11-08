import 'package:cloud_firestore/cloud_firestore.dart';

enum DietType {
  noRestriction,
  vegetarian,
  vegan,
  pescatarian,
  keto,
  diabeticFriendly,
}

class DietaryProfile {
  final List<String> allergies;
  final bool halalRequired;
  final DietType dietType;
  final DateTime createdAt;

  const DietaryProfile({
    required this.allergies,
    required this.halalRequired,
    required this.dietType,
    required this.createdAt,
  });

  // ── Firestore serialization ──────────────────────────
  Map<String, dynamic> toFirestore() => {
    'allergies':     allergies,
    'halalRequired': halalRequired,
    'dietType':      dietType.name,
    'createdAt':     Timestamp.fromDate(createdAt),
  };

  factory DietaryProfile.fromFirestore(
    DocumentSnapshot doc,
  ) {
    final d = doc.data() as Map<String, dynamic>? ?? {};

    DietType parseDietType(String? raw) {
      return DietType.values.firstWhere(
        (e) => e.name == raw,
        orElse: () => DietType.noRestriction,
      );
    }

    return DietaryProfile(
      allergies: List<String>.from(
        d['allergies'] as List<dynamic>? ?? [],
      ),
      halalRequired: d['halalRequired'] as bool? ?? false,
      dietType: parseDietType(d['dietType'] as String?),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  // ── Human-readable summary for Claude prompt ────────
  String toPromptSummary() {
    final parts = <String>[];
    if (halalRequired) parts.add('requires halal food');
    if (allergies.isNotEmpty) {
      parts.add('allergic to: ${allergies.join(", ")}');
    }
    if (dietType != DietType.noRestriction) {
      parts.add('diet type: ${dietType.name}');
    }
    if (parts.isEmpty) return 'no dietary restrictions';
    return parts.join('; ');
  }

  static const String firestoreCollection = 'user_dietary_profile';
}
