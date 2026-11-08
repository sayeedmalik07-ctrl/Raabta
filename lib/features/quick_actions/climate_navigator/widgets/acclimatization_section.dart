import 'package:flutter/material.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/features/quick_actions/climate_navigator/l10n/climate_strings.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/climate_acclimatization_preferences.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/acclimatization_entry_card.dart';

/// Heat adaptation block — header + card; hidden when outdoor eligibility is No.
class AcclimatizationSection extends StatefulWidget {
  const AcclimatizationSection({
    super.key,
    required this.locale,
    this.fetchConciergeArrivalDate,
    this.onOpenHeatGuide,
  });

  final String locale;
  final Future<DateTime?> Function()? fetchConciergeArrivalDate;
  final VoidCallback? onOpenHeatGuide;

  @override
  State<AcclimatizationSection> createState() => _AcclimatizationSectionState();
}

class _AcclimatizationSectionState extends State<AcclimatizationSection> {
  bool _hideSection = false;
  bool _checkingOutdoor = true;

  @override
  void initState() {
    super.initState();
    _refreshSectionVisibility();
  }

  Future<void> _refreshSectionVisibility() async {
    try {
      final prefs = await ClimateAcclimatizationPreferences.load();
      if (!mounted) return;
      setState(() {
        _hideSection = prefs.shouldHideAcclimatizationSection;
        _checkingOutdoor = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _checkingOutdoor = false);
      }
    }
  }

  void _onOutdoorIneligible() {
    setState(() => _hideSection = true);
  }

  void _onClearedPlan() {
    setState(() => _hideSection = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingOutdoor) {
      return const SizedBox.shrink();
    }
    if (_hideSection) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeSectionHeader(
          overline: ClimateStrings.t('section_acclimat_overline', widget.locale),
          title: ClimateStrings.t('section_acclimat_title', widget.locale),
        ),
        const SizedBox(height: AppSpacing.md),
        AcclimatizationEntryCard(
          locale: widget.locale,
          fetchConciergeArrivalDate: widget.fetchConciergeArrivalDate,
          onOpenHeatGuide: widget.onOpenHeatGuide,
          onOutdoorIneligible: _onOutdoorIneligible,
          onPlanCleared: _onClearedPlan,
        ),
      ],
    );
  }
}
