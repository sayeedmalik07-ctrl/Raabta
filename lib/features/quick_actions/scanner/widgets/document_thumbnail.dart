import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/quick_actions/scanner/utils/document_path_resolver.dart';
import 'package:raabta/features/quick_actions/scanner/utils/document_paths.dart';

/// Compact document preview tile for lists and selection rows.
class DocumentThumbnail extends StatelessWidget {
  const DocumentThumbnail({
    super.key,
    required this.documentData,
    this.width = 44,
    this.height = 56,
    this.borderRadius = 8,
  });

  final Map<String, dynamic> documentData;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final localPaths = resolveDocumentImagePaths(documentData);
    final remoteUrls = DocumentPathResolver.remoteUrlsFor(documentData);

    Widget child;
    if (localPaths.isNotEmpty) {
      child = Image.file(
        File(localPaths.first),
        fit: BoxFit.cover,
        width: width,
        height: height,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    } else if (remoteUrls.isNotEmpty) {
      child = CachedNetworkImage(
        imageUrl: remoteUrls.first,
        fit: BoxFit.cover,
        width: width,
        height: height,
        placeholder: (_, _) => _placeholder(showProgress: true),
        errorWidget: (_, _, _) => _placeholder(),
      );
    } else {
      child = _placeholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.sharePurple.withValues(alpha: 0.25),
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _placeholder({bool showProgress = false}) {
    return Container(
      width: width,
      height: height,
      color: AppColors.sharePurple.withValues(alpha: 0.12),
      child: Center(
        child: showProgress
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                Icons.description_outlined,
                size: AppSpacing.iconSm,
                color: AppColors.textOnGlassMuted,
              ),
      ),
    );
  }
}
