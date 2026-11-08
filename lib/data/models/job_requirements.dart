/// Structured job requirements — captured in posting flow and shown on listings.
class JobRequirementsSpec {
  const JobRequirementsSpec({
    this.requiredSkills = const [],
    this.minimumExperience = '',
    this.qualifications = const [],
    this.languageRequirements = const [],
  });

  final List<String> requiredSkills;
  final String minimumExperience;
  final List<String> qualifications;
  final List<String> languageRequirements;

  bool get isSpecified =>
      requiredSkills.isNotEmpty ||
      minimumExperience.trim().isNotEmpty ||
      qualifications.isNotEmpty ||
      languageRequirements.isNotEmpty;

  /// Flat list for legacy matching / search (JobMatchService reads `requirements`).
  List<String> toMatchList() {
    final lines = <String>[];
    lines.addAll(requiredSkills);
    if (minimumExperience.trim().isNotEmpty) {
      lines.add(minimumExperience.trim());
    }
    lines.addAll(qualifications);
    lines.addAll(languageRequirements);
    return lines;
  }

  factory JobRequirementsSpec.fromFirestore(Map<String, dynamic> data) {
    List<String> parseList(dynamic raw) {
      if (raw is! List) return const [];
      return raw.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
    }

    return JobRequirementsSpec(
      requiredSkills: parseList(data['requiredSkills']),
      minimumExperience: data['minimumExperience'] as String? ?? '',
      qualifications: parseList(data['qualifications']),
      languageRequirements: parseList(data['languageRequirements']),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'requiredSkills': requiredSkills,
        'minimumExperience': minimumExperience.trim(),
        'qualifications': qualifications,
        'languageRequirements': languageRequirements,
        'requirements': toMatchList(),
      };

  static List<String> parseCommaSeparated(String raw) {
    return raw
        .split(RegExp(r'[,;\n]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
}
