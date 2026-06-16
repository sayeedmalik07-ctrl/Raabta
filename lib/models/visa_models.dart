enum DeadlineUrgency { red, amber, green }

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
  });

  final String id;
  final String documentType;
  final DateTime expiryDate;
  final String guideCategoryId;

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'documentType': documentType,
        'expiryDate': expiryDate.toIso8601String(),
        'guideCategoryId': guideCategoryId,
      };

  factory DocumentDeadline.fromJson(Map<String, dynamic> json) {
    return DocumentDeadline(
      id: json['id'] as String,
      documentType: json['documentType'] as String,
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      guideCategoryId: json['guideCategoryId'] as String? ?? 'iqama_renewal',
    );
  }
}

class DocumentScanResult {
  const DocumentScanResult({
    required this.documentType,
    required this.keyDates,
    required this.importantInfo,
    required this.actionNeeded,
    required this.summary,
  });

  final String documentType;
  final List<String> keyDates;
  final List<String> importantInfo;
  final String actionNeeded;
  final String summary;

  factory DocumentScanResult.fromJson(Map<String, dynamic> json) {
    return DocumentScanResult(
      documentType: json['documentType'] as String? ?? 'Unknown Document',
      keyDates: (json['keyDates'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      importantInfo: (json['importantInfo'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      actionNeeded: json['actionNeeded'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
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
    steps: 4,
    estimatedTime: '1–2 days',
  ),
  VisaCategory(
    id: 'family_visa',
    emoji: '📝',
    title: 'Family Visa',
    steps: 7,
    estimatedTime: '2–4 weeks',
  ),
  VisaCategory(
    id: 'sponsor_transfer',
    emoji: '🔄',
    title: 'Sponsor Transfer/Change of Employer',
    steps: 6,
    estimatedTime: '1–2 weeks',
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
    name: 'Metrash2 Support',
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
        'en': 'Renew your Qatar residence permit through Metrash2.',
        'hi': 'Metrash2 के माध्यम से अपना कतर निवास परमिट नवीनीकृत करें।',
      },
      language: language,
      steps: [
        _step(
          1,
          {
            'en': 'Check eligibility on Metrash2',
            'hi': 'Metrash2 पर पात्रता जांचें',
          },
          {
            'en':
                'Open Metrash2 app and verify your Iqama is eligible for renewal. Ensure no outstanding fines.',
            'hi':
                'Metrash2 ऐप खोलें और जांचें कि आपका इकामा नवीनीकरण के लिए पात्र है।',
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
          'As shown in Metrash2',
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
                'Once approved, your new Iqama validity will reflect in Metrash2. Print QID if needed.',
            'hi': 'स्वीकृति के बाद Metrash2 में नई वैधता दिखेगी।',
          },
          ['Old QID'],
          'Free',
          '1–2 days',
        ),
      ],
    ),
    _buildGuide(
      categoryId: 'exit_permit',
      title: {'en': 'Exit Permit Guide'},
      summary: {'en': 'Apply for exit permit before leaving Qatar.'},
      language: language,
      steps: [
        _step(
          1,
          {'en': 'Verify travel eligibility'},
          {'en': 'Check Metrash2 for any travel bans or outstanding fines.'},
          ['QID', 'Passport'],
          'Free',
          '5 mins',
        ),
        _step(
          2,
          {'en': 'Apply via Metrash2'},
          {'en': 'Select Exit Permit under Residency Services.'},
          ['Passport', 'QID'],
          '50–100 QR',
          '10 mins',
        ),
        _step(
          3,
          {'en': 'Sponsor approval'},
          {'en': 'Wait for employer/sponsor to approve exit request.'},
          ['Sponsor letter (if required)'],
          'Free',
          '1–2 days',
        ),
        _step(
          4,
          {'en': 'Travel'},
          {'en': 'Carry passport and QID when departing through Hamad Airport.'},
          ['Passport', 'QID', 'Exit permit confirmation'],
          'Free',
          '—',
        ),
      ],
    ),
    _buildGuide(
      categoryId: 'family_visa',
      title: {'en': 'Family Visa Guide'},
      summary: {'en': 'Bring your spouse and children to Qatar.'},
      language: language,
      steps: [
        _step(1, {'en': 'Check salary requirements'}, {'en': 'Confirm minimum salary threshold for family sponsorship.'}, ['Salary certificate', 'QID'], 'Free', '1 day'),
        _step(2, {'en': 'Apply family entry visa'}, {'en': 'Submit application via Metrash2 or MOI.'}, ['Passport copies', 'Marriage/birth certificates'], '500+ QR', '1 week'),
        _step(3, {'en': 'Medical for dependents'}, {'en': 'Dependents complete medical upon arrival.'}, ['Passports'], '100 QR each', '1 day'),
        _step(4, {'en': 'QID for family members'}, {'en': 'Apply for QID after medical clearance.'}, ['Photos', 'Passports'], '100 QR', '3–5 days'),
        _step(5, {'en': 'Health insurance'}, {'en': 'Register dependents on employer health plan if applicable.'}, ['QID copies'], 'Varies', '1–3 days'),
        _step(6, {'en': 'School enrollment (if applicable)'}, {'en': 'Contact schools in your area for admission.'}, ['QID', 'Previous school records'], 'Varies', '1–2 weeks'),
        _step(7, {'en': 'Tenancy registration'}, {'en': 'Update lease/ejari if required for family size.'}, ['Lease contract'], 'Varies', '1 week'),
      ],
    ),
    _buildGuide(
      categoryId: 'sponsor_transfer',
      title: {'en': 'Sponsor Transfer Guide'},
      summary: {'en': 'Change employer or transfer sponsorship in Qatar.'},
      language: language,
      steps: [
        _step(1, {'en': 'Obtain NOC from current sponsor'}, {'en': 'Request No Objection Certificate from current employer.'}, ['Resignation/NOC letter'], 'Free', '3–7 days'),
        _step(2, {'en': 'New employer submits request'}, {'en': 'New company initiates transfer in MOI system.'}, ['Passport', 'QID', 'Contract'], 'Varies', '2–5 days'),
        _step(3, {'en': 'Sign new contract'}, {'en': 'Complete labour contract via Ministry of Labour portal.'}, ['Passport', 'QID'], 'Free', '1–2 days'),
        _step(4, {'en': 'Pay transfer fees'}, {'en': 'Pay applicable fees through Metrash2.'}, ['Bank card'], '500–1500 QR', '10 mins'),
        _step(5, {'en': 'Medical (if required)'}, {'en': 'Complete medical if mandated for transfer.'}, ['QID'], '100 QR', '1 day'),
        _step(6, {'en': 'Updated QID/Iqama issued'}, {'en': 'New sponsor details reflected on QID.'}, ['Old QID'], 'Free', '3–5 days'),
      ],
    ),
    _buildGuide(
      categoryId: 'medical',
      title: {'en': 'Medical Fitness Guide'},
      summary: {'en': 'Complete mandatory medical tests for residency.'},
      language: language,
      steps: [
        _step(1, {'en': 'Book approved centre'}, {'en': 'Find MOI-approved medical centre near you via Hukoomi.'}, ['QID', 'Passport'], 'Free', '10 mins'),
        _step(2, {'en': 'Attend medical test'}, {'en': 'Blood test, X-ray, and general check-up.'}, ['QID', 'Passport', 'Photos'], '100–150 QR', '1–2 hours'),
        _step(3, {'en': 'Receive fitness certificate'}, {'en': 'Results sent electronically to MOI. Check Metrash2.'}, ['Receipt'], 'Free', '1–3 days'),
      ],
    ),
    _buildGuide(
      categoryId: 'qatar_id',
      title: {'en': 'Qatar ID (QID) Guide'},
      summary: {'en': 'Apply for or renew your Qatar ID.'},
      language: language,
      steps: [
        _step(1, {'en': 'Check application type'}, {'en': 'New issue, renewal, or replacement via Metrash2.'}, ['Passport', 'Visa copy'], 'Free', '5 mins'),
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
}) {
  return VisaGuide(
    id: categoryId,
    categoryId: categoryId,
    title: localizedField(title, language),
    summary: localizedField(summary, language),
    steps: steps
        .map((s) => VisaGuideStep.fromJson(s, language))
        .toList(),
    officialLinks: const [
      OfficialLink(name: 'Metrash2', url: 'https://portal.moi.gov.qa'),
      OfficialLink(name: 'Hukoomi', url: 'https://www.hukoomi.gov.qa'),
      OfficialLink(name: 'Hayya Portal', url: 'https://hayya.qa'),
    ],
  );
}

DocumentScanResult fallbackScanResult() {
  return const DocumentScanResult(
    documentType: 'Qatar Residence Permit (Iqama)',
    keyDates: [
      'Issue date: 15 Jan 2024',
      'Expiry date: 15 Jan 2026',
      'Passport expiry: 10 Mar 2028',
    ],
    importantInfo: [
      'Sponsor: ABC Trading W.L.L.',
      'Profession: Sales Representative',
      'QID number: 284XXXXXXXX',
    ],
    actionNeeded:
        'Your Iqama expires in 47 days. Start renewal via Metrash2 at least 30 days before expiry.',
    summary:
        'This appears to be a valid Qatar residence permit. Key expiry dates are highlighted above. Begin renewal soon to avoid fines.',
  );
}
