import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/data/models/job_requirements.dart';
import 'package:raabta/features/post_engine/domain/post_trade_compliance_ack.dart';
import 'package:raabta/data/repositories/businesses_repository.dart';
import 'package:raabta/features/business/domain/business_contact_mode.dart';
import 'package:raabta/data/repositories/jobs_repository.dart';
import 'package:raabta/features/post_engine/data/post_schema_adapter.dart';
import 'package:raabta/features/post_engine/domain/models/post_publish_models.dart';
import 'package:raabta/features/post_engine/domain/models/post_schema_models.dart';
import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';
import 'package:raabta/features/post_engine/domain/post_media_engine.dart';
import 'package:raabta/features/post_engine/domain/post_photo_requirements.dart';
import 'package:raabta/features/post_engine/domain/post_schema_value_coercion.dart';
import 'package:raabta/models/housing_models.dart';
import 'package:raabta/models/marketplace_models.dart';
import 'package:raabta/screens/services/data/service_listings_repository.dart';
import 'package:raabta/screens/services/models/service_listing.dart';
import 'package:raabta/providers/housing_providers.dart';
import 'package:raabta/services/housing_firestore_service.dart';
import 'package:raabta/services/listings_api_service.dart';
import 'package:raabta/services/marketplace_firestore_service.dart';

export 'package:raabta/features/post_engine/domain/models/post_publish_models.dart'
    show PostPublishResult, PostPublishOutcome, PostPublishPhase;

typedef PostPublishPhaseCallback = void Function({
  required PostPublishPhase phase,
  String? listingId,
  List<int>? uploadedPhotoIndexes,
  List<String>? attachedPhotoUrls,
});

/// Thrown when a concurrent publish is attempted on the same engine instance.
class PostPublishInFlightException implements Exception {
  PostPublishInFlightException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Delegates publish to existing vertical repositories — no duplicate write paths.
class PostPublishEngine {
  PostPublishEngine({
    MarketplaceFirestoreService? marketplace,
    HousingFirestoreService? housing,
    HousingRepository? housingRepository,
    ServiceListingsRepository? services,
    BusinessesRepository? businesses,
    JobsRepository? jobs,
    PostMediaEngine? media,
  })  : _marketplace = marketplace ?? MarketplaceFirestoreService(),
        _housing = housing ?? HousingFirestoreService(),
        _housingRepository =
            housingRepository ?? HousingRepository(ListingsApiService()),
        _services = services ?? ServiceListingsRepository(),
        _businesses = businesses ?? BusinessesRepository(),
        _jobs = jobs ?? JobsRepository(),
        _media = media ?? PostMediaEngine();

  final MarketplaceFirestoreService _marketplace;
  final HousingFirestoreService _housing;
  final HousingRepository _housingRepository;
  final ServiceListingsRepository _services;
  final BusinessesRepository _businesses;
  final JobsRepository _jobs;
  final PostMediaEngine _media;

  bool _publishInFlight = false;

  bool get publishInFlight => _publishInFlight;

