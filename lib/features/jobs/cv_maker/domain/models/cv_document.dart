import 'package:intl/intl.dart';
import 'package:raabta/features/jobs/cv_maker/domain/cv_template_catalog.dart';

enum CvTemplateId {
  modern,
  classic,
  professional,
  premium,
}

enum CvSummaryFormat { paragraph, bullets }

/// Assistable free-text fields — max 3 calls each, 15 total per CV.
enum CvAssistField {
  summary,
  skills,
  exp0,
  exp1,
  exp2,
}

extension CvAssistFieldX on CvAssistField {
  String get id => name;
}

/// AI-assist field ids for experience responsibilities / achievements.
String cvAssistFieldResponsibilities(int index) => 'exp${index}_r';

String cvAssistFieldAchievements(int index) => 'exp${index}_a';

bool cvExperienceAssistAllowed(CvDocument cv, int index) =>
    index < 3 &&
    (cv.canAssistField(cvAssistFieldResponsibilities(index)) ||
        cv.canAssistField(cvAssistFieldAchievements(index)) ||
        cv.canAssistField('exp$index'));

class CvExperience {
  const CvExperience({
    this.jobTitle = '',
    this.employer = '',
    this.location = '',
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.responsibilities = const [],
    this.achievements = const [],
    this.bullets = const [],
    this.description = '',
    this.includeSalary = false,
  });

  final String jobTitle;
  final String employer;
  final String location;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final List<String> responsibilities;
  final List<String> achievements;
  final List<String> bullets;
  /// Legacy single-block description — migrated to achievements on load.
  final String description;
  final bool includeSalary;

  List<String> get displayResponsibilities =>
      responsibilities.where((b) => b.trim().isNotEmpty).toList();

