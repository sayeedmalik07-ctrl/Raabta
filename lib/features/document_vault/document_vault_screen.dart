import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/constants/strings/common_strings.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/hub/hub_filter_chip.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/hub_search_decoration.dart';
import 'package:raabta/core/widgets/hub/hub_subscreen_scaffold.dart';
import 'package:raabta/features/document_vault/l10n/document_vault_strings.dart';
import 'package:raabta/features/profile/privacy/widgets/vault_lock_gate.dart';
import 'package:raabta/features/quick_actions/scanner/repositories/scanned_document_repository.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/visahelp/l10n/visa_strings.dart';
import 'package:raabta/services/sharing/models/shareable_card_data.dart';
import 'package:raabta/services/sharing/widgets/share_card_sheet.dart';

class DocumentVaultScreen extends ConsumerStatefulWidget {
  const DocumentVaultScreen({super.key});

  @override
  ConsumerState<DocumentVaultScreen> createState() =>
      _DocumentVaultScreenState();
}

class _DocumentVaultScreenState extends ConsumerState<DocumentVaultScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterType = 'All';

  final _docTypeFilters = [
    'All',
    'QID',
    'Passport',
    'Visa',
    'Labour Card',
    'Driving License',
    'Receipt',
    'Bill',
    'Evidence',
  ];

  final _docTypeEmojis = {
    'qid': '🪪',
    'passport': '📘',
    'visa': '✈️',
    'labourCard': '👷',
    'drivingLicense': '🚗',
    'receipt': '🧾',
    'bill': '📄',
    'evidence': '📎',
    'unknown': '📋',
  };

  Color _dialogBg() =>
      AppColors.isLight ? AppColors.surfaceElevated : AppColors.surface;

  Future<void> _renameDocument(String id, String currentName) async {
    final locale = ref.read(userLanguageProvider);
    final controller = TextEditingController(text: currentName);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _dialogBg(),
        title: Text(
          DocumentVaultStrings.t('vault_rename_title', locale),
          style: AppTypography.headline2.copyWith(fontSize: 18),
        ),
        content: TextField(
          controller: controller,
          style: AppTypography.body.copyWith(color: AppColors.textPrimary),
          decoration: hubSearchInputDecoration(
            hintText: DocumentVaultStrings.t('vault_rename_hint', locale),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(CommonActionStrings.t('action_cancel', locale)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(CommonActionStrings.t('action_save', locale)),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    await ref.read(scannedDocumentRepositoryProvider).rename(id, name);
  }

  Future<void> _deleteDocument(String id) async {
    final locale = ref.read(userLanguageProvider);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _dialogBg(),
        title: Text(
          DocumentVaultStrings.t('vault_delete_title', locale),
          style: AppTypography.headline2.copyWith(fontSize: 18),
        ),
        content: Text(
          DocumentVaultStrings.t('vault_delete_body', locale),
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(CommonActionStrings.t('action_cancel', locale)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              DocumentVaultStrings.t('vault_delete_action', locale),
              style: AppTypography.link.copyWith(color: AppColors.errorBright),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await ref.read(scannedDocumentRepositoryProvider).delete(id);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildEmptyState(BuildContext context, String locale) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: GlassEmptyState(
          accent: GlassEmptyStateAccent.brand,
          icon: Icons.folder_special_outlined,
          title: DocumentVaultStrings.t('vault_empty_title', locale),
          description: DocumentVaultStrings.t('vault_empty_body', locale),
          actionLabel: DocumentVaultStrings.t('vault_empty_cta', locale),
          onAction: () => context.push('/scanner/capture'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);

    return HubSubscreenScaffold(
      title: VisaStrings.t('visa_vault_entry_title', locale),
      subtitle: VisaStrings.t('visa_vault_entry_sub', locale),
      onBack: () => Navigator.of(context).pop(),
      headerTrailing: IconButton(
        icon: Icon(Icons.document_scanner_rounded, color: AppColors.brandFamilyMain),
        tooltip: DocumentVaultStrings.t('vault_scan_new_tooltip', locale),
        onPressed: () => context.push('/scanner/capture'),
      ),
      floatingActionButton: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('scanned_documents')
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            onPressed: () => context.push('/scanner/capture'),
            backgroundColor: AppColors.brandFamilyMain,
            foregroundColor: AppColors.textPrimary,
            icon: const Icon(Icons.add_rounded),
            label: Text(
              DocumentVaultStrings.t('vault_fab_scan', locale),
              style: AppTypography.button.copyWith(color: AppColors.textPrimary),
            ),
          );
        },
      ),
      body: VaultLockGate(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                0,
              ),
              child: TextField(
                controller: _searchController,
                style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: hubSearchInputDecoration(
                  hintText: DocumentVaultStrings.t('vault_search_hint', locale),
                ).copyWith(
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: AppColors.textTertiary,
                            size: AppSpacing.iconMd,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: HubLayoutTokens.filterChipHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                itemCount: _docTypeFilters.length,
                itemBuilder: (_, i) {
                  final f = _docTypeFilters[i];
                  final selected = _filterType == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: buildHubFilterChip(
                      label: Text(
                        f,
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: selected,
                      onSelected: (_) => setState(() => _filterType = f),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('scanned_documents')
                    .orderBy('scanDate', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: HubLoadingPlaceholder(
                          width: MediaQuery.sizeOf(context).width - AppSpacing.xl * 2,
                          height: 200,
                          silhouette: HubLoadingSilhouette.listing,
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState(context, locale);
                  }

                  var docs = snapshot.data!.docs;

                  if (_filterType != 'All') {
                    final filterKey =
                        _filterType.toLowerCase().replaceAll(' ', '');
                    docs = docs.where((doc) {
                      final d = doc.data() as Map<String, dynamic>;
                      final type = d['docType'] as String? ?? '';
                      final category = (d['category'] as String? ?? '').toLowerCase();
                      final tags = ((d['tags'] as List?) ?? const [])
                          .map((e) => e.toString().toLowerCase())
                          .toList();
                      if (filterKey == 'evidence') {
                        return category == 'evidence' ||
                            tags.contains('evidence') ||
                            type.toLowerCase() == 'evidence';
                      }
                      return type.toLowerCase().contains(filterKey);
                    }).toList();
                  }

                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    docs = docs.where((doc) {
                      final d = doc.data() as Map<String, dynamic>;
                      final name = (d['holderName'] as String? ?? '').toLowerCase();
                      final num = (d['documentNumber'] as String? ?? '').toLowerCase();
                      final type = (d['docType'] as String? ?? '').toLowerCase();
                      final ocr = (d['ocrText'] as String? ?? '').toLowerCase();
                      final category = (d['category'] as String? ?? '').toLowerCase();
                      final tags = ((d['tags'] as List?) ?? const [])
                          .map((e) => e.toString().toLowerCase())
                          .join(' ');
                      return name.contains(q) ||
                          num.contains(q) ||
                          type.contains(q) ||
                          ocr.contains(q) ||
                          category.contains(q) ||
                          tags.contains(q);
                    }).toList();
                  }

                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        DocumentVaultStrings.t('vault_no_match', locale),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textOnGlassMuted,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      0,
                      AppSpacing.xl,
                      AppSpacing.xl,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (_, i) {
                      final doc = docs[i];
                      final d = doc.data() as Map<String, dynamic>;
                      final docType = d['docType'] as String? ?? 'unknown';
                      final emoji = _docTypeEmojis[docType] ?? '📋';
                      final expiryTs = d['expiryDate'] as Timestamp?;
                      final expiry = expiryTs?.toDate();
                      final daysLeft = expiry?.difference(DateTime.now()).inDays;

                      var statusColor = AppColors.glassBorder;
                      var statusLabel = '';
                      if (daysLeft != null) {
                        if (daysLeft < 0) {
                          statusColor = AppColors.errorBright;
                          statusLabel =
                              DocumentVaultStrings.t('vault_status_expired', locale);
                        } else if (daysLeft <= 30) {
                          statusColor = AppColors.accentGold;
                          statusLabel = DocumentVaultStrings.format(
                            'vault_status_days_left',
                            locale,
                            params: {'days': '$daysLeft'},
                          );
                        } else {
                          statusColor = AppColors.successBright;
                          statusLabel = DocumentVaultStrings.format(
                            'vault_status_days_left',
                            locale,
                            params: {'days': '$daysLeft'},
                          );
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: GestureDetector(
                          onLongPress: () {
                            showModalBottomSheet<void>(
                              context: context,
                              backgroundColor: _dialogBg(),
                              builder: (ctx) => SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: Icon(
                                        Icons.drive_file_rename_outline,
                                        color: AppColors.textPrimary,
                                      ),
                                      title: Text(
                                        DocumentVaultStrings.t('vault_rename_action', locale),
                                        style: AppTypography.subtitle,
                                      ),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        _renameDocument(
                                          doc.id,
                                          d['displayName'] as String? ??
                                              d['holderName'] as String? ??
                                              DocumentVaultStrings.t(
                                                'vault_document_fallback',
                                                locale,
                                              ),
                                        );
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(
                                        Icons.delete_outline,
                                        color: AppColors.errorBright,
                                      ),
                                      title: Text(
                                        DocumentVaultStrings.t('vault_delete_action', locale),
                                        style: AppTypography.subtitle.copyWith(
                                          color: AppColors.errorBright,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        _deleteDocument(doc.id);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: GlassCard(
                            onTap: () => context.push(
                              '/document-vault/${doc.id}',
                              extra: d,
                            ),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            borderRadius: AppSpacing.radiusMd,
                            glowColor: statusColor,
                            glowIntensity: 0.1,
                            backgroundColor: AppColors.glassSurface,
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.brandFamilyMain
                                        .withValues(alpha: 0.12),
                                    borderRadius:
                                        BorderRadius.circular(AppSpacing.radiusSm),
                                  ),
                                  child: Center(
                                    child: Text(
                                      emoji,
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                  ),
                                ),
                                SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (d['displayName'] as String? ??
                                                d['holderName'] as String? ??
                                                docType)
                                            .replaceAll('_', ' ')
                                            .toUpperCase(),
                                        style: AppTypography.subtitle.copyWith(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (d['holderName'] != null &&
                                          (d['holderName'] as String).isNotEmpty)
                                        Text(
                                          d['holderName'] as String,
                                          style: AppTypography.caption.copyWith(
                                            color: AppColors.textOnGlassSecondary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (statusLabel.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: AppSpacing.xxs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.12),
                                      borderRadius:
                                          BorderRadius.circular(AppSpacing.xs),
                                    ),
                                    child: Text(
                                      statusLabel,
                                      style: AppTypography.caption.copyWith(
                                        color: statusColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                IconButton(
                                  icon: Icon(
                                    Icons.ios_share_rounded,
                                    color: AppColors.textTertiary,
                                    size: AppSpacing.iconMd,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    final expiryTs = d['expiryDate'] as Timestamp?;
                                    final expiry = expiryTs?.toDate();
                                    final docDaysLeft = expiry != null
                                        ? expiry.difference(DateTime.now()).inDays
                                        : 999;
                                    final isExpired = docDaysLeft < 0;

                                    final urgencyColor = isExpired
                                        ? AppColors.errorBright
                                        : docDaysLeft <= 30
                                            ? AppColors.accentGold
                                            : AppColors.successBright;

                                    final docTypeStr =
                                        d['docType'] as String? ?? 'unknown';
                                    final shareEmoji =
                                        _docTypeEmojis[docTypeStr] ?? '📋';

                                    final shareData = DocumentAlertCardData(
                                      docType: docTypeStr.replaceAll('_', ' ').toUpperCase(),
                                      docTypeEmoji: shareEmoji,
                                      holderName: d['holderName'] as String? ?? '',
                                      daysLeft: docDaysLeft.abs(),
                                      expiryDate: expiry ??
                                          DateTime.now().add(const Duration(days: 365)),
                                      isExpired: isExpired,
                                      urgencyColor: urgencyColor,
                                      shareCaption:
                                          '${isExpired ? "⛔" : "⏰"} '
                                          '${docTypeStr.toUpperCase()} '
                                          '${isExpired ? "EXPIRED" : "Expiry Reminder"}\n'
                                          'Holder: ${d["holderName"] ?? ""}\n'
                                          '${isExpired ? "Expired " : ""}${docDaysLeft.abs()} days '
                                          '${isExpired ? "ago" : "remaining"}\n\n'
                                          'Track documents with RAABTA\n${CommonStrings.publicWebsiteHost}',
                                    );
                                    ShareCardSheet.show(context, shareData);
                                  },
                                ),
                                SizedBox(width: AppSpacing.xxs),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.textTertiary,
                                  size: AppSpacing.iconMd,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
