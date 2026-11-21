import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/data/models/job_application.dart';
import 'package:raabta/data/models/job_listing_source.dart';
import 'package:raabta/data/repositories/jobs_repository.dart';
import 'package:raabta/features/business/data/business_appointment_repository.dart';
import 'package:raabta/features/business/data/business_quote_repository.dart';
import 'package:raabta/features/business/domain/business_appointment_request.dart';
import 'package:raabta/features/business/domain/business_quote_request.dart';
import 'package:raabta/features/housing/data/housing_viewing_repository.dart';
import 'package:raabta/features/housing/domain/housing_viewing_request.dart';
import 'package:raabta/features/marketplace/domain/marketplace_offer.dart';
import 'package:raabta/screens/profile/models/my_activity_aggregation.dart';
import 'package:raabta/screens/profile/models/my_activity_item.dart';
import 'package:raabta/screens/services/domain/service_quote.dart';
import 'package:raabta/screens/services/models/service_listing.dart';
import 'package:raabta/config/compliance_flags_gate.dart';
import 'package:raabta/services/firebase_service.dart';

/// Read-only aggregation of pending actions from built vertical features.
class MyActivityRepository {
  MyActivityRepository({
    FirebaseFirestore? firestore,
    HousingViewingRepository? housingViewings,
    JobsRepository? jobs,
    BusinessAppointmentRepository? businessAppointments,
    BusinessQuoteRepository? businessQuotes,
  })  : _db = firestore ??
            (FirebaseService.isReady ? FirebaseFirestore.instance : null),
        _housingViewings = housingViewings ?? HousingViewingRepository(),
        _jobs = jobs ?? JobsRepository(),
        _businessAppointments =
            businessAppointments ?? BusinessAppointmentRepository(),
        _businessQuotes = businessQuotes ?? BusinessQuoteRepository();

  final FirebaseFirestore? _db;
  final HousingViewingRepository _housingViewings;
  final JobsRepository _jobs;
  final BusinessAppointmentRepository _businessAppointments;
  final BusinessQuoteRepository _businessQuotes;

  Stream<MyActivityAggregation> watchPendingItems(String uid) {
    if (_db == null || uid.isEmpty) {
      return Stream.value(const MyActivityAggregation(items: []));
    }

    return Stream<MyActivityAggregation>.multi((controller) {
      final aggregator = MyActivityAggregator();

      void emitMerged() {
        controller.add(aggregator.snapshot());
      }

      final subs = <StreamSubscription<dynamic>>[];

      subs.add(
        _watchMarketplaceOffers(uid).listen(
          (items) {
            aggregator.setSuccess(MyActivityVertical.marketplace, items);
            emitMerged();
          },
          onError: (_) {
            aggregator.setFailure(MyActivityVertical.marketplace);
            emitMerged();
          },
        ),
      );

      subs.add(
        _watchHousingViewings(uid).listen(
          (items) {
            aggregator.setSuccess(MyActivityVertical.housing, items);
            emitMerged();
          },
          onError: (_) {
            aggregator.setFailure(MyActivityVertical.housing);
            emitMerged();
          },
        ),
      );

      subs.add(
        _watchServiceQuotes(uid).listen(
          (items) {
            aggregator.setSuccess(MyActivityVertical.services, items);
            emitMerged();
          },
          onError: (_) {
            aggregator.setFailure(MyActivityVertical.services);
            emitMerged();
          },
        ),
      );

      subs.add(
        _watchJobApplications(uid).listen(
          (items) {
            aggregator.setSuccess(MyActivityVertical.jobs, items);
            emitMerged();
          },
          onError: (_) {
            aggregator.setFailure(MyActivityVertical.jobs);
            emitMerged();
          },
        ),
      );

      subs.add(
        _watchBusinessStructured(uid).listen(
          (items) {
            aggregator.setSuccess(MyActivityVertical.business, items);
            emitMerged();
          },
          onError: (_) {
            aggregator.setFailure(MyActivityVertical.business);
            emitMerged();
          },
        ),
      );

      controller.onCancel = () {
        for (final sub in subs) {
          unawaited(sub.cancel());
        }
      };
    });
  }

