import 'package:scam_shield_core/features/scam_shield/domain/scam_multilingual_matcher.dart';

/// Event-ticket resale / social-channel offer patterns (Phase 35).
abstract final class EventTicketDetector {
  static const _ticketOfferGroups = [
    ['tickets available', 'last minute tickets', 'vip tickets', 'sold out but i have'],
    ['concert tickets', 'match tickets', 'event tickets', 'final tickets'],
    ['تذاكر', 'تذكرة', 'آخر تذاكر'],
  ];

  static const _paymentGroups = [
    ['bank transfer', 'transfer to my account', 'personal account', 'iban'],
    ['pay quickly', 'pay today', 'within hours', 'hurry'],
    ['حوالة', 'تحويل بنكي', 'حساب شخصي'],
  ];

  static const _deliveryGroups = [
    ['screenshot', 'pdf ticket', 'whatsapp ticket', 'send via whatsapp'],
    ['instagram', 'telegram ticket', 'social media'],
  ];

  static const _affiliationGroups = [
    ['official seller', 'organiser contact', 'organizer contact', 'affiliated with'],
    ['from the stadium', 'inside connection'],
  ];

  static const _negativeOfficialSale = [
    'official ticket portal',
    'buy only through our website',
    'qatar calendar official',
    'official link below',
    'portal.qatar2022',
  ];

  static bool detect(String text) {
    final lower = text.toLowerCase();
    if (_negativeOfficialSale.any(
      (p) => ScamMultilingualMatcher.containsPattern(lower, p),
    )) {
      return false;
    }

    var hits = 0;
    for (final group in [
      _ticketOfferGroups,
      _paymentGroups,
      _deliveryGroups,
      _affiliationGroups,
    ]) {
      if (_groupHit(lower, group)) hits++;
    }
    if (hits >= 2) return true;

    final ticketHit = _groupHit(lower, _ticketOfferGroups);
    final payHit = _groupHit(lower, _paymentGroups);
    final socialHit = _groupHit(lower, _deliveryGroups);
    return ticketHit && (payHit || socialHit);
  }

  static bool _groupHit(String lower, List<List<String>> groups) {
    for (final patterns in groups) {
      if (patterns.any((p) => ScamMultilingualMatcher.containsPattern(lower, p))) {
        return true;
      }
    }
    return false;
  }
}
