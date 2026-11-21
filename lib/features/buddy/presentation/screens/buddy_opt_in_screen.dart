import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/buddy/domain/buddy_area_codes.dart';
import 'package:raabta/features/buddy/domain/buddy_constants.dart';
import 'package:raabta/features/buddy/domain/buddy_interest_taxonomy.dart';
import 'package:raabta/features/buddy/domain/buddy_spoken_languages.dart';
import 'package:raabta/features/buddy/domain/buddy_supported_countries.dart';
import 'package:raabta/features/buddy/presentation/l10n/buddy_strings.dart';
import 'package:raabta/features/buddy/providers/buddy_providers.dart';
import 'package:raabta/features/buddy/services/buddy_profile_persistence_service.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/features/buddy/models/buddy_profile.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

class BuddyOptInScreen extends ConsumerStatefulWidget {
  const BuddyOptInScreen({super.key});

  @override
  ConsumerState<BuddyOptInScreen> createState() => _BuddyOptInScreenState();
}

class _BuddyOptInScreenState extends ConsumerState<BuddyOptInScreen> {
  int _step = 0;
  bool _adultChecked = false;
  bool _isNewcomer = false;
  bool _isHelper = false;
  bool _paused = false;
  String? _countryId;
  String? _areaCode;
  String _yearsBand = BuddyConstants.yearsBandUnder1;
  final Set<String> _spoken = {};
  final Set<String> _interests = {};
  bool _saving = false;
  bool _hydrated = false;
  DateTime? _existingOptInAt;
  DateTime? _existingAdultAt;

  void _hydrateFromProfile(BuddyProfile? buddy) {
    if (_hydrated) return;
    _hydrated = true;
    final ai = ref.read(userAIProfileProvider);
    if (buddy != null) {
      setState(() {
        _step = 1;
        _isNewcomer = buddy.isNewcomer;
        _isHelper = buddy.isHelper;
        _paused = buddy.paused;
        _countryId = buddy.nationalityCountryId;
        _areaCode = buddy.areaCode;
        _yearsBand = buddy.yearsInQatarBand;
        _spoken
          ..clear()
          ..addAll(buddy.spokenLanguageCodes);
        _interests
          ..clear()
          ..addAll(buddy.interestTagIds);
        _existingOptInAt = buddy.optInAt;
        _existingAdultAt = buddy.adultAttestationAt;
        _adultChecked = buddy.adultAttestationAt != null;
      });
      return;
    }

    final resolved =
        BuddySupportedCountries.resolveCountryIdFromProfile(ai?.nationality ?? '');
    final area = ai?.areaCode.isNotEmpty == true
        ? ai!.areaCode
        : (BuddyAreaCodes.isValid(ai?.preferredArea) ? ai!.preferredArea : null);
    if (ai?.spokenLanguageCodes.isNotEmpty == true) {
      _spoken.addAll(ai!.spokenLanguageCodes);
    }
    setState(() {
      _countryId = BuddySupportedCountries.isSupportedCountryId(resolved)
          ? resolved
          : null;
      _areaCode = area;
    });
  }

  String _displayName() {
    final user = FirebaseAuth.instance.currentUser;
    final fromAuth = user?.displayName?.trim();
    if (fromAuth != null && fromAuth.isNotEmpty) return fromAuth;
    return 'Raabta member';
  }

  Future<void> _save({required bool isCreate}) async {
    final locale = ref.read(userLanguageProvider);
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;

    if (_countryId == null) {
      _showError(BuddyStrings.t('buddy_err_invalidCountryId', locale));
      return;
    }

    if (isCreate && _existingAdultAt == null && !_adultChecked) {
      _showError(BuddyStrings.t('buddy_err_missingAdultAttestation', locale));
      return;
    }
    final adultAt = _existingAdultAt ?? DateTime.now();
    final draft = BuddyProfilePersistenceService.buildDraft(
      uid: uid,
      displayNickname: _displayName(),
      isNewcomer: _isNewcomer,
      isHelper: _isHelper,
      paused: _paused,
      nationalityCountryId: _countryId!,
      spokenLanguageCodes: _spoken.toList(),
      areaCode: _areaCode ?? '',
      yearsInQatarBand: _yearsBand,
      interestTagIds: _interests.toList(),
      adultAttestationAt: adultAt,
      existingOptInAt: _existingOptInAt,
    );

    setState(() => _saving = true);
    final result = await BuddyProfilePersistenceService.save(
      ref: ref,
      draft: draft,
      selectedCountryId: _countryId!,
      isCreate: isCreate,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (result.errors.isNotEmpty) {
      _showError(BuddyStrings.validationMessage(result.errors.first, locale));
      return;
    }
    if (result.profileWriteFailed || result.userProfileWriteFailed) {
      _showError(BuddyStrings.t('buddy_save_failed', locale));
      return;
    }

    ref.invalidate(buddyProfileProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(BuddyStrings.t('buddy_saved', locale))),
    );
    context.pop();
  }

