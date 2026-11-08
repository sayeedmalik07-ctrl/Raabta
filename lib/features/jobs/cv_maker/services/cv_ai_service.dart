import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';
import 'package:raabta/features/jobs/cv_maker/domain/models/cv_document.dart';

class CvAiAssistResult {
  const CvAiAssistResult({
    required this.success,
    this.options = const [],
    this.error,
    this.fieldCount = 0,
    this.totalAiAssistCalls = 0,
    this.model,
    this.cached = false,
  });

  final bool success;
  final List<String> options;
  final String? error;
  final int fieldCount;
  final int totalAiAssistCalls;
  final String? model;
  final bool cached;

  bool get fieldLimitReached => error == 'field_limit';
  bool get totalLimitReached => error == 'total_limit';
}

/// Routes CV phrasing through backend /api/cv/ai-assist (Haiku-class, capped).
class CvAiService {
  final Map<String, Future<CvAiAssistResult>> _inFlight = {};

  String _requestKey({
    required String cvId,
    required String fieldId,
    required String roughInput,
    required String language,
  }) {
    final normalized = roughInput.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
    return '$cvId|$fieldId|$language|$normalized';
  }

  Future<CvAiAssistResult> assistField({
    required String cvId,
    required String fieldId,
    required String roughInput,
    required Map<String, dynamic> contextFacts,
    String language = 'English',
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const CvAiAssistResult(success: false, error: 'not_signed_in');
    }

    final key = _requestKey(
      cvId: cvId,
      fieldId: fieldId,
      roughInput: roughInput,
      language: language,
    );
    final existing = _inFlight[key];
    if (existing != null) {
      return existing;
    }

    final task = _assistFieldInternal(
      uid: uid,
      cvId: cvId,
      fieldId: fieldId,
      roughInput: roughInput,
      contextFacts: contextFacts,
      language: language,
    );
    _inFlight[key] = task;
    try {
      return await task;
    } finally {
      _inFlight.remove(key);
    }
  }

  Future<CvAiAssistResult> _assistFieldInternal({
    required String uid,
    required String cvId,
    required String fieldId,
    required String roughInput,
    required Map<String, dynamic> contextFacts,
    required String language,
  }) async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) {
        return const CvAiAssistResult(success: false, error: 'not_signed_in');
      }

      final response = await http
          .post(
            Uri.parse('${AppConfig.backendUrl}/api/cv/ai-assist'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'userId': uid,
              'cvId': cvId,
              'fieldId': fieldId,
              'roughInput': roughInput,
              'contextFacts': contextFacts,
              'language': language,
            }),
          )
          .timeout(Duration(seconds: AppConfig.aiRequestTimeout));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200 || data['success'] != true) {
        return CvAiAssistResult(
          success: false,
          error: data['error'] as String? ?? 'request_failed',
          fieldCount: (data['fieldCount'] as num?)?.toInt() ?? 0,
          totalAiAssistCalls: (data['totalAiAssistCalls'] as num?)?.toInt() ?? 0,
        );
      }

      return CvAiAssistResult(
        success: true,
        options: (data['options'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        fieldCount: (data['fieldCount'] as num?)?.toInt() ?? 0,
        totalAiAssistCalls: (data['totalAiAssistCalls'] as num?)?.toInt() ?? 0,
        model: data['model'] as String?,
        cached: data['cached'] == true,
      );
    } catch (e) {
      debugPrint('[CvAiService] assist failed: $e');
      return const CvAiAssistResult(success: false, error: 'network_error');
    }
  }

  Map<String, dynamic> contextForSummary(CvDocument cv) => {
        'profession': cv.experience.firstOrNull?.jobTitle ?? '',
        'yearsHint': cv.experience.length,
        'skills': [
          ...cv.skills.hardSkills,
          ...cv.skills.toolsSoftware,
        ].take(8).join(', '),
      };

  Map<String, dynamic> contextForExperience(
    CvExperience exp, {
    String fieldKind = 'achievements',
  }) => {
        'jobTitle': exp.jobTitle,
        'employer': exp.employer,
        'location': exp.location,
        'startDate': exp.startDate?.toIso8601String(),
        'endDate': exp.endDate?.toIso8601String(),
        'isCurrent': exp.isCurrent,
        'fieldKind': fieldKind,
        'responsibilities': exp.displayResponsibilities,
        'achievements': exp.displayAchievements,
      };

  Map<String, dynamic> contextForSkills(CvDocument cv) => {
        'hardSkills': cv.skills.hardSkills.join(', '),
        'toolsSoftware': cv.skills.toolsSoftware.join(', '),
        'profession': cv.experience.firstOrNull?.jobTitle ?? '',
      };
}

final cvAiServiceProvider = Provider((ref) => CvAiService());
