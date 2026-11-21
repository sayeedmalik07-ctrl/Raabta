import 'dart:async';

import 'package:raabta/features/scam_shield/anonymous_signal/scam_anonymous_signal_event_builder.dart';
import 'package:raabta/features/scam_shield/anonymous_signal/scam_anonymous_signal_prefs.dart';
import 'package:raabta/features/scam_shield/anonymous_signal/scam_anonymous_signal_schema.dart';
import 'package:raabta/features/scam_shield/anonymous_signal/scam_anonymous_signal_uploader.dart';
import 'package:raabta/features/scam_shield/domain/scam_message_sender_type.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';

/// Queues counter-only events locally; uploads at most once per UTC day.
abstract final class ScamAnonymousSignalCoordinator {
  static Future<void> onAssessmentResultShown({
    required ScamShieldAssessmentResult result,
    required String sourceTextForLocalClassification,
    required List<String> evidenceKindNames,
    required String locale,
    required ScamMessageSenderType senderType,
  }) async {
    if (!await ScamAnonymousSignalPrefs.isOptedIn()) return;

    final event = ScamAnonymousSignalEventBuilder.fromAssessment(
      result: result,
      sourceTextForLocalClassification: sourceTextForLocalClassification,
      evidenceKindNames: evidenceKindNames,
      locale: locale,
      senderType: senderType,
    );

    await _enqueue(event.toJson());
    unawaited(flushIfDue());
  }

  static Future<void> markLegitFalseAlarmForLatestQueued({
    required ScamShieldAssessmentResult result,
    required String sourceTextForLocalClassification,
    required List<String> evidenceKindNames,
    required String locale,
    required ScamMessageSenderType senderType,
  }) async {
    if (!await ScamAnonymousSignalPrefs.isOptedIn()) return;

    final event = ScamAnonymousSignalEventBuilder.fromAssessment(
      result: result,
      sourceTextForLocalClassification: sourceTextForLocalClassification,
      evidenceKindNames: evidenceKindNames,
      locale: locale,
      senderType: senderType,
      feedback: ScamAnonymousSignalFeedback.legitFalseAlarm,
    );

    final queue = await ScamAnonymousSignalPrefs.readQueue();
    if (queue.isNotEmpty) {
      queue.removeLast();
    }
    queue.add(event.toJson());
    await ScamAnonymousSignalPrefs.writeQueue(queue);
    unawaited(flushIfDue());
  }

  static Future<void> flushIfDue() async {
    if (!await ScamAnonymousSignalPrefs.isOptedIn()) return;

    final day = ScamAnonymousSignalEventBuilder.utcDayKey(DateTime.now());
    final lastFlush = await ScamAnonymousSignalPrefs.lastFlushDayUtc();
    if (lastFlush == day) return;

    final queue = await ScamAnonymousSignalPrefs.readQueue();
    if (queue.isEmpty) return;

    final sentToday = await ScamAnonymousSignalPrefs.sentCountToday(day);
    if (sentToday >= ScamAnonymousSignalSchema.maxEventsPerInstallPerDay) {
      return;
    }

    final remaining =
        ScamAnonymousSignalSchema.maxEventsPerInstallPerDay - sentToday;
    final batchRaw = queue.take(remaining).toList();
    if (batchRaw.isEmpty) return;

    final attempt = await ScamAnonymousSignalPrefs.backoffAttempt();
    if (attempt > 0) {
      final delaySeconds = 1 << attempt.clamp(0, 6);
      await Future<void>.delayed(Duration(seconds: delaySeconds));
    }

    final installKey = await ScamAnonymousSignalPrefs.installKey();
    if (installKey == null) return;

    final events = batchRaw.map(_eventFromMap).whereType<ScamAnonymousSignalEvent>().toList();
    if (events.isEmpty) return;

    final upload = await ScamAnonymousSignalUploader.uploadBatch(
      installKey: installKey,
      events: events,
    );

    if (upload.ok) {
      await ScamAnonymousSignalPrefs.setBackoffAttempt(0);
      await ScamAnonymousSignalPrefs.addSentCountToday(day, events.length);
      await ScamAnonymousSignalPrefs.markFlushedToday(day);
      final rest = queue.skip(batchRaw.length).toList();
      await ScamAnonymousSignalPrefs.writeQueue(rest);
      return;
    }

    await ScamAnonymousSignalPrefs.setBackoffAttempt(attempt + 1);
  }

  static Future<void> _enqueue(Map<String, dynamic> json) async {
    final day = ScamAnonymousSignalEventBuilder.utcDayKey(DateTime.now());
    final sentToday = await ScamAnonymousSignalPrefs.sentCountToday(day);
    if (sentToday >= ScamAnonymousSignalSchema.maxEventsPerInstallPerDay) {
      return;
    }
    final queue = await ScamAnonymousSignalPrefs.readQueue();
    queue.add(json);
    await ScamAnonymousSignalPrefs.writeQueue(queue);
  }

  static ScamAnonymousSignalEvent? _eventFromMap(Map<String, dynamic> map) {
    try {
      return ScamAnonymousSignalEvent(
        dayUtc: map['day'] as String,
        channel: ScamAnonymousSignalChannel.values.byName(
          (map['channel'] as String) == 'classifieds_chat'
              ? 'classifiedsChat'
              : map['channel'] as String,
        ),
        archetypes: (map['archetypes'] as List<dynamic>).map((e) => e.toString()).toList(),
        evidenceKinds:
            (map['evidenceKinds'] as List<dynamic>).map((e) => e.toString()).toList(),
        riskBand: ScamAnonymousSignalRiskBand.values.byName(map['riskBand'] as String),
        claimedEntityCategory: ScamAnonymousSignalClaimedCategory.values.byName(
          map['claimedEntityCategory'] as String,
        ),
        uiLocale: map['uiLocale'] as String,
        feedback: (map['feedback'] as String) == 'legit_false_alarm'
            ? ScamAnonymousSignalFeedback.legitFalseAlarm
            : ScamAnonymousSignalFeedback.values.byName(map['feedback'] as String),
      );
    } catch (_) {
      return null;
    }
  }
}
