import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/hub/hub_typography.dart';
import 'package:raabta/features/eosb/data/migrant_support_catalog.dart';
import 'package:raabta/features/eosb/data/models/agency_verification_models.dart';
import 'package:raabta/features/eosb/domain/services/agency_verification_service.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/agency_verification_checklist.dart';
import 'package:raabta/features/eosb/presentation/widgets/qatar_real_estate_verification_section.dart';
import 'package:raabta/features/eosb/presentation/widgets/qatar_recruitment_agency_verification_section.dart';
import 'package:raabta/features/eosb/providers/home_country_support_providers.dart';
import 'package:raabta/features/scam_shield/forewarnings/forewarning_moment_id.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/forewarning_slot.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:url_launcher/url_launcher.dart';

/// Routes users to official government agency-verification portals by nationality.
///
/// Raabta is a signpost only — never certifies or rates agencies.
class AgencyVerificationScreen extends ConsumerStatefulWidget {
  const AgencyVerificationScreen({
    super.key,
    this.initialCountryId = '',
    this.initialSection = '',
  });

  final String initialCountryId;

  /// When a Qatar-side [initialSection] is set, that section appears first on screen.
  final String initialSection;

  static const qatarRealEstateSection = 'qatar-realestate';
  static const qatarRecruitmentSection = 'qatar-recruitment';

  static String route({String? countryId, String? section}) {
    final params = <String, String>{};
    final trimmedCountry = countryId?.trim() ?? '';
    final trimmedSection = section?.trim() ?? '';
    if (trimmedCountry.isNotEmpty) {
      params['country'] = trimmedCountry;
    }
    if (trimmedSection.isNotEmpty) {
      params['section'] = trimmedSection;
    }
    if (params.isEmpty) return '/agency-verification/check';
    return Uri(
      path: '/agency-verification/check',
      queryParameters: params,
    ).toString();
  }

  @override
  ConsumerState<AgencyVerificationScreen> createState() =>
      _AgencyVerificationScreenState();
}

