import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:raabta/core/router/app_router.dart';
import 'package:raabta/features/quick_actions/bill_tracker/domain/bill_share_text_heuristics.dart';
import 'package:raabta/features/quick_actions/bill_tracker/domain/bill_tracker_share_payload.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_share_media_parser.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_share_payload.dart';
import 'package:raabta/features/scam_shield/services/scam_shield_share_image_cleanup.dart';
import 'package:share_handler/share_handler.dart';

/// Listens for OS share intents and routes to the share review screen.
class ScamShieldShareHandler {
  ScamShieldShareHandler._();

  static final instance = ScamShieldShareHandler._();

  StreamSubscription<SharedMedia>? _sub;
  bool _handling = false;

  Future<void> initialize() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    try {
      unawaited(ScamShieldShareImageCleanup.purgeStaleOwnedFiles());

      final handler = ShareHandlerPlatform.instance;
      final initial = await handler.getInitialSharedMedia();
      if (initial != null) {
        await _handleMedia(initial);
      }

      await _sub?.cancel();
      _sub = handler.sharedMediaStream.listen(
        (media) => unawaited(_handleMedia(media)),
        onError: (e) => debugPrint('ScamShieldShareHandler stream: $e'),
      );
    } catch (e) {
      debugPrint('ScamShieldShareHandler initialize: $e');
    }
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }

  Future<void> _handleMedia(SharedMedia media) async {
    if (_handling) return;
    _handling = true;
    try {
      final payload = await buildPayloadFromMedia(media);
      if (payload.isEmpty) return;

      final text = payload.sharedText?.trim();
      if (text != null &&
          text.isNotEmpty &&
          !payload.hasImage &&
          !payload.unsupportedOnly &&
          BillShareTextHeuristics.looksLikeQatarUtilityBillSms(text)) {
        BillTrackerSharePayloadStore.setText(text);
        appRouter.go('/bill-tracker/import/text');
        return;
      }

      ScamShieldSharePayloadStore.set(payload);
      appRouter.go('/scam-shield/share-review');
    } finally {
      _handling = false;
    }
  }

  /// Builds a review payload from [SharedMedia] (adopts up to three images).
  @visibleForTesting
  static Future<ScamShieldSharePayload> buildPayloadFromMedia(
    SharedMedia media,
  ) async {
    final plan = ScamShieldShareMediaParser.parse(
      rawContent: media.content,
      attachments: media.attachments,
    );

    if (!plan.isRoutable) {
      return const ScamShieldSharePayload();
    }

    final adoptedPaths = <String>[];
    for (final source in plan.imageSourcePaths) {
      final adopted = await ScamShieldShareImageCleanup.adoptShareImage(source);
      if (adopted != null) {
        adoptedPaths.add(adopted);
      }
    }

    return ScamShieldSharePayload(
      sharedText: plan.sharedText,
      imagePaths: adoptedPaths,
      textWasTruncated: plan.textWasTruncated,
      droppedExtraImageCount: plan.droppedExtraImageCount,
      unsupportedAttachmentCount: plan.unsupportedAttachmentCount,
      unsupportedOnly: plan.unsupportedOnly,
    );
  }
}
