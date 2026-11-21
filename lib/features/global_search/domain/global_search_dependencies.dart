import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/data/models/business_listing.dart';
import 'package:raabta/data/models/job_listing.dart';
import 'package:raabta/features/exchange_locator/domain/repositories/exchange_locator_repository.dart';
import 'package:raabta/features/prayer_mosque/data/mosque_data_source.dart';
import 'package:raabta/features/trip_planner/data/trip_planner_repository.dart';

/// Shared dependencies injected into search providers.
class GlobalSearchDependencies {
  GlobalSearchDependencies({
    this.firestore,
    this.exchangeRepository,
    this.tripPlannerRepository,
    this.locale = 'English',
    MosqueDataSource? mosqueDataSource,
    List<JobListing>? jobsCatalog,
    List<BusinessListing>? businessesCatalog,
  })  : mosqueDataSource = mosqueDataSource ?? MosqueDataSource(),
        jobsCatalog = jobsCatalog ?? const [],
        businessesCatalog = businessesCatalog ?? const [];

  final FirebaseFirestore? firestore;
  final String locale;
  final ExchangeLocatorRepository? exchangeRepository;
  final TripPlannerRepository? tripPlannerRepository;
  final MosqueDataSource mosqueDataSource;
  final List<JobListing> jobsCatalog;
  final List<BusinessListing> businessesCatalog;
}