  Future<PostPublishResult> publish({
    required String publishId,
    required PostVertical vertical,
    required String categoryPath,
    required Map<String, dynamic> fieldValues,
    required String ownerUserId,
    PostCategoryFieldSchema? schema,
    ServiceListingType serviceListingType = ServiceListingType.provider,
    bool posterIdentityVerified = false,
    String sellerFlag = '🌍',
    JobRequirementsSpec? jobRequirements,
    List<String> jobBenefits = const [],
    String jobType = 'Full Time',
    bool tradeComplianceAcknowledged = false,
    String? linkedBusinessId,
    bool sideEffectsAlreadyEmitted = false,
    PostPublishPhaseCallback? onPhaseUpdate,
  }) async {
    if (_publishInFlight) {
      throw PostPublishInFlightException('Publish already in progress');
    }
    _publishInFlight = true;
    try {
      final listingId = publishId;
      void reportPhase(
        PostPublishPhase phase, {
        List<int>? uploadedPhotoIndexes,
        List<String>? attachedPhotoUrls,
      }) {
        onPhaseUpdate?.call(
          phase: phase,
          listingId: listingId,
          uploadedPhotoIndexes: uploadedPhotoIndexes,
          attachedPhotoUrls: attachedPhotoUrls,
        );
      }

      final PostPublishResult result;
      switch (vertical) {
        case PostVertical.marketplace:
          result = await _publishMarketplace(
            publishId: publishId,
            listingId: listingId,
            fieldValues: fieldValues,
            categoryLeafId: PostSchemaAdapter.leafCategoryId(categoryPath),
            ownerUserId: ownerUserId,
            sellerFlag: sellerFlag,
            schema: schema,
            sideEffectsAlreadyEmitted: sideEffectsAlreadyEmitted,
            reportPhase: reportPhase,
          );
        case PostVertical.housing:
          result = await _publishHousing(
            publishId: publishId,
            listingId: listingId,
            fieldValues: fieldValues,
            categoryLeafId: PostSchemaAdapter.leafCategoryId(categoryPath),
            ownerUserId: ownerUserId,
            schema: schema,
            sideEffectsAlreadyEmitted: sideEffectsAlreadyEmitted,
            reportPhase: reportPhase,
          );
        case PostVertical.services:
          result = await _publishService(
            publishId: publishId,
            listingId: listingId,
            fieldValues: fieldValues,
            categoryLeafId: PostSchemaAdapter.leafCategoryId(categoryPath),
            ownerUserId: ownerUserId,
            listingType: serviceListingType,
            posterIdentityVerified: posterIdentityVerified,
            schema: schema,
            sideEffectsAlreadyEmitted: sideEffectsAlreadyEmitted,
            reportPhase: reportPhase,
          );
        case PostVertical.business:
          result = await _publishBusiness(
            publishId: publishId,
            listingId: listingId,
            fieldValues: fieldValues,
            categoryLeafId: PostSchemaAdapter.leafCategoryId(categoryPath),
            ownerUserId: ownerUserId,
            schema: schema,
            sideEffectsAlreadyEmitted: sideEffectsAlreadyEmitted,
            reportPhase: reportPhase,
          );
        case PostVertical.jobs:
          result = await _publishJob(
            publishId: publishId,
            listingId: listingId,
            fieldValues: fieldValues,
            categoryLeafId: PostSchemaAdapter.leafCategoryId(categoryPath),
            ownerUserId: ownerUserId,
            requirements: jobRequirements ?? const JobRequirementsSpec(),
            benefits: jobBenefits,
            type: jobType,
            linkedBusinessId: linkedBusinessId,
            sideEffectsAlreadyEmitted: sideEffectsAlreadyEmitted,
            reportPhase: reportPhase,
          );
      }
      if (tradeComplianceAcknowledged && !result.resumedExistingListing) {
        await _persistTradeComplianceAck(vertical, result.listingId);
      }
      return result;
    } finally {
      _publishInFlight = false;
    }
  }

