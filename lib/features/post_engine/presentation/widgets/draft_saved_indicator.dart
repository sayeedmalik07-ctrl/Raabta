import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';

/// Shows "Saved just now" / "Draft saved 12 seconds ago" during editing.
class DraftSavedIndicator extends StatefulWidget {
  const DraftSavedIndicator({
    super.key,
    required this.lastSavedAt,
    required this.locale,
  });

  final DateTime? lastSavedAt;
  final String locale;

  @override
  State<DraftSavedIndicator> createState() => _DraftSavedIndicatorState();
}

class _DraftSavedIndicatorState extends State<DraftSavedIndicator> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final savedAt = widget.lastSavedAt;
    if (savedAt == null) return const SizedBox.shrink();

    final diff = DateTime.now().difference(savedAt);
    final label = diff.inSeconds < 10
        ? PostEngineStrings.t('draft_saved_just_now', widget.locale)
        : PostEngineStrings.format(
            'draft_saved_ago',
            widget.locale,
            params: {'seconds': '${diff.inSeconds}'},
          );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.cloud_done_outlined, size: 14, color: AppColors.success),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
        ),
      ],
    );
  }
}
