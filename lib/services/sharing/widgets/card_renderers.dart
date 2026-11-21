import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/constants/strings/common_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_fonts.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';
import '../models/shareable_card_data.dart';

// ─── RAABTA brand footer used on all cards ───────────────

class _RaabtaFooter extends StatelessWidget {
  const _RaabtaFooter({this.qrUrl});

  final String? qrUrl;

  @override
  Widget build(BuildContext context) {
    final link = qrUrl ?? CommonStrings.publicWebsiteUrl;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: AppSpacing.avatarSm,
            height: AppSpacing.avatarSm,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.sharePurple, AppColors.sharePurpleLight],
                begin:  Alignment.topLeft,
                end:    Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'R',
                style: AppTypography.title,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CommonStrings.appName,
                  style: AppTypography.chipLabel.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  CommonStrings.appTagline,
                  style: AppTypography.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data:            link,
                version:         QrVersions.auto,
                size:            44,
                backgroundColor: Colors.transparent,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color:    Colors.white,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color:           Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                CommonStrings.publicWebsiteHost,
                style: TextStyle(
                  color:    Colors.white.withValues(alpha: 0.3),
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Decorative glow circle ───────────────────────────────

class _GlowCircle extends StatelessWidget {
  final Color  color;
  final double size;
  final double opacity;
  const _GlowCircle({
    required this.color,
    required this.size,
    this.opacity = 0.15,
  });

  @override
  Widget build(BuildContext context) => Container(
    width:  size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [
          color.withValues(alpha: opacity),
          Colors.transparent,
        ],
      ),
    ),
  );
}

// ─── Section divider ─────────────────────────────────────

class _CardDivider extends StatelessWidget {
  const _CardDivider();
  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    color:  Colors.white.withValues(alpha: 0.08),
  );
}

// ═════════════════════════════════════════════════════════
// CARD 1 — HEALTH SCORE CARD (Rich version)
// ═════════════════════════════════════════════════════════