  Stream<List<MyActivityItem>> _watchMarketplaceOffers(String uid) {
    if (!ComplianceFlagsGate.current.offersEnabled) {
      return Stream.value(const []);
    }
    return _db!.collectionGroup('offers').snapshots().asyncMap((snap) async {
      final items = <MyActivityItem>[];
      for (final doc in snap.docs) {
        final offer = MarketplaceOffer.fromJson(doc.id, doc.data());
        if (!MyActivityFilters.marketplaceOfferNeedsAttention(
          uid,
          sellerId: offer.sellerId,
          buyerId: offer.buyerId,
          status: offer.status.storageValue,
          isExpired: offer.isExpired,
        )) {
          continue;
        }

        var title = offer.listingId;
        final listingRef = doc.reference.parent.parent;
        if (listingRef != null) {
          final listingSnap = await listingRef.get();
          title = listingSnap.data()?['title']?.toString() ?? title;
        }

        final isSeller = offer.sellerId == uid;
        items.add(
          MyActivityItem(
            vertical: MyActivityVertical.marketplace,
            title: title,
            subtitle: offer.offeredPrice.toStringAsFixed(0),
            statusLabel: isSeller ? 'pending' : 'awaiting_buyer',
            route: '/marketplace/listing/${offer.listingId}',
            sortTime: offer.createdAt,
            sourceId: offer.id,
          ),
        );
      }
      return items;
    });
  }

  Stream<List<MyActivityItem>> _watchHousingViewings(String uid) {
    if (!ComplianceFlagsGate.current.viewingsEnabled) {
      return Stream.value(const []);
    }
    return Stream<List<MyActivityItem>>.multi((controller) {
      var ownerItems = <MyActivityItem>[];
      var viewerItems = <MyActivityItem>[];

      void emit() {
        controller.add(mergeHousingActivityItems(ownerItems, viewerItems));
      }

      final subs = <StreamSubscription<dynamic>>[];

      subs.add(
        _housingViewings.watchOwnerRequests(uid).asyncMap((requests) async {
          final items = <MyActivityItem>[];
          for (final request in requests) {
            if (!_housingNeedsAttention(uid, request)) continue;
            items.add(await _housingItem(request));
          }
          return items;
        }).listen(
          (items) {
            ownerItems = items;
            emit();
          },
          onError: controller.addError,
        ),
      );

      subs.add(
        _db!
            .collectionGroup('viewing_requests')
            .where('viewerId', isEqualTo: uid)
            .snapshots()
            .asyncMap((snap) async {
          final items = <MyActivityItem>[];
          for (final doc in snap.docs) {
            final request = HousingViewingRequest.fromJson(doc.id, doc.data());
            if (!_housingNeedsAttention(uid, request)) continue;
            items.add(await _housingItem(request));
          }
          return items;
        }).listen(
          (items) {
            viewerItems = items;
            emit();
          },
          onError: controller.addError,
        ),
      );

      controller.onCancel = () {
        for (final sub in subs) {
          unawaited(sub.cancel());
        }
      };
    });
  }

  bool _housingNeedsAttention(String uid, HousingViewingRequest request) {
    return MyActivityFilters.housingViewingNeedsAttention(
      uid,
      ownerId: request.ownerId,
      viewerId: request.viewerId,
      status: request.status.storageValue,
      isExpired: request.isExpired,
    );
  }

