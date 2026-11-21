import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/jobs/cv_maker/domain/models/cv_document.dart';
import 'package:raabta/features/quick_actions/scanner/services/scanner_ocr_service.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';

/// Reference resume import — OCR (ScannerOcrService) + Claude structured extraction.
class CvImportService {
  CvImportService(this._claude, this._ocr);

  final ClaudeAIService _claude;
  final ScannerOcrService _ocr;

  static const _schema = '''
Return ONLY valid JSON (no markdown). Extract ONLY what appears in the document — use null or empty arrays for missing fields. Never invent employers, dates, metrics, or qualifications.
{
  "fullName": "string or null",
  "email": "string or null",
  "phone": "string or null",
  "location": "string or null",
  "linkedInUrl": "string or null",
  "professionalSummary": "string or null",
  "summaryFormat": "paragraph or bullets",
  "hardSkills": ["string"],
  "toolsSoftware": ["string"],
  "softSkills": ["string"],
  "experience": [{
    "jobTitle": "string",
    "employer": "string",
    "location": "string or null",
    "startDate": "YYYY-MM or null",
    "endDate": "YYYY-MM or null",
    "isCurrent": boolean,
    "responsibilities": ["string"],
    "achievements": ["string"]
  }],
  "education": [{
    "qualification": "string",
    "institution": "string",
    "institutionLocation": "string or null",
    "graduationDate": "YYYY-MM or null",
    "showGraduationYear": boolean
  }],
  "certifications": [{"name":"string","issuer":"string or null","issueDate":"YYYY-MM or null"}],
  "projects": [{"title":"string","description":"string or null","url":"string or null"}],
  "languages": [{"language":"string","proficiency":"string or null"}],
  "confidence": 0.0-1.0
}''';

  Future<CvDocument> extractFromImagePaths({
    required List<String> imagePaths,
    required String cvId,
  }) async {
    final ocrText = await _ocr.extractFromPaths(imagePaths);
    if (ocrText.trim().isEmpty) {
      throw CvImportException('Could not read text from the image.');
    }
    return extractFromOcrText(ocrText: ocrText, cvId: cvId);
  }

  Future<CvDocument> extractFromOcrText({
    required String ocrText,
    required String cvId,
  }) async {
    final prompt = '''
You extract structured CV/resume fields from OCR text for a Qatar job seeker.
Rules: output JSON only; never fabricate; leave unknown fields null/empty; do not add metrics not in the source.

OCR text:
---
$ocrText
---

$_schema''';

    final raw = await _claude.sendMessage(
      prompt,
      requestType: 'cv_reference_import',
    );
    if (raw.trim().isEmpty) {
      throw CvImportException('AI could not extract CV fields. Try clearer photos.');
    }
    final json = _parseJson(raw);
    return _mapToDocument(json, cvId);
  }

  Map<String, dynamic> _parseJson(String raw) {
    var text = raw.trim();
    if (text.startsWith('```')) {
      text = text.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
      text = text.replaceFirst(RegExp(r'\s*```$'), '');
    }
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start >= 0 && end > start) {
      text = text.substring(start, end + 1);
    }
    try {
      return jsonDecode(text) as Map<String, dynamic>;
    } catch (_) {
      throw CvImportException(
        'Could not parse extracted CV data. Try a clearer photo or fewer pages at once.',
      );
    }
  }

  DateTime? _parseYearMonth(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parts = value.trim().split('-');
    if (parts.length >= 2) {
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (y != null && m != null) return DateTime(y, m.clamp(1, 12), 1);
    }
    final yOnly = int.tryParse(value.trim());
    if (yOnly != null) return DateTime(yOnly, 1, 1);
    return null;
  }

  CvDocument _mapToDocument(Map<String, dynamic> json, String cvId) {
    final expList = (json['experience'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((e) {
          final map = Map<String, dynamic>.from(e);
          return CvExperience(
            jobTitle: map['jobTitle'] as String? ?? '',
            employer: map['employer'] as String? ?? '',
            location: map['location'] as String? ?? '',
            startDate: _parseYearMonth(map['startDate'] as String?),
            endDate: _parseYearMonth(map['endDate'] as String?),
            isCurrent: map['isCurrent'] as bool? ?? false,
            responsibilities: (map['responsibilities'] as List<dynamic>?)
                    ?.map((x) => x.toString())
                    .where((s) => s.trim().isNotEmpty)
                    .toList() ??
                const [],
            achievements: (map['achievements'] as List<dynamic>?)
                    ?.map((x) => x.toString())
                    .where((s) => s.trim().isNotEmpty)
                    .toList() ??
                const [],
          );
        })
        .toList();

    return CvDocument(
      id: cvId,
      title: 'Imported CV',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      location: json['location'] as String? ?? '',
      linkedInUrl: json['linkedInUrl'] as String? ?? '',
      professionalSummary: json['professionalSummary'] as String? ?? '',
      summaryFormat: json['summaryFormat'] == 'bullets'
          ? CvSummaryFormat.bullets
          : CvSummaryFormat.paragraph,
      skills: CvSkills(
        hardSkills: (json['hardSkills'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .where((s) => s.trim().isNotEmpty)
                .toList() ??
            const [],
        toolsSoftware: (json['toolsSoftware'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .where((s) => s.trim().isNotEmpty)
                .toList() ??
            const [],
        softSkills: (json['softSkills'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .where((s) => s.trim().isNotEmpty)
                .toList() ??
            const [],
      ),
      experience: expList,
      education: (json['education'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((e) {
            final map = Map<String, dynamic>.from(e);
            final grad = _parseYearMonth(map['graduationDate'] as String?);
            return CvEducation(
              qualification: map['qualification'] as String? ?? '',
              institution: map['institution'] as String? ?? '',
              institutionLocation: map['institutionLocation'] as String? ?? '',
              graduationDate: grad,
              year: grad != null ? '${grad.year}' : '',
              showGraduationYear: map['showGraduationYear'] as bool? ?? true,
            );
          })
          .toList(),
      certifications: (json['certifications'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((e) {
            final map = Map<String, dynamic>.from(e);
            final d = _parseYearMonth(map['issueDate'] as String?);
            return CvCertification(
              name: map['name'] as String? ?? '',
              issuer: map['issuer'] as String? ?? '',
              issueDate: d,
              year: d != null ? '${d.year}' : '',
            );
          })
          .toList(),
      projects: (json['projects'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((e) {
            final map = Map<String, dynamic>.from(e);
            return CvProject(
              title: map['title'] as String? ?? '',
              description: map['description'] as String? ?? '',
              url: map['url'] as String? ?? '',
            );
          })
          .toList(),
      languageEntries: (json['languages'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((e) {
            final map = Map<String, dynamic>.from(e);
            return CvLanguageEntry(
              language: map['language'] as String? ?? '',
              proficiency: map['proficiency'] as String? ?? '',
            );
          })
          .toList(),
      updatedAt: DateTime.now(),
    );
  }
}

class CvImportException implements Exception {
  CvImportException(this.message);
  final String message;
  @override
  String toString() => message;
}

final cvImportServiceProvider = Provider((ref) {
  return CvImportService(
    ref.watch(claudeAIServiceProvider),
    ref.watch(scannerOcrServiceProvider),
  );
});