  Future<void> _optOut() async {
    final locale = ref.read(userLanguageProvider);
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(BuddyStrings.t('buddy_opt_out', locale)),
        content: Text(BuddyStrings.t('buddy_opt_out_confirm', locale)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('OK')),
        ],
      ),
    );
    if (ok != true) return;
    await BuddyProfilePersistenceService.deleteProfile(uid);
    ref.invalidate(buddyProfileProvider);
    if (mounted) context.pop();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final buddyAsync = ref.watch(buddyProfileProvider);
    final isCreate = buddyAsync.valueOrNull == null;

    buddyAsync.whenData((buddy) {
      if (!_hydrated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _hydrateFromProfile(buddy);
        });
      }
    });

    return GlassScreenScaffold(
      title: _step == 0
          ? BuddyStrings.t('buddy_consent_title', locale)
          : BuddyStrings.t('buddy_opt_in_title', locale),
      body: buddyAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.xxxl,
              ),
              child: _step == 0 ? _consentStep(locale) : _formStep(locale, isCreate),
            ),
    );
  }

  Widget _consentStep(String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            BuddyStrings.t('buddy_consent_body', locale),
            style: AppTypography.body,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        CheckboxListTile(
          value: _adultChecked,
          onChanged: (v) => setState(() => _adultChecked = v ?? false),
          title: Text(BuddyStrings.t('buddy_consent_adult_checkbox', locale)),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        const SizedBox(height: AppSpacing.lg),
        GlassPrimaryButton(
          label: BuddyStrings.t('buddy_consent_continue', locale),
          onPressed: _adultChecked ? () => setState(() => _step = 1) : null,
        ),
      ],
    );
  }

  Widget _formStep(String locale, bool isCreate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          BuddyStrings.t('buddy_manage_hint', locale),
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        SwitchListTile(
          title: Text(BuddyStrings.t('buddy_role_newcomer', locale)),
          value: _isNewcomer,
          onChanged: (v) => setState(() => _isNewcomer = v),
        ),
        SwitchListTile(
          title: Text(BuddyStrings.t('buddy_role_helper', locale)),
          value: _isHelper,
          onChanged: (v) => setState(() => _isHelper = v),
        ),
        if (_isHelper || _isNewcomer)
          SwitchListTile(
            title: Text(BuddyStrings.t('buddy_paused', locale)),
            value: _paused,
            onChanged: (v) => setState(() => _paused = v),
          ),
        const SizedBox(height: AppSpacing.md),
        Text(BuddyStrings.t('buddy_country_label', locale), style: AppTypography.subtitle),
        DropdownButtonFormField<String>(
          value: _countryId,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: [
            for (final c in BuddySupportedCountries.ordered)
              DropdownMenuItem(
                value: c.countryId,
                child: Text(
                  CommunityStrings.nationalityLabel(c.countryId, locale),
                ),
              ),
          ],
          onChanged: (v) => setState(() => _countryId = v),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(BuddyStrings.t('buddy_spoken_languages_label', locale), style: AppTypography.subtitle),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final lang in BuddySpokenLanguages.options)
              FilterChip(
                label: Text(BuddyStrings.t(lang.labelKey, locale)),
                selected: _spoken.contains(lang.code),
                onSelected: (sel) {
                  setState(() {
                    if (sel) {
                      if (_spoken.length < BuddyConstants.maxSpokenLanguages) {
                        _spoken.add(lang.code);
                      }
                    } else {
                      _spoken.remove(lang.code);
                    }
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(BuddyStrings.t('buddy_area_label', locale), style: AppTypography.subtitle),
        DropdownButtonFormField<String>(
          value: BuddyAreaCodes.isValid(_areaCode) ? _areaCode : null,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: [
            for (final area in BuddyAreaCodes.all)
              DropdownMenuItem(value: area, child: Text(area)),
          ],
          onChanged: (v) => setState(() => _areaCode = v),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(BuddyStrings.t('buddy_years_label', locale), style: AppTypography.subtitle),
        ...[
          (BuddyConstants.yearsBandUnder1, 'buddy_years_under_1'),
          (BuddyConstants.yearsBand1To3, 'buddy_years_1_3'),
          (BuddyConstants.yearsBand3Plus, 'buddy_years_3_plus'),
        ].map(
          (e) => RadioListTile<String>(
            title: Text(BuddyStrings.t(e.$2, locale)),
            value: e.$1,
            groupValue: _yearsBand,
            onChanged: (v) => setState(() => _yearsBand = v ?? _yearsBand),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(BuddyStrings.t('buddy_interests_label', locale), style: AppTypography.subtitle),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final tag in BuddyInterestTaxonomy.all)
              FilterChip(
                label: Text(BuddyStrings.t(tag.labelKey, locale)),
                selected: _interests.contains(tag.id),
                onSelected: (sel) {
                  setState(() {
                    if (sel) {
                      if (_interests.length < BuddyConstants.maxInterestTags) {
                        _interests.add(tag.id);
                      }
                    } else {
                      _interests.remove(tag.id);
                    }
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        GlassPrimaryButton(
          label: BuddyStrings.t('buddy_save', locale),
          onPressed: _saving ? null : () => _save(isCreate: isCreate),
        ),
        if (!isCreate) ...[
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: _optOut,
            child: Text(BuddyStrings.t('buddy_opt_out', locale)),
          ),
        ],
      ],
    );
  }
}
