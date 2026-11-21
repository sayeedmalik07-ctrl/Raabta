/// Regulator routing for claim denial escalation (QCB vs QFCRA).
enum InsurerRegulatoryBody {
  qcb,
  qfcra,
}

extension InsurerRegulatoryBodyX on InsurerRegulatoryBody {
  String get storageValue => name;

  static InsurerRegulatoryBody fromStorage(String? raw) {
    return raw == 'qfcra' ? InsurerRegulatoryBody.qfcra : InsurerRegulatoryBody.qcb;
  }
}
