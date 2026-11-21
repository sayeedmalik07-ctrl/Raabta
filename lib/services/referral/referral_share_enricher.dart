import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/services/referral/referral_analytics_service.dart';
import 'package:raabta/services/referral/referral_deep_links.dart';
import 'package:raabta/services/referral/referral_service.dart';
import 'package:raabta/services/sharing/models/shareable_card_data.dart';

/// Invisibly attaches referral links to EOSB/Overtime share payloads.
abstract final class ReferralShareEnricher {
  static bool isReferralEligible(ShareableCardType type) =>
      type == ShareableCardType.eosbSettlement ||
      type == ShareableCardType.overtimeTruth;

  static Future<ShareableCardData> enrich(ShareableCardData data) async {
    if (!isReferralEligible(data.type)) return data;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return data;

    final code = await ReferralService.instance.ensureReferralCode(uid);
    if (code == null) return data;

    final link = ReferralDeepLinks.invite(code);
    final caption = '${data.shareCaption}\n$link';

    await ReferralAnalyticsService.referralLinkShared(
      referralCode: code,
      shareType: data.type.name,
    );

    return _copyWithReferral(data, referralLinkUrl: link, shareCaption: caption);
  }

  static ShareableCardData _copyWithReferral(
    ShareableCardData data, {
    required String referralLinkUrl,
    required String shareCaption,
  }) {
    switch (data.type) {
      case ShareableCardType.eosbSettlement:
        final d = data as EosbSettlementCardData;
        return EosbSettlementCardData(
          estimatedEosb: d.estimatedEosb,
          confidenceScore: d.confidenceScore,
          employerOffer: d.employerOffer,
          difference: d.difference,
          isUnderpaid: d.isUnderpaid,
          calculatedAt: d.calculatedAt,
          shareCaption: shareCaption,
          referralLinkUrl: referralLinkUrl,
        );
      case ShareableCardType.overtimeTruth:
        final d = data as OvertimeTruthCardData;
        return OvertimeTruthCardData(
          monthLabel: d.monthLabel,
          companyName: d.companyName,
          totalHours: d.totalHours,
          estimatedAmount: d.estimatedAmount,
          employerPaid: d.employerPaid,
          difference: d.difference,
          currency: d.currency,
          shareCaption: shareCaption,
          referralLinkUrl: referralLinkUrl,
        );
      default:
        return data;
    }
  }
}
