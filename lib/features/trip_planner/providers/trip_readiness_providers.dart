import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_readiness_models.dart';
import 'package:raabta/features/trip_planner/domain/services/trip_readiness_calculator.dart';
import 'package:raabta/features/trip_planner/presentation/screens/trip_subscreens.dart';
import 'package:raabta/features/trip_planner/providers/trip_planner_providers.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Live vault document snapshots for readiness auto-checks.
final vaultDocumentsForReadinessProvider =
    StreamProvider<List<TripVaultDocSnapshot>>((ref) {
  return FirebaseFirestore.instance
      .collection('scanned_documents')
      .orderBy('scanDate', descending: true)
      .snapshots()
      .map(
        (snap) => snap.docs.map((doc) {
          final data = doc.data();
          DateTime? expiry;
          final raw = data['expiryDate'];
          if (raw is Timestamp) {
            expiry = raw.toDate();
          } else if (raw is String) {
            expiry = DateTime.tryParse(raw);
          }
          return TripVaultDocSnapshot(
            docType: data['docType'] as String? ?? 'unknown',
            expiryDate: expiry,
          );
        }).toList(),
      );
});

/// Recomputed on every trip, deadline, or vault change — never cached as a score.
final tripReadinessProvider =
    Provider.family<TripReadinessResult, String>((ref, tripId) {
  final plannerState = ref.watch(tripPlannerProvider);
  final trip = tripForId(plannerState, tripId);
  if (trip == null) return TripReadinessResult.empty;

  final deadlines = ref.watch(documentDeadlinesProvider).valueOrNull ?? [];
  final vaultDocs =
      ref.watch(vaultDocumentsForReadinessProvider).valueOrNull ?? [];

  return TripReadinessCalculator.compute(
    trip: trip,
    deadlines: deadlines,
    vaultDocs: vaultDocs,
  );
});
