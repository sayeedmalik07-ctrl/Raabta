/// Lightweight detection for Qatar utility bill SMS / shared text (no SMS API).
abstract final class BillShareTextHeuristics {
  static const _providerTokens = [
    'kahramaa',
    'ooredoo',
    'vodafone',
    'qatar cool',
    'qatarcool',
    'marafeq',
    'bein',
    'km.qa',
    'ooredoo.qa',
    'vodafone.qa',
  ];

  static const _billSignals = [
    'bill',
    'amount due',
    'due date',
    'payment due',
    'account',
    'qar',
    'qr ',
    'riyal',
    'فاتورة',
    'مبلغ',
    'استحقاق',
    'kahramaa',
  ];

  /// True when shared/pasted text likely describes a Qatar utility bill alert.
  static bool looksLikeQatarUtilityBillSms(String raw) {
    final text = raw.trim().toLowerCase();
    if (text.length < 20) return false;

    final hasProvider = _providerTokens.any(text.contains);
    final hasBillSignal = _billSignals.any(text.contains);
    final hasAmount = RegExp(r'qar\s*[\d,.]+|[\d,.]+\s*qar|\bqr\s*[\d,.]+')
        .hasMatch(text);

    return hasProvider && (hasBillSignal || hasAmount);
  }
}
