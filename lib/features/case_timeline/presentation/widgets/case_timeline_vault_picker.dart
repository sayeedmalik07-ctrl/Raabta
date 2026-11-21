import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/case_timeline/presentation/l10n/case_timeline_strings.dart';
import 'package:raabta/providers/auth_providers.dart';

/// Pick an existing vault document or scan a new one.
Future<String?> showCaseTimelineVaultPicker(
  BuildContext context,
  WidgetRef ref,
  String locale,
) async {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
    ),
    builder: (ctx) {
      return _VaultPickerSheet(locale: locale);
    },
  );
}

class _VaultPickerSheet extends ConsumerWidget {
  const _VaultPickerSheet({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUserProvider)?.uid ?? '';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              CaseTimelineStrings.t('ct_attach_document', locale),
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: const Icon(Icons.document_scanner_outlined),
              title: Text(CaseTimelineStrings.t('ct_scan_new', locale)),
              onTap: () async {
                await context.push('/scanner/capture');
                if (context.mounted) Navigator.pop(context);
              },
            ),
            if (uid.isNotEmpty) ...[
              Text(
                CaseTimelineStrings.t('ct_pick_vault', locale),
                style: AppTypography.caption,
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 240,
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('scanned_documents')
                      .where('userId', isEqualTo: uid)
                      .orderBy('scanDate', descending: true)
                      .limit(15)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return Center(
                        child: Text(
                          CaseTimelineStrings.t('ct_empty_body', locale),
                          style: AppTypography.caption,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data();
                        final title = (data['displayName'] as String?)?.isNotEmpty == true
                            ? data['displayName'] as String
                            : (data['category'] as String? ?? 'Document');
                        return ListTile(
                          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(
                            data['category']?.toString() ?? '',
                            style: AppTypography.caption,
                          ),
                          onTap: () => Navigator.pop(context, doc.id),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
