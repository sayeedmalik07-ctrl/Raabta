import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_text_styles.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';

/// Presentation-only BusinessCard (hub kit §4).
class HubBusinessCard extends StatelessWidget {
  const HubBusinessCard({
    super.key,
    required this.name,
    required this.categoryLine,
    required this.openNow,
    this.closingTime,
    this.services = const [],
    this.logoUrl,
    this.logoInitial,
    this.trailing,
    this.onTap,
  });

  final String name;
  final String categoryLine;
  final bool openNow;
  final String? closingTime;
  final List<String> services;
  final String? logoUrl;
  final String? logoInitial;
  final Widget? trailing;
  final VoidCallback? onTap;

  static const int maxServiceChips = 3;

  @override
  Widget build(BuildContext context) {
    final chips = services
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .take(maxServiceChips)
        .toList();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          borderRadius: AppRadius.lg,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LogoTile(url: logoUrl, initial: logoInitial),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.h3,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      categoryLine,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _OpenNowRow(openNow: openNow, closingTime: closingTime),
                    if (chips.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: chips
                            .map(
                              (label) => _ServiceChip(label: label),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoTile extends StatelessWidget {
  const _LogoTile({this.url, this.initial});

  final String? url;
  final String? initial;

  @override
  Widget build(BuildContext context) {
    final size = HubLayoutTokens.businessCardLogoSize;
    final trimmedUrl = url?.trim();
    if (trimmedUrl != null && trimmedUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Image.network(
          trimmedUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _InitialTile(size: size, initial: initial),
        ),
      );
    }
    return _InitialTile(size: size, initial: initial);
  }
}

class _InitialTile extends StatelessWidget {
  const _InitialTile({required this.size, this.initial});

  final double size;
  final String? initial;

  @override
  Widget build(BuildContext context) {
    final raw = (initial ?? '?').trim();
    final letter =
        raw.isEmpty ? '?' : raw.substring(0, 1).toUpperCase();
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.brandFamilyMain.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Center(
          child: Text(
            letter,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.brandFamilyText,
            ),
          ),
        ),
      ),
    );
  }
}

class _OpenNowRow extends StatelessWidget {
  const _OpenNowRow({required this.openNow, this.closingTime});

  final bool openNow;
  final String? closingTime;

  @override
  Widget build(BuildContext context) {
    final statusColor =
        openNow ? AppColors.success : AppColors.textSecondary;
    final closing = closingTime?.trim();
    final statusText = openNow
        ? (closing != null && closing.isNotEmpty
            ? 'Open now • closes $closing'
            : 'Open now')
        : 'Closed';

    return Row(
      children: [
        Text(
          '• ',
          style: AppTextStyles.bodyMedium.copyWith(
            color: statusColor,
            fontSize: 12,
          ),
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
          ),
        ),
        Flexible(
          child: Text(
            statusText,
            style: AppTextStyles.bodyMedium.copyWith(
              color: statusColor,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ServiceChip extends StatelessWidget {
  const _ServiceChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