  Future<MyActivityItem> _housingItem(HousingViewingRequest request) async {
    var title = request.listingId;
    final listingSnap =
        await _db!.collection('listings').doc(request.listingId).get();
    if (listingSnap.exists) {
      title = listingSnap.data()?['title']?.toString() ?? title;
    }

    return MyActivityItem(
      vertical: MyActivityVertical.housing,
      title: title,
      statusLabel: request.status.storageValue,
      route: '/housing/listing/${request.listingId}',
      sortTime: request.createdAt,
      sourceId: request.id,
    );
  }

  Stream<List<MyActivityItem>> _watchServiceQuotes(String uid) {
    if (!ComplianceFlagsGate.current.quotesEnabled) {
      return Stream.value(const []);
    }
    return Stream<List<MyActivityItem>>.multi((controller) {
      var customerItems = <MyActivityItem>[];
      var providerItems = <MyActivityItem>[];

      void emit() {
        controller.add([...customerItems, ...providerItems]);
      }

      final subs = <StreamSubscription<dynamic>>[];

      subs.add(
        _db!
            .collection('service_listings')
            .where('userId', isEqualTo: uid)
            .snapshots()
            .asyncMap((snap) async {
          final items = <MyActivityItem>[];
          for (final doc in snap.docs) {
            final listing = ServiceListing.fromFirestore(doc);
            if (!listing.isRequest || !listing.quotesOpen) continue;

            final quotesSnap = await doc.reference.collection('quotes').get();
            for (final quoteDoc in quotesSnap.docs) {
              final quote = ServiceQuote.fromJson(quoteDoc.id, quoteDoc.data());
              if (quote.status != ServiceQuoteStatus.submitted) continue;
              items.add(
                MyActivityItem(
                  vertical: MyActivityVertical.services,
                  title: listing.displayTitle,
                  statusLabel: 'quote_submitted',
                  route: '/services/listing/${listing.id}',
                  sortTime: quote.createdAt,
                  subtitle: quote.providerName,
                  sourceId: quote.id,
                ),
              );
            }
          }
          return items;
        }).listen(
          (items) {
            customerItems = items;
            emit();
          },
          onError: controller.addError,
        ),
      );

      subs.add(
        _db
            .collectionGroup('quotes')
            .where('providerId', isEqualTo: uid)
            .snapshots()
            .asyncMap((snap) async {
          final items = <MyActivityItem>[];
          for (final doc in snap.docs) {
            final quote = ServiceQuote.fromJson(doc.id, doc.data());
            final listingSnap = await _db
                .collection('service_listings')
                .doc(quote.requestListingId)
                .get();
            if (!listingSnap.exists) continue;
            final listing = ServiceListing.fromFirestore(listingSnap);

            if (quote.status == ServiceQuoteStatus.selected) {
              items.add(
                MyActivityItem(
                  vertical: MyActivityVertical.services,
                  title: listing.displayTitle,
                  statusLabel: 'quote_selected',
                  route:
                      '/services/listing/${listing.id}/chat/${quote.providerId}',
                  sortTime: quote.createdAt,
                  subtitle: quote.providerName,
                  sourceId: quote.id,
                ),
              );
            }
          }
          return items;
        }).listen(
          (items) {
            providerItems = items;
            emit();
          },
          onError: controller.addError,
        ),
      );

      controller.onCancel = () {
        for (final sub in subs) {
          unawaited(sub.cancel());
        }
      };
    });
  }

