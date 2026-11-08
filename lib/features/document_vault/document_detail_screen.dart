import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/document_page_preview.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/screens/ai_chat/ai_chat_context_builder.dart';
import 'package:raabta/screens/ai_chat/l10n/ai_chat_strings.dart';

class DocumentDetailScreen extends ConsumerWidget {
  const DocumentDetailScreen({
    super.key,
    required this.documentId,
    required this.documentData,
  });

  final String documentId;
  final Map<String, dynamic> documentData;

  void _openInRaabtaAi(BuildContext context, {String? initialQuestion}) {
    final ctx = AiChatContextBuilder.fromDocumentVault(documentData);
    context.push(
      '/ai-chat',
      extra: {
        if (initialQuestion != null) 'query': initialQuestion,
        'contextSubtitle': ctx.label,
        'contextSource': ctx.source.routeValue,
        'contextBody': ctx.body,
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docType = documentData['docType'] as String? ?? 'Document';
    final questions =
        AiChatContextBuilder.suggestedVaultQuestions(docType);

    return Scaffold(
      backgroundColor: AppColors.isLight
          ? AppColors.background
          : const Color(0xFF0D0826),
      appBar: AppBar(
        backgroundColor: AppColors.isLight
            ? AppColors.background
            : const Color(0xFF0D0826),
        elevation: 0,
        title: Text(
          docType.replaceAll('_', ' ').toUpperCase(),
          style: TextStyle(
            color: AppColors.isLight
                ? AppColors.textPrimary
                : Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        iconTheme: IconThemeData(
          color: AppColors.isLight
              ? AppColors.textPrimary
              : Colors.white,
        ),
      ),
      body: Column(
        children: [
          DocumentPagePreview(documentData: documentData),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.sharePurple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.sharePurple.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              children: [
                _InfoRow(
                  'Holder',
                  documentData['holderName'] as String? ?? 'N/A',
                ),
                _InfoRow(
                  'Number',
                  documentData['documentNumber'] as String? ?? 'N/A',
                ),
                if (documentData['expiryDate'] != null)
                  _InfoRow(
                    'Expires',
                    _formatExpiry(documentData['expiryDate']),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Ask Raabta AI about this document:',
                style: TextStyle(
                  color: AppColors.isLight
                      ? AppColors.textOnGlassMuted
                      : Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ...questions.map(
                  (q) => GestureDetector(
                    onTap: () => _openInRaabtaAi(context, initialQuestion: q),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.isLight
                            ? AppColors.glassSurface
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.isLight
                              ? AppColors.glassBorder
                              : Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: AppColors.sharePurple,
                            size: 14,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              q,
                              style: TextStyle(
                                color: AppColors.isLight
                                    ? AppColors.textOnGlassSecondary
                                    : Colors.white.withValues(alpha: 0.7),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                FilledButton.icon(
                  onPressed: () => _openInRaabtaAi(context),
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: Text(
                    AiChatStrings.t('ai_open_in_chat', 'English'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatExpiry(dynamic value) {
    if (value == null) return 'N/A';
    if (value is String) return value;
    try {
      final dt = (value as dynamic).toDate() as DateTime;
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return value.toString();
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.isLight
                    ? AppColors.textOnGlassMuted
                    : Colors.white.withValues(alpha: 0.4),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.isLight
                    ? AppColors.textPrimary
                    : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
