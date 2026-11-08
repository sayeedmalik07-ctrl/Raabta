import 'package:raabta/features/home/utils/expat_score_profile_helper.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

/// Approved progressive capture fields in display order.
enum ProgressiveProfileField {
  profession,
  nationality,
  preferredArea,
}

/// Pure step-resolution logic for the progressive profile capture flow.
abstract final class ProgressiveProfileFlow {
  ProgressiveProfileFlow._();

  static const totalSteps = 3;

  static const _order = [
    ProgressiveProfileField.profession,
    ProgressiveProfileField.nationality,
    ProgressiveProfileField.preferredArea,
  ];

  static bool isFlowComplete(UserAIProfile profile) {
    return !ExpatScoreProfileHelper.isProfileIncomplete(profile);
  }

  static List<ProgressiveProfileField> incompleteFields(UserAIProfile profile) {
    final fields = <ProgressiveProfileField>[];
    if (profile.profession.trim().isEmpty) {
      fields.add(ProgressiveProfileField.profession);
    }
    if (profile.nationality.trim().isEmpty) {
      fields.add(ProgressiveProfileField.nationality);
    }
    if (profile.preferredArea.trim().isEmpty) {
      fields.add(ProgressiveProfileField.preferredArea);
    }
    return fields;
  }

  static ProgressiveProfileField? firstIncompleteField(UserAIProfile profile) {
    final fields = incompleteFields(profile);
    return fields.isEmpty ? null : fields.first;
  }

  static int stepNumberFor(ProgressiveProfileField field) {
    return switch (field) {
      ProgressiveProfileField.profession => 1,
      ProgressiveProfileField.nationality => 2,
      ProgressiveProfileField.preferredArea => 3,
    };
  }

  static String fieldValue(UserAIProfile profile, ProgressiveProfileField field) {
    return switch (field) {
      ProgressiveProfileField.profession => profile.profession,
      ProgressiveProfileField.nationality => profile.nationality,
      ProgressiveProfileField.preferredArea => profile.preferredArea,
    };
  }

  /// Next incomplete field after [current], or null when the flow is finished.
  static ProgressiveProfileField? nextIncompleteAfter(
    ProgressiveProfileField current,
    UserAIProfile profile,
  ) {
    final start = _order.indexOf(current) + 1;
    for (var i = start; i < _order.length; i++) {
      final field = _order[i];
      if (fieldValue(profile, field).trim().isEmpty) {
        return field;
      }
    }
    return null;
  }

  /// Previous field in canonical order (for back navigation within the flow).
  static ProgressiveProfileField? previousField(ProgressiveProfileField current) {
    final index = _order.indexOf(current);
    if (index <= 0) return null;
    return _order[index - 1];
  }
}
