import 'package:raabta/services/drafts/draftable_form.dart';

/// Dev/admin check: surfaces multi-field forms missing draft protection.
abstract final class DraftCoverageChecker {
  /// Returns catalog entries not marked [DraftableFormDescriptor.isProtected].
  static List<DraftableFormDescriptor> findUnprotectedForms() =>
      DraftableFormRegistry.findUnprotectedForms();

  static bool get isFullyProtected => DraftableFormRegistry.isFullyProtected;
}
