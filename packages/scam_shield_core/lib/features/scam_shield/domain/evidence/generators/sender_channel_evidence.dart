import 'package:scam_shield_core/features/scam_shield/domain/evidence/scam_channel_static_rules.dart';
import 'package:scam_shield_core/features/scam_shield/domain/evidence/scam_evidence_models.dart';
import 'package:scam_shield_core/features/scam_shield/domain/official_directory.dart';
import 'package:scam_shield_core/features/scam_shield/domain/official_directory_models.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_message_sender_type.dart';

abstract final class SenderChannelEvidenceGenerator {
  static const priority = 800;

  static bool producesMismatchFlag({
    required String text,
    required String locale,
    required ScamMessageSenderType senderType,
    required List<String> localFlags,
  }) {
    return generate(
      text: text,
      locale: locale,
      senderType: senderType,
      localFlags: localFlags,
    ).any((e) => e.kind == ScamEvidenceKind.senderChannelMismatch);
  }

  static List<ScamEvidence> generate({
    required String text,
    required String locale,
    required ScamMessageSenderType senderType,
    List<String> localFlags = const [],
  }) {
    if (!senderType.isActionable) return const [];
    final claim = OfficialDirectory.detectClaimedEntity(text, locale);
    final entityId = claim.primaryId;
    if (entityId == null) return const [];

    final entry = OfficialDirectory.lookupById(entityId);
    final out = <ScamEvidence>[];

    if (entry != null &&
        (entry.officialSenders.isNotEmpty ||
            entry.contactChannelNote.isNotEmpty)) {
      if (_mismatchWithDirectory(senderType, entry)) {
        out.add(
          ScamEvidence(
            kind: ScamEvidenceKind.senderChannelMismatch,
            priority: priority,
            textKey: 'ss_evidence_sender_directory_mismatch',
            params: {'entity': entry.displayName(locale)},
            sourceLabel: entry.channelSourceUrl.isNotEmpty
                ? entry.channelSourceUrl
                : 'Official directory',
            sourceDate: entry.lastVerified,
            sourceUrl: entry.channelSourceUrl.isNotEmpty
                ? entry.channelSourceUrl
                : null,
            entityId: entry.id,
          ),
        );
      }
      return out;
    }

    if (_isGovLike(entry) &&
        senderType == ScamMessageSenderType.whatsAppTelegramSocial) {
      out.add(
        const ScamEvidence(
          kind: ScamEvidenceKind.senderChannelMismatch,
          priority: priority,
          textKey: ScamChannelStaticRules.govWhatsAppRuleKey,
          sourceLabel: ScamChannelStaticRules.otpPinSourceLabel,
          sourceUrl: ScamChannelStaticRules.otpPinSourceUrl,
        ),
      );
    }

    if (localFlags.contains('ss_flag_otp') && senderType.isActionable) {
      out.add(
        const ScamEvidence(
          kind: ScamEvidenceKind.senderChannelMismatch,
          priority: priority - 1,
          textKey: ScamChannelStaticRules.otpPinRuleKey,
          sourceLabel: ScamChannelStaticRules.otpPinSourceLabel,
          sourceUrl: ScamChannelStaticRules.otpPinSourceUrl,
        ),
      );
    }

    return out;
  }

  static bool _mismatchWithDirectory(
    ScamMessageSenderType senderType,
    OfficialDirectoryEntry entry,
  ) {
    if (entry.officialSenders.isEmpty && entry.contactChannelNote.isEmpty) {
      return false;
    }
    return senderType == ScamMessageSenderType.whatsAppTelegramSocial ||
        senderType == ScamMessageSenderType.localMobile ||
        senderType == ScamMessageSenderType.internationalNumber;
  }

  static bool _isGovLike(OfficialDirectoryEntry? entry) {
    if (entry == null) return false;
    return entry.category == OfficialDirectoryCategory.government;
  }
}
