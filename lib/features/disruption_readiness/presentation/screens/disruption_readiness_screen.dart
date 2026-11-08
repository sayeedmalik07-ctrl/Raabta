import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/disruption_readiness/data/disruption_readiness_catalog.dart';
import 'package:raabta/features/disruption_readiness/data/disruption_readiness_models.dart';
import 'package:raabta/features/disruption_readiness/domain/disruption_go_bag_service.dart';
import 'package:raabta/features/disruption_readiness/presentation/l10n/disruption_readiness_strings.dart';
import 'package:raabta/features/disruption_readiness/providers/disruption_readiness_providers.dart';
import 'package:raabta/features/disruption_readiness/presentation/screens/disruption_understand_alert_screen.dart';
import 'package:raabta/features/disruption_readiness/services/disruption_readiness_analytics.dart';
import 'package:raabta/features/eosb/providers/home_country_support_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:url_launcher/url_launcher.dart';

class DisruptionReadinessScreen extends ConsumerStatefulWidget {
  const DisruptionReadinessScreen({
    super.key,
    required this.profile,
    this.tripId,
  });

  final DisruptionEntryProfile profile;
  final String? tripId;

  static String route({
    required DisruptionEntryProfile profile,
    String? tripId,
  }) {
    final base = switch (profile) {
      DisruptionEntryProfile.leavingQatar => '/disruption-readiness/leaving',
      DisruptionEntryProfile.knowQatar => '/disruption-readiness/know',
      DisruptionEntryProfile.tripPlanner => '/disruption-readiness/trip',
    };
    final id = tripId?.trim();
    if (profile == DisruptionEntryProfile.tripPlanner &&
        id != null &&
        id.isNotEmpty) {
      return '$base?tripId=${Uri.encodeComponent(id)}';
    }
    return base;
  }

  @override
  ConsumerState<DisruptionReadinessScreen> createState() =>
      _DisruptionReadinessScreenState();
}