  Future<PostPublishResult> _publishMarketplace({
    required String publishId,
    required String listingId,
    required Map<String, dynamic> fieldValues,
    required String categoryLeafId,
    required String ownerUserId,
    required String sellerFlag,
    PostCategoryFieldSchema? schema,
    required bool sideEffectsAlreadyEmitted,
    required void Function(
      PostPublishPhase, {
      List<int>? uploadedPhotoIndexes,
      List<String>? attachedPhotoUrls,
    }) reportPhase,
  }) async {
    final existing = await _marketplace.getListing(listingId);
    final resumed = existing != null;
    if (resumed) {
      _assertOwner(existing.ownerUserId ?? '', ownerUserId);
    }

    final minPhotos = schema != null
        ? PostPhotoRequirements.minPhotoCount(schema, fieldValues)
        : 0;
    final wasAlreadyComplete = resumed &&
        _photoOutcome(
              requiresPhotos: minPhotos > 0,
              attachedCount: existing.photoUrls.length,
              minRequired: minPhotos,
            ) ==
            PostPublishOutcome.completed;

    reportPhase(PostPublishPhase.creating);
    if (!resumed) {
      final mapped = PostSchemaAdapter.toMarketplaceFields(
        fieldValues,
        categoryLeafId: categoryLeafId,
      );
      await _marketplace.createListing(
        MarketplaceListingSubmission(
          ownerUserId: ownerUserId,
          categoryId: mapped['categoryId'] as String,
          title: mapped['title'] as String,
          priceQar: mapped['priceQar'] as int,
          description: mapped['description'] as String,
          condition: mapped['condition'] as String,
          area: mapped['area'] as String,
          sellerFlag: sellerFlag,
          schemaFields: Map<String, dynamic>.from(
            mapped['schemaFields'] as Map? ?? const {},
          ),
        ),
        listingId: listingId,
      );
    }
    reportPhase(PostPublishPhase.created);

    final localPaths = PostMediaEngine.normalizePhotoPaths(fieldValues['photos']);
    final slotCount = PostPhotoRequirements.resolvedPhotoSlotCount(
      vertical: PostVertical.marketplace,
      schema: schema ??
          const PostCategoryFieldSchema(categoryPath: '', fields: []),
      values: fieldValues,
    );
    final existingUrls = existing?.photoUrls ?? const [];

    reportPhase(PostPublishPhase.uploading);
    final upload = await _media.uploadPhotosForPublish(
      vertical: PostVertical.marketplace,
      listingId: listingId,
      localPaths: localPaths,
      ownerUserId: ownerUserId,
      slotCount: slotCount,
      existingAttachedUrls: existingUrls,
      minRequired: minPhotos,
    );

    reportPhase(
      PostPublishPhase.attaching,
      uploadedPhotoIndexes: upload.uploadedIndexes,
    );
    if (upload.photoUrls.isNotEmpty) {
      await _marketplace.attachPhotos(listingId, upload.photoUrls);
    }

    reportPhase(
      PostPublishPhase.finalizing,
      attachedPhotoUrls: upload.photoUrls,
    );
    final outcome = _photoOutcome(
      requiresPhotos: minPhotos > 0,
      attachedCount: upload.photoUrls.length,
      minRequired: minPhotos,
    );
    if (outcome == PostPublishOutcome.completed) {
      reportPhase(PostPublishPhase.completed, attachedPhotoUrls: upload.photoUrls);
    }

    return PostPublishResult(
      listingId: listingId,
      publishId: publishId,
      photoUrls: upload.photoUrls,
      outcome: outcome,
      sideEffectsAlreadyEmitted:
          sideEffectsAlreadyEmitted || wasAlreadyComplete,
      resumedExistingListing: resumed,
    );
  }