class _AgencyVerificationScreenState
    extends ConsumerState<AgencyVerificationScreen> {
  static const _service = AgencyVerificationService();

  String? _selectedCountryId;

  @override
  void initState() {
    super.initState();
    if (widget.initialCountryId.trim().isNotEmpty) {
      _selectedCountryId = widget.initialCountryId.trim().toLowerCase();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _selectedCountryId != null) return;
      ref.read(homeCountryUserContextProvider.future).then((context) {
        if (!mounted || _selectedCountryId != null) return;
        final resolved = _service.resolve(context);
        if (resolved.countryId != null) {
          setState(() => _selectedCountryId = resolved.countryId);
        }
      });
    });
  }

  Future<void> _openPortal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  AgencyVerificationView _viewForSelection() {
    final id = _selectedCountryId;
    if (id == null || id.isEmpty) {
      return const AgencyVerificationView.noCountrySelected();
    }
    return _service.resolveByCountryId(id);
  }

  bool get _recruitmentSectionFirst =>
      widget.initialSection.trim().toLowerCase() ==
      AgencyVerificationScreen.qatarRecruitmentSection.toLowerCase();

  List<Widget> _qatarSectionWidgets(String locale) {
    final section = widget.initialSection.trim().toLowerCase();
    final recruitmentOnly =
        section == AgencyVerificationScreen.qatarRecruitmentSection.toLowerCase();
    final realEstateOnly =
        section == AgencyVerificationScreen.qatarRealEstateSection.toLowerCase();

    if (recruitmentOnly) {
      return [
        QatarRecruitmentAgencyVerificationSection(
          locale: locale,
          onOpenUrl: _openPortal,
        ),
      ];
    }
    if (realEstateOnly) {
      return [
        QatarRealEstateVerificationSection(
          locale: locale,
          onOpenUrl: _openPortal,
        ),
      ];
    }

    return [
      if (_recruitmentSectionFirst)
        QatarRecruitmentAgencyVerificationSection(
          locale: locale,
          onOpenUrl: _openPortal,
        )
      else
        QatarRealEstateVerificationSection(
          locale: locale,
          onOpenUrl: _openPortal,
        ),
      const SizedBox(height: AppSpacing.lg),
      if (_recruitmentSectionFirst)
        QatarRealEstateVerificationSection(
          locale: locale,
          onOpenUrl: _openPortal,
        )
      else
        QatarRecruitmentAgencyVerificationSection(
          locale: locale,
          onOpenUrl: _openPortal,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final view = _viewForSelection();

    final qatarSections = _qatarSectionWidgets(locale);

    return GlassScreenScaffold(
      title: EosbStrings.t('agency_verify_screen_title', locale),
      titleStyle: HubTypography.hubTitle,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          ForewarningSlot(
            momentId: ForewarningMomentId.visaProUnofficialAgent,
            locale: locale,
          ),
          ...qatarSections,
          const SizedBox(height: AppSpacing.xl),
          Text(
            EosbStrings.t('agency_verify_origin_country_heading', locale),
            style: AppTypography.subtitle,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            EosbStrings.t('agency_verify_origin_country_hint', locale),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            EosbStrings.t('agency_verify_country_heading', locale),
            style: AppTypography.subtitle,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...MigrantSupportCatalog.countries.map((country) {
            final selected = _selectedCountryId == country.countryId;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GlassCard(
                onTap: () =>
                    setState(() => _selectedCountryId = country.countryId),
                padding: const EdgeInsets.all(AppSpacing.md),
                glowColor:
                    selected ? AppColors.brandFamilyMain : AppColors.glassBorder,
                glowIntensity: selected ? 0.18 : 0.06,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        EosbStrings.t(country.displayNameKey, locale),
                        style: AppTypography.subtitle,
                      ),
                    ),
                    if (selected)
                      Icon(Icons.check_circle, color: AppColors.brandFamilyMain),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.lg),
          if (view.status != AgencyVerificationDisplayStatus.noCountrySelected)
            _PortalSection(
              view: view,
              locale: locale,
              onOpenPortal: _openPortal,
            ),
          const SizedBox(height: AppSpacing.lg),
          AgencyVerificationChecklist(locale: locale),
        ],
      ),
    );
  }
}

class _PortalSection extends StatelessWidget {
  const _PortalSection({
    required this.view,
    required this.locale,
    required this.onOpenPortal,
  });

  final AgencyVerificationView view;
  final String locale;
  final Future<void> Function(String url) onOpenPortal;

  @override
  Widget build(BuildContext context) {
    final verifiedPortal =
        view.status == AgencyVerificationDisplayStatus.verifiedPortal &&
            view.portal != null;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: verifiedPortal
          ? AppColors.greenFamilyMain
          : AppColors.glassBorder,
      glowIntensity: verifiedPortal ? 0.12 : 0.06,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (verifiedPortal) ...[
            Text(
              EosbStrings.t(view.portal!.authorityNameKey, locale),
              style: AppTypography.subtitle.copyWith(
                color: AppColors.greenFamilyMain,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              EosbStrings.t(view.portal!.searchInstructionKey, locale),
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              EosbStrings.t(view.portal!.goodStandingStatusKey, locale),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (view.portal!.additionalVerificationKey != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                EosbStrings.t(view.portal!.additionalVerificationKey!, locale),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            GlassPrimaryButton(
              label: EosbStrings.t('agency_verify_open_portal', locale),
              icon: Icons.open_in_new_rounded,
              accentColor: AppColors.brandFamilyMain,
              expand: true,
              onPressed: () => onOpenPortal(view.portal!.portalUrl),
            ),
          ] else ...[
            Text(
              EosbStrings.t(
                view.notConfirmedReasonKey ??
                    'agency_verify_generic_not_confirmed',
                locale,
              ),
              style: AppTypography.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            EosbStrings.t('agency_verify_disclaimer', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
