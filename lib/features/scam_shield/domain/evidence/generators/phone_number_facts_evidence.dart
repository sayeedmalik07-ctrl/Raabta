import 'package:raabta/features/scam_shield/check_number/number_facts.dart';
import 'package:raabta/features/scam_shield/check_number/number_facts_parser.dart';
import 'package:raabta/features/scam_shield/check_number/number_guidance_resolver.dart';
import 'package:raabta/features/scam_shield/data/scam_authority_directory_config.dart';
import 'package:raabta/features/scam_shield/domain/evidence/scam_evidence_models.dart';
import 'package:raabta/features/scam_shield/domain/payment_candidate_extractor.dart';
import 'package:raabta/features/scam_shield/domain/scam_message_sender_type.dart';

abstract final class PhoneNumberFactsEvidenceGenerator {
  static const priority = 620;

  static Future<List<ScamEvidence>> generateAsync({
    required String text,
    required ScamMessageSenderType senderType,
  }) async {
    final phones = PaymentCandidateExtractor.extract(text).phones;
    if (phones.isEmpty) return const [];

    final facts = await NumberFactsParser.parse(phones.first);
    final claimed = ScamAuthorityDirectoryConfig.findClaimedInText(text);
    final channel = _channelFromSender(senderType);
    final cards = await NumberGuidanceResolver.resolve(
      NumberGuidanceInput(
        facts: facts,
        channel: channel,
        claimedAuthorityId: claimed.isNotEmpty ? claimed.first.id : null,
      ),
    );

    if (!cards.any((c) => c.id == 'cra_voip_no_whatsapp')) {
      return const [];
    }

    return [
      ScamEvidence(
        kind: ScamEvidenceKind.phoneNumberConcern,
        priority: priority,
        textKey: 'ss_cn_guidance_cra_voip',
        sourceLabel: cards
            .firstWhere((c) => c.id == 'cra_voip_no_whatsapp')
            .sourceLabel,
        sourceUrl: cards
            .firstWhere((c) => c.id == 'cra_voip_no_whatsapp')
            .sourceUrl,
      ),
    ];
  }

  static CheckNumberReachChannel? _channelFromSender(ScamMessageSenderType t) {
    return switch (t) {
      ScamMessageSenderType.whatsAppTelegramSocial =>
        CheckNumberReachChannel.whatsAppOrVoip,
      ScamMessageSenderType.senderNameOrShortCode =>
        CheckNumberReachChannel.sms,
      ScamMessageSenderType.localMobile => CheckNumberReachChannel.phoneCall,
      ScamMessageSenderType.internationalNumber =>
        CheckNumberReachChannel.phoneCall,
      ScamMessageSenderType.email => CheckNumberReachChannel.otherApp,
      ScamMessageSenderType.notSure => null,
    };
  }
}
