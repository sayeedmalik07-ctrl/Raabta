/// Shared checklist row shape — mirrors Tenancy/Sponsorship catalog defs.
class CaseTimelineChecklistItemDef {
  const CaseTimelineChecklistItemDef({
    required this.id,
    required this.titleKey,
    this.subtitleKey,
    this.optional = false,
    this.informal = false,
  });

  final String id;
  final String titleKey;
  final String? subtitleKey;
  final bool optional;
  final bool informal;
}
