import 'dart:io';

import 'package:flutter/material.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';

class LostFoundListingPhoto extends StatelessWidget {
  const LostFoundListingPhoto({
    super.key,
    required this.photoUrl,
    this.height = 180,
    this.compact = false,
  });

  final String photoUrl;
  final double height;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Image.network(
        photoUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => GlassContainer(
          height: compact ? 120 : height,
          padding: EdgeInsets.zero,
          child: Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: compact ? 28 : 36,
            ),
          ),
        ),
      ),
    );
  }
}

class LostFoundComposerPhotoPicker extends StatelessWidget {
  const LostFoundComposerPhotoPicker({
    super.key,
    required this.locale,
    required this.pendingFile,
    required this.enabled,
    required this.uploading,
    required this.attachEnabled,
    required this.onPick,
    required this.onRemove,
    this.disabledHint,
  });

  final String locale;
  final File? pendingFile;
  final bool enabled;
  final bool uploading;
  final bool attachEnabled;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  final String? disabledHint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          CommunityStrings.t('community_lf_photo_optional', locale),
          style: AppTypography.caption,
        ),
        if (disabledHint != null && !attachEnabled) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            disabledHint!,
            style: AppTypography.caption.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        if (pendingFile != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: Image.file(
              pendingFile!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: enabled && !uploading ? onRemove : null,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: Text(
                CommunityStrings.t('community_lf_photo_remove', locale),
              ),
            ),
          ),
        ] else
          OutlinedButton.icon(
            onPressed: enabled && !uploading && attachEnabled ? onPick : null,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: Text(
              CommunityStrings.t('community_lf_photo_add', locale),
            ),
          ),
        if (uploading) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            CommunityStrings.t('community_lf_photo_uploading', locale),
            style: AppTypography.caption,
          ),
        ],
      ],
    );
  }
}
