enum ContractScamPatternDomain {
  employment,
  housing,
  any,
}

enum ContractScamPatternNextStep {
  paymentCheck,
  inCallAssistant,
  officialDirectory,
  beforeYouSign,
  contractAnalyzer,
}

class ContractScamPatternFinding {
  const ContractScamPatternFinding({
    required this.groupId,
    required this.categoryKey,
    required this.wordingKey,
    required this.sourceLabelKey,
    required this.nextStep,
    required this.priority,
    this.sourceDateIso,
    this.params = const {},
  });

  final String groupId;
  final String categoryKey;
  final String wordingKey;
  final String sourceLabelKey;
  final ContractScamPatternNextStep nextStep;
  final int priority;
  final String? sourceDateIso;
  final Map<String, String> params;
}

class ContractScamPatternResult {
  const ContractScamPatternResult({
    required this.findings,
    required this.scannedCharacterCount,
  });

  static const empty = ContractScamPatternResult(
    findings: [],
    scannedCharacterCount: 0,
  );

  final List<ContractScamPatternFinding> findings;
  final int scannedCharacterCount;

  bool get hasFindings => findings.isNotEmpty;
}