  Stream<List<MyActivityItem>> _watchBusinessStructured(String uid) {
    final flags = ComplianceFlagsGate.current;
    if (!flags.businessQuotesEnabled && !flags.businessAppointmentsEnabled) {
      return Stream.value(const []);
    }
    return Stream<List<MyActivityItem>>.multi((controller) {
      var ownerApptItems = <MyActivityItem>[];
      var requesterApptItems = <MyActivityItem>[];
      var ownerQuoteItems = <MyActivityItem>[];
      var requesterQuoteItems = <MyActivityItem>[];

      void emit() {
        final seen = <String>{};
        final merged = <MyActivityItem>[];
        for (final item in [
          ...ownerApptItems,
          ...requesterApptItems,
          ...ownerQuoteItems,
          ...requesterQuoteItems,
        ]) {
          final sourceId = item.sourceId;
          if (sourceId != null) {
            if (!seen.add(sourceId)) continue;
          }
          merged.add(item);
        }
        controller.add(merged);
      }

      final subs = <StreamSubscription<dynamic>>[];

      subs.add(
        _businessAppointments.watchOwnerRequests(uid).asyncMap((requests) async {
          return [
            for (final request in requests)
              if (MyActivityFilters.businessAppointmentNeedsAttention(
                uid,
                ownerId: request.ownerId,
                requesterId: request.requesterId,
                status: request.status.storageValue,
                isExpired: request.isExpired,
              ))
                await _businessAppointmentItem(request),
          ];
        }).listen(
          (items) {
            ownerApptItems = items;
            emit();
          },
          onError: controller.addError,
        ),
      );

      subs.add(
        _db!
            .collectionGroup('appointment_requests')
            .where('requesterId', isEqualTo: uid)
            .snapshots()
            .asyncMap((snap) async {
          final items = <MyActivityItem>[];
          for (final doc in snap.docs) {
            final request =
                BusinessAppointmentRequest.fromJson(doc.id, doc.data());
            if (!MyActivityFilters.businessAppointmentNeedsAttention(
              uid,
              ownerId: request.ownerId,
              requesterId: request.requesterId,
              status: request.status.storageValue,
              isExpired: request.isExpired,
            )) {
              continue;
            }
            items.add(await _businessAppointmentItem(request));
          }
          return items;
        }).listen(
          (items) {
            requesterApptItems = items;
            emit();
          },
          onError: controller.addError,
        ),
      );

      subs.add(
        _businessQuotes.watchOwnerRequests(uid).asyncMap((requests) async {
          return [
            for (final request in requests)
              if (MyActivityFilters.businessQuoteNeedsAttention(
                uid,
                ownerId: request.ownerId,
                requesterId: request.requesterId,
                status: request.status.storageValue,
                isExpired: request.isExpired,
              ))
                await _businessQuoteItem(request),
          ];
        }).listen(
          (items) {
            ownerQuoteItems = items;
            emit();
          },
          onError: controller.addError,
        ),
      );

      subs.add(
        _db!
            .collectionGroup('quote_requests')
            .where('requesterId', isEqualTo: uid)
            .snapshots()
            .asyncMap((snap) async {
          final items = <MyActivityItem>[];
          for (final doc in snap.docs) {
            final request = BusinessQuoteRequest.fromJson(doc.id, doc.data());
            if (!MyActivityFilters.businessQuoteNeedsAttention(
              uid,
              ownerId: request.ownerId,
              requesterId: request.requesterId,
              status: request.status.storageValue,
              isExpired: request.isExpired,
            )) {
              continue;
            }
            items.add(await _businessQuoteItem(request));
          }
          return items;
        }).listen(
          (items) {
            requesterQuoteItems = items;
            emit();
          },
          onError: controller.addError,
        ),
      );

      controller.onCancel = () {
        for (final sub in subs) {
          unawaited(sub.cancel());
        }
      };
    });
  }

  Future<MyActivityItem> _businessAppointmentItem(
    BusinessAppointmentRequest request,
  ) async {
    var title = request.businessId;
    final snap = await _db!
        .collection('businesses')
        .doc(request.businessId)
        .get();
    if (snap.exists) {
      title = snap.data()?['name']?.toString() ?? title;
    }
    return MyActivityItem(
      vertical: MyActivityVertical.business,
      title: title,
      statusLabel: request.status.storageValue,
      route: '/businesses?listingId=${request.businessId}',
      sortTime: request.updatedAt,
      sourceId: '${request.businessId}_${request.id}',
    );
  }

