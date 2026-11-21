import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/quick_actions/scanner/utils/document_paths.dart';

class DocumentPagePreview extends StatelessWidget {
  const DocumentPagePreview({super.key, required this.documentData});

  final Map<String, dynamic> documentData;

  @override
  Widget build(BuildContext context) {
    final localPaths = resolveDocumentImagePaths(documentData);
    final pageUrls =
        (documentData['pageUrls'] as List?)?.cast<String>() ?? const [];
    final hasLocal = localPaths.isNotEmpty;
    final hasRemote = pageUrls.any((u) => u.startsWith('http'));

    if (!hasLocal && !hasRemote) {
      return Container(
        height: 180,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.sharePurple.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.sharePurple.withValues(alpha: 0.2),
          ),
        ),
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.isLight
                ? AppColors.textOnGlassMuted
                : Colors.white38,
          ),
        ),
      );
    }

    final itemCount = hasLocal ? localPaths.length : pageUrls.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: hasLocal
                      ? Image.file(
                          File(localPaths[index]),
                          fit: BoxFit.contain,
                        )
                      : CachedNetworkImage(
                          imageUrl: pageUrls[index],
                          fit: BoxFit.contain,
                          placeholder: (_, _) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (_, _, _) => Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.isLight
                                ? AppColors.textOnGlassMuted
                                : Colors.white38,
                          ),
                        ),
                ),
              );
            },
          ),
        ),
        if (itemCount > 1)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs, left: AppSpacing.lg),
            child: Text(
              '$itemCount pages — swipe to preview',
              style: TextStyle(
                color: AppColors.isLight
                    ? AppColors.textOnGlassMuted
                    : Colors.white38,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }
}