  List<String> get displayAchievements {
    if (achievements.isNotEmpty) {
      return achievements.where((b) => b.trim().isNotEmpty).toList();
    }
    if (bullets.isNotEmpty) {
      return bullets.where((b) => b.trim().isNotEmpty).toList();
    }
    if (description.trim().isEmpty) return const [];
    return description
        .split('\n')
        .map((l) => l.replaceFirst(RegExp(r'^[\s•\-*]+\s*'), '').trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }

  /// @deprecated use [displayAchievements]
  List<String> get displayBullets => displayAchievements;

  String? get dateValidationError {
    if (startDate == null) return null;
    final effectiveEnd = isCurrent ? DateTime.now() : endDate;
    if (effectiveEnd == null) return null;
    if (startDate!.isAfter(effectiveEnd)) {
      return 'Start date must be before end date (or today if current role).';
    }
    return null;
  }

  String get dateRangeLabel {
    final fmt = DateFormat('MMM yyyy');
    final start = startDate == null ? '' : fmt.format(startDate!);
    final end = isCurrent
        ? 'Present'
        : (endDate == null ? '' : fmt.format(endDate!));
    if (start.isEmpty && end.isEmpty) return '';
    if (start.isEmpty) return end;
    if (end.isEmpty) return start;
    return '$start - $end';
  }

  CvExperience copyWith({
    String? jobTitle,
    String? employer,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrent,
    List<String>? responsibilities,
    List<String>? achievements,
    List<String>? bullets,
    String? description,
    bool? includeSalary,
    bool clearEndDate = false,
  }) {
    return CvExperience(
      jobTitle: jobTitle ?? this.jobTitle,
      employer: employer ?? this.employer,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      isCurrent: isCurrent ?? this.isCurrent,
      responsibilities: responsibilities ?? this.responsibilities,
      achievements: achievements ?? this.achievements,
      bullets: bullets ?? this.bullets,
      description: description ?? this.description,
      includeSalary: includeSalary ?? this.includeSalary,
    );
  }

  Map<String, dynamic> toJson() => {
        'jobTitle': jobTitle,
        'employer': employer,
        'location': location,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'isCurrent': isCurrent,
        'responsibilities': responsibilities,
        'achievements': achievements,
        'bullets': bullets,
        'description': description,
        'includeSalary': includeSalary,
      };

  factory CvExperience.fromJson(Map<String, dynamic> json) {
    final rawResp = (json['responsibilities'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];
    final rawAch = (json['achievements'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];
    final rawBullets = (json['bullets'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];
    final legacyDescription = json['description'] as String? ?? '';
    final achievements = rawAch.isNotEmpty
        ? rawAch
        : (rawBullets.isNotEmpty ? rawBullets : const <String>[]);
    return CvExperience(
      jobTitle: json['jobTitle'] as String? ?? '',
      employer: json['employer'] as String? ?? '',
      location: json['location'] as String? ?? '',
      startDate: DateTime.tryParse(json['startDate'] as String? ?? ''),
      endDate: DateTime.tryParse(json['endDate'] as String? ?? ''),
      isCurrent: json['isCurrent'] as bool? ?? false,
      responsibilities: rawResp,
      achievements: achievements,
      bullets: rawBullets,
      description: legacyDescription,
      includeSalary: json['includeSalary'] as bool? ?? false,
    );
  }
}

class CvEducation {
  const CvEducation({
    this.institution = '',
    this.institutionLocation = '',
    this.qualification = '',
    this.year = '',
    this.graduationDate,
    this.showGraduationYear = true,
  });

  final String institution;
  final String institutionLocation;
  final String qualification;
  final String year;
  final DateTime? graduationDate;
  final bool showGraduationYear;

  String get graduationLabel {
    if (graduationDate != null) {
      return DateFormat('MMM yyyy').format(graduationDate!);
    }
    return year;
  }

  CvEducation copyWith({
    String? institution,
    String? institutionLocation,
    String? qualification,
    String? year,
    DateTime? graduationDate,
    bool? showGraduationYear,
    bool clearGraduationDate = false,
  }) {
    return CvEducation(
      institution: institution ?? this.institution,
      institutionLocation: institutionLocation ?? this.institutionLocation,
      qualification: qualification ?? this.qualification,
      year: year ?? this.year,
      graduationDate:
          clearGraduationDate ? null : (graduationDate ?? this.graduationDate),
      showGraduationYear: showGraduationYear ?? this.showGraduationYear,
    );
  }

  Map<String, dynamic> toJson() => {
        'institution': institution,
        'institutionLocation': institutionLocation,
        'qualification': qualification,
        'year': year,
        'graduationDate': graduationDate?.toIso8601String(),
        'showGraduationYear': showGraduationYear,
      };

  factory CvEducation.fromJson(Map<String, dynamic> json) {
    final gradDate = DateTime.tryParse(json['graduationDate'] as String? ?? '');
    return CvEducation(
      institution: json['institution'] as String? ?? '',
      institutionLocation: json['institutionLocation'] as String? ?? '',
      qualification: json['qualification'] as String? ?? '',
      year: json['year'] as String? ?? '',
      graduationDate: gradDate,
      showGraduationYear: json['showGraduationYear'] as bool? ?? true,
    );
  }
}

class CvSkills {
  const CvSkills({
    this.hardSkills = const [],
    this.toolsSoftware = const [],
    this.softSkills = const [],
  });

  final List<String> hardSkills;
  final List<String> toolsSoftware;
  final List<String> softSkills;

  CvSkills copyWith({
    List<String>? hardSkills,
    List<String>? toolsSoftware,
    List<String>? softSkills,
  }) {
    return CvSkills(
      hardSkills: hardSkills ?? this.hardSkills,
      toolsSoftware: toolsSoftware ?? this.toolsSoftware,
      softSkills: softSkills ?? this.softSkills,
    );
  }

  Map<String, dynamic> toJson() => {
        'hardSkills': hardSkills,
        'toolsSoftware': toolsSoftware,
        'softSkills': softSkills,
      };

  factory CvSkills.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CvSkills();
    return CvSkills(
      hardSkills: (json['hardSkills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      toolsSoftware: (json['toolsSoftware'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      softSkills: (json['softSkills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  /// Migrate legacy flat skills list into hard skills.
  factory CvSkills.fromLegacyList(List<String> legacy) {
    return CvSkills(hardSkills: legacy);
  }
}

class CvCertification {
  const CvCertification({
    this.name = '',
    this.issuer = '',
    this.year = '',
    this.issueDate,
  });

  final String name;
  final String issuer;
  final String year;
  final DateTime? issueDate;

  String get dateLabel {
    if (issueDate != null) return DateFormat('MMM yyyy').format(issueDate!);
    return year;
  }

  CvCertification copyWith({
    String? name,
    String? issuer,
    String? year,
    DateTime? issueDate,
    bool clearIssueDate = false,
  }) {
    return CvCertification(
      name: name ?? this.name,
      issuer: issuer ?? this.issuer,
      year: year ?? this.year,
      issueDate: clearIssueDate ? null : (issueDate ?? this.issueDate),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'issuer': issuer,
        'year': year,
        'issueDate': issueDate?.toIso8601String(),
      };

  factory CvCertification.fromJson(Map<String, dynamic> json) {
    return CvCertification(
      name: json['name'] as String? ?? '',
      issuer: json['issuer'] as String? ?? '',
      year: json['year'] as String? ?? '',
      issueDate: DateTime.tryParse(json['issueDate'] as String? ?? ''),
    );
  }
}

class CvProject {
  const CvProject({
    this.title = '',
    this.description = '',
    this.url = '',
  });

  final String title;
  final String description;
  final String url;

  CvProject copyWith({String? title, String? description, String? url}) {
    return CvProject(
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'url': url,
      };

  factory CvProject.fromJson(Map<String, dynamic> json) {
    return CvProject(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
}

class CvLanguageEntry {
  const CvLanguageEntry({
    this.language = '',
    this.proficiency = '',
  });

  final String language;
  final String proficiency;

  CvLanguageEntry copyWith({String? language, String? proficiency}) {
    return CvLanguageEntry(
      language: language ?? this.language,
      proficiency: proficiency ?? this.proficiency,
    );
  }

  Map<String, dynamic> toJson() => {
        'language': language,
        'proficiency': proficiency,
      };

  factory CvLanguageEntry.fromJson(Map<String, dynamic> json) {
    return CvLanguageEntry(
      language: json['language'] as String? ?? '',
      proficiency: json['proficiency'] as String? ?? '',
    );
  }
}

class CvDocument {
  const CvDocument({
    required this.id,
    this.title = 'My CV',
    this.templateId = CvTemplateId.modern,
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.linkedInUrl = '',
    this.nationality = '',
    this.languageEntries = const [],
    this.professionalSummary = '',
    this.summaryFormat = CvSummaryFormat.paragraph,
    this.skills = const CvSkills(),
    this.experience = const [],
    this.education = const [],
    this.certifications = const [],
    this.projects = const [],
    this.photoLocalPath,
    this.photoStorageUrl,
    this.aiAssistCounts = const {},
    this.totalAiAssistCalls = 0,
    this.vaultDocumentId,
    this.isRtl = false,
    this.updatedAt,
  });

  static const maxAiAssistPerField = 2;
  static const maxAiAssistTotal = 8;

  final String id;
  final String title;
  final CvTemplateId templateId;
  final String fullName;
  final String email;
  final String phone;
  final String location;
  final String linkedInUrl;
  /// Legacy — mapped to [location] when empty on load.
  final String nationality;
  final List<CvLanguageEntry> languageEntries;
  final String professionalSummary;
  final CvSummaryFormat summaryFormat;
  final CvSkills skills;
  final List<CvExperience> experience;
  final List<CvEducation> education;
  final List<CvCertification> certifications;
  final List<CvProject> projects;
  /// Per-CV optional photo (local path); not the global profile avatar.
  final String? photoLocalPath;
  final String? photoStorageUrl;
  final Map<String, int> aiAssistCounts;
  final int totalAiAssistCalls;
  final String? vaultDocumentId;
  final bool isRtl;
  final DateTime? updatedAt;

  int assistCountFor(String fieldId) => aiAssistCounts[fieldId] ?? 0;

  bool canAssistField(String fieldId) =>
      totalAiAssistCalls < maxAiAssistTotal &&
      assistCountFor(fieldId) < maxAiAssistPerField;

  List<String> get summaryBulletLines {
    if (summaryFormat != CvSummaryFormat.bullets) return const [];
    return professionalSummary
        .split('\n')
        .map((l) => l.replaceFirst(RegExp(r'^[\s•\-*]+\s*'), '').trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }

  CvDocument copyWith({
    String? title,
    CvTemplateId? templateId,
    String? fullName,
    String? email,
    String? phone,
    String? location,
    String? linkedInUrl,
    String? nationality,
    List<CvLanguageEntry>? languageEntries,
    String? professionalSummary,
    CvSummaryFormat? summaryFormat,
    CvSkills? skills,
    List<CvExperience>? experience,
    List<CvEducation>? education,
    List<CvCertification>? certifications,
    List<CvProject>? projects,
    String? photoLocalPath,
    String? photoStorageUrl,
    bool clearPhotoLocalPath = false,
    bool clearPhotoStorageUrl = false,
    Map<String, int>? aiAssistCounts,
    int? totalAiAssistCalls,
    String? vaultDocumentId,
    bool? isRtl,
    DateTime? updatedAt,
  }) {
    return CvDocument(
      id: id,
      title: title ?? this.title,
      templateId: templateId ?? this.templateId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      linkedInUrl: linkedInUrl ?? this.linkedInUrl,
      nationality: nationality ?? this.nationality,
      languageEntries: languageEntries ?? this.languageEntries,
      professionalSummary: professionalSummary ?? this.professionalSummary,
      summaryFormat: summaryFormat ?? this.summaryFormat,
      skills: skills ?? this.skills,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      certifications: certifications ?? this.certifications,
      projects: projects ?? this.projects,
      photoLocalPath: clearPhotoLocalPath
          ? null
          : (photoLocalPath != null && photoLocalPath.isEmpty
              ? null
              : (photoLocalPath ?? this.photoLocalPath)),
      photoStorageUrl: clearPhotoStorageUrl
          ? null
          : (photoStorageUrl ?? this.photoStorageUrl),
      aiAssistCounts: aiAssistCounts ?? this.aiAssistCounts,
      totalAiAssistCalls: totalAiAssistCalls ?? this.totalAiAssistCalls,
      vaultDocumentId: vaultDocumentId ?? this.vaultDocumentId,
      isRtl: isRtl ?? this.isRtl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'templateId': templateId.name,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'location': location,
        'linkedInUrl': linkedInUrl,
        'nationality': nationality,
        'languageEntries':
            languageEntries.map((e) => e.toJson()).toList(),
        'professionalSummary': professionalSummary,
        'summaryFormat': summaryFormat.name,
        'skills': skills.toJson(),
        'experience': experience.map((e) => e.toJson()).toList(),
        'education': education.map((e) => e.toJson()).toList(),
        'certifications': certifications.map((c) => c.toJson()).toList(),
        'projects': projects.map((p) => p.toJson()).toList(),
        'photoLocalPath': photoLocalPath,
        'photoStorageUrl': photoStorageUrl,
        'aiAssistCounts': aiAssistCounts,
        'totalAiAssistCalls': totalAiAssistCalls,
        'vaultDocumentId': vaultDocumentId,
        'isRtl': isRtl,
        'updatedAt': (updatedAt ?? DateTime.now()).toIso8601String(),
      };

  factory CvDocument.fromJson(Map<String, dynamic> json) {
    final legacySkills = (json['skills'] is List)
        ? (json['skills'] as List<dynamic>).map((e) => e.toString()).toList()
        : null;

    final skills = json['skills'] is Map<String, dynamic>
        ? CvSkills.fromJson(json['skills'] as Map<String, dynamic>)
        : CvSkills.fromLegacyList(legacySkills ?? const []);

    final legacyLanguages = (json['languages'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .where((l) => l.isNotEmpty)
            .toList() ??
        const [];
    final languageEntries = (json['languageEntries'] as List<dynamic>?)
            ?.map((e) => CvLanguageEntry.fromJson(e as Map<String, dynamic>))
            .toList() ??
        legacyLanguages
            .map((l) => CvLanguageEntry(language: l))
            .toList();

    var location = json['location'] as String? ?? '';
    final nationality = json['nationality'] as String? ?? '';
    if (location.isEmpty && nationality.isNotEmpty) {
      location = nationality;
    }

    return CvDocument(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'My CV',
      templateId: CvTemplateCatalog.parseStoredId(json['templateId'] as String?),
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      location: location,
      linkedInUrl: json['linkedInUrl'] as String? ?? '',
      nationality: nationality,
      languageEntries: languageEntries,
      professionalSummary: json['professionalSummary'] as String? ?? '',
      summaryFormat: CvSummaryFormat.values.firstWhere(
        (v) => v.name == json['summaryFormat'],
        orElse: () => CvSummaryFormat.paragraph,
      ),
      skills: skills,
      experience: (json['experience'] as List<dynamic>?)
              ?.map((e) => CvExperience.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      education: (json['education'] as List<dynamic>?)
              ?.map((e) => CvEducation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      certifications: (json['certifications'] as List<dynamic>?)
              ?.map((e) => CvCertification.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      projects: (json['projects'] as List<dynamic>?)
              ?.map((e) => CvProject.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      photoLocalPath: json['photoLocalPath'] as String?,
      photoStorageUrl: json['photoStorageUrl'] as String?,
      aiAssistCounts: Map<String, int>.from(
        (json['aiAssistCounts'] as Map<dynamic, dynamic>? ?? {}).map(
          (k, v) => MapEntry(k.toString(), (v as num).toInt()),
        ),
      ),
      totalAiAssistCalls: (json['totalAiAssistCalls'] as num?)?.toInt() ?? 0,
      vaultDocumentId: json['vaultDocumentId'] as String?,
      isRtl: json['isRtl'] as bool? ?? false,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }
}
