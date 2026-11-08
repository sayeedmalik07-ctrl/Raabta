import 'package:raabta/features/global_search/domain/search_personalization_signal.dart';

/// Local personalization inputs for Global Search ranking (S10).
///
/// Built from existing profile + recent searches only — no sensitive inference.
class SearchPersonalizationContext {
  const SearchPersonalizationContext({
    this.schemaVersion = schemaVersionCurrent,
    this.enabled = false,
    this.preferredArea = '',
    this.explicitProfession = '',
    this.explicitSkills = const [],
    this.explicitServiceTrades = const [],
    this.explicitJobCategories = const [],
    this.explicitPropertyTypes = const [],
    this.categoryInterests = const [],
    this.savedJobIds = const {},
    this.savedHousingIds = const {},
    this.savedBusinessIds = const {},
    this.recentSearchSignals = const [],
  });

  static const schemaVersionCurrent = 1;

  final int schemaVersion;
  final bool enabled;
  final String preferredArea;
  final String explicitProfession;
  final List<String> explicitSkills;
  final List<String> explicitServiceTrades;
  final List<String> explicitJobCategories;
  final List<String> explicitPropertyTypes;
  final List<String> categoryInterests;
  final Set<String> savedJobIds;
  final Set<String> savedHousingIds;
  final Set<String> savedBusinessIds;
  final List<SearchRecentSearchSignal> recentSearchSignals;

  static const neutral = SearchPersonalizationContext();

  bool get isActive => enabled;
}
