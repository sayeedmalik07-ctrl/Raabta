import 'dart:async';

import 'package:raabta/data/models/job_requirements.dart';
import 'package:raabta/features/post_engine/domain/models/post_publish_models.dart';
import 'package:raabta/features/post_engine/domain/models/post_schema_models.dart';
import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';
import 'package:raabta/features/post_engine/domain/post_draft_manager.dart';
import 'package:raabta/features/post_engine/domain/post_draft_publish_state.dart';
import 'package:raabta/features/post_engine/domain/post_publish_engine.dart';
import 'package:raabta/screens/services/models/service_listing.dart';

/// Orchestrates publish with draft-resume state and reliable draft clearing.
class PostPublishCoordinator {
  PostPublishCoordinator({
    required this.draftManager,
    required this.engine,
  });

  final PostDraftManager draftManager;
  final PostPublishEngine engine;

  Future<PostPublishResult> publish({
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
  }) async {
    final stored = await draftManager.loadRestorableDraft();
    final storedData = stored?.data ?? const <String, dynamic>{};

    final publishId = PostDraftPublishState.publishId(storedData) ??
        PostDraftPublishState.publishId(fieldValues) ??
        PostDraftPublishState.generatePublishId();
    final sideEffectsEmitted =
        PostDraftPublishState.sideEffectsEmitted(storedData);

    Future<void> persistDraft({
      PostPublishPhase? phase,
      String? listingId,
      List<int>? uploadedPhotoIndexes,
      List<String>? attachedPhotoUrls,
      bool? markSideEffectsEmitted,
    }) async {
      final payload = PostDraftPublishState.apply(
        draft: {...storedData, ...fieldValues},
        publishId: publishId,
        listingId: listingId ?? publishId,
        publishPhase: phase,
        uploadedPhotoIndexes: uploadedPhotoIndexes,
        attachedPhotoUrls: attachedPhotoUrls,
        sideEffectsEmitted: markSideEffectsEmitted,
      );
      await draftManager.savePublishState(payload);
    }

    await persistDraft(phase: PostPublishPhase.creating, listingId: publishId);

    try {
      final result = await engine.publish(
        publishId: publishId,
        vertical: vertical,
        categoryPath: categoryPath,
        fieldValues: fieldValues,
        ownerUserId: ownerUserId,
        schema: schema,
        serviceListingType: serviceListingType,
        posterIdentityVerified: posterIdentityVerified,
        sellerFlag: sellerFlag,
        jobRequirements: jobRequirements,
        jobBenefits: jobBenefits,
        jobType: jobType,
        tradeComplianceAcknowledged: tradeComplianceAcknowledged,
        linkedBusinessId: linkedBusinessId,
        sideEffectsAlreadyEmitted: sideEffectsEmitted,
        onPhaseUpdate: ({
          required phase,
          listingId,
          uploadedPhotoIndexes,
          attachedPhotoUrls,
        }) {
          unawaited(
            persistDraft(
              phase: phase,
              listingId: listingId,
              uploadedPhotoIndexes: uploadedPhotoIndexes,
              attachedPhotoUrls: attachedPhotoUrls,
            ),
          );
        },
      );

      if (result.isSuccess) {
        await draftManager.clearDraft();
        return PostPublishResult(
          listingId: result.listingId,
          publishId: result.publishId,
          photoUrls: result.photoUrls,
          outcome: result.outcome,
          sideEffectsAlreadyEmitted: sideEffectsEmitted,
          resumedExistingListing: result.resumedExistingListing,
        );
      }

      await persistDraft(
        phase: result.isPartialMedia
            ? PostPublishPhase.uploading
            : PostPublishPhase.created,
        listingId: result.listingId,
        attachedPhotoUrls: result.photoUrls,
      );

      return result;
    } on PostPublishOwnershipException {
      rethrow;
    } on PostPublishMediaException catch (_) {
      await persistDraft(
        phase: PostPublishPhase.uploading,
        listingId: publishId,
      );
      rethrow;
    }
  }
}
