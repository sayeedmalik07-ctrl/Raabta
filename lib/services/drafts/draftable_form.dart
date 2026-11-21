/// Contract for a multi-field form that opts into local draft protection.
///
/// Forms register via [DraftableFormRegistry.register] — see `DRAFT_PROTECTION.md`.
/// Runtime wiring is confirmed when [DraftPersistenceMixin.setupDraftPersistence]
/// or [DraftAwareSheet] calls [DraftableFormRegistry.markActive].
class DraftableFormDescriptor {
  const DraftableFormDescriptor({
    required this.formId,
    required this.label,
    required this.entryRoute,
    this.isProtected = false,
    this.isDynamicKey = false,
  });

  /// Stable Hive draft key (see [DraftBoxKeys]).
  final String formId;

  /// Human-readable label for admin/dev coverage UI.
  final String label;

  /// GoRouter path or screen entry where the form lives.
  final String entryRoute;

  /// Whether draft mixin/sheet is wired for this form.
  final bool isProtected;

  /// True when formId includes dynamic suffixes (e.g. per-date, per-group).
  final bool isDynamicKey;
}

/// Central catalog of forms expected to have draft protection.
class DraftableFormRegistry {
  DraftableFormRegistry._();

  static final Map<String, DraftableFormDescriptor> _catalog = {};
  static final Set<String> _activeFormIds = {};

  static List<DraftableFormDescriptor> get catalog =>
      List.unmodifiable(_catalog.values);

  static void register(DraftableFormDescriptor descriptor) {
    _catalog[descriptor.formId] = descriptor;
  }

  /// Called by mixin/sheet when a form initializes draft persistence.
  static void markActive(String formId) {
    _activeFormIds.add(formId);
    final existing = _catalog[formId];
    if (existing != null) {
      _catalog[formId] = DraftableFormDescriptor(
        formId: existing.formId,
        label: existing.label,
        entryRoute: existing.entryRoute,
        isProtected: true,
        isDynamicKey: existing.isDynamicKey,
      );
    }
  }

  static void resetForTests() {
    _catalog.clear();
    _activeFormIds.clear();
  }

  /// Forms in catalog marked unprotected (for admin/dev check).
  static List<DraftableFormDescriptor> findUnprotectedForms() {
    return _catalog.values
        .where((d) => !d.isProtected && !d.isDynamicKey)
        .toList()
      ..sort((a, b) => a.label.compareTo(b.label));
  }

  static bool get isFullyProtected => findUnprotectedForms().isEmpty;
}
