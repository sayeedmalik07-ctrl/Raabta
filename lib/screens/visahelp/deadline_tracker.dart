import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_error_state.dart';
import 'package:raabta/core/widgets/hub/hub_deadline_urgency_row.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/glass_settings_tile.dart';
import 'package:raabta/services/drafts/draftable_form.dart';
import 'package:raabta/core/widgets/draft_restore_banner.dart';
import 'package:raabta/services/drafts/draft_box_keys.dart';
import 'package:raabta/services/drafts/draft_form_controller.dart';
import 'package:raabta/services/drafts/draft_service.dart';
import 'package:raabta/models/visa_models.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/visahelp/l10n/visa_strings.dart';

Color _deadlineDialogBg(bool light) =>
    light ? AppColors.surfaceElevated : AppColors.surface;

TextStyle _deadlineDialogTitleStyle() => TextStyle(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.bold,
    );

TextStyle _deadlineDialogBodyStyle() => TextStyle(
      color: AppColors.textSecondary,
    );

/// Hub kit §4 filter-style pill — semantic status tint (16%) + icon + label.
class _DeadlineTrackerSummaryChip extends StatelessWidget {
  const _DeadlineTrackerSummaryChip({
    required this.semanticColor,
    required this.label,
    this.icon,
  });

  final Color semanticColor;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: semanticColor.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: semanticColor.withValues(alpha: 0.38),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13),
        child: SizedBox(
          height: HubLayoutTokens.filterChipHeight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: semanticColor),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: semanticColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeadlineTrackerWidget extends ConsumerStatefulWidget {
  const DeadlineTrackerWidget({super.key, this.highlightDeadlineId});

  final String? highlightDeadlineId;

  @override
  ConsumerState<DeadlineTrackerWidget> createState() =>
      _DeadlineTrackerWidgetState();
}

class _DeadlineTrackerWidgetState extends ConsumerState<DeadlineTrackerWidget> {
  final _itemKeys = <String, GlobalKey>{};

  HubDeadlineUrgencyTier _hubUrgencyTier(DeadlineUrgency u) {
    return switch (u) {
      DeadlineUrgency.red => HubDeadlineUrgencyTier.critical,
      DeadlineUrgency.amber => HubDeadlineUrgencyTier.attention,
      DeadlineUrgency.green => HubDeadlineUrgencyTier.comfortable,
    };
  }

  Color _urgencyAccent(DeadlineUrgency urgency) =>
      hubDeadlineUrgencyColor(_hubUrgencyTier(urgency));

  String _expiryLine(DocumentDeadline d, String locale) {
    final days = d.daysRemaining;
    if (days < 0) {
      return VisaStrings.format(
        'visa_deadline_expired_days_ago',
        locale,
        params: {'days': '${days.abs()}'},
      );
    }
    if (days == 0) {
      return VisaStrings.t('visa_deadline_expires_today', locale);
    }
    if (days == 1) {
      return VisaStrings.t('visa_deadline_expires_one_day', locale);
    }
    return VisaStrings.format(
      'visa_deadline_expires_days',
      locale,
      params: {'days': '$days'},
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToHighlight());
  }

