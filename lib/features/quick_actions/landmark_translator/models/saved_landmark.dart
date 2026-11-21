import 'package:cloud_firestore/cloud_firestore.dart';

class SavedLandmark {
  final String id;
  final String label;
  final String englishDescription;
  final String arabicDescription;
  final DateTime lastUsed;

  const SavedLandmark({
    required this.id,
    required this.label,
    required this.englishDescription,
    required this.arabicDescription,
    required this.lastUsed,
  });

  /// Per-user subcollection: `users/{uid}/saved_landmarks`.
  static const String subcollection = 'saved_landmarks';

  static String pathForUser(String uid) => 'users/$uid/$subcollection';

  static CollectionReference<Map<String, dynamic>> collectionForUser(
    String uid,
  ) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection(subcollection);

  // Preset labels the user can choose as a shortcut name
  static const List<String> presetLabels = [
    '🏠  Home',
    '💼  Work',
    '🏋️  Gym',
    '🕌  Mosque',
    '🏫  School',
    '🏥  Clinic',
    '🛒  Supermarket',
    '📍  Custom',
  ];

  factory SavedLandmark.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return SavedLandmark(
      id:                  doc.id,
      label:               d['label']               as String? ?? '',
      englishDescription:  d['englishDescription']  as String? ?? '',
      arabicDescription:   d['arabicDescription']   as String? ?? '',
      lastUsed: (d['lastUsed'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'label':              label,
    'englishDescription': englishDescription,
    'arabicDescription':  arabicDescription,
    'lastUsed':           Timestamp.fromDate(lastUsed),
  };
}