  Future<PostPublishResult> _publishHousing({
    required String publishId,
    required String listingId,
    required Map<String, dynamic> fieldValues,
    required String categoryLeafId,
    required String ownerUserId,
    PostCategoryFieldSchema? schema,
    required bool sideEffectsAlreadyEmitted,
    required void Function(
      PostPublishPhase, {
      List<int>? uploadedPhotoIndexes,
      List<String>? attachedPhotoUrls,
    }) reportPhase,
  }) async {
    final existingBefore = await _housing.getListing(listingId);
    final resumed = existingBefore != null;
    if (resumed) {
      _assertOwner(existingBefore.ownerUserId ?? '', ownerUserId);
    }

    final minPhotos = schema != null
        ? PostPhotoRequirements.minPhotoCount(schema, fieldValues)
        : 0;
    final wasAlreadyComplete = resumed &&
        _photoOutcome(
              requiresPhotos: minPhotos > 0,
              attachedCount: existingBefore.photoUrls.length,
              minRequired: minPhotos,
            ) ==
            PostPublishOutcome.completed;

    reportPhase(PostPublishPhase.creating);
    final mapped = PostSchemaAdapter.toHousingFields(
      fieldValues,
      categoryLeafId: categoryLeafId,
    );
    final request = CreateListingRequest(
      title: mapped['title'] as String,
      area: mapped['area'] as String,
      pricePerMonth: mapped['pricePerMonth'] as int,
      type: mapped['type'] as ListingType,
      furnished: PostSchemaValueCoercion.isFurnished(fieldValues['furnishing']) ||
          fieldValues['furnished'] == true,
      bedrooms:
          PostSchemaValueCoercion.parseGridCount(fieldValues['bedrooms']) ?? 1,
      bathrooms:
          PostSchemaValueCoercion.parseGridCount(fieldValues['bathrooms']) ?? 1,
      photoUrls: const [],
      description: mapped['description'] as String,
      amenities: const [],
      genderPreference: mapped['genderPreference'] as GenderPreference,
      nationalityPreference: NationalityPreference.any,
      whatsapp: fieldValues['whatsapp']?.toString() ?? '',
      phone: fieldValues['phone']?.toString() ?? '',
      contactName: fieldValues['contactName']?.toString() ?? '',
      featured: false,
      isPremiumUser: false,
      zone: mapped['zone'] as String?,
      streetNumber: mapped['streetNumber'] as String?,
      buildingNumber: mapped['buildingNumber'] as String?,
      schemaFields: Map<String, dynamic>.from(
        mapped['schemaFields'] as Map? ?? const {},
      ),
    );

    final listing = resumed
        ? existingBefore
        : await _housing.createListing(request, listingId: listingId);
    reportPhase(PostPublishPhase.created);

    final localPaths = PostMediaEngine.normalizePhotoPaths(fieldValues['photos']);
    final slotCount = PostPhotoRequirements.resolvedPhotoSlotCount(
      vertical: PostVertical.housing,
      schema: schema ??
          const PostCategoryFieldSchema(categoryPath: '', fields: []),
      values: fieldValues,
    );
    final existingUrls = listing.photoUrls;

    reportPhase(PostPublishPhase.uploading);
    final upload = await _media.uploadPhotosForPublish(
      vertical: PostVertical.housing,
      listingId: listing.id,
      localPaths: localPaths,
      ownerUserId: ownerUserId,
      slotCount: slotCount,
      existingAttachedUrls: existingUrls,
      minRequired: minPhotos,
    );

    reportPhase(
      PostPublishPhase.attaching,
      uploadedPhotoIndexes: upload.uploadedIndexes,
    );
    if (upload.photoUrls.isNotEmpty) {
      await _housing.attachPhotos(listing.id, upload.photoUrls);
    }

    reportPhase(
      PostPublishPhase.finalizing,
      attachedPhotoUrls: upload.photoUrls,
    );

    final outcome = _photoOutcome(
      requiresPhotos: minPhotos > 0,
      attachedCount: upload.photoUrls.length,
      minRequired: minPhotos,
    );

    if (outcome == PostPublishOutcome.completed) {
      try {
        await _housingRepository.scanListingScam(
          listingId: listing.id,
          request: CreateListingRequest(
            title: request.title,
            area: request.area,
            pricePerMonth: request.pricePerMonth,
            type: request.type,
            furnished: request.furnished,
            bedrooms: request.bedrooms,
            bathrooms: request.bathrooms,
            photoUrls: upload.photoUrls,
            description: request.description,
            amenities: request.amenities,
            genderPreference: request.genderPreference,
            nationalityPreference: request.nationalityPreference,
            whatsapp: request.whatsapp,
            phone: request.phone,
            contactName: request.contactName,
            featured: request.featured,
            isPremiumUser: request.isPremiumUser,
            zone: request.zone,
            streetNumber: request.streetNumber,
            buildingNumber: request.buildingNumber,
            schemaFields: request.schemaFields,
          ),
        );
      } catch (_) {
        // Best-effort — listing still published (matches legacy PostListingScreen).
      }
      reportPhase(PostPublishPhase.completed, attachedPhotoUrls: upload.photoUrls);
    }

    return PostPublishResult(
      listingId: listing.id,
      publishId: publishId,
      photoUrls: upload.photoUrls,
      outcome: outcome,
      sideEffectsAlreadyEmitted:
          sideEffectsAlreadyEmitted || wasAlreadyComplete,
      resumedExistingListing: resumed,
    );
  }