class _DisruptionReadinessScreenState
    extends ConsumerState<DisruptionReadinessScreen> {
  Map<String, bool> _goBag = {};
  String? _selectedEmbassyCountryId;
  final _airlineController = TextEditingController();

  @override
  void initState() {
    super.initState();
    DisruptionReadinessAnalytics.moduleOpened(
      profile: widget.profile.name,
      tripId: widget.tripId,
    );
    if (_goBagPersistenceReady) {
      _loadGoBag();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final home = ref.read(homeCountryUserContextProvider).valueOrNull;
      final id = home?.nationality.trim().toLowerCase();
      if (id != null && id.isNotEmpty) {
        setState(() => _selectedEmbassyCountryId = _normalizeCountryId(id));
      }
    });
  }

  @override
  void dispose() {
    _airlineController.dispose();
    super.dispose();
  }

  static String _normalizeCountryId(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('india')) return 'india';
    if (lower.contains('nepal')) return 'nepal';
    if (lower.contains('philipp') || lower.contains('filipino')) {
      return 'philippines';
    }
    if (lower.contains('bangladesh') || lower.contains('bengali')) {
      return 'bangladesh';
    }
    if (lower.contains('pakistan')) return 'pakistan';
    if (lower.contains('sri') || lower.contains('lanka')) return 'sri_lanka';
    return lower.replaceAll(' ', '_');
  }

  DisruptionGoBagScope get _goBagScope => switch (widget.profile) {
        DisruptionEntryProfile.tripPlanner => DisruptionGoBagScope.trip,
        DisruptionEntryProfile.leavingQatar => DisruptionGoBagScope.leaving,
        DisruptionEntryProfile.knowQatar => DisruptionGoBagScope.know,
      };

  String? get _effectiveTripId =>
      DisruptionGoBagService.normalizedTripId(widget.tripId);

  bool get _goBagPersistenceReady =>
      widget.profile != DisruptionEntryProfile.tripPlanner ||
      DisruptionGoBagService.tripScopeReady(widget.tripId);

  Future<void> _loadGoBag() async {
    if (!_goBagPersistenceReady) return;
    final service = ref.read(disruptionGoBagServiceProvider);
    final loaded = await service.load(
      scope: _goBagScope,
      tripId: _effectiveTripId,
    );
    if (mounted) setState(() => _goBag = loaded);
  }

  Future<void> _toggleGoBag(String itemId, bool value) async {
    if (!_goBagPersistenceReady) return;
    final service = ref.read(disruptionGoBagServiceProvider);
    await service.setItem(
      scope: _goBagScope,
      tripId: _effectiveTripId,
      itemId: itemId,
      completed: value,
    );
    setState(() => _goBag = {..._goBag, itemId: value});
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _searchAirlineSite() async {
    final name = _airlineController.text.trim();
    if (name.isEmpty) return;
    final query = Uri.encodeComponent('$name airline official website');
    final uri = Uri.parse('https://www.google.com/search?q=$query');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final blocks = DisruptionReadinessCatalog.publishedFor(widget.profile);

    return GlassScreenScaffold(
      title: DisruptionReadinessStrings.t('dr_screen_title', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          Text(
            DisruptionReadinessStrings.t('dr_screen_subtitle', locale),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GlassCard(
            onTap: () =>
                context.push(DisruptionUnderstandAlertScreen.route),
            padding: const EdgeInsets.all(AppSpacing.md),
            glowColor: AppColors.info,
            glowIntensity: 0.12,
            child: Row(
              children: [
                const Icon(Icons.sms_outlined, color: AppColors.info),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DisruptionReadinessStrings.t(
                          'dr_understand_alert_entry_title',
                          locale,
                        ),
                        style: AppTypography.subtitle.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        DisruptionReadinessStrings.t(
                          'dr_understand_alert_entry_body',
                          locale,
                        ),
                        style: AppTypography.bodySmall.copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (widget.profile == DisruptionEntryProfile.tripPlanner &&
              !_goBagPersistenceReady) ...[
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              glowColor: AppColors.warning,
              glowIntensity: 0.1,
              child: Text(
                DisruptionReadinessStrings.t(
                  'dr_trip_checklist_unavailable',
                  locale,
                ),
                style: AppTypography.bodySmall.copyWith(height: 1.45),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          ...blocks.map(
            (block) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _BlockCard(
                block: block,
                locale: locale,
                goBag: _goBag,
                goBagChecklistEnabled: _goBagPersistenceReady,
                onGoBagToggle: _toggleGoBag,
                selectedEmbassyCountryId: _selectedEmbassyCountryId,
                onEmbassyCountrySelected: (id) =>
                    setState(() => _selectedEmbassyCountryId = id),
                airlineController: _airlineController,
                onOpenUrl: _openUrl,
                onSearchAirline: _searchAirlineSite,
                onOpenEmergency: () => context.push('/trip-planner/emergency'),
                onOpenVault: () => context.push('/document-vault'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockCard extends StatelessWidget {
  const _BlockCard({
    required this.block,
    required this.locale,
    required this.goBag,
    required this.goBagChecklistEnabled,
    required this.onGoBagToggle,
    required this.selectedEmbassyCountryId,
    required this.onEmbassyCountrySelected,
    required this.airlineController,
    required this.onOpenUrl,
    required this.onSearchAirline,
    required this.onOpenEmergency,
    required this.onOpenVault,
  });

  final DisruptionContentBlock block;
  final String locale;
  final Map<String, bool> goBag;
  final bool goBagChecklistEnabled;
  final void Function(String itemId, bool value) onGoBagToggle;
  final String? selectedEmbassyCountryId;
  final ValueChanged<String> onEmbassyCountrySelected;
  final TextEditingController airlineController;
  final Future<void> Function(String url) onOpenUrl;
  final VoidCallback onSearchAirline;
  final VoidCallback onOpenEmergency;
  final VoidCallback onOpenVault;

  @override
  Widget build(BuildContext context) {
    final severityColor = block.id == 'live_status_disclaimer'
        ? AppColors.info
        : AppColors.warning;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: severityColor,
      glowIntensity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DisruptionReadinessStrings.t(block.titleKey, locale),
            style: AppTypography.subtitle.copyWith(color: severityColor),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            DisruptionReadinessStrings.t(block.bodyKey, locale),
            style: AppTypography.bodySmall.copyWith(height: 1.45),
          ),
          if (block.id == 'before_airport') ...[
            const SizedBox(height: AppSpacing.md),
            _AirlinePrompt(
              locale: locale,
              controller: airlineController,
              onSearch: onSearchAirline,
            ),
          ],
          if (block.id == 'go_bag' && goBagChecklistEnabled) ...[
            const SizedBox(height: AppSpacing.sm),
            ...DisruptionReadinessCatalog.goBagItemIds.map(
              (id) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: goBag[id] == true,
                onChanged: (v) => onGoBagToggle(id, v ?? false),
                title: Text(
                  DisruptionReadinessStrings.goBagItemLabel(id, locale),
                  style: AppTypography.bodySmall,
                ),
              ),
            ),
          ],
          if (block.id == 'embassy') ...[
            const SizedBox(height: AppSpacing.md),
            _EmbassySection(
              locale: locale,
              selectedCountryId: selectedEmbassyCountryId,
              onCountrySelected: onEmbassyCountrySelected,
              onOpenUrl: onOpenUrl,
            ),
          ],
          if (block.id == 'emergency_999') ...[
            const SizedBox(height: AppSpacing.md),
            GlassPrimaryButton(
              label: DisruptionReadinessStrings.t('dr_call_999', locale),
              icon: Icons.phone,
              accentColor: AppColors.errorBright,
              expand: true,
              onPressed: () => onOpenUrl('tel:999'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: onOpenEmergency,
              icon: const Icon(Icons.emergency_outlined, size: 18),
              label: Text(
                DisruptionReadinessStrings.t(
                  'dr_open_emergency_numbers',
                  locale,
                ),
              ),
            ),
          ],
          if (block.id == 'keep_records') ...[
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: onOpenVault,
              icon: const Icon(Icons.folder_outlined, size: 18),
              label: Text(
                DisruptionReadinessStrings.t('dr_document_vault', locale),
              ),
            ),
          ],
          ...block.links.where((l) => l.showInUi).map(
                (link) => Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: _ExternalLinkButton(
                    label: DisruptionReadinessStrings.t(link.labelKey, locale),
                    url: link.officialUrl!,
                    locale: locale,
                    lastVerifiedIso: link.lastVerifiedIso,
                    onOpen: onOpenUrl,
                  ),
                ),
              ),
          if (block.source != null) ...[
            const SizedBox(height: AppSpacing.md),
            _SourceFooter(source: block.source!, locale: locale),
          ],
        ],
      ),
    );
  }
}

class _SourceFooter extends StatelessWidget {
  const _SourceFooter({required this.source, required this.locale});

  final DisruptionOfficialSourceRef source;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final name = DisruptionReadinessStrings.t(source.nameKey, locale);
    if (!source.hasLiveLink) {
      return Text(
        DisruptionReadinessStrings.t('dr_source_unverified', locale),
        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
      );
    }
    final date = DateFormat.yMMMd().format(DateTime.parse(source.lastVerifiedIso));
    final text = DisruptionReadinessStrings.t('dr_source_footer', locale)
        .replaceAll('{source}', name)
        .replaceAll('{date}', date);
    return Text(
      text,
      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
    );
  }
}

class _ExternalLinkButton extends StatelessWidget {
  const _ExternalLinkButton({
    required this.label,
    required this.url,
    required this.locale,
    required this.lastVerifiedIso,
    required this.onOpen,
  });

  final String label;
  final String url;
  final String locale;
  final String lastVerifiedIso;
  final Future<void> Function(String url) onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () => onOpen(url),
          icon: const Icon(Icons.open_in_new_rounded, size: 18),
          label: Text(label),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.info,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DisruptionReadinessStrings.t('dr_needs_internet', locale),
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _AirlinePrompt extends StatelessWidget {
  const _AirlinePrompt({
    required this.locale,
    required this.controller,
    required this.onSearch,
  });

  final String locale;
  final TextEditingController controller;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DisruptionReadinessStrings.t('dr_airline_prompt_title', locale),
          style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: DisruptionReadinessStrings.t(
              'dr_airline_prompt_hint',
              locale,
            ),
            isDense: true,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => onSearch(),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: onSearch,
          icon: const Icon(Icons.travel_explore_outlined, size: 18),
          label: Text(
            DisruptionReadinessStrings.t('dr_airline_open_website', locale),
          ),
        ),
        Text(
          DisruptionReadinessStrings.t('dr_needs_internet', locale),
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _EmbassySection extends StatelessWidget {
  const _EmbassySection({
    required this.locale,
    required this.selectedCountryId,
    required this.onCountrySelected,
    required this.onOpenUrl,
  });

  final String locale;
  final String? selectedCountryId;
  final ValueChanged<String> onCountrySelected;
  final Future<void> Function(String url) onOpenUrl;

  @override
  Widget build(BuildContext context) {
    final entry = DisruptionEmbassyCatalog.forCountryId(selectedCountryId) ??
        DisruptionEmbassyCatalog.india;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final country in DisruptionEmbassyCatalog.countries)
              ChoiceChip(
                label: Text(country.countryId.replaceAll('_', ' ')),
                selected: selectedCountryId == country.countryId,
                onSelected: (_) => onCountrySelected(country.countryId),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (entry.status == DisruptionEmbassyPortalStatus.verified &&
            entry.portalUrl != null) ...[
          Text(
            DisruptionReadinessStrings.t(entry.authorityNameKey!, locale),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton.icon(
            onPressed: () => onOpenUrl(entry.portalUrl!),
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: Text(
              DisruptionReadinessStrings.t('dr_embassy_open_portal', locale),
            ),
          ),
          Text(
            DisruptionReadinessStrings.t('dr_needs_internet', locale),
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
        ] else
          Text(
            DisruptionReadinessStrings.t(
              entry.notConfirmedReasonKey ?? 'dr_embassy_bd_not_confirmed',
              locale,
            ),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }
}
