import 'package:raabta/data/qatar_health_insurance_kb.dart';
import 'package:raabta/data/qatar_labour_law_kb.dart';
import 'package:raabta/data/raabta_resident_knowledge.dart';

/// Reuses existing KB topic detectors — no parallel legal-NLP stack.
abstract final class LegalGuidanceClassifier {
  /// Resident topics that imply law, regulation, or official government process.
  static const _regulatoryResidentTopics = {
    'qid',
    'family_sponsorship',
    'sponsorship_transfer',
    'housing_tenancy',
    'outdoor_work_heat',
    'traffic',
  };

  /// True when the assistant should append the general legal disclaimer.
  static bool requiresDisclaimer(String message) {
    if (message.trim().isEmpty) return false;

    if (QatarLabourLawKB.isLabourQuery(message)) return true;
    if (QatarLabourLawKB.detectLabourTopics(message).isNotEmpty) return true;
    if (QatarHealthInsuranceKB.isHealthInsuranceQuery(message)) return true;

    final residentTopics = RaabtaResidentKnowledge.detectTopics(message);
    if (residentTopics.any(_regulatoryResidentTopics.contains)) return true;

    return false;
  }
}