  Future<PostPublishResult> _publishService({
    required String publishId,
    required String listingId,
    required Map<String, dynamic> fieldValues,
    required String categoryLeafId,
    required String ownerUserId,
    ServiceListingType listingType = ServiceListingType.provider,
    bool posterIdentityVerified = false,
    PostCategoryFieldSchema? schema,
    required bool sideEffectsAlreadyEmitted,
    required void Function(
      PostPublishPhase, {
      List<int>? uploadedPhotoIndexes,
      List<String>? attachedPhotoUrls,
    }) reportPhase,
  }) async {
    final existing = await _services.fetchListing(listingId);
    final resumed = existing != null;
    if (resumed) {
      _assertOwner(existing.userId, ownerUserId);
    }

    final minPhotos = schema != null
        ? PostPhotoRequirements.minPhotoCount(schema, fieldValues)
        : 0;
    final wasAlreadyComplete = resumed &&
        _photoOutcome(
              requiresPhotos: minPhotos > 0,
              attachedCount: existing.imageUrl.isNotEmpty ? 1 : 0,
              minRequired: minPhotos > 0 ? 1 : 0,
            ) ==
            PostPublishOutcome.completed;

    reportPhase(PostPublishPhase.creating);
    final mapped = PostSchemaAdapter.toServiceFields(
      fieldValues,
      categoryId: categoryLeafId,
      serviceName: fieldValues['serviceName']?.toString() ??
          fieldValues['title']?.toString() ??
          'Service',
      userId: ownerUserId,
      listingType: listingType,
    );
    final submission = ServiceListingSubmission(
      userId: mapped['userId'] as String,
      serviceCategoryId: mapped['serviceCategoryId'] as String,
      serviceCategory: mapped['serviceCategory'] as String,
      serviceName: mapped['serviceName'] as String,
      title: mapped['title'] as String,
      description: mapped['description'] as String,
      providerName: mapped['providerName'] as String,
      phone: mapped['phone'] as String,
      area: mapped['area'] as String,
      imageUrl: existing?.imageUrl ?? '',
      listingType: listingType,
      schemaFields: Map<String, dynamic>.from(
        mapped['schemaFields'] as Map? ?? const {},
      ),
      posterIdentityVerified: posterIdentityVerified,
    );

    if (!resumed) {
      await _services.createListing(submission, listingId: listingId);
    }
    reportPhase(PostPublishPhase.created);

    final allPaths = PostMediaEngine.normalizePhotoPaths(fieldValues['photos']);
    final localPaths = allPaths.take(1).toList();
    final slotCount = localPaths.isNotEmpty ? 1 : 0;
    final existingUrls =
        existing != null && existing.imageUrl.isNotEmpty
            ? [existing.imageUrl]
            : const <String>[];

    reportPhase(PostPublishPhase.uploading);
    final upload = await _media.uploadPhotosForPublish(
      vertical: PostVertical.services,
      listingId: listingId,
      localPaths: localPaths,
      ownerUserId: ownerUserId,
      slotCount: slotCount,
      existingAttachedUrls: existingUrls,
      minRequired: minPhotos > 0 ? 1 : 0,
    );

    reportPhase(
      PostPublishPhase.attaching,
      uploadedPhotoIndexes: upload.uploadedIndexes,
    );
    var imageUrl = upload.photoUrls.isNotEmpty ? upload.photoUrls.first : '';
    if (imageUrl.isNotEmpty) {
      await _services.updateListing(
        id: listingId,
        submission: ServiceListingSubmission(
          userId: submission.userId,
          serviceCategoryId: submission.serviceCategoryId,
          serviceCategory: submission.serviceCategory,
          serviceName: submission.serviceName,
          title: submission.title,
          description: submission.description,
          providerName: submission.providerName,
          phone: submission.phone,
          area: submission.area,
          imageUrl: imageUrl,
          listingType: submission.listingType,
          schemaFields: submission.schemaFields,
          posterIdentityVerified: submission.posterIdentityVerified,
        ),
      );
    } else if (existingUrls.isNotEmpty) {
      imageUrl = existingUrls.first;
    }

    reportPhase(
      PostPublishPhase.finalizing,
      attachedPhotoUrls: imageUrl.isEmpty ? const [] : [imageUrl],
    );

    final outcome = _photoOutcome(
      requiresPhotos: minPhotos > 0,
      attachedCount: imageUrl.isEmpty ? 0 : 1,
      minRequired: minPhotos > 0 ? 1 : 0,
    );
    if (outcome == PostPublishOutcome.completed) {
      reportPhase(
        PostPublishPhase.completed,
        attachedPhotoUrls: imageUrl.isEmpty ? const [] : [imageUrl],
      );
    }

    return PostPublishResult(
      listingId: listingId,
      publishId: publishId,
      photoUrls: imageUrl.isEmpty ? const [] : [imageUrl],
      outcome: outcome,
      sideEffectsAlreadyEmitted:
          sideEffectsAlreadyEmitted || wasAlreadyComplete,
      resumedExistingListing: resumed,
    );
  }

