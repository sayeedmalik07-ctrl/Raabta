import 'package:cloud_firestore/cloud_firestore.dart';

enum DeadlineUrgency { red, amber, green }

/// Qatar-relevant document types for the Deadline Tracker picker.
enum DocumentDeadlineType {
  qatarId,
  passport,
  residencePermit,
  drivingLicense,
  istimara,
  healthInsurance,
  visitVisa,
}

class DocumentDeadlineTypeDef {
  const DocumentDeadlineTypeDef({
    required this.type,
    required this.label,
    required this.emoji,
    required this.guideCategoryId,
  });

  final DocumentDeadlineType type;
  final String label;
  final String emoji;
  final String guideCategoryId;

  String get id => type.name;
}

const documentDeadlineTypes = [
  DocumentDeadlineTypeDef(
    type: DocumentDeadlineType.qatarId,
    label: 'Qatar ID (QID)',
    emoji: '🆔',
    guideCategoryId: 'qatar_id',
  ),
  DocumentDeadlineTypeDef(
    type: DocumentDeadlineType.passport,
    label: 'Passport',
    emoji: '🛂',
    guideCategoryId: 'exit_permit',
  ),
  DocumentDeadlineTypeDef(
    type: DocumentDeadlineType.residencePermit,
    label: 'Residence Permit',
    emoji: '📄',
    guideCategoryId: 'iqama_renewal',
  ),
  DocumentDeadlineTypeDef(
    type: DocumentDeadlineType.drivingLicense,
    label: 'Driving License',
    emoji: '🚗',
    guideCategoryId: 'qatar_id',
  ),
  DocumentDeadlineTypeDef(
    type: DocumentDeadlineType.istimara,
    label: 'Vehicle Istimara',
    emoji: '🚙',
    guideCategoryId: 'qatar_id',
  ),
  DocumentDeadlineTypeDef(
    type: DocumentDeadlineType.healthInsurance,
    label: 'Health Insurance',
    emoji: '🏥',
    guideCategoryId: 'medical',
  ),
  DocumentDeadlineTypeDef(
    type: DocumentDeadlineType.visitVisa,
    label: 'Visit Visa',
    emoji: '✈️',
    guideCategoryId: 'family_visa',
  ),
];

DocumentDeadlineTypeDef deadlineTypeDefFor(String? typeId) {
  return documentDeadlineTypes.firstWhere(
    (d) => d.id == typeId || d.label == typeId,
    orElse: () => documentDeadlineTypes.first,
  );
}

DocumentDeadlineTypeDef deadlineTypeDefForLegacyLabel(String label) {
  final lower = label.toLowerCase();
  if (lower.contains('qid') || lower.contains('qatar id')) {
    return documentDeadlineTypes.first;
  }
  if (lower.contains('passport')) {
    return documentDeadlineTypes[1];
  }
  if (lower.contains('iqama') || lower.contains('residence')) {
    return documentDeadlineTypes[2];
  }
  if (lower.contains('driving') || lower.contains('license')) {
    return documentDeadlineTypes[3];
  }
  if (lower.contains('istimara') || lower.contains('registration')) {
    return documentDeadlineTypes[4];
  }
  if (lower.contains('health') || lower.contains('insurance')) {
    return documentDeadlineTypes[5];
  }
  if (lower.contains('visit') || lower.contains('family')) {
    return documentDeadlineTypes[6];
  }
  return documentDeadlineTypes[2];
}

DocumentDeadlineTypeDef get visitVisaDeadlineTypeDef =>
    documentDeadlineTypes.firstWhere(
      (d) => d.type == DocumentDeadlineType.visitVisa,
    );

enum VisitVisaNicknameIssue { tooLong, invalidCharacters }

/// Optional guest nickname for visit-visa deadlines (stored in [DocumentDeadline.documentType]).
abstract final class VisitVisaNicknamePolicy {
  VisitVisaNicknamePolicy._();

  /// English catalog label — used when comparing legacy stored values.
  static const canonicalEnglishLabel = 'Visit Visa';

  /// Maximum trimmed nickname length (single-line guest label, not an ID).
  static const maxNicknameLength = 40;