  @override
  void didUpdateWidget(covariant DeadlineTrackerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.highlightDeadlineId != widget.highlightDeadlineId) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToHighlight());
    }
  }

  void _scrollToHighlight() {
    final id = widget.highlightDeadlineId;
    if (id == null || id.isEmpty) return;
    final key = _itemKeys[id];
    final ctx = key?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.2,
      );
    }
  }

  Future<void> _showAddDialog(String locale) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => DeadlineAddDialog(locale: locale),
    );

    if (saved != true || !mounted) return;

    // Values applied inside dialog on save — reload from provider stream.
  }

  Future<void> _attachPhoto(DocumentDeadline deadline, String locale) async {
    final docs = await FirebaseFirestore.instance
        .collection('scanned_documents')
        .orderBy('scanDate', descending: true)
        .limit(25)
        .get();

    if (!mounted) return;

    if (docs.docs.isEmpty) {
      final scan = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: _deadlineDialogBg(AppColors.isLight),
          title: Text(
            VisaStrings.t('visa_no_vault_documents', locale),
            style: _deadlineDialogTitleStyle(),
          ),
          content: Text(
            VisaStrings.t('visa_scan_first_message', locale),
            style: _deadlineDialogBodyStyle(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(VisaStrings.t('visa_cancel', locale)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(VisaStrings.t('visa_scan_document_action', locale)),
            ),
          ],
        ),
      );
      if (scan == true && mounted) {
        context.push('/scanner/capture?source=visa');
      }
      return;
    }

    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _deadlineDialogBg(AppColors.isLight),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      VisaStrings.t('visa_attach_from_vault', locale),
                      style: _deadlineDialogTitleStyle(),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push('/scanner/capture?source=visa');
                    },
                    child: Text(VisaStrings.t('visa_scan_new', locale)),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: docs.docs.map((doc) {
                  final d = doc.data();
                  final name = d['displayName'] as String? ??
                      d['docType'] as String? ??
                      VisaStrings.t('visa_document_fallback', locale);
                  final category = d['category'] as String? ?? '';
                  return ListTile(
                    leading: const Icon(Icons.description, color: AppColors.cyanGlow),
                    title: Text(
                      name,
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      category,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    onTap: () => Navigator.pop(ctx, doc.id),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );

    if (picked != null) {
      await ref.read(documentDeadlinesControllerProvider).attachVaultDocument(
            deadlineId: deadline.id,
            vaultDocumentId: picked,
          );
    }
  }

  Widget _summaryRow(List<DocumentDeadline> deadlines, String locale) {
    final within30 =
        deadlines.where((d) => d.daysRemaining >= 0 && d.daysRemaining < 30).length;
    final within90 =
        deadlines.where((d) => d.daysRemaining >= 0 && d.daysRemaining < 90).length;
    final expired = deadlines.where((d) => d.daysRemaining < 0).length;

    if (deadlines.isEmpty) return const SizedBox.shrink();

    final chips = <Widget>[
      if (within30 > 0)
        _DeadlineTrackerSummaryChip(
          semanticColor: AppColors.errorBright,
          icon: Icons.warning_amber_rounded,
          label: VisaStrings.format(
            'visa_expiring_30_days',
            locale,
            params: {'count': '$within30'},
          ),
        ),
      if (within90 > within30)
        _DeadlineTrackerSummaryChip(
          semanticColor: AppColors.accentGold,
          label: VisaStrings.format(
            'visa_due_30_90_days',
            locale,
            params: {'count': '${within90 - within30}'},
          ),
        ),
      if (expired > 0)
        _DeadlineTrackerSummaryChip(
          semanticColor: AppColors.errorBright,
          icon: Icons.error_outline,
          label: VisaStrings.format(
            'visa_expired_count',
            locale,
            params: {'count': '$expired'},
          ),
        ),
      if (within30 == 0 && expired == 0)
        _DeadlineTrackerSummaryChip(
          semanticColor: AppColors.successBright,
          icon: Icons.check_circle_outline,
          label: VisaStrings.t('visa_all_documents_ok', locale),
        ),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < chips.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              chips[i],
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final deadlinesAsync = ref.watch(documentDeadlinesProvider);

    return deadlinesAsync.when(
      loading: () => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: HubLoadingPlaceholder(
            width: MediaQuery.sizeOf(context).width - AppSpacing.xl * 2,
            height: 140,
            silhouette: HubLoadingSilhouette.formTool,
          ),
        ),
      ),
      error: (e, _) => GlassErrorState(
        message: VisaStrings.t('visa_load_deadlines_error', locale),
        retryLabel: CommonActionStrings.t('action_retry', locale),
        onRetry: () => ref.invalidate(documentDeadlinesProvider),
      ),
      data: (deadlines) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    VisaStrings.t('visa_deadline_tracker_title', locale),
                    style: AppTypography.headline2.copyWith(fontSize: 18),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddDialog(locale),
                  icon: Icon(
                    Icons.add,
                    color: AppColors.brandFamilyMain,
                    size: AppSpacing.iconMd,
                  ),
                  label: Text(
                    VisaStrings.t('visa_add', locale),
                    style: AppTypography.link.copyWith(
                      color: AppColors.brandFamilyMain,
                    ),
                  ),
                ),
              ],
            ),
            _summaryRow(deadlines, locale),
            if (deadlines.isEmpty)
              GlassEmptyState(
                accent: GlassEmptyStateAccent.brand,
                icon: Icons.event_busy_outlined,
                title: VisaStrings.t('visa_no_deadlines_title', locale),
                description: VisaStrings.t('visa_no_deadlines_body', locale),
              )
            else
              ...deadlines.map((deadline) {
                final tier = _hubUrgencyTier(deadline.urgency);
                final accent = _urgencyAccent(deadline.urgency);
                final highlighted = widget.highlightDeadlineId == deadline.id;
                _itemKeys.putIfAbsent(deadline.id, GlobalKey.new);
                final titleLine =
                    '${deadline.typeDef.emoji} ${deadline.displayTitle(
                  VisaStrings.t('visa_deadline_visit_visa_label', locale),
                )}';

                return Padding(
                  key: _itemKeys[deadline.id],
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: GlassCard(
                      onTap: null,
                      padding: EdgeInsets.zero,
                      borderRadius: AppSpacing.radiusMd,
                      glowColor: highlighted ? AppColors.brandFamilyMain : accent,
                      glowIntensity: highlighted ? 0.22 : 0.1,
                      backgroundColor: AppColors.glassSurface,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      HubDeadlineUrgencyRow(
                                        tier: tier,
                                        title: titleLine,
                                        subtitle: _expiryLine(deadline, locale),
                                      ),
                                      if (deadline.vaultDocumentId != null) ...[
                                        const SizedBox(height: AppSpacing.xs),
                                        GestureDetector(
                                          onTap: () => context.push(
                                            '/document-vault/${deadline.vaultDocumentId}',
                                          ),
                                          child: Text(
                                            VisaStrings.t(
                                              'visa_deadline_attached_view',
                                              locale,
                                            ),
                                            style: AppTypography.caption
                                                .copyWith(
                                              color: AppColors.link,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => ref
                                      .read(
                                        documentDeadlinesControllerProvider,
                                      )
                                      .removeDeadline(deadline.id),
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                            if (!deadline.isVisitVisaEntry) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: () =>
                                        _attachPhoto(deadline, locale),
                                    icon: Icon(
                                      Icons.attach_file,
                                      size: AppSpacing.iconSm,
                                      color: AppColors.brandFamilyMain,
                                    ),
                                    label: Text(
                                      deadline.vaultDocumentId == null
                                          ? VisaStrings.t(
                                              'visa_attach_photo',
                                              locale,
                                            )
                                          : VisaStrings.t(
                                              'visa_change_photo',
                                              locale,
                                            ),
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.brandFamilyMain,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () => context.push(
                                      '/visa/guide/${deadline.guideCategoryId}',
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          AppColors.brandFamilyMain,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: AppSpacing.xs,
                                      ),
                                    ),
                                    child: Text(
                                      VisaStrings.t('visa_how_to_renew', locale),
                                      style: AppTypography.caption.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.brandFamilyMain,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

/// Add document deadline — shared for hub hero CTA and tracker.
class DeadlineAddDialog extends ConsumerStatefulWidget {
  const DeadlineAddDialog({super.key, required this.locale});

  final String locale;

  @override
  ConsumerState<DeadlineAddDialog> createState() => _DeadlineAddDialogState();
}

class _DeadlineAddDialogState extends ConsumerState<DeadlineAddDialog> {
  late DocumentDeadlineTypeDef _selectedType;
  late DateTime _selectedDate;
  late bool _remind30;
  late bool _remind7;
  late bool _remind1;

  final TextEditingController _visitVisaNicknameController =
      TextEditingController();
  String? _visitVisaNicknameErrorKey;

  late DraftFormController _draftController;
  DraftRecord? _pendingDraft;
  bool _showRestoreBanner = false;

  @override
  void initState() {
    super.initState();
    _selectedType = documentDeadlineTypes.first;
    _selectedDate = DateTime.now().add(const Duration(days: 90));
    _remind30 = true;
    _remind7 = true;
    _remind1 = true;
    _draftController = DraftFormController(formId: DraftBoxKeys.deadlineTrackerAdd);
    DraftableFormRegistry.markActive(DraftBoxKeys.deadlineTrackerAdd);
    _bootstrapDraft();
  }

  Future<void> _bootstrapDraft() async {
    await _draftController.init();
    final draft = await _draftController.loadRestorableDraft();
    if (!mounted || draft == null) return;
    setState(() {
      _pendingDraft = draft;
      _showRestoreBanner = true;
    });
  }

  Map<String, dynamic> _serialize() => {
        'typeId': _selectedType.id,
        'expiryDate': _selectedDate.toIso8601String(),
        'remind30': _remind30,
        'remind7': _remind7,
        'remind1': _remind1,
        if (_selectedType.type == DocumentDeadlineType.visitVisa)
          'visitVisaNickname': _visitVisaNicknameController.text,
      };

  void _applyDraft(Map<String, dynamic> data) {
    final typeId = data['typeId']?.toString();
    _selectedType = documentDeadlineTypes.firstWhere(
      (t) => t.id == typeId,
      orElse: () => documentDeadlineTypes.first,
    );
    _selectedDate = DateTime.tryParse(data['expiryDate']?.toString() ?? '') ??
        DateTime.now().add(const Duration(days: 90));
    _remind30 = data['remind30'] != false;
    _remind7 = data['remind7'] != false;
    _remind1 = data['remind1'] != false;
    if (_selectedType.type == DocumentDeadlineType.visitVisa) {
      _visitVisaNicknameController.text =
          data['visitVisaNickname']?.toString() ?? '';
    } else {
      _visitVisaNicknameController.clear();
    }
    _visitVisaNicknameErrorKey = null;
  }

  void _notifyChanged() => _draftController.scheduleSave(_serialize());

  @override
  void dispose() {
    _visitVisaNicknameController.dispose();
    _draftController.dispose();
    super.dispose();
  }

  bool get _isVisitVisaSelected =>
      _selectedType.type == DocumentDeadlineType.visitVisa;

  String? _validateVisitVisaNickname() {
    if (!_isVisitVisaSelected) return null;
    final raw = _visitVisaNicknameController.text;
    if (raw.trim().isEmpty) return null;
    final issue = VisitVisaNicknamePolicy.validateNonEmptyInput(raw);
    if (issue == VisitVisaNicknameIssue.tooLong) {
      return 'visa_visit_visa_nickname_too_long';
    }
    if (issue == VisitVisaNicknameIssue.invalidCharacters) {
      return 'visa_visit_visa_nickname_invalid';
    }
    return null;
  }

  Future<void> _save() async {
    final nicknameError = _validateVisitVisaNickname();
    if (nicknameError != null) {
      setState(() => _visitVisaNicknameErrorKey = nicknameError);
      return;
    }
    await ref.read(documentDeadlinesControllerProvider).addDeadline(
          typeDef: _selectedType,
          expiryDate: _selectedDate,
          remind30Days: _remind30,
          remind7Days: _remind7,
          remind1Day: _remind1,
          visitVisaNickname:
              _isVisitVisaSelected ? _visitVisaNicknameController.text : null,
        );
    await _draftController.clear();
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;
    return AlertDialog(
      backgroundColor: _deadlineDialogBg(AppColors.isLight),
      title: Text(
        VisaStrings.t('visa_add_document_deadline', locale),
        style: _deadlineDialogTitleStyle(),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_showRestoreBanner && _pendingDraft != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: DraftRestoreBanner(
                  savedAt: _pendingDraft!.savedAt,
                  onRestore: () {
                    setState(() {
                      _applyDraft(_pendingDraft!.data);
                      _showRestoreBanner = false;
                      _pendingDraft = null;
                    });
                  },
                  onDiscard: () async {
                    await _draftController.clear();
                    setState(() {
                      _showRestoreBanner = false;
                      _pendingDraft = null;
                    });
                  },
                ),
              ),
            DropdownButtonFormField<DocumentDeadlineTypeDef>(
              initialValue: _selectedType,
              dropdownColor: _deadlineDialogBg(AppColors.isLight),
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: VisaStrings.t('visa_document_type', locale),
                labelStyle: TextStyle(color: AppColors.textOnGlassSecondary),
              ),
              items: documentDeadlineTypes
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text('${t.emoji} ${t.label}'),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _selectedType = v;
                    if (v.type != DocumentDeadlineType.visitVisa) {
                      _visitVisaNicknameController.clear();
                      _visitVisaNicknameErrorKey = null;
                    }
                  });
                  _notifyChanged();
                }
              },
            ),
            if (_isVisitVisaSelected) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _visitVisaNicknameController,
                maxLength: VisitVisaNicknamePolicy.maxNicknameLength + 8,
                maxLines: 1,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: VisaStrings.t(
                    'visa_visit_visa_nickname_label',
                    locale,
                  ),
                  hintText: VisaStrings.t(
                    'visa_visit_visa_nickname_hint',
                    locale,
                  ),
                  errorText: _visitVisaNicknameErrorKey == null
                      ? null
                      : VisaStrings.format(
                          _visitVisaNicknameErrorKey!,
                          locale,
                          params: {
                            'max': VisitVisaNicknamePolicy.maxNicknameLength
                                .toString(),
                          },
                        ),
                  labelStyle:
                      TextStyle(color: AppColors.textOnGlassSecondary),
                  counterText: '',
                ),
                onChanged: (_) {
                  if (_visitVisaNicknameErrorKey != null) {
                    setState(() => _visitVisaNicknameErrorKey = null);
                  }
                  _notifyChanged();
                },
              ),
            ],
            const SizedBox(height: 12),
            GlassSettingsTile(
              title: VisaStrings.format(
                'visa_expiry_label',
                locale,
                params: {
                  'date':
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                },
              ),
              trailing: Icon(
                Icons.calendar_today,
                color: AppColors.brandFamilyMain,
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                  _notifyChanged();
                }
              },
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                VisaStrings.t('visa_reminder_alerts', locale),
                style:
                    AppTypography.caption.copyWith(color: AppColors.textSecondary),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                VisaStrings.t('visa_remind_30_days', locale),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              value: _remind30,
              activeTrackColor: AppColors.brandFamilyMain,
              onChanged: (v) {
                setState(() => _remind30 = v);
                _notifyChanged();
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                VisaStrings.t('visa_remind_7_days', locale),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              value: _remind7,
              activeTrackColor: AppColors.brandFamilyMain,
              onChanged: (v) {
                setState(() => _remind7 = v);
                _notifyChanged();
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                VisaStrings.t('visa_remind_1_day', locale),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              value: _remind1,
              activeTrackColor: AppColors.brandFamilyMain,
              onChanged: (v) {
                setState(() => _remind1 = v);
                _notifyChanged();
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(VisaStrings.t('visa_cancel', locale)),
        ),
        FilledButton(
          onPressed: _save,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.brandFamilyMain,
            foregroundColor: AppColors.textPrimary,
          ),
          child: Text(VisaStrings.t('visa_save', locale)),
        ),
      ],
    );
  }
}