  Future<PostPublishResult> _publishBusiness({
    required String publishId,
    required String listingId,
    required Map<String, dynamic> fieldValues,
    required String categoryLeafId,
    required String ownerUserId,
    PostCategoryFieldSchema? schema,
    required bool sideEffectsAlreadyEmitted,
    required void Function(
      PostPublishPhase, {
      List<int>? uploadedPhotoIndexes,
      List<String>? attachedPhotoUrls,
    }) reportPhase,
  }) async {
    final existingDoc = await _businesses.fetchBusinessDoc(listingId);
    final resumed = existingDoc != null;
    if (resumed) {
      _assertOwner(
        existingDoc['ownerUserId']?.toString() ?? '',
        ownerUserId,
      );
    }

    final minPhotos = schema != null
        ? PostPhotoRequirements.minPhotoCount(schema, fieldValues)
        : 0;
    final existingUrls = existingDoc?['photoUrls'] is List
        ? (existingDoc!['photoUrls'] as List).map((e) => e.toString()).toList()
        : const <String>[];
    final wasAlreadyComplete = resumed &&
        _photoOutcome(
              requiresPhotos: minPhotos > 0,
              attachedCount: existingUrls.length,
              minRequired: minPhotos,
            ) ==
            PostPublishOutcome.completed;

    reportPhase(PostPublishPhase.creating);
    final mapped = PostSchemaAdapter.toBusinessFields(
      fieldValues,
      categoryLeafId: categoryLeafId,
    );
    if (!resumed) {
      await _businesses.createBusiness(
        name: mapped['name'] as String,
        category: mapped['category'] as String,
        categoryId: mapped['categoryId'] as String?,
        location: mapped['location'] as String,
        phone: mapped['phone'] as String,
        whatsapp: mapped['whatsapp'] as String?,
        description: mapped['description'] as String?,
        languages: (mapped['languages'] as List<String>?) ?? const [],
        tags: (mapped['tags'] as List<String>?) ?? const [],
        website: mapped['website'] as String?,
        openingHours: mapped['openingHours'],
        socialLinks: mapped['socialLinks'] as Map<String, dynamic>?,
        servicesOffered: mapped['servicesOffered'] as List<dynamic>?,
        profileFields: mapped['profileFields'] as Map<String, dynamic>?,
        contactMode: BusinessContactModeX.fromStorage(
          mapped['contactMode'] as String?,
        ),
        businessId: listingId,
      );
    }
    reportPhase(PostPublishPhase.created);

    final localPaths = PostMediaEngine.normalizePhotoPaths(fieldValues['photos']);
    final slotCount = PostPhotoRequirements.resolvedPhotoSlotCount(
      vertical: PostVertical.business,
      schema: schema ??
          const PostCategoryFieldSchema(categoryPath: '', fields: []),
      values: fieldValues,
    );

    reportPhase(PostPublishPhase.uploading);
    final logoUrl = await _uploadBusinessSinglePhoto(
      fieldValues['logo'],
      listingId: listingId,
      ownerUserId: ownerUserId,
      photoIndex: 1000,
    );
    final coverUrl = await _uploadBusinessSinglePhoto(
      fieldValues['cover_photo'],
      listingId: listingId,
      ownerUserId: ownerUserId,
      photoIndex: 1001,
    );
    final upload = await _media.uploadPhotosForPublish(
      vertical: PostVertical.business,
      listingId: listingId,
      localPaths: localPaths,
      ownerUserId: ownerUserId,
      slotCount: slotCount,
      existingAttachedUrls: existingUrls,
      minRequired: minPhotos,
    );

    reportPhase(
      PostPublishPhase.attaching,
      uploadedPhotoIndexes: upload.uploadedIndexes,
    );
    if (upload.photoUrls.isNotEmpty ||
        logoUrl != null ||
        coverUrl != null) {
      await _businesses.attachBusinessMedia(
        businessId: listingId,
        galleryUrls: upload.photoUrls.isEmpty ? null : upload.photoUrls,
        logoUrl: logoUrl,
        coverUrl: coverUrl,
      );
    }

    reportPhase(
      PostPublishPhase.finalizing,
      attachedPhotoUrls: upload.photoUrls,
    );
    final outcome = _photoOutcome(
      requiresPhotos: minPhotos > 0,
      attachedCount: upload.photoUrls.length,
      minRequired: minPhotos,
    );
    if (outcome == PostPublishOutcome.completed) {
      reportPhase(PostPublishPhase.completed, attachedPhotoUrls: upload.photoUrls);
    }

    return PostPublishResult(
      listingId: listingId,
      publishId: publishId,
      photoUrls: upload.photoUrls,
      outcome: outcome,
      sideEffectsAlreadyEmitted:
          sideEffectsAlreadyEmitted || wasAlreadyComplete,
      resumedExistingListing: resumed,
    );
  }