  static final RegExp _controlChars =
      RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]');

  static VisitVisaNicknameIssue? validateNonEmptyInput(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.contains('\n') || trimmed.contains('\r')) {
      return VisitVisaNicknameIssue.invalidCharacters;
    }
    if (_controlChars.hasMatch(trimmed)) {
      return VisitVisaNicknameIssue.invalidCharacters;
    }
    final collapsed = trimmed.replaceAll(RegExp(r'\s+'), ' ');
    if (collapsed.length > maxNicknameLength) {
      return VisitVisaNicknameIssue.tooLong;
    }
    return null;
  }

  /// Returns trimmed nickname for persistence, or `null` when empty / whitespace-only.
  static String? sanitizeOptionalNickname(String? raw) {
    if (raw == null) return null;
    final issue = validateNonEmptyInput(raw);
    if (issue != null) return null;
    final trimmed = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (trimmed.isEmpty) return null;
    return trimmed;
  }

  static String documentTypeForPersistence({
    required String? rawNickname,
    required String defaultVisitVisaLabel,
  }) {
    final nick = sanitizeOptionalNickname(rawNickname);
    if (nick == null) return defaultVisitVisaLabel;
    return nick;
  }

  static String resolveDisplayTitle({
    required String storedDocumentType,
    required String defaultVisitVisaLabel,
  }) {
    final trimmed = storedDocumentType.trim();
    if (trimmed.isEmpty) return defaultVisitVisaLabel;
    if (trimmed == defaultVisitVisaLabel ||
        trimmed == canonicalEnglishLabel) {
      return defaultVisitVisaLabel;
    }
    if (trimmed.contains('\n') ||
        trimmed.contains('\r') ||
        _controlChars.hasMatch(trimmed)) {
      return defaultVisitVisaLabel;
    }
    var collapsed = trimmed.replaceAll(RegExp(r'\s+'), ' ');
    if (collapsed.length > maxNicknameLength) {
      collapsed = collapsed.substring(0, maxNicknameLength);
    }
    return collapsed;
  }
}

class VisaCategory {
  const VisaCategory({
    required this.id,
    required this.emoji,
    required this.title,
    required this.steps,
    required this.estimatedTime,
  });

  final String id;
  final String emoji;
  final String title;
  final int steps;
  final String estimatedTime;
}

