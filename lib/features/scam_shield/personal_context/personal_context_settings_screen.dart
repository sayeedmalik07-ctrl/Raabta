import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/scam_shield/domain/official_directory.dart';
import 'package:raabta/features/scam_shield/domain/official_directory_models.dart';
import 'package:raabta/features/scam_shield/personal_context/personal_context_hive_store.dart';
import 'package:raabta/features/scam_shield/personal_context/personal_context_prompt_prefs.dart';
import 'package:raabta/features/scam_shield/personal_context/personal_context_providers.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/report_pack/report_pack_repository.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:scam_shield_core/features/scam_shield/domain/evidence/personal_context_models.dart';

class PersonalContextSettingsScreen extends ConsumerStatefulWidget {
  const PersonalContextSettingsScreen({super.key});

  @override
  ConsumerState<PersonalContextSettingsScreen> createState() =>
      _PersonalContextSettingsScreenState();
}

class _PersonalContextSettingsScreenState
    extends ConsumerState<PersonalContextSettingsScreen> {
  final _selectedBanks = <String>{};
  final _selectedTelecom = <String>{};
  var _noBankInQatar = false;
  var _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final snap = await PersonalContextHiveStore.loadSnapshot();
    if (!mounted) return;
    setState(() {
      _selectedBanks.addAll(snap.bankDirectoryIds);
      _selectedTelecom.addAll(snap.telecomDirectoryIds);
      _noBankInQatar = snap.noBankInQatar;
      _loaded = true;
    });
  }

  List<OfficialDirectoryEntry> _banks() {
    return OfficialDirectory.snapshot.entries
        .where((e) => e.category == OfficialDirectoryCategory.banking)
        .toList();
  }

  List<OfficialDirectoryEntry> _telecoms() {
    return OfficialDirectory.snapshot.entries
        .where((e) => e.category == OfficialDirectoryCategory.telecom)
        .toList();
  }

  Future<void> _save(String locale) async {
    final snap = PersonalContextSnapshot(
      bankDirectoryIds: _noBankInQatar ? const [] : _selectedBanks.toList(),
      telecomDirectoryIds: _selectedTelecom.toList(),
      noBankInQatar: _noBankInQatar,
    );
    await PersonalContextHiveStore.saveSnapshot(snap);
    await PersonalContextPromptPrefs.clearDeclined();
    await _maybePrefillBankLine(locale, snap);
    ref.invalidate(personalContextSnapshotProvider);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _maybePrefillBankLine(
    String locale,
    PersonalContextSnapshot snap,
  ) async {
    if (snap.noBankInQatar || snap.bankDirectoryIds.length != 1) return;
    final id = snap.bankDirectoryIds.first;
    final entry = OfficialDirectory.lookupById(id);
    if (entry == null || !entry.verified) return;
    final note = entry.contactNote(locale);
    if (note == null || note.trim().isEmpty) return;
    final draft = await ReportPackRepository.loadDraft();
    if (draft.bankFraudLine.trim().isNotEmpty) return;
    await ReportPackRepository.saveDraft(
      draft.copyWith(bankFraudLine: note.trim()),
    );
  }

  Future<void> _deleteAll() async {
    await PersonalContextHiveStore.deleteAll();
    ref.invalidate(personalContextSnapshotProvider);
    if (mounted) {
      setState(() {
        _selectedBanks.clear();
        _selectedTelecom.clear();
        _noBankInQatar = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    if (!_loaded) {
      return GlassScreenScaffold(
        title: ScamShieldStrings.t('ss_personal_context_title', locale),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return GlassScreenScaffold(
      title: ScamShieldStrings.t('ss_personal_context_title', locale),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            ScamShieldStrings.t('ss_personal_context_why', locale),
            style: AppTypography.body,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            ScamShieldStrings.t('ss_personal_context_banks_heading', locale),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final entry in _banks())
                FilterChip(
                  label: Text(entry.displayName(locale)),
                  selected: _selectedBanks.contains(entry.id),
                  onSelected: _noBankInQatar
                      ? null
                      : (v) {
                          setState(() {
                            if (v) {
                              _selectedBanks.add(entry.id);
                            } else {
                              _selectedBanks.remove(entry.id);
                            }
                          });
                        },
                ),
            ],
          ),
          CheckboxListTile(
            value: _noBankInQatar,
            onChanged: (v) {
              setState(() {
                _noBankInQatar = v ?? false;
                if (_noBankInQatar) _selectedBanks.clear();
              });
            },
            title: Text(
              ScamShieldStrings.t('ss_personal_context_no_bank', locale),
              style: AppTypography.bodySmall,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            ScamShieldStrings.t('ss_personal_context_telecom_heading', locale),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final entry in _telecoms())
                FilterChip(
                  label: Text(entry.displayName(locale)),
                  selected: _selectedTelecom.contains(entry.id),
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _selectedTelecom
                          ..clear()
                          ..add(entry.id);
                      } else {
                        _selectedTelecom.remove(entry.id);
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          GlassPrimaryButton(
            label: ScamShieldStrings.t('ss_personal_context_save', locale),
            onPressed: () => _save(locale),
          ),
          TextButton(
            onPressed: _deleteAll,
            child: Text(
              ScamShieldStrings.t('ss_personal_context_delete', locale),
            ),
          ),
        ],
      ),
    );
  }
}