  Future<PostPublishResult> _publishJob({
    required String publishId,
    required String listingId,
    required Map<String, dynamic> fieldValues,
    required String categoryLeafId,
    required String ownerUserId,
    required JobRequirementsSpec requirements,
    required List<String> benefits,
    required String type,
    String? linkedBusinessId,
    required bool sideEffectsAlreadyEmitted,
    required void Function(
      PostPublishPhase, {
      List<int>? uploadedPhotoIndexes,
      List<String>? attachedPhotoUrls,
    }) reportPhase,
  }) async {
    if (!requirements.isSpecified) {
      throw StateError('Job requirements must be specified before publishing');
    }

    final existing = await _jobs.fetchJob(listingId);
    final resumed = existing != null;
    if (resumed) {
      _assertOwner(existing.postedBy ?? '', ownerUserId);
    }
    final wasAlreadyComplete = resumed;

    reportPhase(PostPublishPhase.creating);
    if (!resumed) {
      final mapped = PostSchemaAdapter.toJobFields(
        fieldValues,
        category: categoryLeafId,
        requirements: requirements,
        benefits: benefits,
        type: type,
      );
      await _jobs.createJob(
        title: mapped['title'] as String,
        company: mapped['company'] as String,
        salary: mapped['salary'] as String,
        location: mapped['location'] as String,
        description: mapped['description'] as String,
        contact: mapped['contact'] as String,
        category: mapped['category'] as String,
        benefits: mapped['benefits'] as List<String>,
        requirements: mapped['requirements'] as JobRequirementsSpec,
        email: mapped['email'] as String?,
        type: mapped['type'] as String,
        jobId: listingId,
        businessId: linkedBusinessId,
      );
    }

    reportPhase(PostPublishPhase.created);
    reportPhase(PostPublishPhase.finalizing);
    reportPhase(PostPublishPhase.completed);

    return PostPublishResult(
      listingId: listingId,
      publishId: publishId,
      outcome: PostPublishOutcome.completed,
      sideEffectsAlreadyEmitted:
          sideEffectsAlreadyEmitted || wasAlreadyComplete,
      resumedExistingListing: resumed,
    );
  }

  Future<String?> _uploadBusinessSinglePhoto(
    dynamic fieldValue, {
    required String listingId,
    required String ownerUserId,
    required int photoIndex,
  }) async {
    final paths = PostMediaEngine.normalizePhotoPaths(fieldValue);
    if (paths.isEmpty) return null;
    final path = paths.first;
    if (path.startsWith('http')) return path;
    final file = File(path);
    if (!file.existsSync()) return null;
    return _media.uploadPhotos(
      vertical: PostVertical.business,
      listingId: listingId,
      localPaths: [path],
      ownerUserId: ownerUserId,
    ).then((urls) => urls.isEmpty ? null : urls.first);
  }

  PostPublishOutcome _photoOutcome({
    required bool requiresPhotos,
    required int attachedCount,
    required int minRequired,
  }) {
    if (!requiresPhotos) {
      return PostPublishOutcome.completed;
    }
    if (attachedCount >= minRequired && attachedCount > 0) {
      return PostPublishOutcome.completed;
    }
    return PostPublishOutcome.listingCreatedMediaIncomplete;
  }

  void _assertOwner(String listingOwner, String ownerUserId) {
    if (listingOwner.isEmpty || listingOwner != ownerUserId) {
      throw PostPublishOwnershipException(
        'Listing belongs to another user and cannot be resumed',
      );
    }
  }

  Future<void> _persistTradeComplianceAck(
    PostVertical vertical,
    String listingId,
  ) async {
    final patch = PostTradeComplianceAck.fields();
    final db = FirebaseFirestore.instance;
    final collection = switch (vertical) {
      PostVertical.marketplace => 'marketplace_listings',
      PostVertical.housing => 'listings',
      PostVertical.services => 'service_listings',
      PostVertical.business => 'businesses',
      PostVertical.jobs => 'jobs',
    };
    await db.collection(collection).doc(listingId).set(
          patch,
          SetOptions(merge: true),
        );
  }
}