class HealthScoreCardRenderer extends StatelessWidget {
  final HealthScoreCardData data;
  const HealthScoreCardRenderer({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isRtl = data.language == 'Arabic' ||
        data.language == 'Urdu';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:        AppColors.shareCardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: data.verdictColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color:      data.verdictColor.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [

            // Background glow effects
            Positioned(
              top: -40, right: -40,
              child: _GlowCircle(
                color: data.verdictColor,
                size:  200,
                opacity: 0.12,
              ),
            ),
            Positioned(
              bottom: 60, left: -30,
              child: _GlowCircle(
                color: AppColors.sharePurple,
                size:  150,
                opacity: 0.08,
              ),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // ── TOP HEADER SECTION ──────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    20, 20, 20, 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        data.verdictColor.withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end:   Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [

                      // Product name + score row
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          // Product image or emoji placeholder
                          Container(
                            width:  64, height: 64,
                            decoration: BoxDecoration(
                              color: data.verdictColor
                                  .withValues(alpha: 0.12),
                              borderRadius:
                                  BorderRadius.circular(14),
                              border: Border.all(
                                color: data.verdictColor
                                    .withValues(alpha: 0.25),
                              ),
                            ),
                            child: data.productImageUrl != null
                                ? ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(
                                      13,
                                    ),
                                    child: Image.network(
                                      data.productImageUrl!,
                                      fit:          BoxFit.contain,
                                      errorBuilder:
                                          (_, _, _) =>
                                            _ProductEmoji(
                                              color: data
                                                  .verdictColor,
                                            ),
                                    ),
                                  )
                                : _ProductEmoji(
                                    color: data.verdictColor,
                                  ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data.productName,
                                  style: const TextStyle(
                                    color:      Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize:   17,
                                    height:     1.2,
                                  ),
                                  maxLines:  2,
                                  overflow:  TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data.brand,
                                  style: TextStyle(
                                    color:    Colors.white
                                        .withValues(alpha: 0.45),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Verdict pill
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical:   5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: data.verdictColor
                                        .withValues(alpha: 0.15),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                    border: Border.all(
                                      color: data.verdictColor
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: Text(
                                    data.verdict.toUpperCase(),
                                    style: TextStyle(
                                      color:         data.verdictColor,
                                      fontWeight:    FontWeight.w900,
                                      fontSize:      11,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Score ring — large and prominent
                          _LargeScoreRing(
                            score: data.healthScore,
                            color: data.verdictColor,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Motivational message
                      Container(
                        width:   double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: data.verdictColor
                              .withValues(alpha: 0.08),
                          borderRadius:
                              BorderRadius.circular(12),
                          border: Border.all(
                            color: data.verdictColor
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          '✨  ${data.motivationalMessage}',
                          textAlign: isRtl
                              ? TextAlign.right
                              : TextAlign.center,
                          style: TextStyle(
                            color:      data.verdictColor,
                            fontWeight: FontWeight.w700,
                            fontSize:   13,
                            fontStyle:  FontStyle.italic,
                            height:     1.4,
                          ),
                        ),
                      ),

                      // Halal community data + allergy row
                      ...[
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _HalalCommunityPill(
                              snapshot: data.halalSnapshot,
                            ),
                            const SizedBox(width: 8),
                            if (data.allergyWarnings
                                .isNotEmpty)
                              Expanded(
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical:   6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFE63946,
                                    ).withValues(alpha: 0.12),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFE63946,
                                      ).withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Text(
                                    '⚠️  ${data.allergyWarnings.take(2).join(", ")}',
                                    style: const TextStyle(
                                      color:      Color(
                                        0xFFE63946,
                                      ),
                                      fontSize:   10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow:
                                        TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const _CardDivider(),

                // ── NUTRIENTS SECTION ───────────────────
                if (data.topNutrients.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16, 14, 16, 0,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '📊',
                              style:
                                  TextStyle(fontSize: 13),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'NUTRITION PER 100G',
                              style: TextStyle(
                                color:         Colors.white
                                    .withValues(alpha: 0.45),
                                fontSize:      10,
                                fontWeight:    FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...data.topNutrients.take(5).map(
                          (n) => _RichNutrientBar(
                            nutrient: n,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),
                const _CardDivider(),

                // ── ADDITIVES SECTION ───────────────────
                if (data.topAdditives.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16, 12, 16, 4,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '🧪',
                              style:
                                  TextStyle(fontSize: 13),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'ADDITIVES DECODED',
                              style: TextStyle(
                                color:         Colors.white
                                    .withValues(alpha: 0.45),
                                fontSize:      10,
                                fontWeight:    FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...data.topAdditives.take(4).map(
                          (a) => _RichAdditiveRow(a: a),
                        ),
                      ],
                    ),
                  ),

                const _CardDivider(),
                const _RaabtaFooter(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════
// CARD 2 — BILL SPLIT CARD (Rich version)
// ═════════════════════════════════════════════════════════

class BillSplitCardRenderer extends StatelessWidget {
  final BillSplitCardData data;
  const BillSplitCardRenderer({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final perPerson = data.people.isEmpty
        ? 0.0
        : data.totalQar / data.people.length;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:        const Color(0xFF080C1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color:      AppColors.accentGold.withValues(alpha: 0.15),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [

            // Background glow
            Positioned(
              top: -60, left: -60,
              child: _GlowCircle(
                color:   AppColors.accentGold,
                size:    220,
                opacity: 0.10,
              ),
            ),
            Positioned(
              bottom: -40, right: -40,
              child: _GlowCircle(
                color:   AppColors.sharePurple,
                size:    160,
                opacity: 0.08,
              ),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // ── HEADER ──────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    20, 22, 20, 18,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1A1208),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end:   Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // Bill emoji
                          Container(
                            width:  52, height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.accentGold
                                  .withValues(alpha: 0.12),
                              borderRadius:
                                  BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.accentGold
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                '💳',
                                style: TextStyle(
                                  fontSize: 26,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data.groupName ??
                                      'Bill Split',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color:      Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize:   20,
                                    height:     1.1,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Text(
                                      '${data.people.length} people',
                                      style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.45),
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (data.isRecurring) ...[
                                      Text(
                                        '  •  ',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.2),
                                          fontSize: 12,
                                        ),
                                      ),
                                      Container(
                                        padding:
                                            const EdgeInsets
                                                .symmetric(
                                          horizontal: 7,
                                          vertical:   2,
                                        ),
                                        decoration:
                                            BoxDecoration(
                                          color: const Color(
                                            0xFF6C3FC5,
                                          ).withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius
                                                  .circular(6),
                                        ),
                                        child: const Text(
                                          '🔄 Recurring',
                                          style: TextStyle(
                                            color:    Color(
                                              0xFF6C3FC5,
                                            ),
                                            fontSize: 10,
                                            fontWeight:
                                                FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Total + Per person highlight boxes
                      Row(
                        children: [
                          // Total box
                          Expanded(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withValues(alpha: 0.05),
                                borderRadius:
                                    BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white
                                      .withValues(alpha: 0.08),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Total Bill',
                                    style: TextStyle(
                                      color: Colors.white
                                          .withValues(alpha: 0.4),
                                      fontSize: 10,
                                      fontWeight:
                                          FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'QAR ${data.totalQar.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color:      Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize:   22,
                                    ),
                                  ),
                                  if (data.taxPercent > 0)
                                    Text(
                                      'incl. ${data.taxPercent.toStringAsFixed(0)}% tax',
                                      style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.3),
                                        fontSize: 9,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          // Per person box — highlighted
                          Expanded(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                gradient:
                                    const LinearGradient(
                                  colors: [
                                    Color(0xFF2A1E00),
                                    Color(0xFF1A1208),
                                  ],
                                  begin: Alignment.topLeft,
                                  end:
                                      Alignment.bottomRight,
                                ),
                                borderRadius:
                                    BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(
                                    0xFFFFB627,
                                  ).withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Each Pays',
                                    style: TextStyle(
                                      color: const Color(
                                        0xFFFFB627,
                                      ).withValues(alpha: 0.7),
                                      fontSize: 10,
                                      fontWeight:
                                          FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'QAR ${perPerson.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color:      AppColors.accentGold,
                                      fontWeight: FontWeight.w900,
                                      fontSize:   22,
                                    ),
                                  ),
                                  Text(
                                    '≈ ${perPerson.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: const Color(
                                        0xFFFFB627,
                                      ).withValues(alpha: 0.4),
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const _CardDivider(),

                // ── PEOPLE ROWS ──────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16, 14, 16, 4,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SPLIT BREAKDOWN',
                        style: TextStyle(
                          color:         Colors.white
                              .withValues(alpha: 0.35),
                          fontSize:      9,
                          fontWeight:    FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...data.people.map(
                        (p) => _BillPersonRow(person: p),
                      ),
                    ],
                  ),
                ),

                const _CardDivider(),
                const _RaabtaFooter(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════
// CARD 3 — WARRANTY ALERT CARD (Rich version)
// ═════════════════════════════════════════════════════════

class WarrantyAlertCardRenderer extends StatelessWidget {
  final WarrantyAlertCardData data;
  const WarrantyAlertCardRenderer({
    super.key,
    required this.data,
  });

  Color get _color {
    if (data.isExpired || data.daysLeft <= 7) {
      return AppColors.errorBright;
    }
    if (data.daysLeft <= 30) return AppColors.accentGold;
    return AppColors.successBright;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:        const Color(0xFF0A0510),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _color.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color:      _color.withValues(alpha: 0.15),
            blurRadius: 20,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              top: -50, right: -50,
              child: _GlowCircle(
                color: _color, size: 200, opacity: 0.12,
              ),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // ── Status bar ───────────────────────────
                Container(
                  width:   double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 11,
                  ),
                  color: _color.withValues(alpha: 0.15),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        data.isExpired
                            ? Icons.error_rounded
                            : Icons.shield_rounded,
                        color: _color,
                        size:  14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        data.isExpired
                            ? '⛔  WARRANTY EXPIRED'
                            : data.daysLeft <= 7
                                ? '🚨  EXPIRES IN ${data.daysLeft} DAYS — ACT NOW'
                                : data.daysLeft <= 30
                                    ? '⚠️  WARRANTY EXPIRING SOON'
                                    : '🛡️  WARRANTY ACTIVE',
                        style: TextStyle(
                          color:         _color,
                          fontWeight:    FontWeight.w900,
                          fontSize:      12,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Product info ─────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20, 18, 20, 4,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width:  64, height: 64,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _color.withValues(alpha: 0.15),
                              _color.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end:   Alignment.bottomRight,
                          ),
                          borderRadius:
                              BorderRadius.circular(16),
                          border: Border.all(
                            color: _color.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '🛡️',
                            style: const TextStyle(
                              fontSize: 30,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.productName,
                              style: const TextStyle(
                                color:      Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize:   18,
                                height:     1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.brand,
                              style: TextStyle(
                                color:    Colors.white
                                    .withValues(alpha: 0.5),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withValues(alpha: 0.06),
                                borderRadius:
                                    BorderRadius.circular(6),
                              ),
                              child: Text(
                                data.category,
                                style: TextStyle(
                                  color:    Colors.white
                                      .withValues(alpha: 0.4),
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Big countdown ────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16, 16, 16, 0,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _color.withValues(alpha: 0.10),
                          _color.withValues(alpha: 0.04),
                        ],
                        begin: Alignment.topCenter,
                        end:   Alignment.bottomCenter,
                      ),
                      borderRadius:
                          BorderRadius.circular(16),
                      border: Border.all(
                        color: _color.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          data.isExpired
                              ? '${data.daysLeft.abs()}'
                              : '${data.daysLeft}',
                          style: TextStyle(
                            color:      _color,
                            fontWeight: FontWeight.w900,
                            fontSize:   56,
                            height:     1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.isExpired
                              ? 'DAYS SINCE EXPIRY'
                              : data.daysLeft == 1
                                  ? 'DAY REMAINING'
                                  : 'DAYS REMAINING',
                          style: TextStyle(
                            color:         _color
                                .withValues(alpha: 0.7),
                            fontSize:      11,
                            fontWeight:    FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Expiry: '
                          '${data.expiryDate.day}/'
                          '${data.expiryDate.month}/'
                          '${data.expiryDate.year}  •  '
                          'Paid: QAR ${data.purchasePriceQar.toStringAsFixed(0)}',
                          style: TextStyle(
                            color:    Colors.white
                                .withValues(alpha: 0.4),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Qatar law note
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16, 12, 16, 14,
                  ),
                  child: Container(
                    width:   double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                    child: Text(
                      '⚖️  Qatar Consumer Protection Law mandates '
                      '1–2 year minimum warranty on electronics '
                      '& major appliances',
                      style: TextStyle(
                        color:    Colors.white.withValues(alpha: 0.45),
                        fontSize: 10,
                        height:   1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const _CardDivider(),
                const _RaabtaFooter(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════
// CARD 4 — WAIT TIME CARD (Rich version)
// ═════════════════════════════════════════════════════════

class WaitTimeCardRenderer extends StatelessWidget {
  final WaitTimeCardData data;
  const WaitTimeCardRenderer({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:        const Color(0xFF040D1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: data.statusColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color:      data.statusColor.withValues(alpha: 0.15),
            blurRadius: 20,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              top: -40, right: -40,
              child: _GlowCircle(
                color:   data.statusColor,
                size:    180,
                opacity: 0.12,
              ),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // ── Location header ──────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    20, 20, 20, 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        data.statusColor.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end:   Alignment.bottomCenter,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width:  52, height: 52,
                        decoration: BoxDecoration(
                          color: data.statusColor
                              .withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(14),
                          border: Border.all(
                            color: data.statusColor
                                .withValues(alpha: 0.25),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            data.locationEmoji,
                            style: const TextStyle(
                              fontSize: 26,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.locationName,
                              style: const TextStyle(
                                color:      Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize:   17,
                                height:     1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.locationArea,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color:    Colors.white
                                    .withValues(alpha: 0.4),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical:   4,
                              ),
                              decoration: BoxDecoration(
                                color: data.statusColor
                                    .withValues(alpha: 0.15),
                                borderRadius:
                                    BorderRadius.circular(16),
                                border: Border.all(
                                  color: data.statusColor
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                              child: Text(
                                data.currentStatus
                                    .toUpperCase(),
                                style: TextStyle(
                                  color:         data.statusColor,
                                  fontWeight:    FontWeight.w900,
                                  fontSize:      10,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const _CardDivider(),

                // ── Big wait time display ────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        data.statusColor.withValues(alpha: 0.06),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end:   Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'CURRENT WAIT TIME',
                        style: TextStyle(
                          color:         Colors.white
                              .withValues(alpha: 0.35),
                          fontSize:      9,
                          fontWeight:    FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        crossAxisAlignment:
                            CrossAxisAlignment.baseline,
                        textBaseline:
                            TextBaseline.alphabetic,
                        children: [
                          Text(
                            '~${data.estimatedMinutes}',
                            style: TextStyle(
                              color:      data.statusColor,
                              fontWeight: FontWeight.w900,
                              fontSize:   72,
                              height:     1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'min',
                                style: TextStyle(
                                  color:      data.statusColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize:   20,
                                ),
                              ),
                              Text(
                                'wait',
                                style: TextStyle(
                                  color: data.statusColor
                                      .withValues(alpha: 0.5),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (data.communityReportCount > 0)
                        Text(
                          'Based on ${data.communityReportCount} community reports',
                          style: TextStyle(
                            color:    Colors.white
                                .withValues(alpha: 0.25),
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),

                const _CardDivider(),

                // ── Best time strip ──────────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.successBright
                              .withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.schedule_rounded,
                          color: AppColors.successBright,
                          size:  18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BEST TIME TO VISIT',
                              style: TextStyle(
                                color:         Colors.white
                                    .withValues(alpha: 0.35),
                                fontSize:      9,
                                fontWeight:    FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              data.bestTimeToVisit,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color:      AppColors.successBright,
                                fontWeight: FontWeight.w800,
                                fontSize:   14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '📍 Qatar',
                        style: TextStyle(
                          color:    Colors.white
                              .withValues(alpha: 0.25),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                const _CardDivider(),
                const _RaabtaFooter(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════
// CARD 5 — DOCUMENT ALERT CARD (Rich version)
// ═════════════════════════════════════════════════════════

class DocumentAlertCardRenderer extends StatelessWidget {
  final DocumentAlertCardData data;
  const DocumentAlertCardRenderer({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:        const Color(0xFF0A0505),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: data.urgencyColor.withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color:      data.urgencyColor.withValues(alpha: 0.2),
            blurRadius: 24,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              top: -30, right: -30,
              child: _GlowCircle(
                color:   data.urgencyColor,
                size:    180,
                opacity: 0.14,
              ),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // ── Urgency header ───────────────────────
                Container(
                  width:   double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        data.urgencyColor.withValues(alpha: 0.25),
                        data.urgencyColor.withValues(alpha: 0.10),
                      ],
                      begin: Alignment.topCenter,
                      end:   Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        data.isExpired
                            ? '⛔  DOCUMENT EXPIRED'
                            : data.daysLeft <= 3
                                ? '🚨  CRITICAL — RENEW NOW'
                                : data.daysLeft <= 14
                                    ? '⚠️  URGENT RENEWAL NEEDED'
                                    : '⏰  EXPIRY REMINDER',
                        style: TextStyle(
                          color:         data.urgencyColor,
                          fontWeight:    FontWeight.w900,
                          fontSize:      13,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // ── Document type + holder ───────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20, 18, 20, 0,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width:  72, height: 72,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              data.urgencyColor
                                  .withValues(alpha: 0.15),
                              data.urgencyColor
                                  .withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end:   Alignment.bottomRight,
                          ),
                          borderRadius:
                              BorderRadius.circular(18),
                          border: Border.all(
                            color: data.urgencyColor
                                .withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            data.docTypeEmoji,
                            style: const TextStyle(
                              fontSize: 36,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical:   3,
                              ),
                              decoration: BoxDecoration(
                                color: data.urgencyColor
                                    .withValues(alpha: 0.12),
                                borderRadius:
                                    BorderRadius.circular(6),
                              ),
                              child: Text(
                                data.docType,
                                style: TextStyle(
                                  color:         data.urgencyColor,
                                  fontWeight:    FontWeight.w900,
                                  fontSize:      10,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data.holderName,
                              style: const TextStyle(
                                color:      Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize:   20,
                                height:     1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Expires: '
                              '${data.expiryDate.day}/'
                              '${data.expiryDate.month}/'
                              '${data.expiryDate.year}',
                              style: TextStyle(
                                color:    Colors.white
                                    .withValues(alpha: 0.45),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Countdown display ────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16, 16, 16, 0,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          data.urgencyColor.withValues(alpha: 0.10),
                          data.urgencyColor.withValues(alpha: 0.04),
                        ],
                        begin: Alignment.topCenter,
                        end:   Alignment.bottomCenter,
                      ),
                      borderRadius:
                          BorderRadius.circular(16),
                      border: Border.all(
                        color: data.urgencyColor
                            .withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          data.isExpired
                              ? '${data.daysLeft.abs()}'
                              : '${data.daysLeft}',
                          style: TextStyle(
                            color:      data.urgencyColor,
                            fontWeight: FontWeight.w900,
                            fontSize:   64,
                            height:     1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          data.isExpired
                              ? 'DAYS OVERDUE'
                              : data.daysLeft == 1
                                  ? 'DAY LEFT'
                                  : 'DAYS LEFT',
                          style: TextStyle(
                            color:         data.urgencyColor
                                .withValues(alpha: 0.8),
                            fontWeight:    FontWeight.w900,
                            fontSize:      12,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Action message ───────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16, 12, 16, 14,
                  ),
                  child: Container(
                    width:   double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                    child: Text(
                      data.isExpired
                          ? '🏛️  Visit MOI or use Metrash app '
                            'immediately to avoid fines and '
                            'travel restrictions.'
                          : data.daysLeft <= 14
                              ? '🏛️  Start renewal via Metrash '
                                'or Qatar MOI portal today. '
                                'Processing takes 3-7 days.'
                              : '📱  Reminder set by RAABTA. '
                                'Begin renewal at least '
                                '30 days before expiry.',
                      style: TextStyle(
                        color:    Colors.white.withValues(alpha: 0.55),
                        fontSize: 11,
                        height:   1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const _CardDivider(),
                const _RaabtaFooter(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SHARED SUB-WIDGETS ───────────────────────────────────

class _LargeScoreRing extends StatelessWidget {
  final int   score;
  final Color color;
  const _LargeScoreRing({
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76, height: 76,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 76, height: 76,
            child: CircularProgressIndicator(
              value:           score / 100,
              strokeWidth:     7,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              color:           color,
              strokeCap:       StrokeCap.round,
            ),
          ),
          Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  color:      color,
                  fontWeight: FontWeight.w900,
                  fontSize:   24,
                  height:     1,
                ),
              ),
              Text(
                '/100',
                style: TextStyle(
                  color:    Colors.white.withValues(alpha: 0.3),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductEmoji extends StatelessWidget {
  final Color color;
  const _ProductEmoji({required this.color});
  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      '🛒',
      style: TextStyle(fontSize: 28),
    ),
  );
}

class _HalalCommunityPill extends StatelessWidget {
  final HalalShareSnapshot snapshot;
  const _HalalCommunityPill({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.accentGold;
    final label = snapshot.hasCommunityData
        ? '🏷️ ${snapshot.communityLabels.first} (community-reported)'
        : 'ℹ️ No halal info — check packaging';
    return Flexible(
      child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10, vertical: 5,
      ),
      decoration: BoxDecoration(
        color:         color.withValues(alpha: 0.12),
        borderRadius:  BorderRadius.circular(16),
        border:        Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color:      color,
          fontSize:   10,
          fontWeight: FontWeight.w700,
        ),
      ),
      ),
    );
  }
}

class _RichNutrientBar extends StatelessWidget {
  final NutrientRow nutrient;
  const _RichNutrientBar({required this.nutrient});

  Color get _color {
    if (nutrient.dailyPct < 10) return AppColors.successBright;
    if (nutrient.dailyPct < 25) return const Color(0xFF7BC67E);
    if (nutrient.dailyPct < 50) return AppColors.accentGold;
    return AppColors.errorBright;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              nutrient.name,
              style: TextStyle(
                color:    Colors.white.withValues(alpha: 0.65),
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value:           (nutrient.dailyPct / 100)
                        .clamp(0.0, 1.0),
                    minHeight:       6,
                    backgroundColor: Colors.white
                        .withValues(alpha: 0.07),
                    valueColor:
                        AlwaysStoppedAnimation(_color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 36,
            child: Text(
              nutrient.amount,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color:      Colors.white,
                fontWeight: FontWeight.w700,
                fontSize:   11,
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 32,
            child: Text(
              '${nutrient.dailyPct.round()}%',
              textAlign: TextAlign.right,
              style: TextStyle(
                color:      _color,
                fontSize:   10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RichAdditiveRow extends StatelessWidget {
  final AdditiveRow a;
  const _RichAdditiveRow({required this.a});

  Color get _color {
    switch (a.status) {
      case 'safe':  return AppColors.successBright;
      case 'avoid': return AppColors.errorBright;
      default:      return AppColors.accentGold;
    }
  }

  String get _icon {
    switch (a.status) {
      case 'safe':  return '🟢';
      case 'avoid': return '🔴';
      default:      return '🟡';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(
        horizontal: 10, vertical: 7,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 7, vertical: 3,
            ),
            decoration: BoxDecoration(
              color:         _color.withValues(alpha: 0.15),
              borderRadius:  BorderRadius.circular(5),
            ),
            child: Text(
              a.code,
              style: TextStyle(
                color:         _color,
                fontSize:      10,
                fontWeight:    FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              a.plainName,
              style: TextStyle(
                color:    Colors.white.withValues(alpha: 0.65),
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _icon,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _BillPersonRow extends StatelessWidget {
  final SplitPersonRow person;
  const _BillPersonRow({required this.person});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 14, vertical: 11,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: Row(
        children: [
          Text(
            person.flag,
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  style: const TextStyle(
                    color:      Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize:   14,
                  ),
                ),
                Text(
                  person.currency,
                  style: TextStyle(
                    color:    Colors.white.withValues(alpha: 0.3),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                person.formattedHomeAmount,
                style: const TextStyle(
                  color:      AppColors.accentGold,
                  fontWeight: FontWeight.w900,
                  fontSize:   18,
                ),
              ),
              Text(
                'QAR ${person.shareQar.toStringAsFixed(2)}',
                style: TextStyle(
                  color:    Colors.white.withValues(alpha: 0.3),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── 6. EOSB SETTLEMENT CARD ──────────────────────────────

class EosbSettlementCardRenderer extends StatelessWidget {
  const EosbSettlementCardRenderer({super.key, required this.data});

  final EosbSettlementCardData data;

  String _formatQar(double amount) {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return 'QAR $formatted';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor =
        data.isUnderpaid ? AppColors.errorBright : AppColors.emeraldGlow;
    final statusLabel = data.isUnderpaid
        ? 'Potential Underpayment'
        : 'Estimated Entitlement';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF040D1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.emeraldGlow.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.emeraldGlow.withValues(alpha: 0.15),
            blurRadius: 20,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.emeraldGlow.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  const Text('💼', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EOSB Truth Engine',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Qatar End of Service Benefits',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Text(
                    _formatQar(data.estimatedEosb),
                    style: const TextStyle(
                      color: AppColors.emeraldGlow,
                      fontWeight: FontWeight.w900,
                      fontSize: 36,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatBlock(
                        label: 'Confidence',
                        value: '${data.confidenceScore}%',
                        color: AppColors.cyanGlow,
                      ),
                      if (data.employerOffer != null)
                        _StatBlock(
                          label: 'Employer',
                          value: _formatQar(data.employerOffer!),
                          color: AppColors.accentGold,
                        ),
                      if (data.difference != null && data.difference! > 0)
                        _StatBlock(
                          label: 'Gap',
                          value: _formatQar(data.difference!),
                          color: AppColors.errorBright,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const _CardDivider(),
            _RaabtaFooter(qrUrl: data.referralLinkUrl),
          ],
        ),
      ),
    );
  }
}

// ─── 6a. EOSB TRUTH CERTIFICATE CARD (no QR) ─────────────

class EosbTruthCertificateCardRenderer extends StatelessWidget {
  const EosbTruthCertificateCardRenderer({super.key, required this.data});

  final EosbTruthCertificateCardData data;

  @override
  Widget build(BuildContext context) {
    final p = data.presentation;
    final textDir = p.isRtl ? TextDirection.rtl : TextDirection.ltr;
    final align = p.isRtl ? TextAlign.right : TextAlign.left;

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: AppFonts.textThemeFor(Theme.of(context).textTheme, p.locale),
      ),
      child: Directionality(
        textDirection: textDir,
        child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF040D1A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.emeraldGlow.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.emeraldGlow.withValues(alpha: 0.15),
              blurRadius: 20,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.emeraldGlow.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      p.brandLabel,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.certificateHeading,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      p.entitlementHeading,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.entitlementAmountDisplay,
                      style: const TextStyle(
                        color: AppColors.emeraldGlow,
                        fontWeight: FontWeight.w900,
                        fontSize: 34,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    _CertInfoRow(label: p.basicSalaryLabel, align: align),
                    const SizedBox(height: 6),
                    _CertInfoRow(label: p.serviceDurationLabel, align: align),
                    const SizedBox(height: 6),
                    _CertInfoRow(
                      label: p.inputCompletenessLabel,
                      align: align,
                    ),
                    const SizedBox(height: 6),
                    _CertInfoRow(
                      label: p.estimateConfidenceLabel,
                      align: align,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      p.legalSourceLabel,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11,
                      ),
                      textAlign: align,
                    ),
                    if (p.articleReferenceLabel.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        p.articleReferenceLabel,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 11,
                        ),
                        textAlign: align,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${p.rulesetLabel}: ${p.rulesetVersionValue}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 10,
                      ),
                      textAlign: align,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      p.fingerprintShort,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.certificateIdDisplay,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 10,
                        fontFamily: 'monospace',
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.accentGold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            p.trustStateHeading,
                            style: TextStyle(
                              color: AppColors.accentGold.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p.trustStateLabel,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      p.disclaimer,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 8,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const _CardDivider(),
              if (p.showVerificationQr)
                _RaabtaFooter(qrUrl: p.verificationUrl)
              else
                _TruthCertificateFooter(brandLabel: p.brandLabel),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class _CertInfoRow extends StatelessWidget {
  const _CertInfoRow({required this.label, required this.align});

  final String label;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.7),
        fontSize: 11,
      ),
      textAlign: align,
    );
  }
}

class _TruthCertificateFooter extends StatelessWidget {
  const _TruthCertificateFooter({required this.brandLabel});

  final String brandLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: AppSpacing.avatarSm,
            height: AppSpacing.avatarSm,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.sharePurple, AppColors.sharePurpleLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                brandLabel.isNotEmpty ? brandLabel[0] : 'R',
                style: AppTypography.title,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brandLabel,
                  style: AppTypography.chipLabel.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  CommonStrings.appTagline,
                  style: AppTypography.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class TripItineraryCardRenderer extends StatelessWidget {
  const TripItineraryCardRenderer({super.key, required this.data});

  final TripItineraryCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF040D1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.blueGlow.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.blueGlow.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  const Text('✈️', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.tripTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                        ),
                        Text(
                          TripStrings.t('trip_title', 'English'),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatBlock(
                    label: 'Days',
                    value: '${data.totalDays}',
                    color: AppColors.cyanGlow,
                  ),
                  _StatBlock(
                    label: 'Activities',
                    value: '${data.activityCount}',
                    color: AppColors.accentGold,
                  ),
                  _StatBlock(
                    label: 'Budget',
                    value: formatTripCurrency(
                      data.totalBudget,
                      symbol: data.currency,
                    ),
                    color: AppColors.emeraldGlow,
                  ),
                ],
              ),
            ),
            const _CardDivider(),
            const _RaabtaFooter(),
          ],
        ),
      ),
    );
  }
}

class PrayerTimesCardRenderer extends StatelessWidget {
  const PrayerTimesCardRenderer({super.key, required this.data});

  final PrayerTimesCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF041A14),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.tealGlow.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.tealGlow.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  const Text('🕌', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Islamic Companion',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          data.location,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Text(
                    'Next: ${data.nextPrayer}',
                    style: const TextStyle(
                      color: AppColors.emeraldGlow,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.hijriDate,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const _CardDivider(),
            const _RaabtaFooter(),
          ],
        ),
      ),
    );
  }
}

// ─── 6b. OVERTIME TRUTH CARD ──────────────────────────────

class OvertimeTruthCardRenderer extends StatelessWidget {
  const OvertimeTruthCardRenderer({super.key, required this.data});

  final OvertimeTruthCardData data;

  @override
  Widget build(BuildContext context) {
    final underpaid = data.difference > 1;
    final accent = underpaid ? AppColors.errorBright : AppColors.accentGold;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF040D1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.45), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'RAABTA · Overtime Truth Engine',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data.monthLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (data.companyName.isNotEmpty)
              Text(
                data.companyName,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            const SizedBox(height: 16),
            Text(
              '${data.totalHours.toStringAsFixed(1)} OT hours',
              style: TextStyle(
                color: accent,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Estimated: ${data.currency} ${data.estimatedAmount.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            Text(
              'Employer paid: ${data.currency} ${data.employerPaid.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            if (underpaid)
              Text(
                'Gap: ${data.currency} ${data.difference.toStringAsFixed(0)}',
                style: TextStyle(
                  color: accent,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            const SizedBox(height: 16),
            _RaabtaFooter(qrUrl: data.referralLinkUrl),
          ],
        ),
      ),
    );
  }
}

class FriendsFamilyLoanCardRenderer extends StatelessWidget {
  const FriendsFamilyLoanCardRenderer({super.key, required this.data});

  final FriendsFamilyLoanCardData data;

  @override
  Widget build(BuildContext context) {
    final net = data.netBalance;
    final theyOweYou = net >= 0;
    final accent =
        theyOweYou ? AppColors.cyanGlow : AppColors.accentGold;

    return Container(
      width: 360,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0E1A), Color(0xFF121829)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.glassBorderBright),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: AppColors.sharePurple.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusLg),
              ),
            ),
            child: const Text(
              '🤝  FRIENDS & FAMILY LOAN SUMMARY',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.cyanGlow,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1.1,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.personName,
                  style: AppTypography.headline2.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  'Net balance',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'QAR ${net.abs().toStringAsFixed(0)} ${theyOweYou ? 'owed to you' : 'you owe'}',
                  style: TextStyle(
                    color: accent,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                for (final row in data.activeEntries.take(4)) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                row.directionLabel,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                'QAR ${row.amount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Due ${row.dueDate.day}/${row.dueDate.month}',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              row.statusLabel.toUpperCase(),
                              style: TextStyle(
                                color: row.statusLabel == 'overdue'
                                    ? AppColors.errorBright
                                    : AppColors.cyanGlow,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const _RaabtaFooter(),
        ],
      ),
    );
  }
}

class HealthInsuranceComplianceCardRenderer extends StatelessWidget {
  const HealthInsuranceComplianceCardRenderer({super.key, required this.data});

  final HealthInsuranceComplianceCardData data;

  @override
  Widget build(BuildContext context) {
    final accent = data.hasViolation
        ? AppColors.errorBright
        : AppColors.chipHealthInsurance;

    return Container(
      width: 360,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0E1A), Color(0xFF121829)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.glassBorderBright),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: AppColors.chipHealthInsurance.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusLg),
              ),
            ),
            child: const Text(
              '🏥  HEALTH INSURANCE COMPLIANCE CHECK',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.chipHealthInsurance,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1.1,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(data.checkedAt),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.overviewSummary,
                  style: TextStyle(
                    color: accent,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 14),
                for (final row in data.checks) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: row.statusColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.circle, size: 10, color: row.statusColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                row.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                row.statusLabel.toUpperCase(),
                                style: TextStyle(
                                  color: row.statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const _RaabtaFooter(),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';
}

class HealthInsurancePolicyCardRenderer extends StatelessWidget {
  const HealthInsurancePolicyCardRenderer({super.key, required this.data});

  final HealthInsurancePolicyCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0E1A), Color(0xFF121829)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.glassBorderBright),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: AppColors.chipHealthInsurance.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusLg),
              ),
            ),
            child: const Text(
              '📄  MY POLICY SUMMARY',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.chipHealthInsurance,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1.1,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.documentName,
                  style: AppTypography.headline2.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 10),
                if (data.summary.isNotEmpty)
                  Text(
                    data.summary,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ..._bulletSection('Coverage', data.coverageCategories),
                ..._bulletSection('Exclusions', data.exclusions),
                ..._bulletSection('Network', data.networkNotes),
                ..._bulletSection('Notes', data.ambiguityNotes),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    data.disclaimerText,
                    style: TextStyle(
                      color: AppColors.warning.withValues(alpha: 0.95),
                      fontSize: 10,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const _RaabtaFooter(),
        ],
      ),
    );
  }

  List<Widget> _bulletSection(String title, List<String> items) {
    if (items.isEmpty) return const [];
    return [
      const SizedBox(height: 10),
      Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
      for (final item in items.take(4))
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            '• $item',
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ),
    ];
  }
}

class HealthInsuranceDenialCardRenderer extends StatelessWidget {
  const HealthInsuranceDenialCardRenderer({super.key, required this.data});

  final HealthInsuranceDenialCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0E1A), Color(0xFF121829)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.glassBorderBright),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: AppColors.chipHealthInsurance.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusLg),
              ),
            ),
            child: const Text(
              '🏥  CLAIM DENIAL DISPUTE RECORD',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.chipHealthInsurance,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1.1,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.insurerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.denialReasonLabel,
                  style: TextStyle(
                    color: AppColors.chipHealthInsurance.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Steps completed: ${data.stepsCompleted}/${data.stepsTotal}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'Documents attached: ${data.documentsAttached}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Text(
                  data.disclaimerText,
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ],
            ),
          ),
          const _RaabtaFooter(),
        ],
      ),
    );
  }
}

class PersonalBudgetCardRenderer extends StatelessWidget {
  const PersonalBudgetCardRenderer({super.key, required this.data});

  final PersonalBudgetCardData data;

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.emeraldGlow;
    final savings = data.savingsRatePercent;
    final savingsColor = savings != null && savings < 0
        ? AppColors.errorBright
        : accent;

    return Container(
      width: 360,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF071510), Color(0xFF0E2218)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusLg),
              ),
            ),
            child: const Text(
              '💰  QATAR PERSONAL BUDGET SNAPSHOT',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1.1,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly cost',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'QAR ${data.monthlyCost.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: accent,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _BudgetStatChip(
                        label: 'Savings rate',
                        value: savings != null
                            ? '${savings.toStringAsFixed(1)}%'
                            : '—',
                        color: savingsColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _BudgetStatChip(
                        label: 'Pressure',
                        value: data.pressureLabel,
                        color: data.pressureColor,
                      ),
                    ),
                  ],
                ),
                if (data.segments.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    'Top categories',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final seg in data.segments.take(4))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: seg.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              seg.label,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Text(
                            'QAR ${seg.amount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Generated ${data.generatedAt.day}/${data.generatedAt.month}/${data.generatedAt.year}',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
          const _RaabtaFooter(),
        ],
      ),
    );
  }
}

class UtilityBillsCardRenderer extends StatelessWidget {
  const UtilityBillsCardRenderer({super.key, required this.data});

  final UtilityBillsCardData data;

  @override
  Widget build(BuildContext context) {
    final outstanding = data.totalOutstanding;
    final accent =
        outstanding > 0 ? AppColors.errorBright : AppColors.successBright;

    return Container(
      width: 360,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0620), Color(0xFF12102A)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: AppColors.sharePurple.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusLg),
              ),
            ),
            child: const Text(
              '💳  MY QATAR UTILITY BILLS',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.cyanGlow,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1.1,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Outstanding balance',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  outstanding > 0
                      ? 'QAR ${outstanding.toStringAsFixed(0)}'
                      : 'All paid ✓',
                  style: TextStyle(
                    color: accent,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _BudgetStatChip(
                        label: 'Overdue',
                        value: '${data.overdueCount}',
                        color: data.overdueCount > 0
                            ? AppColors.errorBright
                            : AppColors.successBright,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _BudgetStatChip(
                        label: 'Due soon',
                        value: '${data.dueSoonCount}',
                        color: data.dueSoonCount > 0
                            ? AppColors.accentGold
                            : AppColors.successBright,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _BudgetStatChip(
                        label: 'Paid',
                        value: '${data.paidCount}',
                        color: AppColors.successBright,
                      ),
                    ),
                  ],
                ),
                if (data.unpaidBills.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    'Unpaid bills',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final row in data.unpaidBills.take(4))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Text(row.emoji, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  row.provider,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  row.dueLabel,
                                  style: TextStyle(
                                    color: row.isOverdue
                                        ? AppColors.errorBright
                                        : Colors.white54,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'QAR ${row.amount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
          const _RaabtaFooter(),
        ],
      ),
    );
  }
}

class _BudgetStatChip extends StatelessWidget {
  const _BudgetStatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}