class VisaGuideStep {
  const VisaGuideStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.documents,
    required this.cost,
    required this.time,
  });

  final int stepNumber;
  final String title;
  final String description;
  final List<String> documents;
  final String cost;
  final String time;

  factory VisaGuideStep.fromJson(Map<String, dynamic> json, String language) {
    return VisaGuideStep(
      stepNumber: (json['stepNumber'] as num?)?.toInt() ?? 1,
      title: localizedField(json['title'], language),
      description: localizedField(json['description'], language),
      documents: (json['documents'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      cost: json['cost']?.toString() ?? 'Varies',
      time: json['time']?.toString() ?? 'Varies',
    );
  }
}

class OfficialLink {
  const OfficialLink({
    required this.name,
    required this.url,
  });

  final String name;
  final String url;

  factory OfficialLink.fromJson(Map<String, dynamic> json) {
    return OfficialLink(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }
}

class VisaGuide {
  const VisaGuide({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.summary,
    required this.steps,
    required this.officialLinks,
  });

  final String id;
  final String categoryId;
  final String title;
  final String summary;
  final List<VisaGuideStep> steps;
  final List<OfficialLink> officialLinks;

  factory VisaGuide.fromJson(Map<String, dynamic> json, String language) {
    final stepsJson = json['steps'] as List<dynamic>? ?? [];
    return VisaGuide(
      id: json['id'] as String? ?? json['categoryId'] as String,
      categoryId: json['categoryId'] as String,
      title: localizedField(json['title'], language),
      summary: localizedField(json['summary'], language),
      steps: stepsJson
          .map((e) => VisaGuideStep.fromJson(e as Map<String, dynamic>, language))
          .toList(),
      officialLinks: (json['officialLinks'] as List<dynamic>?)
              ?.map((e) => OfficialLink.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class DocumentDeadline {
  const DocumentDeadline({
    required this.id,
    required this.documentType,
    required this.expiryDate,
    required this.guideCategoryId,
    this.typeId,
    this.remind30Days = true,
    this.remind7Days = true,
    this.remind1Day = true,
    this.vaultDocumentId,
  });

  final String id;
  final String documentType;
  final DateTime expiryDate;
  final String guideCategoryId;
  final String? typeId;
  final bool remind30Days;
  final bool remind7Days;
  final bool remind1Day;
  final String? vaultDocumentId;

  DocumentDeadlineTypeDef get typeDef =>
      deadlineTypeDefFor(typeId ?? documentType);

  bool get isVisitVisaEntry =>
      typeDef.type == DocumentDeadlineType.visitVisa;

  String displayTitle(String defaultVisitVisaLabel) {
    if (!isVisitVisaEntry) return documentType;
    return VisitVisaNicknamePolicy.resolveDisplayTitle(
      storedDocumentType: documentType,
      defaultVisitVisaLabel: defaultVisitVisaLabel,
    );
  }

  /// Generic reminder / next-step label — never the guest nickname.
  String get notificationDocumentLabel {
    if (!isVisitVisaEntry) return documentType;
    return visitVisaDeadlineTypeDef.label;
  }

  int get daysRemaining {
    final today = DateTime.now();
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final now = DateTime(today.year, today.month, today.day);
    return expiry.difference(now).inDays;
  }

  DeadlineUrgency get urgency {
    final days = daysRemaining;
    if (days < 30) return DeadlineUrgency.red;
    if (days <= 90) return DeadlineUrgency.amber;
    return DeadlineUrgency.green;
  }

  String get expiryLabel {
    final days = daysRemaining;
    if (days < 0) return 'Expired ${days.abs()} days ago';
    if (days == 0) return 'Expires today';
    if (days == 1) return 'Expires in 1 day';
    return 'Expires in $days days';
  }

  List<int> get enabledReminderOffsets {
    final offsets = <int>[];
    if (remind30Days) offsets.add(30);
    if (remind7Days) offsets.add(7);
    if (remind1Day) offsets.add(1);
    return offsets;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'documentType': documentType,
        'expiryDate': expiryDate.toIso8601String(),
        'guideCategoryId': guideCategoryId,
        'typeId': typeId,
        'remind30Days': remind30Days,
        'remind7Days': remind7Days,
        'remind1Day': remind1Day,
        'vaultDocumentId': vaultDocumentId,
      };

  Map<String, dynamic> toFirestore({required String userId}) => {
        'userId': userId,
        'documentType': documentType,
        'typeId': typeId ?? typeDef.id,
        'expiryDate': Timestamp.fromDate(expiryDate),
        'guideCategoryId': guideCategoryId,
        'remind30Days': remind30Days,
        'remind7Days': remind7Days,
        'remind1Day': remind1Day,
        if (vaultDocumentId != null) 'vaultDocumentId': vaultDocumentId,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      };

  factory DocumentDeadline.fromJson(Map<String, dynamic> json) {
    return DocumentDeadline(
      id: json['id'] as String,
      documentType: json['documentType'] as String,
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      guideCategoryId: json['guideCategoryId'] as String? ?? 'iqama_renewal',
      typeId: json['typeId'] as String?,
      remind30Days: json['remind30Days'] as bool? ?? true,
      remind7Days: json['remind7Days'] as bool? ?? true,
      remind1Day: json['remind1Day'] as bool? ?? true,
      vaultDocumentId: json['vaultDocumentId'] as String?,
    );
  }

  factory DocumentDeadline.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    final expiry = d['expiryDate'];
    DateTime expiryDate;
    if (expiry is Timestamp) {
      expiryDate = expiry.toDate();
    } else if (expiry is String) {
      expiryDate = DateTime.parse(expiry);
    } else {
      expiryDate = DateTime.now();
    }
    final typeId = d['typeId'] as String?;
    final documentType = d['documentType'] as String? ?? 'Document';
    return DocumentDeadline(
      id: doc.id,
      documentType: documentType,
      expiryDate: expiryDate,
      guideCategoryId: d['guideCategoryId'] as String? ?? 'iqama_renewal',
      typeId: typeId,
      remind30Days: d['remind30Days'] as bool? ?? true,
      remind7Days: d['remind7Days'] as bool? ?? true,
      remind1Day: d['remind1Day'] as bool? ?? true,
      vaultDocumentId: d['vaultDocumentId'] as String?,
    );
  }

  DocumentDeadline copyWith({
    String? id,
    String? documentType,
    DateTime? expiryDate,
    String? guideCategoryId,
    String? typeId,
    bool? remind30Days,
    bool? remind7Days,
    bool? remind1Day,
    String? vaultDocumentId,
    bool clearVaultDocumentId = false,
  }) {
    return DocumentDeadline(
      id: id ?? this.id,
      documentType: documentType ?? this.documentType,
      expiryDate: expiryDate ?? this.expiryDate,
      guideCategoryId: guideCategoryId ?? this.guideCategoryId,
      typeId: typeId ?? this.typeId,
      remind30Days: remind30Days ?? this.remind30Days,
      remind7Days: remind7Days ?? this.remind7Days,
      remind1Day: remind1Day ?? this.remind1Day,
      vaultDocumentId:
          clearVaultDocumentId ? null : (vaultDocumentId ?? this.vaultDocumentId),
    );
  }
}

class EmergencyContact {
  const EmergencyContact({
    required this.name,
    required this.number,
    required this.description,
  });

  final String name;
  final String number;
  final String description;
}

const visaCategories = [
  VisaCategory(
    id: 'iqama_renewal',
    emoji: '📄',
    title: 'Iqama Renewal',
    steps: 5,
    estimatedTime: '3–5 days',
  ),
  VisaCategory(
    id: 'exit_permit',
    emoji: '✈️',
    title: 'Exit Permit',
    steps: 6,
    estimatedTime: 'Varies',
  ),
  VisaCategory(
    id: 'family_visa',
    emoji: '📝',
    title: 'Family Visa',
    steps: 8,
    estimatedTime: '2–4 weeks',
  ),
  VisaCategory(
    id: 'sponsor_transfer',
    emoji: '🔄',
    title: 'Sponsor Transfer/Change of Employer',
    steps: 6,
    estimatedTime: 'Varies',
  ),
  VisaCategory(
    id: 'medical',
    emoji: '🏥',
    title: 'Medical',
    steps: 3,
    estimatedTime: '1 day',
  ),
  VisaCategory(
    id: 'qatar_id',
    emoji: '🆔',
    title: 'Qatar ID',
    steps: 4,
    estimatedTime: '5–7 days',
  ),
];

const emergencyContacts = [
  EmergencyContact(
    name: 'Emergency (Police/Ambulance)',
    number: '999',
    description: 'Life-threatening emergencies only',
  ),
  EmergencyContact(
    name: 'MOI Qatar Hotline',
    number: '109',
    description: 'Ministry of Interior general inquiries',
  ),
  EmergencyContact(
    name: 'Metrash Support',
    number: '107',
    description: 'Residency, visa, and traffic services',
  ),
  EmergencyContact(
    name: 'Hukoomi Portal Help',
    number: '109',
    description: 'Government e-services support',
  ),
];

String languageToCode(String language) {
  switch (language) {
    case 'اردو':
      return 'ur';
    case 'हिंदी':
      return 'hi';
    case 'العربية':
      return 'ar';
    case 'Filipino':
      return 'fil';
    case 'বাংলা':
      return 'bn';
    default:
      return 'en';
  }
}

String localizedField(dynamic field, String language) {
  if (field == null) return '';
  if (field is String) return field;
  if (field is Map) {
    final code = languageToCode(language);
    return (field[code] ?? field['en'] ?? field.values.first)?.toString() ?? '';
  }
  return field.toString();
}

const _exitPermitCategoryId = 'exit_permit';
const _sponsorTransferCategoryId = 'sponsor_transfer';

Map<String, String> _exitPermitGuideTitle() => {
      'en': 'Exit & Travel Eligibility Guide',
    };

Map<String, String> _exitPermitGuideSummary() => {
      'en':
          'Whether you need an exit permit before leaving Qatar depends on your '
          'worker category and current status — not every resident must apply. '
          'Most private-sector workers covered by the Labour Law can generally '
          'leave without an exit permit following September 2018 reforms. Some '
          'categories and designated critical workers may have additional '
          'requirements. Confirm your status on MOI/Metrash and use Raabta\'s '
          'Leaving Qatar checklist for category-specific guidance — '
          'informational only, not legal advice.',
    };

const List<OfficialLink> _exitPermitOfficialLinks = [
  OfficialLink(
    name: 'Ministry of Interior (Metrash)',
    url: 'https://portal.moi.gov.qa',
  ),
  OfficialLink(
    name: 'Hukoomi',
    url: 'https://www.hukoomi.gov.qa',
  ),
];

List<Map<String, dynamic>> _exitPermitGuideSteps() => [
      _step(
        1,
        {'en': 'Confirm your worker category'},
        {
          'en':
              'Exit rules differ by category. Most private-sector workers '
              'covered by the Labour Law can generally leave without an exit '
              'permit after the September 2018 reform. Workers outside the '
              'Labour Law, government, oil and gas, designated critical '
              'workers (up to 5% per employer), domestic workers, and military '
              'personnel may have different rules. Check MOI/Metrash for your '
              'current status.',
        },
        ['QID', 'Passport'],
        'Free',
        '10 mins',
      ),
      _step(
        2,
        {'en': 'Check travel bans and outstanding fines'},
        {
          'en':
              'Separate from exit-permit rules: travel bans, unpaid traffic '
              'fines, and other MOI holds can block departure. Run MOI travel '
              'ban and fine checks before booking travel.',
        },
        ['QID', 'Passport'],
        'Free',
        '5 mins',
      ),
      _step(
        3,
        {'en': 'If you may be a designated critical worker'},
        {
          'en':
              'Under Decision No. 95 of 2019, employers may designate up to 5% '
              'of workers who need prior MOI approval before leaving because of '
              'the nature of their work. Essential workers in this category '
              'may need a Leave Notification via Metrash. Confirm the current '
              'fee and validity on the official portal when you apply.',
        },
        ['QID', 'Passport'],
        'Varies',
        'Varies',
      ),
      _step(
        4,
        {'en': 'Domestic workers — notification rule'},
        {
          'en':
              'Domestic workers under Law No. 15 of 2017 typically do not '
              'need an exit permit but must inform their employer at least '
              '72 hours before departure (Decision No. 95 of 2019). Confirm '
              'current rules on the MOI portal.',
        },
        ['QID', 'Passport'],
        'Free',
        '—',
      ),
      _step(
        5,
        {'en': 'Use Raabta Leaving Qatar checklist'},
        {
          'en':
              'Open Raabta\'s Leaving Qatar flow for category-specific exit '
              'permit guidance, travel-ban checks, and departure planning. '
              'This guide does not replace official MOI verification.',
        },
        ['QID'],
        'Free',
        '5 mins',
      ),
      _step(
        6,
        {'en': 'Before you travel'},
        {
          'en':
              'Carry passport and QID. Re-check Metrash immediately before '
              'departure for any last-minute holds or status changes.',
        },
        ['Passport', 'QID'],
        'Free',
        '—',
      ),
    ];

Map<String, String> _sponsorTransferGuideTitle() => {
      'en': 'Sponsor Transfer Guide',
    };

Map<String, String> _sponsorTransferGuideSummary() => {
      'en':
          'Procedural steps for changing employer within Qatar\'s labour market '
          'through the Ministry of Labour, with residence updates through the '
          'Ministry of Interior. For NOC status, notice period, permit validity, '
          'and the 90-day post-expiry window, use Raabta\'s Employer Transfer '
          'readiness tool — informational only, not legal advice.',
    };

const List<OfficialLink> _sponsorTransferOfficialLinks = [
  OfficialLink(
    name: 'Ministry of Labour',
    url: 'https://www.mol.gov.qa',
  ),
  OfficialLink(
    name: 'Ministry of Interior (Metrash)',
    url: 'https://portal.moi.gov.qa',
  ),
  OfficialLink(
    name: 'MoL Employer Change Guide (PDF)',
    url:
        'https://www.mol.gov.qa/admin/EServices/User%20Guide%20for%20Changing%20employer%20(1).pdf',
  ),
];

List<Map<String, dynamic>> _sponsorTransferGuideSteps() => [
      _step(
        1,
        {'en': 'Check readiness before you apply'},
        {
          'en':
              'Use Raabta\'s Sponsorship Transfer tool for NOC status (not '
              'required for eligible changes), notice obligations, residence '
              'permit validity, and whether you may fall within the post-expiry '
              'window. This guide covers Ministry procedure only.',
        },
        [
          'QID',
          'Passport',
          'Employment start date (for readiness check)',
          'Residence permit expiry (for readiness check)',
        ],
        'Free',
        'Varies',
      ),
      _step(
        2,
        {'en': 'Ministry of Labour employer-change application'},
        {
          'en':
              'Standard labour-market transfers start through the Ministry of '
              'Labour employer-change service on mol.gov.qa. The new employer '
              'typically submits the request with worker details and new contract '
              'information.',
        },
        [
          'Passport',
          'QID',
          'New employment contract or offer details (if required)',
        ],
        'Varies',
        'Varies',
      ),
      _step(
        3,
        {'en': 'Worker review and approval'},
        {
          'en':
              'The worker reviews and approves the request through the Ministry '
              'of Labour process. An employer No Objection Certificate is not the '
              'legal gateway for eligible employer changes under current rules.',
        },
        ['QID', 'Mobile number linked to QID (if required by the service)'],
        'Varies',
        'Varies',
      ),
      _step(
        4,
        {'en': 'Current employer notification'},
        {
          'en':
              'The current employer is notified through the Ministry process and '
              'may submit comments or confirm a notice-period waiver if agreed. '
              'Current employer permission or an NOC is not required to initiate '
              'eligible transfers.',
        },
        [
          'Formal notice evidence (if applicable — see Sponsorship Transfer tool)',
          'Current employment contract (if available)',
        ],
        'Varies',
        'Varies',
      ),
      _step(
        5,
        {'en': 'Notice obligations and contract authentication'},
        {
          'en':
              'Applicable notice obligations may affect timing — use Raabta\'s '
              'Sponsorship Transfer tool for notice guidance. After Ministry '
              'processing, the new employment contract is authenticated through '
              'the Ministry of Labour digital contract process where applicable.',
        },
        [
          'Signed employment contract',
          'Previous employment contract (if available)',
        ],
        'Varies',
        'Varies',
      ),
      _step(
        6,
        {'en': 'Ministry of Interior residence and QID'},
        {
          'en':
              'After the Ministry of Labour process, residence permit and QID '
              'updates proceed through the Ministry of Interior. Metrash supports '
              'residence enquiries and sponsor updates — it is not the primary '
              'channel for the standard labour-market employer-change application. '
              'Applicable Ministry or residence charges depend on the service; '
              'verify current fees on the official Ministry portals.',
        },
        [
          'Passport',
          'QID',
          'Authenticated contract copy (if issued)',
        ],
        'Varies',
        'Varies',
      ),
    ];

/// Canonical Firestore payload for [visa_guides/sponsor_transfer].
Map<String, dynamic> sponsorTransferVisaGuideFirestoreDocument() {
  return {
    'id': _sponsorTransferCategoryId,
    'categoryId': _sponsorTransferCategoryId,
    'title': _sponsorTransferGuideTitle(),
    'summary': _sponsorTransferGuideSummary(),
    'officialLinks': _sponsorTransferOfficialLinks
        .map((link) => {'name': link.name, 'url': link.url})
        .toList(),
    'steps': _sponsorTransferGuideSteps(),
  };
}

VisaGuide fallbackVisaGuide(String categoryId, String language) {
  final guides = fallbackVisaGuides(language);
  return guides.firstWhere(
    (g) => g.categoryId == categoryId,
    orElse: () => guides.first,
  );
}

List<VisaGuide> fallbackVisaGuides(String language) {
  return [
    _buildGuide(
      categoryId: 'iqama_renewal',
      title: {
        'en': 'Iqama Renewal Guide',
        'hi': 'इकामा नवीनीकरण गाइड',
        'ur': 'اقامہ تجدید گائیڈ',
        'ar': 'دليل تجديد الإقامة',
      },
      summary: {
        'en': 'Renew your Qatar residence permit through Metrash.',
        'hi': 'Metrash के माध्यम से अपना कतर निवास परमिट नवीनीकृत करें।',
      },
      language: language,
      steps: [
        _step(
          1,
          {
            'en': 'Check eligibility on Metrash',
            'hi': 'Metrash पर पात्रता जांचें',
          },
          {
            'en':
                'Open Metrash app and verify your Iqama is eligible for renewal. Ensure no outstanding fines.',
            'hi':
                'Metrash ऐप खोलें और जांचें कि आपका इकामा नवीनीकरण के लिए पात्र है।',
          },
          ['Valid passport', 'Current QID', 'Medical fitness (if required)'],
          '100–200 QR',
          '10 mins',
        ),
        _step(
          2,
          {'en': 'Complete medical check (if due)', 'hi': 'मेडिकल जांच पूरी करें'},
          {
            'en':
                'Visit an approved medical centre if your fitness certificate is expired or due.',
            'hi': 'यदि फिटness प्रमाणपत्र समाप्त है तो अ approved medical centre जाएं।',
          },
          ['QID copy', 'Passport copy'],
          '100–150 QR',
          '1–2 hours',
        ),
        _step(
          3,
          {'en': 'Pay renewal fees online', 'hi': 'ऑनलाइन शुल्क भुगतान करें'},
          {
            'en': 'Go to Residency Services → Iqama Renewal and pay via debit/credit card.',
            'hi': 'Residency Services → Iqama Renewal पर जाएं और कार्ड से भुगतान करें।',
          },
          ['Bank card'],
          'As shown in Metrash',
          '5 mins',
        ),
        _step(
          4,
          {'en': 'Employer/sponsor approval', 'hi': 'नियोक्ता/प्रायोजक की स्वीकृति'},
          {
            'en':
                'Your sponsor may need to approve the renewal request in the MOI system.',
            'hi': 'आपके प्रायोजक को MOI सिस्टम में अनुरोध स्वीकृत करना पड़ सकता है।',
          },
          ['Employment contract (if requested)'],
          'Free',
          '1–3 days',
        ),
        _step(
          5,
          {'en': 'Collect updated Iqama', 'hi': 'अपडेटेड इकामा प्राप्त करें'},
          {
            'en':
                'Once approved, your new Iqama validity will reflect in Metrash. Print QID if needed.',
            'hi': 'स्वीकृति के बाद Metrash में नई वैधता दिखेगी।',
          },
          ['Old QID'],
          'Free',
          '1–2 days',
        ),
      ],
    ),
    _buildGuide(
      categoryId: _exitPermitCategoryId,
      title: _exitPermitGuideTitle(),
      summary: _exitPermitGuideSummary(),
      language: language,
      officialLinks: _exitPermitOfficialLinks,
      steps: _exitPermitGuideSteps(),
    ),
    _buildGuide(
      categoryId: 'family_visa',
      title: {'en': 'Family Visa Guide'},
      summary: {'en': 'Bring your spouse and children to Qatar.'},
      language: language,
      steps: [
        _step(1, {'en': 'Check salary requirements'}, {'en': 'Confirm minimum salary threshold for family sponsorship.'}, ['Salary certificate', 'QID'], 'Free', '1 day'),
        _step(2, {'en': 'Apply family entry visa'}, {'en': 'Submit application via Metrash or MOI.'}, ['Passport copies', 'Marriage/birth certificates'], '500+ QR', '1 week'),
        _step(3, {'en': 'Medical for dependents'}, {'en': 'Dependents complete medical upon arrival.'}, ['Passports'], '100 QR each', '1 day'),
        _step(4, {'en': 'QID for family members'}, {'en': 'Apply for QID after medical clearance.'}, ['Photos', 'Passports'], '100 QR', '3–5 days'),
        _step(5, {'en': 'Health insurance'}, {'en': 'Register dependents on employer health plan if applicable.'}, ['QID copies'], 'Varies', '1–3 days'),
        _step(6, {'en': 'School enrollment (if applicable)'}, {'en': 'Contact schools in your area for admission.'}, ['QID', 'Previous school records'], 'Varies', '1–2 weeks'),
        _step(7, {'en': 'Tenancy registration'}, {'en': 'Update lease/ejari if required for family size.'}, ['Lease contract'], 'Varies', '1 week'),
        _step(
          8,
          {'en': 'Dependent employment (if applicable)'},
          {
            'en':
                'Family-residency holders may have a Ministry of Labour work-permit '
                'route that allows entering the labour market without changing '
                'residency type. Permanent residents, GCC citizens, and investor '
                'residents may also use MOL work-permit services. Eligibility, '
                'fees, and current requirements must be confirmed through the '
                'official Ministry of Labour service — see Jobs in Raabta for '
                'general labour-market orientation.',
          },
          ['QID', 'Passport'],
          'Varies',
          'Varies',
        ),
      ],
    ),
    _buildGuide(
      categoryId: _sponsorTransferCategoryId,
      title: _sponsorTransferGuideTitle(),
      summary: _sponsorTransferGuideSummary(),
      language: language,
      officialLinks: _sponsorTransferOfficialLinks,
      steps: _sponsorTransferGuideSteps(),
    ),
    _buildGuide(
      categoryId: 'medical',
      title: {'en': 'Medical Fitness Guide'},
      summary: {'en': 'Complete mandatory medical tests for residency.'},
      language: language,
      steps: [
        _step(1, {'en': 'Book approved centre'}, {'en': 'Find MOI-approved medical centre near you via Hukoomi.'}, ['QID', 'Passport'], 'Free', '10 mins'),
        _step(2, {'en': 'Attend medical test'}, {'en': 'Blood test, X-ray, and general check-up.'}, ['QID', 'Passport', 'Photos'], '100–150 QR', '1–2 hours'),
        _step(3, {'en': 'Receive fitness certificate'}, {'en': 'Results sent electronically to MOI. Check Metrash.'}, ['Receipt'], 'Free', '1–3 days'),
      ],
    ),
    _buildGuide(
      categoryId: 'qatar_id',
      title: {'en': 'Qatar ID (QID) Guide'},
      summary: {'en': 'Apply for or renew your Qatar ID.'},
      language: language,
      steps: [
        _step(1, {'en': 'Check application type'}, {'en': 'New issue, renewal, or replacement via Metrash.'}, ['Passport', 'Visa copy'], 'Free', '5 mins'),
        _step(2, {'en': 'Submit biometrics'}, {'en': 'Visit MOI service centre for fingerprint and photo.'}, ['Passport', 'Photos'], '100 QR', '30 mins'),
        _step(3, {'en': 'Pay fees'}, {'en': 'Pay QID fees online or at service centre.'}, ['Bank card'], '100–200 QR', '5 mins'),
        _step(4, {'en': 'Collect QID card'}, {'en': 'Collect from service centre or via authorized delivery.'}, ['Receipt', 'Old QID (if renewal)'], 'Free', '5–7 days'),
      ],
    ),
  ];
}

Map<String, dynamic> _step(
  int number,
  Map<String, String> title,
  Map<String, String> description,
  List<String> documents,
  String cost,
  String time,
) {
  return {
    'stepNumber': number,
    'title': title,
    'description': description,
    'documents': documents,
    'cost': cost,
    'time': time,
  };
}

VisaGuide _buildGuide({
  required String categoryId,
  required Map<String, String> title,
  required Map<String, String> summary,
  required String language,
  required List<Map<String, dynamic>> steps,
  List<OfficialLink>? officialLinks,
}) {
  return VisaGuide(
    id: categoryId,
    categoryId: categoryId,
    title: localizedField(title, language),
    summary: localizedField(summary, language),
    steps: steps
        .map((s) => VisaGuideStep.fromJson(s, language))
        .toList(),
    officialLinks: officialLinks ??
        const [
          OfficialLink(name: 'Metrash', url: 'https://portal.moi.gov.qa'),
          OfficialLink(name: 'Hukoomi', url: 'https://www.hukoomi.gov.qa'),
          OfficialLink(name: 'Hayya Portal', url: 'https://hayya.qa'),
        ],
  );
}
