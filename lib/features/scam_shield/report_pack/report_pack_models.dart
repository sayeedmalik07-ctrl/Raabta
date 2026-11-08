class ReportPackTransactionLine {
  const ReportPackTransactionLine({
    this.amount = '',
    this.currency = 'QAR',
    this.date = '',
    this.method = '',
    this.reference = '',
  });

  final String amount;
  final String currency;
  final String date;
  final String method;
  final String reference;

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'currency': currency,
        'date': date,
        'method': method,
        'reference': reference,
      };

  factory ReportPackTransactionLine.fromJson(Map<String, dynamic> json) {
    return ReportPackTransactionLine(
      amount: json['amount']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'QAR',
      date: json['date']?.toString() ?? '',
      method: json['method']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
    );
  }

  bool get isEmpty =>
      amount.isEmpty &&
      date.isEmpty &&
      method.isEmpty &&
      reference.isEmpty;
}

class ReportPackOtherPartyDetail {
  const ReportPackOtherPartyDetail({
    required this.kind,
    required this.value,
  });

  final String kind;
  final String value;

  Map<String, dynamic> toJson() => {'kind': kind, 'value': value};

  factory ReportPackOtherPartyDetail.fromJson(Map<String, dynamic> json) {
    return ReportPackOtherPartyDetail(
      kind: json['kind']?.toString() ?? 'other',
      value: json['value']?.toString() ?? '',
    );
  }
}

class ReportPackTimelineEntry {
  const ReportPackTimelineEntry({
    required this.labelKey,
    this.userDate = '',
  });

  final String labelKey;
  final String userDate;

  Map<String, dynamic> toJson() => {
        'labelKey': labelKey,
        'userDate': userDate,
      };

  factory ReportPackTimelineEntry.fromJson(Map<String, dynamic> json) {
    return ReportPackTimelineEntry(
      labelKey: json['labelKey']?.toString() ?? '',
      userDate: json['userDate']?.toString() ?? '',
    );
  }
}

class ReportPackDraft {
  const ReportPackDraft({
    this.userSummary = '',
    this.otherPartyDetails = const [],
    this.transactions = const [],
    this.timeline = const [],
    this.selectedEvidenceIds = const [],
    this.stepsTakenKeys = const {},
    this.includeContactDetails = false,
    this.contactName = '',
    this.contactPhone = '',
    this.contactEmail = '',
    this.bankFraudLine = '',
    this.bankCaseNumber = '',
    this.authorityReferenceNumbers = '',
  });

  final String userSummary;
  final List<ReportPackOtherPartyDetail> otherPartyDetails;
  final List<ReportPackTransactionLine> transactions;
  final List<ReportPackTimelineEntry> timeline;
  final List<String> selectedEvidenceIds;
  final Set<String> stepsTakenKeys;
  final bool includeContactDetails;
  final String contactName;
  final String contactPhone;
  final String contactEmail;
  final String bankFraudLine;
  final String bankCaseNumber;
  final String authorityReferenceNumbers;

  ReportPackDraft copyWith({
    String? userSummary,
    List<ReportPackOtherPartyDetail>? otherPartyDetails,
    List<ReportPackTransactionLine>? transactions,
    List<ReportPackTimelineEntry>? timeline,
    List<String>? selectedEvidenceIds,
    Set<String>? stepsTakenKeys,
    bool? includeContactDetails,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    String? bankFraudLine,
    String? bankCaseNumber,
    String? authorityReferenceNumbers,
  }) {
    return ReportPackDraft(
      userSummary: userSummary ?? this.userSummary,
      otherPartyDetails: otherPartyDetails ?? this.otherPartyDetails,
      transactions: transactions ?? this.transactions,
      timeline: timeline ?? this.timeline,
      selectedEvidenceIds: selectedEvidenceIds ?? this.selectedEvidenceIds,
      stepsTakenKeys: stepsTakenKeys ?? this.stepsTakenKeys,
      includeContactDetails: includeContactDetails ?? this.includeContactDetails,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      bankFraudLine: bankFraudLine ?? this.bankFraudLine,
      bankCaseNumber: bankCaseNumber ?? this.bankCaseNumber,
      authorityReferenceNumbers:
          authorityReferenceNumbers ?? this.authorityReferenceNumbers,
    );
  }

  Map<String, dynamic> toJson() => {
        'userSummary': userSummary,
        'otherPartyDetails':
            otherPartyDetails.map((e) => e.toJson()).toList(),
        'transactions': transactions.map((e) => e.toJson()).toList(),
        'timeline': timeline.map((e) => e.toJson()).toList(),
        'selectedEvidenceIds': selectedEvidenceIds,
        'stepsTakenKeys': stepsTakenKeys.toList(),
        'includeContactDetails': includeContactDetails,
        'contactName': contactName,
        'contactPhone': contactPhone,
        'contactEmail': contactEmail,
        'bankFraudLine': bankFraudLine,
        'bankCaseNumber': bankCaseNumber,
        'authorityReferenceNumbers': authorityReferenceNumbers,
      };

  factory ReportPackDraft.fromJson(Map<String, dynamic> json) {
    return ReportPackDraft(
      userSummary: json['userSummary']?.toString() ?? '',
      otherPartyDetails: [
        for (final item in json['otherPartyDetails'] as List<dynamic>? ?? [])
          if (item is Map)
            ReportPackOtherPartyDetail.fromJson(
              Map<String, dynamic>.from(item),
            ),
      ],
      transactions: [
        for (final item in json['transactions'] as List<dynamic>? ?? [])
          if (item is Map)
            ReportPackTransactionLine.fromJson(
              Map<String, dynamic>.from(item),
            ),
      ],
      timeline: [
        for (final item in json['timeline'] as List<dynamic>? ?? [])
          if (item is Map)
            ReportPackTimelineEntry.fromJson(
              Map<String, dynamic>.from(item),
            ),
      ],
      selectedEvidenceIds: [
        for (final id in json['selectedEvidenceIds'] as List<dynamic>? ?? [])
          id.toString(),
      ],
      stepsTakenKeys: {
        for (final k in json['stepsTakenKeys'] as List<dynamic>? ?? [])
          k.toString(),
      },
      includeContactDetails: json['includeContactDetails'] == true,
      contactName: json['contactName']?.toString() ?? '',
      contactPhone: json['contactPhone']?.toString() ?? '',
      contactEmail: json['contactEmail']?.toString() ?? '',
      bankFraudLine: json['bankFraudLine']?.toString() ?? '',
      bankCaseNumber: json['bankCaseNumber']?.toString() ?? '',
      authorityReferenceNumbers:
          json['authorityReferenceNumbers']?.toString() ?? '',
    );
  }
}
