import 'dart:io';

import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/models/intelligence/evidence_entry.dart';
import 'package:raabta/services/intelligence/evidence_pdf_service.dart';

/// Metadata line + optional thumbnail for an evidence attachment.
class EvidenceAttachmentPreview extends StatelessWidget {
  const EvidenceAttachmentPreview({
    super.key,
    required this.entry,
    this.summary,
  });

  final EvidenceEntry entry;
  final EvidenceAttachmentSummary? summary;

  @override
  Widget build(BuildContext context) {
    if (entry.attachmentDocumentId == null) return const SizedBox.shrink();

    final metadataLine = entry.attachmentMetadata.displayLine(
      fallbackRecordedAt: entry.createdAt,
    );
    final imagePath = summary?.localImagePath;
    final imageUrl = summary?.imageUrl;
    Widget? preview;
    if (imagePath != null && File(imagePath).existsSync()) {
      preview = ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Image.file(File(imagePath), height: 120, fit: BoxFit.cover),
      );
    } else if (imageUrl != null && imageUrl.startsWith('http')) {
      preview = ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Image.network(imageUrl, height: 120, fit: BoxFit.cover),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (preview != null) ...[
          preview,
          const SizedBox(height: AppSpacing.xs),
        ],
        Text(
          summary?.label ?? 'Document Vault: ${entry.attachmentDocumentId}',
          style: AppTypography.caption,
        ),
        if (metadataLine.isNotEmpty)
          Text(
            metadataLine,
            style: AppTypography.caption.copyWith(
              color: entry.attachmentCaptureSource == 'gallery'
                  ? AppColors.warning
                  : AppColors.info,
            ),
          ),
      ],
    );
  }
}

/// Explicit one-shot location ask before in-app camera capture.
Future<bool?> showEvidenceLocationCaptureDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Tag photo with location?'),
      content: const Text(
        'Evidence Trail can record your location once, at the moment you take '
        'this photo. It is not tracked in the background.\n\n'
        'You can still save the photo with a timestamp only if you skip location.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Photo only (no location)'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Allow location for this photo'),
        ),
      ],
    ),
  );
}
