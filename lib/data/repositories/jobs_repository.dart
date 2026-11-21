import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/data/models/job_application.dart';
import 'package:raabta/data/models/job_application_lifecycle.dart';
import 'package:raabta/data/models/job_listing.dart';
import 'package:raabta/data/models/job_listing_source.dart';
import 'package:raabta/data/models/job_requirements.dart';
import 'package:raabta/data/repositories/job_application_chat_repository.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:raabta/config/compliance_flags_gate.dart';
import 'package:raabta/services/jobs/job_application_notification_service.dart';

class JobsRepository {
  JobsRepository({
    FirebaseFirestore? firestore,
    JobApplicationChatRepository? chatRepository,
    JobApplicationNotificationService? notifications,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _usesDefaultFirestore = firestore == null,
        _chat = chatRepository ?? JobApplicationChatRepository(firestore: firestore),
        _notifications =
            notifications ?? JobApplicationNotificationService();

  final FirebaseFirestore _db;
  final bool _usesDefaultFirestore;
  final JobApplicationChatRepository _chat;
  final JobApplicationNotificationService _notifications;

  bool get _firebaseUnavailable =>
      _usesDefaultFirestore && !FirebaseService.isReady;

  static const jobsCollection = 'jobs';
  static const applicationsCollection = 'job_applications';

  /// Firestore `whereIn` limit for document-ID batch reads.
  static const activeJobsByIdsChunkSize = 30;

  Stream<List<JobListing>> watchActiveJobs({int limit = 100}) {
    if (_firebaseUnavailable) {
      return Stream.value(const []);
    }
    return _db
        .collection(jobsCollection)
        .where('status', isEqualTo: 'active')
        .limit(limit)
        .snapshots()
        .map(_mapAndSortActiveJobs);
  }

  static List<JobListing> _mapAndSortActiveJobs(
    QuerySnapshot<Map<String, dynamic>> snap,
  ) {
    final jobs = snap.docs
        .map((doc) => JobListing.fromFirestore(doc.data(), doc.id))
        .toList();
    jobs.sort((a, b) {
      final aTime = a.postedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.postedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return jobs;
  }

  Future<String> createJob({
    required String title,
    required String company,
    required String salary,
    required String location,
    required String description,
    required String contact,
    required String category,
    required List<String> benefits,
    required JobRequirementsSpec requirements,
    String? email,
    String type = 'Full Time',
    String? jobId,
    String? businessId,
  }) async {
    if (_firebaseUnavailable) {
      throw StateError('Firebase is not initialized');
    }

    final uid = _usesDefaultFirestore
        ? (FirebaseAuth.instance.currentUser?.uid ?? '')
        : 'test-user';
    final spec = requirements;
    final experience =
        spec.minimumExperience.trim().isNotEmpty ? spec.minimumExperience.trim() : 'Not specified';

    final payload = <String, dynamic>{
      'title': title.trim(),
      'company': company.trim(),
      'salary': salary.trim(),
      'location': location.trim(),
      'description': description.trim(),
      'contact': contact.trim(),
      'category': category,
      'industry': category,
      'type': type,
      'experience': experience,
      'benefits': benefits,
      'email': email?.trim(),
      'status': 'active',
      'applicantCount': 0,
      'postedBy': uid,
      'listingSource': JobListingSource.raabtaNative.storageValue,
      'createdAt': FieldValue.serverTimestamp(),
      ...spec.toFirestore(),
    };
    final trimmedBusinessId = businessId?.trim();
    if (trimmedBusinessId != null && trimmedBusinessId.isNotEmpty) {
      payload['businessId'] = trimmedBusinessId;
    }

    if (jobId != null && jobId.isNotEmpty) {
      final existing = await _db.collection(jobsCollection).doc(jobId).get();
      if (existing.exists) {
        final owner = existing.data()?['postedBy']?.toString() ?? '';
        if (owner != uid) {
          throw StateError('listing_ownership_mismatch');
        }
        return jobId;
      }
      await _db.collection(jobsCollection).doc(jobId).set(payload);
      return jobId;
    }

    final doc = await _db.collection(jobsCollection).add(payload);
    return doc.id;
  }

  Future<JobListing?> fetchJob(String jobId) async {
    if (_firebaseUnavailable || jobId.isEmpty) return null;
    final snap = await _db.collection(jobsCollection).doc(jobId).get();
    if (!snap.exists) return null;
    return JobListing.fromFirestore(snap.data() ?? {}, snap.id);
  }

  /// Loads active listings for the given document IDs using chunked `whereIn`.
  ///
  /// Returns a map keyed by job id. Does not query when [jobIds] is empty.
  Future<Map<String, JobListing>> fetchActiveJobsByIds(
    List<String> jobIds,
  ) async {
    final orderedUnique = orderedUniqueSavedJobIds(jobIds);
    if (orderedUnique.isEmpty) {
      return const {};
    }
    if (_firebaseUnavailable) {
      throw StateError('Firebase is not initialized');
    }

    final found = <String, JobListing>{};
    for (var start = 0; start < orderedUnique.length; start += activeJobsByIdsChunkSize) {
      final end = start + activeJobsByIdsChunkSize;
      final chunk = orderedUnique.sublist(
        start,
        end > orderedUnique.length ? orderedUnique.length : end,
      );
      final snap = await _db
          .collection(jobsCollection)
          .where(FieldPath.documentId, whereIn: chunk)
          .where('status', isEqualTo: 'active')
          .get();
      for (final doc in snap.docs) {
        found[doc.id] = JobListing.fromFirestore(doc.data(), doc.id);
      }
    }
    return found;
  }

  /// Preserves first-seen order and drops blank / duplicate ids.
  static List<String> orderedUniqueSavedJobIds(List<String> jobIds) {
    final seen = <String>{};
    final ordered = <String>[];
    for (final raw in jobIds) {
      final id = raw.trim();
      if (id.isEmpty || seen.contains(id)) continue;
      seen.add(id);
      ordered.add(id);
    }
    return ordered;
  }

  /// Maps [savedJobIds] order onto [activeById] from [fetchActiveJobsByIds].
  static List<JobListing> orderActiveSavedJobs({
    required List<String> savedJobIds,
    required Map<String, JobListing> activeById,
  }) {
    final listings = <JobListing>[];
    for (final id in orderedUniqueSavedJobIds(savedJobIds)) {
      final job = activeById[id];
      if (job != null) {
        listings.add(job);
      }
    }
    return listings;
  }

  Future<void> submitApplication({
    required String jobId,
    required String jobTitle,
    required String company,
    String? cvVaultDocumentId,
    String? cvDocumentId,
  }) async {
    ComplianceFlagsGate.requireJobApplicationStatus();
    if (_firebaseUnavailable) {
      throw StateError('Firebase is not initialized');
    }
    final uid = _usesDefaultFirestore ? FirebaseAuth.instance.currentUser?.uid : 'test-user';
    if (uid == null || uid.isEmpty) {
      throw StateError('Sign in required to submit an application');
    }

    final job = await fetchJob(jobId);
    if (job == null) {
      throw StateError('Job not found');
    }
    if (!job.supportsApplicationTracking) {
      throw StateError('Application tracking is not available for this listing');
    }

    final existing = await _db
        .collection(applicationsCollection)
        .where('jobId', isEqualTo: jobId)
        .where('applicantUid', isEqualTo: uid)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      throw StateError('You have already applied to this job');
    }

    final applicationId =
        JobApplication.deterministicDocId(jobId, uid);
    final application = JobApplication(
      id: applicationId,
      jobId: jobId,
      jobTitle: jobTitle,
      company: company,
      applicantUid: uid,
      status: JobApplicationStatus.applied,
      listingSource: job.listingSource,
      createdAt: DateTime.now(),
      cvVaultDocumentId: cvVaultDocumentId,
      cvDocumentId: cvDocumentId,
    );

    await _db
        .collection(applicationsCollection)
        .doc(applicationId)
        .set(application.toFirestore());

    await _db.collection(jobsCollection).doc(jobId).update({
      'applicantCount': FieldValue.increment(1),
    });
  }

  Stream<List<JobApplication>> watchUserApplications(String uid) {
    if (_firebaseUnavailable || uid.isEmpty) {
      return Stream.value(const []);
    }
    return _db
        .collection(applicationsCollection)
        .where('applicantUid', isEqualTo: uid)
        .snapshots()
        .map((snap) {
      final apps = snap.docs
          .map(JobApplication.fromFirestore)
          .where((app) => app.isNativeTracked)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return apps;
    });
  }

  Stream<JobApplication?> watchUserApplicationForJob({
    required String uid,
    required String jobId,
  }) {
    if (_firebaseUnavailable || uid.isEmpty || jobId.isEmpty) {
      return Stream.value(null);
    }
    return _db
        .collection(applicationsCollection)
        .where('jobId', isEqualTo: jobId)
        .where('applicantUid', isEqualTo: uid)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      final app = JobApplication.fromFirestore(snap.docs.first);
      return app.isNativeTracked ? app : null;
    });
  }

  Stream<List<JobApplication>> watchJobApplications(String jobId) {
    if (_firebaseUnavailable || jobId.isEmpty) {
      return Stream.value(const []);
    }
    return _db
        .collection(applicationsCollection)
        .where('jobId', isEqualTo: jobId)
        .snapshots()
        .map((snap) {
      final apps = snap.docs
          .map(JobApplication.fromFirestore)
          .where((app) => app.isNativeTracked)
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return apps;
    });
  }

  Future<void> updateApplicationStatus({
    required JobApplication application,
    required JobApplicationStatus nextStatus,
    required String locale,
  }) async {
    ComplianceFlagsGate.requireJobApplicationStatus();
    if (_firebaseUnavailable) {
      throw StateError('Firebase is not initialized');
    }
    if (!application.isNativeTracked) {
      throw StateError('Cannot update status for this application');
    }
    if (!JobApplicationLifecycle.canEmployerSet(application.status, nextStatus)) {
      throw StateError('Invalid status transition');
    }

    await _db.collection(applicationsCollection).doc(application.id).update({
      'status': nextStatus.storageValue,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _chat.sendStatusSystemMessage(
      jobId: application.jobId,
      applicantUid: application.applicantUid,
      statusKey: nextStatus.labelKey(),
    );

    await _notifications.notifyStatusChanged(
      recipientUserId: application.applicantUid,
      jobId: application.jobId,
      jobTitle: application.jobTitle,
      statusKey: nextStatus.labelKey(),
      locale: locale,
    );
  }

  Stream<List<Map<String, dynamic>>> watchUserJobs(String uid) {
    if (_firebaseUnavailable || uid.isEmpty) {
      return Stream.value(const []);
    }
    return _db
        .collection(jobsCollection)
        .where('postedBy', isEqualTo: uid)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        DateTime? createdAt;
        final raw = data['createdAt'];
        if (raw is Timestamp) createdAt = raw.toDate();
        return {
          'id': doc.id,
          ...data,
          'createdAt': createdAt ?? DateTime.now(),
        };
      }).toList()
        ..sort((a, b) {
          final aT = a['createdAt'] as DateTime;
          final bT = b['createdAt'] as DateTime;
          return bT.compareTo(aT);
        });
    });
  }
}
