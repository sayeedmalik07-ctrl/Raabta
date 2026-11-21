import 'package:scam_shield_core/features/scam_shield/domain/evidence/event_ticket_detector.dart';
import 'package:scam_shield_core/features/scam_shield/domain/evidence/event_ticket_source.dart';
import 'package:scam_shield_core/features/scam_shield/domain/evidence/scam_evidence_models.dart';

abstract final class EventTicketEvidenceGenerator {
  static const priority = 640;

  static List<ScamEvidence> generate(String text) {
    if (!EventTicketSourceCatalog.notice.verified) return const [];
    if (!EventTicketDetector.detect(text)) return const [];

    final n = EventTicketSourceCatalog.notice;
    return [
      ScamEvidence(
        kind: ScamEvidenceKind.eventTicketScam,
        priority: priority,
        textKey: 'ss_evidence_event_ticket_scam',
        sourceLabel: n.sourceLabel,
        sourceUrl: n.sourceUrl,
        sourceDate: DateTime.tryParse(n.noticeDateIso),
        direction: ScamEvidenceDirection.concern,
      ),
    ];
  }
}