  Future<MyActivityItem> _businessQuoteItem(BusinessQuoteRequest request) async {
    var title = request.businessId;
    final snap = await _db!
        .collection('businesses')
        .doc(request.businessId)
        .get();
    if (snap.exists) {
      title = snap.data()?['name']?.toString() ?? title;
    }
    return MyActivityItem(
      vertical: MyActivityVertical.business,
      title: title,
      statusLabel: request.status.storageValue,
      route: '/businesses?listingId=${request.businessId}',
      sortTime: request.updatedAt,
      sourceId: '${request.businessId}_${request.id}',
    );
  }

  Stream<List<MyActivityItem>> _watchJobApplications(String uid) {
    if (!ComplianceFlagsGate.current.jobApplicationStatusEnabled) {
      return Stream.value(const []);
    }
    return Stream<List<MyActivityItem>>.multi((controller) {
      var candidateItems = <MyActivityItem>[];
      final employerItemsByJob = <String, List<MyActivityItem>>{};
      final employerSubs = <String, StreamSubscription<List<MyActivityItem>>>{};

      void emit() {
        final employerItems =
            employerItemsByJob.values.expand((items) => items).toList();
        controller.add([...candidateItems, ...employerItems]);
      }

      final subs = <StreamSubscription<dynamic>>[];

      subs.add(
        _jobs.watchUserApplications(uid).listen(
          (apps) {
            candidateItems = [
              for (final app in apps)
                if (MyActivityFilters.jobApplicationNeedsAttention(
                  uid,
                  applicantUid: app.applicantUid,
                  status: app.status.storageValue,
                  jobPosterUid: null,
                ))
                  MyActivityItem(
                    vertical: MyActivityVertical.jobs,
                    title: app.jobTitle,
                    subtitle: app.company,
                    statusLabel: app.status.storageValue,
                    route: '/jobs/chat/${app.jobId}/${app.applicantUid}',
                    sortTime: app.updatedAt ?? app.createdAt,
                    sourceId: app.id,
                  ),
            ];
            emit();
          },
          onError: controller.addError,
        ),
      );

      subs.add(
        _jobs.watchUserJobs(uid).listen(
          (jobs) {
            final activeJobIds = <String>{};
            for (final job in jobs) {
              if (job['listingSource'] ==
                  JobListingSource.aggregatedExternal.storageValue) {
                continue;
              }
              final jobId = job['id'] as String;
              activeJobIds.add(jobId);
              if (employerSubs.containsKey(jobId)) continue;

              final jobTitle = job['title']?.toString() ?? 'Job';
              employerSubs[jobId] = _jobs.watchJobApplications(jobId).map(
                (apps) {
                  return [
                    for (final app in apps)
                      if (MyActivityFilters.jobApplicationNeedsAttention(
                        uid,
                        applicantUid: app.applicantUid,
                        status: app.status.storageValue,
                        jobPosterUid: uid,
                      ))
                        MyActivityItem(
                          vertical: MyActivityVertical.jobs,
                          title: jobTitle,
                          subtitle: app.applicantUid,
                          statusLabel: app.status.storageValue,
                          route: '/jobs/listing/$jobId/applications',
                          sortTime: app.createdAt,
                          sourceId: app.id,
                        ),
                  ];
                },
              ).listen(
                (items) {
                  employerItemsByJob[jobId] = items;
                  emit();
                },
                onError: controller.addError,
              );
            }

            for (final jobId in employerSubs.keys.toList()) {
              if (!activeJobIds.contains(jobId)) {
                unawaited(employerSubs.remove(jobId)?.cancel());
                employerItemsByJob.remove(jobId);
              }
            }
            emit();
          },
          onError: controller.addError,
        ),
      );

      controller.onCancel = () {
        for (final sub in subs) {
          unawaited(sub.cancel());
        }
        for (final sub in employerSubs.values) {
          unawaited(sub.cancel());
        }
      };
    });
  }
}
